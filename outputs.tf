output "ipv4_address" {
  value       = digitalocean_droplet.app.ipv4_address
  description = "Public IPv4 address"
}

output "ipv6_address" {
  value       = digitalocean_droplet.app.ipv6_address
  description = "Public IPv6 address"
}

output "ssh_command" {
  value       = "ssh root@${digitalocean_droplet.app.ipv4_address}"
  description = "SSH command to connect"
}

output "app_url" {
  value       = "http://${digitalocean_droplet.app.ipv4_address}"
  description = "Application URL"
}
