# hashicluster-iac/master - master.pkr.hcl
#
# Definitions for building a master machine image for a hashicluster.

packer {
  required_plugins {
    amazon = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "aws_region" {
  type        = string
  description = "AWS region where this AMI should be built."
  default     = "us-east-1"
}

variable "aws_ami_force_deregister" {
  type        = bool
  description = "Force deregistering a previous AMI."
  default     = false
}

variable "aws_ami_force_delete_snapshot" {
  type        = bool
  description = "Force deleting snapshots."
  default     = false
}

variable "aws_builders" {
  type        = object({
    amd64 = string
    arm64 = string
  })
  description = "Instance types for building AWS AMIs."
  default     = {
    amd64 = "t3a.nano"
    arm64 = "t4g.nano"
  }
}

variable "aws_source_ami" {
  type        = string
  description = "Source AMI used for building this AMI."
  default     = "hashicluster-generic-ami-*-*"
}

variable "mi_arch" {
  type        = string
  description = "Machine image architecture (amd64 or arm64)."
  default     = "amd64"
}

variable "mi_version" {
  type        = string
  description = "Machine image version."
  default     = "dev"
}

locals {
  # Machine image name.
  mi_name = "master"

  # Instance type to use for building the AWS AMI.
  instance_type = var.mi_arch == "amd64" ? var.aws_builders.amd64 : var.mi_arch == "arm64" ? var.aws_builders.arm64 : null
}

source "vagrant" "master" {
  communicator = "ssh"
  source_path  = "out/generic/package.box"
  provider     = "virtualbox"
  output_dir   = "out/${local.mi_name}"
  skip_add     = true
}

source "amazon-ebs" "master" {
  ami_name      = "hashicluster-${local.mi_name}-ami-${var.mi_version}-${var.mi_arch}"
  instance_type = local.instance_type
  region        = var.aws_region
  source_ami_filter {
    filters = {
      name                = var.aws_source_ami
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      arch                = var.mi_arch
    }
    most_recent = true
    owners      = ["self"]
  }

  ssh_username          = "ubuntu"
  force_deregister      = var.aws_ami_force_deregister
  force_delete_snapshot = var.aws_ami_force_delete_snapshot
}

build {
  name    = "master"
  sources = [
    "source.vagrant.master",
    "source.amazon-ebs.master",
  ]

  # create config tmp dirs
  provisioner "shell" {
    inline = [
      "mkdir -p /tmp/consul-setup/",
      "mkdir -p /tmp/nomad-setup/",
      "mkdir -p /tmp/vault-setup/",
    ]
  }

  # upload consul configs
  provisioner "file" {
    sources     = [
      "configs/consul/00-agent.hcl",
      "configs/consul/10-server.hcl",
      "configs/consul/50-master.hcl",
    ]
    destination = "/tmp/consul-setup/"
  }

  # upload nomad configs
  provisioner "file" {
    sources     = [
      "configs/nomad/00-agent.hcl",
      "configs/nomad/10-server.hcl",
      "configs/nomad/50-master.hcl",
    ]
    destination = "/tmp/nomad-setup/"
  }

  # upload vault configs
  provisioner "file" {
    sources     = [
      "configs/vault/00-agent.hcl",
      "configs/vault/10-server.hcl",
      "configs/vault/50-master.hcl",
    ]
    destination = "/tmp/vault-setup/"
  }

  # run setup scripts
  provisioner "shell" {
    scripts = [
      "scripts/consul_setup.sh",
      "scripts/nomad_setup.sh",
      "scripts/vault_setup.sh",
      "build/master/setup.sh",
    ]
  }
}
