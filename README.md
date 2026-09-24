# terraform-aws-backup-vault

Terraform module for an AWS Backup vault — the encrypted store that
recovery points are written into, optionally locked so their retention
cannot be shortened.

## Cost

Vaults themselves carry no charge. The recovery points inside them bill
per gigabyte-month, at a lower rate once moved to cold storage. Cross-
region and cross-account copies bill for the transfer and for a second
copy of the data. See AWS's
[Backup pricing](https://aws.amazon.com/backup/pricing/) page for
current rates.

## Design

Split from
[`terraform-aws-backup-plan`](https://github.com/kn47ytv9mv/terraform-aws-backup-plan)
because one vault commonly receives recovery points from several plans,
and a plan's rules reference the vault by name from outside — a 1:many
relationship, not a bundling candidate.

`force_destroy` defaults **false**. A destroy then fails while recovery
points remain, rather than silently discarding every backup the vault
holds. That is the safer failure, and matches this family's choice
elsewhere not to expose an easy path to deleting data.

### Vault Lock

`lock` enforces retention in a way nobody can shorten or bypass —
including the account root user and AWS Support. Two modes, and the
difference matters:

- **Governance mode** (omit `changeable_for_days`) — a sufficiently
  privileged principal can still remove the lock. Useful as a guardrail
  against mistakes.
- **Compliance mode** (set `changeable_for_days`) — the lock becomes
  immutable once that grace period elapses. After that, **the vault
  cannot be deleted until every recovery point in it has aged out
  naturally**, and neither you nor AWS can shorten that. Set this only
  when a regulator requires it, and only with retention values you are
  prepared to live with for their full duration.

## Usage

```hcl
module "vault" {
  source = "kn47ytv9mv/backup-vault/aws"

  name        = "production"
  kms_key_arn = module.key.arn
}
```

Or directly from this repository, locked in governance mode:

```hcl
module "vault" {
  source = "github.com/kn47ytv9mv/terraform-aws-backup-vault"

  name = "production"

  lock = {
    min_retention_days = 30
    max_retention_days = 365
  }
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.3 |
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |
| random | ~> 3.9 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| name | Name of the vault. If null, a unique name is generated. | `null` | no |
| kms_key_arn | ARN of the KMS key encrypting recovery points, from `terraform-aws-kms-key`. Cannot be changed after creation. | `null` | no |
| force_destroy | Whether destroying the vault also deletes the recovery points inside it. | `false` | no |
| lock | Vault Lock, enforcing retention nobody can shorten. Setting `changeable_for_days` selects compliance mode, which becomes immutable. | `null` | no |
| tags | A map of tags to assign to the vault. | `null` | no |

## Outputs

| Name | Description |
|---|---|
| id | The ID (name) of the vault. |
| arn | The ARN of the vault. Feed this into another rule's copy destination for cross-region copies. |
| name | The name of the vault. Feed this into `terraform-aws-backup-plan`'s rules as `target_vault_name`. |
| recovery_points | Number of recovery points currently stored in the vault. |

## License

MIT — see [LICENSE.md](LICENSE.md).
