aws_bootstrap_instance_type = "m4.large"
aws_master_instance_type = "m4.xlarge"
aws_master_root_volume_type = "gp2"
aws_master_root_volume_size = 64
aws_ami = "ami-053073b95aa285347"
aws_region = "eu-west-2"

##List string
aws_master_availability_zones = ["eu-west-2a","eu-west-2b","eu-west-2c"]

##list string
aws_worker_availability_zones = ["eu-west-2a","eu-west-2b","eu-west-2c"]

##"The identifier for the cluster."
cluster_id = "upi-ocp-dev-rdw9n"

##The base domain used for public records."
base_domain = "awscloudops.co.uk"

machine_cidr = "10.0.0.0/16"
master_count = 3

#new stuff

cluster_domain = "upi-ocp-dev.awscloudops.co.uk"
