# outputs.tf

output "cluster_master_ip" {
  value       = [for _, v in module.cluster_master : v.public_ip]
  description = "Public IP addresses for the cluster masters."
}

output "cluster_worker_ip" {
  value       = [for _, v in module.cluster_worker : v.public_ip]
  description = "Public IP addresses for the cluster workers."
}
