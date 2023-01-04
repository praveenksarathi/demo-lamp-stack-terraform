variable "vpc_id" {
    type = string
    default = "vpc-0f38cf9453a57b3f6"
}

variable "subnet_id" {
    type = string
    default = "subnet-00fe2421e1eec2c51"
}

variable "ssh_user" {
    type = string
    default = "ubuntu"
}

variable "key_name" {
    type = string
    default = "wp-key-03" 
}

variable "private_key_path" {
    type = string
    default = "/home/praveen/terraform/testKey.pem"
}

variable "ami" {
    type = string
    default = "ami-07c2ae35d31367b3e"
}