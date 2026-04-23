# resource "aws_eip" "agent_public" {
#   domain   = "vpc"
#   instance = aws_instance.agent_server.id
# }

locals {
  agent_user_data = templatefile("${path.module}/templates/agent-userdata.sh.tftpl", {
    ca_cert          = file(var.ca_cert_abs_path)
    approle_roleid   = vault_approle_auth_backend_role.pki_agent_app_role.role_id
    approle_secretid = vault_approle_auth_backend_role_secret_id.id.secret_id
    client_name      = var.client_dns
    vault_addr       = var.vault_addr
    approle_path     = vault_auth_backend.approle.path
    agent_config = templatefile("${path.module}/templates/agent.hcl.tftpl", {
      vault_addr                 = var.vault_addr
      client_name                = var.client_dns
      approle_path               = vault_auth_backend.approle.path
      pki_external_ca_mount_path = vault_mount.pki_external_ca.path
      pki_external_ca_role       = vault_pki_secret_backend_external_ca_role.this.name
    })
  })
}

resource "aws_instance" "agent_server" {
  ami           = data.aws_ami.ubuntu_jammy_24_04.id
  instance_type = "t2.micro"
  key_name      = var.key_pair_name

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true

  tags = {
    Name = "${var.prefix}-pki-external-ca-demo-instance"
  }

  user_data = local.agent_user_data
}

resource "local_file" "agent_user_data" {
  filename = "${path.module}/tmp/agent-user-data.sh"
  content  = local.agent_user_data
}

