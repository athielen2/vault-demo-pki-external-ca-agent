resource "vault_auth_backend" "approle" {
  type = "approle"
  path = "${var.prefix}-pki-external-ca-approle"
}

resource "vault_policy" "pki_app_role" {
  name = "${var.prefix}-pki-external-ca-app-role-policy"

  policy = <<EOF
path "${vault_mount.pki_external_ca.path}/*" {
  capabilities = ["read", "create", "update"]
}
path "${vault_mount.pki_external_ca.path}/config/${vault_pki_secret_backend_acme_account.this.name}/*" {
  capabilities = ["update"]
}
path "${vault_mount.pki_external_ca.path}/roles/${vault_pki_secret_backend_external_ca_role.this.name}/acme/" {
  capabilities = ["update"]
}
path "auth/token/*" {
  capabilities = ["read", "create", "update"]
}
path "sys/capabilities-self" {
  capabilities = ["update"]
}
EOF
}

resource "vault_approle_auth_backend_role" "pki_agent_app_role" {
  backend            = vault_auth_backend.approle.path
  role_name          = "${var.prefix}-pki-external-ca-agent-approle"
  token_policies     = ["default", vault_policy.pki_app_role.name]
  secret_id_ttl      = 2629800
  token_num_uses     = 0
  token_ttl          = 2629800
  token_max_ttl      = 2629800 * 2
  secret_id_num_uses = 10
}

resource "vault_approle_auth_backend_role_secret_id" "id" {
  backend   = vault_auth_backend.approle.path
  role_name = vault_approle_auth_backend_role.pki_agent_app_role.role_name
}

resource "local_file" "approle_role_id" {
  filename = "${path.module}/tmp/role_id"
  content  = vault_approle_auth_backend_role.pki_agent_app_role.role_id
}

resource "local_file" "approle_secret_id" {
  filename = "${path.module}/tmp/secret_id"
  content  = vault_approle_auth_backend_role_secret_id.id.secret_id
}
