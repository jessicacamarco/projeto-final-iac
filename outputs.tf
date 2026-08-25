output "public_ip" {
  description = "IP público da instância"

  value = module.servidor_web.public_ip
}

output "public_dns" {
  description = "DNS público da instância"

  value = module.servidor_web.public_dns
}
