#AWS Network Variables
variable "vpc_id" {
  type    = string
  default = "vpc-0f38cf9453a57b3f6"
}

variable "subnet_id" {
  type    = string
  default = "subnet-00fe2421e1eec2c51"
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

#AWS Resource Variables
variable "ami" {
  type    = string
  default = "ami-07c2ae35d31367b3e"
  # default = "ami-084e8c05825742534"
}

variable "bucket_name" {
  type    = string
  default = "praveenksarathi-15703"
}

variable "machine_type" {
  type    = string
  default = "t2.micro"
}

variable "boot_disk_size" {
  type    = number
  default = 20
}

variable "data_disk_size" {
  type    = number
  default = 50
}

#Access Variables
variable "private_key_path" {
  type    = string
  default = "/home/praveen/dumps/terraform/testKey.pem"
}

variable "acl_value" {
  type    = string
  default = "private"
}

variable "key_name" {
  type    = string
  default = "nginx-server-key"
}

variable "ssh_user" {
  type    = string
  default = "ubuntu"
}