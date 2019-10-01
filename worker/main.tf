locals {
  cluster_id      = data.terraform_remote_state.main.outputs.cluster_id
}

provider "aws" {
  region = data.terraform_remote_state.main.outputs.region
}

resource "aws_launch_configuration" "worker-lc" {
  name_prefix                 = "${local.cluster_id}-worker-lc-"
  associate_public_ip_address = false
  instance_type               = "${var.instance_type}"
  image_id                    = data.terraform_remote_state.main.outputs.encrypted_ami_copy
  security_groups             = data.terraform_remote_state.main.outputs.worker_sg_ids
  enable_monitoring = true
  iam_instance_profile = data.terraform_remote_state.main.outputs.worker_role_instance_profile_name
  user_data         = data.local_file.worker-ignition.content
}

resource "aws_autoscaling_group" "worker-asg" {
  name                 = "${local.cluster_id}-worker-asg"
  launch_configuration = "${aws_launch_configuration.worker-lc.name}"
  min_size             = "${var.instance_count}"
  max_size             = "${var.instance_count}"
  vpc_zone_identifier  = data.terraform_remote_state.main.outputs.private_subnet_ids

  tags = [{
    key                 = "kubernetes.io/cluster/${local.cluster_id}"
    value               = "owned"
    propagate_at_launch = "true"
    },
    {
      key                 = "Name"
      value               = "${data.terraform_remote_state.main.outputs.cluster_id}-worker"
      propagate_at_launch = "true"

  }]

  depends_on = [aws_launch_configuration.worker-lc]
}