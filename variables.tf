variable "name" {
  default     = null
  description = "Name of the vault. If null, a unique name is generated."
}

variable "kms_key_arn" {
  default     = null
  description = "ARN of the KMS key encrypting recovery points in this vault, from terraform-aws-kms-key. If null, AWS's own managed key for Backup is used. Cannot be changed after creation."
}

variable "force_destroy" {
  default     = false
  description = "Whether destroying the vault also deletes the recovery points inside it. Defaults false, so a destroy cannot silently discard every backup the vault holds — the destroy fails instead while recovery points remain, which is the safer failure."
}

variable "lock" {
  default     = null
  description = "Vault Lock, which enforces retention in a way nobody can shorten or bypass — including the account root user and AWS itself. min_retention_days and max_retention_days bound every recovery point's retention. changeable_for_days sets the grace period before the lock becomes immutable: while it is running the lock can still be removed, and once it elapses the vault cannot be deleted until every recovery point has aged out naturally. Omitting changeable_for_days creates the lock in governance mode, which a sufficiently privileged principal can still remove. If null, no lock is applied."
  type = object({
    min_retention_days  = optional(number)
    max_retention_days  = optional(number)
    changeable_for_days = optional(number)
  })

  validation {
    condition     = var.lock == null || var.lock.min_retention_days == null || var.lock.max_retention_days == null || var.lock.max_retention_days >= var.lock.min_retention_days
    error_message = "A vault lock's max_retention_days cannot be less than its min_retention_days."
  }
}

variable "tags" {
  default     = null
  description = "A map of tags to assign to the vault."
}
