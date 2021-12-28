# main.tf

provider "aws" {
  region = var.region
}

data "aws_ami" "master" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${local.name}-master-ami-*-amd64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

data "aws_ami" "worker" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["${local.name}-worker-ami-*-amd64"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "cluster_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.0"

  name = local.name
  cidr = "10.42.0.0/16"

  azs              = ["${var.region}a", "${var.region}b", "${var.region}c"]
  public_subnets   = ["10.42.0.0/24", "10.42.1.0/24", "10.42.2.0/24"]
  private_subnets  = ["10.42.100.0/24", "10.42.101.0/24", "10.42.102.0/24"]
  database_subnets = ["10.42.200.0/24", "10.42.201.0/24", "10.42.202.0/24"]

  tags = local.tags
}

module "cluster_external_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Security group for external traffic."
  vpc_id      = module.cluster_vpc.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["all-icmp", "ssh-tcp"]
  egress_cidr_blocks  = ["0.0.0.0/0"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

module "cluster_internal_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 4.0"

  name        = local.name
  description = "Security group for internal traffic."
  vpc_id      = module.cluster_vpc.vpc_id

  ingress_cidr_blocks = ["10.42.0.0/16"]
  ingress_rules       = ["all-all"]
  egress_cidr_blocks  = ["10.42.0.0/16"]
  egress_rules        = ["all-all"]

  tags = local.tags
}

module "cluster_master" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.2"

  count = 3

  name              = "${local.name}-master-${count.index}"
  ami               = data.aws_ami.master.id
  instance_type     = "t3a.micro"
  availability_zone = element(module.cluster_vpc.azs, count.index % 3)
  subnet_id         = element(module.cluster_vpc.public_subnets, count.index % 3)
  vpc_security_group_ids = [
    module.cluster_external_security_group.security_group_id,
    module.cluster_internal_security_group.security_group_id,
  ]
  ebs_optimized               = true
  key_name                    = aws_key_pair.operator.key_name
  associate_public_ip_address = true
  iam_instance_profile        = module.cluster_ec2_member_role.iam_instance_profile_name

  tags = local.tags
}

module "cluster_worker" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.2"

  count = 5

  name              = "${local.name}-worker-${count.index}"
  ami               = data.aws_ami.worker.id
  instance_type     = "t3a.micro"
  availability_zone = element(module.cluster_vpc.azs, count.index % 3)
  subnet_id         = element(module.cluster_vpc.public_subnets, count.index % 3)
  vpc_security_group_ids = [
    module.cluster_external_security_group.security_group_id,
    module.cluster_internal_security_group.security_group_id,
  ]
  ebs_optimized               = true
  key_name                    = aws_key_pair.operator.key_name
  associate_public_ip_address = true
  iam_instance_profile        = module.cluster_ec2_member_role.iam_instance_profile_name

  tags = local.tags
}

module "cluster_ec2_member_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  version = "~> 4.3"

  create_role             = true
  create_instance_profile = true

  # fixme 27/12/2021: this is probably insanely bad
  trusted_role_arns = ["*"]
  role_name         = "${local.name}-ec2-cluster-member-role"
  role_requires_mfa = false

  custom_role_policy_arns           = [module.cluster_ec2_member_policy.arn]
  number_of_custom_role_policy_arns = 1
}

module "cluster_ec2_member_policy" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-policy"
  version = "~> 4.3"

  name        = "ec2-cluster-member-policy"
  path        = "/${local.name}/"
  description = "Policy for cluster members."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeInstances"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

# The ssh key of the operator.
resource "aws_key_pair" "operator" {
  key_name   = "${local.name}-operator"
  public_key = var.ssh_key
}

locals {
  name = "hashicluster"

  tags = {
    Terraform              = true
    HashiCluster           = true
    "HashiCluster/Version" = "demo"
    "HashiCluster/Name"    = "sample"
  }
}
