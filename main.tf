
provider "aws" {
  region = var.region
}

resource "aws_kms_key" "praveen_key" {
  description              = "KMS Key for ebs encryption"
  deletion_window_in_days  = 10
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
}

resource "aws_s3_bucket" "log_bucket" {
  bucket = var.bucket_name
}

# resource "aws_s3_bucket_acl" "example_bucket_acl" {
#   bucket = aws_s3_bucket.log_bucket.id
#   acl    = var.acl_value
# }

resource "aws_security_group" "nginx" {
  name   = "nginx_access"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx" {
  ami                         = var.ami
  subnet_id                   = var.subnet_id
  instance_type               = var.machine_type
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.ec2_profile.name

  # root disk
  root_block_device {
    volume_size           = var.boot_disk_size
    volume_type           = "gp2"
    encrypted             = true
    kms_key_id            = aws_kms_key.praveen_key.key_id
    delete_on_termination = true
  }

  # # data disk (Enable if needed)
  # ebs_block_device {
  #   device_name           = "/dev/xvda"
  #   volume_size           = var.data_disk_size
  #   volume_type           = "gp2"
  #   encrypted             = true
  #   kms_key_id            = aws_kms_key.praveen_key.key_id    
  #   delete_on_termination = true
  # }

  tags = {
    Name        = "test-app-nginx"
    Environment = "demo"
  }

  provisioner "remote-exec" {
    inline = ["echo 'Waiting for the machine to be up and ready!'"]

    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
      host        = aws_instance.nginx.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = ["sudo apt update", "sudo apt install python3 -y", "apt install python3-pip -y", "echo Done!"]
    connection {
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.private_key_path)
      host        = aws_instance.nginx.public_ip
    }
  }
  provisioner "local-exec" {
    command = "ansible-playbook  -i ${aws_instance.nginx.public_ip}, --private-key ${var.private_key_path} nginx.yaml"
  }
}

#To Display IP details on completion of job
output "nginx_ip" {
  description = "Please access the application using the following IP"
  value       = aws_instance.nginx.public_ip
}
