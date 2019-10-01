data "local_file" "master-ignition" {
  #template = "${file("${path.module}/templates/kms-key-policy.json")}"
  filename = "ignition-files/master.ign"

}



data "local_file" "bootstrap-ignition" {
  #template = "${file("${path.module}/templates/kms-key-policy.json")}"
  filename = "ignition-files/bootstrap.ign"

}