# variables.tf

variable "region" {
  type        = string
  description = "AWS region for this deployment."
}

variable "ssh_key" {
  type        = string
  description = "SSH key allowed by the created EC2 instances."
}
