output "master_availability_zones" {
  value = var.aws_master_availability_zones
}

output "worker_availability_zones" {
  value = var.aws_worker_availability_zones
}

output "az_to_subnet_id" {
  value = module.vpc.az_to_private_subnet_id
}

output "cluster_id" {
  value = var.cluster_id
}

output "worker_sg_ids" {
  value = [module.vpc.worker_sg_id]
}

output "encrypted_ami_copy" {
  value = aws_ami_copy.main.id
}

output "region" {
  value = var.aws_region
}

output "worker_role_name" {
  value = module.iam.worker_role_name
}

output "worker_role_instance_profile_name" {
  value = module.iam.worker_role_instance_profile_name
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}