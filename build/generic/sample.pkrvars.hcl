# hashicluster-iac/generic - sample.pkrvars.hcl
#
# Sample packer variables file for building a generic machine image.

aws_region = "eu-east-1"

aws_ami_force_deregister      = false
aws_ami_force_delete_snapshot = false

aws_builders = {
  amd64 = "t3a.nano"
  arm64 = "t4g.nano"
}

mi_arch    = "amd64"
mi_version = "dev"
