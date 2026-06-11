# CI workflows

Each example in `examples/` has a thin caller workflow (`tf-example-<name>.yml`) that invokes the shared reusable workflow `terraform-example-test.yml`.

Two modes:

| Mode | When | What runs |
|---|---|---|
| **Plan only** (default) | every push to `main` / PR touching the example, its module, or the workflows | `init` → `fmt -check` → `validate` → `plan` — nothing is deployed, no cost |
| **Deploy** (opt-in) | manual: Actions → pick workflow → *Run workflow* → tick **deploy** | plan mode + accept Marketplace terms → `apply` → SSH smoke test into each FortiGate → `destroy` |

The destroy step always runs after an apply attempt — success or failure — so nothing keeps billing after a broken run. Deploy runs take roughly 7-15 minutes depending on the example.

## Setup to replicate this CI

### 1. Create a service principal

In Azure Cloud Shell (or any `az` CLI logged into the right subscription):

```bash
SUB_ID=$(az account show --query id -o tsv)

az ad sp create-for-rbac --name fortiqa-ci \
  --role Contributor \
  --scopes /subscriptions/$SUB_ID
```

Copy the JSON output — the `password` is shown only once.

### 2. Grant roles

| Role | Needed for | Scope |
|---|---|---|
| `Reader` | plan-only mode (sufficient if you never deploy) | subscription |
| `Contributor` | deploy mode: creating/destroying resources | subscription |
| `User Access Administrator` | deploy mode for **active-passive-sdn** only — the SDN fabric connector creates a custom role definition and role assignments | subscription |

```bash
az role assignment create --assignee <appId> --role "User Access Administrator" \
  --scope /subscriptions/$SUB_ID
```

Note: `User Access Administrator` lets the credential grant roles, making it powerful — rotate the client secret regularly (`az ad sp credential reset --id <appId>`) and consider a dedicated test subscription.

### 3. Create the GitHub repository secrets

Repo → Settings → Secrets and variables → Actions → *New repository secret*:

| Secret | Value |
|---|---|
| `ARM_CLIENT_ID` | `appId` from step 1 |
| `ARM_CLIENT_SECRET` | `password` from step 1 |
| `ARM_TENANT_ID` | `tenant` from step 1 |
| `ARM_SUBSCRIPTION_ID` | the subscription ID |
| `PASSWORD` | FortiGate admin password. For plan-only any value works; for deploy it must satisfy Azure VM rules: 12+ chars, 3 of upper/lower/digit/special, must not contain the username |

The reusable workflow reads all of these via `secrets: inherit` from the callers.

### 4. Azure Marketplace terms

Deploy mode automatically runs `az vm image terms accept` for the offer/SKU configured in each caller (default `fortinet_fortigate-vm` / `fortinet_fg-vm_byol_76`), so no manual acceptance is needed. The BYOL image boots unlicensed, which is fine for the smoke test.

## How the SSH smoke test works

When a caller sets `ssh_test_output`, after a successful apply the workflow reads the listed terraform output(s), SSHes in with `username`/`PASSWORD` and runs `get system status` + `show system interface`. Each entry is `OUTPUT_NAME[:port]` (port defaults to 22), space-separated:

```yaml
ssh_test_output: FGT-A-MGMT-IP FGT-B-MGMT-IP   # active-passive: one mgmt IP per member
ssh_test_output: ELB-PIP:50030 ELB-PIP:50031   # active-active: NAT'd through the ELB
```

It retries for up to 10 minutes per FortiGate to allow for boot time, and fails the job if any FortiGate never answers. Destroy still runs afterwards.

## Adding a new example

Copy any `tf-example-*.yml` and change:

1. `example` — directory name under `examples/`
2. `prefix` — keep it short and **lowercase** (several examples feed it into `domain_name_label`, which Azure restricts to lowercase)
3. The `paths` filters — example dir + module dir + the two workflow files
4. `ssh_test_output` — the terraform output(s) exposing mgmt IP(s)
5. `extra_tfvars` — any required variables beyond the common five (`prefix`, `location`, `username`, `password`, `subscription_id`); see `tf-example-azurevirtualwan.yml` for plan-only placeholder values

## Per-example notes

| Example | Deploy supported | Notes |
|---|---|---|
| single | yes | 1 FGT, mgmt via `FGT-MGMT-IP` |
| active-passive-elb-ilb | yes | 2 FGTs, HA formation verified via `get system status` |
| active-passive-sdn | yes | needs the extra `User Access Administrator` role |
| active-active-elb-ilb | yes | mgmt SSH NAT'd through ELB: ports 50030 + n |
| azurevirtualwan | plan only | managed NVA needs a real managed identity + FortiManager; deploy takes 30+ min |
