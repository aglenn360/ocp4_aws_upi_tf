data "terraform_remote_state" "main" {
  backend = "local"

  config = {
    path = "${path.module}/../terraform.tfstate"
  }
}

data "local_file" "worker-ignition" {
  #template = "${file("${path.module}/templates/kms-key-policy.json")}"
  filename = "../ignition-files/worker.ign"

}