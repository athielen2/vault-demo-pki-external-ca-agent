data "aws_route53_zone" "public" {
  name = var.top_level_domain_name
}

resource "aws_route53_record" "vault_agent_pki" {
  zone_id = data.aws_route53_zone.public.zone_id
  name    = var.client_dns
  type    = "A"
  ttl     = 300
  records = [aws_instance.agent_server.public_ip]
}
