resource "random_uuid" "resource" {}

resource "aws_backup_vault" "resource" {
  name          = coalesce(var.name, random_uuid.resource.id)
  kms_key_arn   = var.kms_key_arn
  force_destroy = var.force_destroy

  tags = var.tags
}

resource "aws_backup_vault_lock_configuration" "resource" {
  count = var.lock != null ? 1 : 0

  backup_vault_name   = aws_backup_vault.resource.name
  min_retention_days  = var.lock.min_retention_days
  max_retention_days  = var.lock.max_retention_days
  changeable_for_days = var.lock.changeable_for_days
}

output "id" {
  description = "The ID (name) of the vault."
  value       = aws_backup_vault.resource.id
}

output "arn" {
  description = "The ARN of the vault. Feed this into another vault's copy_action destination_vault_arn for cross-region or cross-account copies."
  value       = aws_backup_vault.resource.arn
}

output "name" {
  description = "The name of the vault. Feed this into terraform-aws-backup-plan's rules as target_vault_name."
  value       = aws_backup_vault.resource.name
}

output "recovery_points" {
  description = "Number of recovery points currently stored in the vault."
  value       = aws_backup_vault.resource.recovery_points
}
