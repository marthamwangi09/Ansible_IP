resource "aws_key_pair" "key_pair" {
  key_name   = "host1-key"
  public_key = var.public_key  # Update the key in the.tfvars file
}

# Create a security group
resource "aws_security_group" "web_security_group" {
  name        = "web_security_group"
  description = "Security group for web access"

  ingress {
    from_port   = 22  # SSH
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH access from anywhere
  }

  ingress {
    from_port   = 3000  # HTTP
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow Frontend App access from anywhere
  }

  ingress {
    from_port   = 5000  # HTTP
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow Backend App access from anywhere
  }

  ingress {
    from_port   = 27017  # HTTP
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow Database access from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch an EC2 instance
resource "aws_instance" "the_instance" {
  ami           = "ami-016b30666f212275a"  # Change this to your desired AMI ID
  instance_type = "t3.micro"  # Change this to your desired instance type

  key_name      = aws_key_pair.key_pair.key_name

  vpc_security_group_ids = [aws_security_group.web_security_group.name]

  tags = {
    Name = "Ansible-1"
  }

  #ass
  provisioner "local-exec" {
    command = <<-EOT
      echo "host1 ansible_host=${aws_instance.the_instance.public_dns}" >> /etc/ansible/hosts
    EOT
  }

  lifecycle {
    ignore_changes = [
      key_name,
    ]
  }
}
