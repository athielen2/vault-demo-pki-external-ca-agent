variable "vault_addr" {
  type    = string
  default = "localhost:8200"
}

variable "vault_namespace" {
  type    = string
  default = ""
}

variable "region" {
  default = "ap-southeast-1"
}

variable "prefix" {
  type = string
}

variable "key_pair_name" {
  type = string
}

variable "subnet_id" {
  type        = string
  description = "Subnet to deploy the servers into (you can retrieve this from the hvd module)"
}

variable "ssh_ingress" {
  type        = list(string)
  description = "CIDR blocks allowed to access SSH (port 22)."
}

variable "http_tls_ingress" {
  type        = list(string)
  description = "CIDR blocks allowed to access HTTP/HTTPS (ports 80 and 443)."
  default     = ["0.0.0.0/0"]
}

variable "top_level_domain_name" {
  default     = "localhost"
  description = "Top level domain name"
}

variable "client_dns" {
  description = "Domain Name for Agent server. DNS should be the same top_level_domain_name."
}

variable "acme_email_contacts" {
  type = list(string)
}
