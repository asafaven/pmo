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
variable "zones" {
  default = ["us-east1-b","us-east1-c"]
}
variable "port_number" {
  default = "6000"
}
variable "git_repo" {
  default = "https://github.com/asafaven/pom.git"
}
