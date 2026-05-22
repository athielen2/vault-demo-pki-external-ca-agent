resource "vault_mount" "pki_external_ca" {
  path = "${var.prefix}-pki-external-ca"
  type = "pki-external-ca"
}

resource "vault_pki_external_ca_secret_backend_acme_account" "this" {
  mount          = vault_mount.pki_external_ca.path
  name           = "${var.prefix}-acme-account"
  directory_url  = "https://acme-v02.api.letsencrypt.org/directory"
  email_contacts = var.acme_email_contacts
  key_type       = "ec-384"
}

resource "vault_pki_external_ca_secret_backend_role" "this" {
  mount             = vault_mount.pki_external_ca.path
  name              = "${var.prefix}-role"
  acme_account_name = vault_pki_external_ca_secret_backend_acme_account.this.name

  allowed_domains        = [var.top_level_domain_name]
  allowed_domain_options = ["subdomains"]
}
