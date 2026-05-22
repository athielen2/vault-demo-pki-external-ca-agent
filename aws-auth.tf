resource "vault_auth_backend" "aws" {
  type = "aws"
  path = "${var.prefix}-pki-external-ca-aws"
}

resource "vault_aws_auth_backend_role" "pki_agent_aws_role" {
  backend                  = vault_auth_backend.aws.path
  role                     = "${var.prefix}-pki-external-ca-agent-aws"
  auth_type                = "iam"
  bound_iam_principal_arns = [aws_iam_role.agent_server.arn]
  token_policies           = [vault_policy.pki_app_role.name]
  token_ttl                = 3600
  token_max_ttl            = 30 * 24 * 3600
}

data "vault_policy_document" "pki_app_role" {
  rule {
    path         = "${vault_mount.pki_external_ca.path}/role/${vault_pki_external_ca_secret_backend_role.this.name}/*"
    capabilities = ["read", "create", "update", "list"]
  }
}

resource "vault_policy" "pki_app_role" {
  name   = "${var.prefix}-pki-external-ca-app-role-policy"
  policy = data.vault_policy_document.pki_app_role.hcl
}

