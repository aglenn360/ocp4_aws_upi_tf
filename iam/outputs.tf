output "worker_role_name" {
  value = aws_iam_role.worker_role.name
}

output "worker_role_instance_profile_name" {
  value = aws_iam_instance_profile.worker.name
}