## OCP 4.1 deployment on AWS Cloud using User provisioned Infrastructure

### Architecture:

When using this method, you can: <br>
  * Specify the number of masters and workers you want to provision<br>
  * Change Network Security Group rules in order to lock down the ingress access to the cluster<br>
  * Change Infrastructure component names<br>
  * Add tags

This Terraform based aproach will split VMs accross 3 AWS Availability Zones<br>


Deployment can be split into 4 steps:
 * Create Control Plane (masters) and Surrounding Infrastructure (DNS,VPC etc.)
 * Destroy Bootstrap VM
 * Create Compute (worker) nodes

### Prereqs:

This method uses the following tools:<br>
  * terraform >= 0.12<br>
  * openshift-cli<br>
  * git<br>
  * jq (optional)
  


### Preparation

1. Prepare AWS Cloud for Openshift installation:<br>
https://github.com/openshift/installer/tree/master/docs/user/aws



2. Clone this repository

```sh
  $> git clone https://github.com/aglenn360/ocp4_aws_upi_tf.git
  $> cd ocp4_aws_upi_tf
```

3. Initialize Terraform working directories (current and worker):

```sh
$> terraform init
$> cd worker
$> terraform init
$> cd ../
```

4. Download openshift-install binary and get the pull-secret from:<br>
https://cloud.redhat.com/openshift/install/aws/installer-provisioned

5. Copy openshift-install binary to `/usr/local/bin` directory<br>
```sh
cp openshift-install /usr/local/bin/
```

6. Generate install config files:<br>
```sh
$> openshift-install create install-config --dir=ignition-files
```

```console
$> ./openshift-install create install-config --dir=ignition-files
? SSH Public Key /home/user_id/.ssh/id_rsa.pub
? Platform aws
? Region eu-west-2
? Base Domain example.com
? Cluster Name test
? Pull Secret [? for help]
```

6.1. Edit the install-config.yaml file to set the number of compute, or worker, replicas to 0, as shown in the following compute stanza:
```console
compute:
- hyperthreading: Enabled
  name: worker
  platform: {}
  replicas: 0
```

7. Generate manifests:<br>
```sh
$> openshift-install create manifests --dir=ignition-files
```

7.1. Remove the files that define the control plane machines:<br>
```sh
$> rm -f ignition-files/openshift/99_openshift-cluster-api_master-machines-*
```

7.2. Remove the Kubernetes manifest files that define the worker machines:<br>
```sh
$> rm -f ignition-files/openshift/99_openshift-cluster-api_worker-machineset-*
```

Because you create and manage the worker machines yourself, you do not need to initialize these machines.<br>

8. Obtain the Ignition config files:<br>
```sh
$> openshift-install create ignition-configs --dir=ignition-files
```

9. Extract the infrastructure name from the Ignition config file metadata, run one of the following commands:<br>
```sh
$> jq -r .infraID ignition-files/metadata.json
$> egrep -o 'infraID.*,' ignition-files/metadata.json
```

10. Open terraform.tfvars file and fill in the variables:<br>
```console
aws_bootstrap_instance_type = ""
aws_master_instance_type = ""
aws_master_root_volume_type = ""
aws_master_root_volume_size = 64
aws_ami = "ami_name"
aws_region = "eu-west-2"

##List string
aws_master_availability_zones = ""

##list string
aws_worker_availability_zones = ""

##"The identifier for the cluster."
cluster_id = "openshift-lnkh2"

##The base domain used for public records."
base_domain = "example.com"

machine_cidr = "10.0.0.0/16"
master_count = 3

```


### Start OCP v4.1 Deployment

You can either run the `upi-ocp-install.sh` script or run the steps manually:

1. Run the installation script:<br>
```sh
$> ./upi-ocp-install.sh
```

> After Control Plane is deployed, script will replace the default Ingress Controller of type `LoadBalancerService` to type `HostNetwork`. This will disable the creation of Public facing Azure Load Balancer and will allow to have a custom Network Security Rules which won't be overwritten by Kubernetes.

> Once this is done, it will continue with Compute nodes deployment.

2. Manual approach:

2.1. Initialize Terraform directory:
```sh
terraform init
```
2.2. Run Terraform Plan and check what resources will be provisioned:
```sh
terraform plan
```
2.3. Once ready, run Terraform apply to provision Control plane resources:
```sh
terraform apply -auto-approve
```
2.4. Once Terraform job is finished, run `openshift-install`. It will check when the bootstraping is finished.
```sh
openshift-install wait-for bootstrap-complete --dir=ignition-files
```


2.5. Since we dont need bootstrap VM anymore, we can remove it:
```sh
terraform destroy -target=module.bootstrap -auto-approve
```

2.6. Check openshift-ingress service type (it should be type: ClusterIP):
```sh
oc get svc -n openshift-ingress
 NAME                      TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                   AGE
 router-internal-default   *ClusterIP*   172.30.72.53   <none>        80/TCP,443/TCP,1936/TCP   37m
```

2.7. Wait for installation to be completed. Run `openshift-install` command:
```sh
openshift-install wait-for install-complete --dir=ignition-files
```

 approve the CSR generated by each kubelet.

You can approve all `Pending` CSR requests using:

```sh
oc get csr -o json | jq -r '.items[] | select(.status == {} ) | .metadata.name' | xargs oc adm certificate approve
```


