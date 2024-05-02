#VPC
variable "project_id" {
  description = "project id"
  default = "apester-project"
}

variable "region" {
  default = "us-east1"
}
variable "web_server_name" {
  default = "apester-wb"
}
# variable "zone-1" {
#   default = "us-east1-b"
# }

# variable "zone-2" {
#   default = "us-east1-c"
# }
variable "machine" {
  default = "e2-standard-2"
}

variable "zones" {
  default = ["us-east1-b","us-east1-c"]
}
variable "port_number" {
  default = "6000"
}
variable "git_repo" {
  default = "https://github.com/asafaven/pom.git"
}
variable "application_folder" {
  default = "/opt/apester"
}