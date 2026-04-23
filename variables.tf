variable "vault_addr" {
  type    = string
  default = "localhost:8200"
}

variable "ca_cert_abs_path" {
  type = string
}

variable "region" {
  default = "ap-southeast-1"
}

variable "prefix" {
  type = string
}

variable "key_pair_name" {}

#subnet-06f3a182c113a9eb9

variable "security_group_ids" {
  description = "Security group to deploy the servers into (you can retrieve this from the hvd module)"
}

variable "subnet_id" {
  description = "Subnet to deploy the servers into (you can retrieve this from the hvd module)"
}

variable "top_level_domain_name" {
  default     = "localhost"
  description = "Top level domain name"
}

variable "client_dns" {
  description = "Domain Name for Agent server. DNS should be the same top_level_domain_name."
}

variable "ami_owner" {}

variable "ami_name" {}

variable "acme_email_contacts" {
  type = list(string)
}

variable "allowed_domains" {
  type    = list(string)
  default = ["example.com"]
}

variable "allowed_bare_domains" {
  type    = list(string)
  default = ["bare_domains", "subdomains"]
}
