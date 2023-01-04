
provider "aws" {
  region = "eu-west-2"
}

resource "aws_kms_key" "praveen_key" {
  description              = "KMS Key for ebs encryption"
  deletion_window_in_days  = 10
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
}


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
  instance_type               = "t2.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nginx.id]
  key_name                    = var.key_name

  # root disk
  root_block_device {
    volume_size           = "20"
    volume_type           = "gp2"
    encrypted             = true
    kms_key_id            = aws_kms_key.praveen_key.key_id      
    delete_on_termination = true
  }

  # # data disk (Enable if needed)
  # ebs_block_device {
  #   device_name           = "/dev/xvda"
  #   volume_size           = "50"
  #   volume_type           = "gp2"
  #   encrypted             = true
  #   kms_key_id            = aws_kms_key.praveen_key.key_id    
  #   delete_on_termination = true
  # }
  
  tags = {
    Name        = "test-app-nginx"
    Environment = "dev"
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

output "nginx_ip" {
  value = aws_instance.nginx.public_ip
}
