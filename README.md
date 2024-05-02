Solution for the task:
----------------------

The task was done using terraform tool.

Prerequisites for installation:
-------------------------------
 - GCP Account with project api enabled for compute.googleapis.com,iam.googleapis.com,iamcredentials.googleapis.com
 - gcloud authorized to the relevant account (I.E. gcloud auth login)
 - Terraform installed on client machine

The environment was created by the following way:

External LB -> Regional Instance Group -> Compute Engines running the web server.

You can run the terraform by:
git clone https://github.com/asafaven/pmo.git
Than modify the parameters on the pmo/tf/terraform.tfvars and pmo/tf/variables.tf.
cd pmo/tf
terraform init
terraform plan
terraform apply

After the LB start up, it can take time until it responds to requests (up to 10 minutes, usually less)

Web Server
----------
The web server was created by python flask on the web-flask folder.

  
Terraform Provider
-------------------
Configured on tf/providers.tf

 * google - to perform actions on gcp, authorized to the relevant account by the current gcloud connection.


Terraform actions:
------------------
A - We create a VPC network, and a small subnetwork run on "10.0.1.0/24" cidr.

B - Create "google_compute_instance_template" - includes the properties of the VM's should be started. Shell script was added in order to git clone the web server and start it.

C - Create google_compute_region_instance_group_manager - a manager that creates regional instance group, so the compute will be on different zones.

D - Create backend service, that generally defines the target for the loadbalancer requests, on our case it is the regional instance group.

E - Create all the objects required for the load balancer: fowarding rule, http proxy, url map.

F - Create the LB.








