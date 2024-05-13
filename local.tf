locals {
  common-tags = {
    Owner      = "kms"
    CreateDate = formatdate("YYYY-MM-DD", timestamp())

  }
}