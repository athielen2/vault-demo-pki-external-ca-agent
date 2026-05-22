# Vault PKI External CA + Agent Demo

This repository demonstrates how to use Vault's PKI External CA secrets engine with Vault Agent to automate certificate lifecycle for a simple Nginx web server running on AWS.

- PKI External CA docs: https://developer.hashicorp.com/vault/docs/secrets/pki-external-ca
- Vault Agent + PKI External CA docs: https://developer.hashicorp.com/vault/docs/agent-and-proxy/agent/pki-external-ca

## Demo Purpose

The demo shows how Vault can request publicly trusted certificates from an external CA over ACME (Let's Encrypt in this case), then deliver cert/key material to an app host without manual certificate operations.

Key ideas:

- Vault's `pki-external-ca` mount brokers ACME interactions with the public CA.
- Vault Agent authenticates to Vault using AWS IAM auth.
- Agent templates render cert/key files used by Nginx.
- Nginx reloads automatically when key material is written.
- Agent will keep the certificate refreshed automatically.

This repository deploys:

- A single EC2 instance with Nginx.
- A Route53 `A` record pointing your demo DNS name at the instance.
- Vault resources: `pki-external-ca` mount, ACME account, role, AWS auth mount/role, and policy.

## Prerequisites

1. Terraform installed.
2. AWS credentials with permission to create necessary resources
3. A Route53 public hosted zone already created for your top-level domain.
4. A Vault cluster
5. An SSH key pair in the target AWS region.
6. Public DNS name under your hosted zone that can be used for ACME HTTP-01 validation.

## Configuration

Populate `terraform.tfvars` with your environment-specific values. This repo expects values like:

```hcl
region                = "us-east-1"
vault_addr            = "https://vault.example.com:8200"
vault_namespace       = "admin/example"
prefix                = "demo"
acme_email_contacts   = ["you@example.com"]
key_pair_name         = "my-keypair"
subnet_id             = "subnet-xxxxxxxx"
top_level_domain_name = "example.com"
client_dns            = "demo.example.com"
ssh_ingress           = ["x.x.x.x/32"]
http_tls_ingress      = ["0.0.0.0/0"]
```

Notes:

- `client_dns` should be a subdomain of `top_level_domain_name`.
- `acme_email_contacts` is used for the ACME account registration.
- The demo uses a Let's Encrypt directory (`https://acme-v02.api.letsencrypt.org/directory`).

## Deploy

From this repository root:

```bash
terraform init
terraform plan
terraform apply
```

## Demo Walkthrough

Use the following flow during your demo.

1. Confirm initial TLS failure (no cert yet) either through a browser or the terminal.

```bash
curl -vkI https://<client_dns>
```

You should see a TLS/certificate error because no certificate has been rendered yet.

2. SSH to the instance

```bash
ssh -i <path-to-key.pem> ubuntu@<client_dns>
```

3. View and walk through the agent configuration. Point out that authentication is handled automatically through AWS auth, and that the agent is set up to issue a certificate for the correct domain. You may also mention the Nginx "post-render" actions. 

```bash
cat /home/ubuntu/agent.hcl
```

4. Start Vault Agent manually

```bash
sudo vault agent -config /home/ubuntu/agent.hcl
```

5. Observe certificate retrieval in logs

In the running agent output, watch for successful auth, ACME challenge handling, and template rendering events. This is where you show that Vault is brokering cert issuance from the external CA.

6. Inspect the retrieved certificate

Open a second SSH session or stop the agent after issuance, then run:

```bash
openssl x509 -in /home/ubuntu/nginx-cert.crt -text -noout
```

7. Validate HTTPS now succeeds through the browser or terminal:

```bash
curl -vkI https://<client_dns>
```

8. Show Vault-side caching behavior

```bash
rm /home/ubuntu/nginx-cert.crt
```

Then re-trigger rendering by running agent again (if not already running) and note that Vault can return cached certificate material according to engine behavior and certificate lifetime, rather than always forcing a brand-new issuance.

## Cleanup

```bash
terraform destroy
```

## Troubleshooting Tips

- ACME challenge failures:
  - Ensure `client_dns` resolves publicly to this instance.
  - Ensure port 80 is reachable from the internet.
- Vault auth failures:
  - Verify EC2 instance IAM role matches the Vault AWS auth role binding.
  - Verify Vault address/namespace values are correct.
- TLS still failing after issuance:
  - Confirm `/home/ubuntu/nginx-cert.crt` and `/home/ubuntu/nginx-cert.key` exist.
  - Check Nginx status and reload behavior.
