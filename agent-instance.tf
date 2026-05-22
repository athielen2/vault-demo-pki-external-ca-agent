locals {
  agent_user_data = templatefile("${path.module}/templates/agent-userdata.sh.tftpl", {
    client_name     = var.client_dns
    vault_addr      = var.vault_addr
    vault_namespace = var.vault_namespace
    agent_config = templatefile("${path.module}/templates/agent.hcl.tftpl", {
      vault_addr                 = var.vault_addr
      vault_namespace            = var.vault_namespace
      client_name                = var.client_dns
      aws_auth_path              = vault_auth_backend.aws.path
      aws_auth_role              = vault_aws_auth_backend_role.pki_agent_aws_role.role
      pki_external_ca_mount_path = vault_mount.pki_external_ca.path
      pki_external_ca_role       = vault_pki_external_ca_secret_backend_role.this.name
    })
  })
}

data "aws_subnet" "agent" {
  id = var.subnet_id
}

resource "aws_iam_role" "agent_server" {
  name = "${var.prefix}-pki-external-ca-demo-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name = "${var.prefix}-pki-external-ca-demo-role"
  }
}

resource "aws_iam_instance_profile" "agent_server" {
  name = "${var.prefix}-pki-external-ca-demo-profile"
  role = aws_iam_role.agent_server.name
}

resource "aws_security_group" "agent_server" {
  name        = "${var.prefix}-pki-external-ca-demo-sg"
  description = "Allow SSH, HTTP, and HTTPS access"
  vpc_id      = data.aws_subnet.agent.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_ingress
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.http_tls_ingress
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.http_tls_ingress
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.prefix}-pki-external-ca-demo-sg"
  }
}

resource "aws_instance" "agent_server" {
  ami           = data.aws_ami.hc_base_ubuntu_2404.id
  instance_type = "t3.micro"
  key_name      = var.key_pair_name

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.agent_server.id]
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.agent_server.name

  user_data                   = local.agent_user_data
  user_data_replace_on_change = true

  tags = {
    Name = "${var.prefix}-pki-external-ca-demo-instance"
  }
}

resource "local_file" "agent_user_data" {
  filename = "${path.module}/tmp/agent-user-data.sh"
  content  = local.agent_user_data
}
