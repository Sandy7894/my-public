output "ssh_key" {
  description = "ssh key generated by terraform"
  value       = module.test-module.ssh_key
  sensitive = true
}
