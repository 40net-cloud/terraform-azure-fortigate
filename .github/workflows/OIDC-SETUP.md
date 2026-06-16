# CI Azure auth setup (OIDC / workload identity federation)

How to wire up the CI's Azure authentication from scratch in another repo or
subscription. The workflows authenticate with **OIDC** — short-lived federated
tokens, **no client secret stored in GitHub**.

All commands assume `az login` as a user who can create app registrations and
assign roles. Set these once:

```bash
APP_NAME="fortiqa-ci"
REPO="40net-cloud/terraform-azure-fortigate"   # owner/repo you are wiring up
SUB_ID=$(az account show --query id -o tsv)
TENANT_ID=$(az account show --query tenantId -o tsv)
```

## 1. Create the app registration + service principal

```bash
APP_ID=$(az ad app create --display-name "$APP_NAME" --query appId -o tsv)
az ad sp create --id "$APP_ID"            # service principal for the app
echo "APP_ID=$APP_ID"
```

No `--password` / no `create-for-rbac`: OIDC needs **no secret**.

## 2. Assign roles (scope: subscription)

```bash
az role assignment create --assignee "$APP_ID" --role "Contributor" \
  --scope "/subscriptions/$SUB_ID"

# Only needed for the active-passive-sdn example (its SDN connector creates a
# custom role definition + role assignments):
az role assignment create --assignee "$APP_ID" --role "User Access Administrator" \
  --scope "/subscriptions/$SUB_ID"
```

Plan-only CI needs just `Reader`; deploy needs `Contributor`.

## 3. Add federated credentials (one per run identity)

Azure only trusts a GitHub OIDC token whose **subject** exactly matches a
federated credential on the app. Add one per ref/trigger you run from.

```bash
# main branch (push + workflow_dispatch on main)
az ad app federated-credential create --id "$APP_ID" --parameters "$(cat <<JSON
{
  "name": "github-main",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:${REPO}:ref:refs/heads/main",
  "audiences": ["api://AzureADTokenExchange"]
}
JSON
)"

# pull requests (only if you want PR runs to authenticate; plan-only by default)
az ad app federated-credential create --id "$APP_ID" --parameters "$(cat <<JSON
{
  "name": "github-pull-request",
  "issuer": "https://token.actions.githubusercontent.com",
  "subject": "repo:${REPO}:pull_request",
  "audiences": ["api://AzureADTokenExchange"]
}
JSON
)"
```

Subject patterns: branch `repo:OWNER/REPO:ref:refs/heads/<branch>`, PR
`repo:OWNER/REPO:pull_request`, environment `repo:OWNER/REPO:environment:<name>`.
Max 20 per app. List existing: `az ad app federated-credential list --id "$APP_ID" -o table`.

## 4. Set the GitHub repository secrets

No `ARM_CLIENT_SECRET`. Using the GitHub CLI:

```bash
gh secret set ARM_CLIENT_ID       --repo "$REPO" --body "$APP_ID"
gh secret set ARM_TENANT_ID       --repo "$REPO" --body "$TENANT_ID"
gh secret set ARM_SUBSCRIPTION_ID --repo "$REPO" --body "$SUB_ID"

# FortiGate admin password used by the post-deploy SSH test. Must satisfy Azure
# VM rules: 12+ chars, 3 of upper/lower/digit/special, not containing the username.
gh secret set PASSWORD --repo "$REPO" --body 'REPLACE-with-a-strong-password'
```

| Secret | Value |
|---|---|
| `ARM_CLIENT_ID` | app registration `appId` (step 1) |
| `ARM_TENANT_ID` | tenant ID |
| `ARM_SUBSCRIPTION_ID` | subscription ID |
| `PASSWORD` | FortiGate admin password (deploy/SSH test) |

The workflows set `ARM_USE_OIDC=true` and request `id-token: write`, so the
azurerm provider and `azure/login@v3` obtain tokens via federation at runtime.

## 5. Marketplace terms

Deploy mode runs `az vm image terms accept` automatically for the configured
offer/SKU, so no manual step. (Requires the role from step 2.)

## Migrating an existing secret-based setup

1. Do steps 1–3 are likely already done; just add the federated credential(s) (step 3).
2. Confirm the workflows use OIDC (`ARM_USE_OIDC`, `azure/login@v3`, `id-token: write`).
3. After a green OIDC run, delete the old secret:

   ```bash
   gh secret delete ARM_CLIENT_SECRET --repo "$REPO"
   az ad app credential reset ...   # not needed; instead remove any client secrets:
   az ad app credential list --id "$APP_ID" -o table   # review, then delete unused
   ```

## Verify

```bash
az ad app federated-credential list --id "$APP_ID" --query "[].subject" -o tsv
gh secret list --repo "$REPO"
```

Then dispatch a plan-only run (`deploy=false`) — if init/plan authenticate, OIDC
is working; no resources are created.
