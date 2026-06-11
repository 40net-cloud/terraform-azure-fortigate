# CI workflows

Each example in `examples/` has a thin caller workflow (`tf-example-<name>.yml`) that invokes the shared reusable workflow `terraform-example-test.yml`. The shared workflow runs `terraform init`, `fmt -check`, `validate`, and `plan` (no apply, no resources created) against the example directory.

Triggers: push to `main` and pull requests touching the example, its module, or the workflow files; plus manual `workflow_dispatch`.

## Required repository secrets

| Secret | Purpose |
|---|---|
| `ARM_CLIENT_ID` | Service principal app ID |
| `ARM_CLIENT_SECRET` | Service principal secret |
| `ARM_SUBSCRIPTION_ID` | Azure subscription (also passed as `TF_VAR_subscription_id`) |
| `ARM_TENANT_ID` | Azure AD tenant |
| `PASSWORD` | FortiGate admin password (`TF_VAR_password`) |

The service principal needs only Reader-level access for plan.

## Adding a new example

Copy any `tf-example-*.yml`, change `example`, `prefix`, and the `paths` filters. Variables without defaults beyond the common five (`prefix`, `location`, `username`, `password`, `subscription_id`) can be supplied via the `extra_tfvars` input — see `tf-example-azurevirtualwan.yml`, which passes plan-only placeholders for the managed identity and FortiManager values.
