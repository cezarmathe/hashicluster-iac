# hashicluster-iac/generic - generic.pkr.hcl
#
# Definitions for building a generic machine image for a hashicluster.

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
  mi_name = "generic"

  # Instance type to use for building the AWS AMI.
  instance_type = var.mi_arch == "amd64" ? var.aws_builders.amd64 : var.mi_arch == "arm64" ? var.aws_builders.arm64 : null

  # Machine architecture.
  mi_arch = var.mi_arch == "amd64" ? "x86_64" : var.mi_arch == "arm64" ? "aarch64" : null
}

source "vagrant" "generic" {
  communicator = "ssh"
  source_path  = "generic/ubuntu2004"
  provider     = "virtualbox"
  output_dir   = "out/${local.mi_name}"
  skip_add     = true
}

source "amazon-ebs" "generic" {
  ami_name      = "hashicluster-${local.mi_name}-ami-${var.mi_version}-${var.mi_arch}"
  instance_type = local.instance_type
  region        = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-*-20.04-${var.mi_arch}-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = local.mi_arch
    }
    most_recent = true
    owners      = ["099720109477"]
  }

  ssh_username          = "ubuntu"
  force_deregister      = var.aws_ami_force_deregister
  force_delete_snapshot = var.aws_ami_force_delete_snapshot
}

build {
  name    = "generic"
  sources = [
    "source.vagrant.generic",
    "source.amazon-ebs.generic",
  ]

  # wait for cloud-init to finish
  provisioner "shell" {
    only   = ["amazon-ebs.generic"]
    inline = ["/usr/bin/cloud-init status --wait"]
  }

  # run setup scripts
  provisioner "shell" {
    scripts = [
      "scripts/tools_setup.sh",
      "scripts/hashicorp_setup.sh",
      "build/generic/setup.sh",
    ]
  }
}
