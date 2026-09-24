mock_provider "aws" {}

run "lock_retention_bounds_must_be_ordered" {
  command = plan

  variables {
    lock = {
      min_retention_days = 90
      max_retention_days = 30
    }
  }

  expect_failures = [var.lock]
}

run "name_defaults_to_random_uuid" {
  command = apply

  assert {
    condition     = aws_backup_vault.resource.name == random_uuid.resource.id
    error_message = "Leaving name unset should fall back to the generated random_uuid."
  }
}

run "force_destroy_defaults_false" {
  command = plan

  assert {
    condition     = aws_backup_vault.resource.force_destroy == false
    error_message = "force_destroy should default false, so a destroy cannot silently discard every recovery point the vault holds."
  }
}

run "no_lock_by_default" {
  command = plan

  assert {
    condition     = length(aws_backup_vault_lock_configuration.resource) == 0
    error_message = "Leaving lock unset should create no lock configuration."
  }
}

run "lock_creates_one_configuration" {
  command = plan

  variables {
    lock = {
      min_retention_days  = 30
      max_retention_days  = 365
      changeable_for_days = 3
    }
  }

  assert {
    condition     = length(aws_backup_vault_lock_configuration.resource) == 1
    error_message = "Setting lock should create exactly one lock configuration."
  }

  assert {
    condition     = aws_backup_vault_lock_configuration.resource[0].changeable_for_days == 3
    error_message = "The lock's grace period should pass through unchanged."
  }
}

run "readme_default_example" {
  command = plan

  variables {
    name        = "production"
    kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/abc"
  }
}

run "readme_governance_lock_example" {
  command = plan

  variables {
    name = "production"

    lock = {
      min_retention_days = 30
      max_retention_days = 365
    }
  }
}
