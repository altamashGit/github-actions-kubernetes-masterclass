resource "aws_key_pair" "terraform_key_pair" {
    key_name   = "local_key_pair"
    public_key = file(var.key_path)
}

resource "aws_security_group" "terraform_ec2_sg" {
    name       = "terraform-ec2-sg"
    description = "Security group for Terraform EC2 instance"

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
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

}


resource "aws_instance" "terraform_ec2_instance" {
    count             = var.server_count
    ami               = var.ami_id
    instance_type     = var.instace_type
    key_name          = aws_key_pair.terraform_key_pair.key_name
    vpc_security_group_ids = [aws_security_group.terraform_ec2_sg.id]

    user_data = file("user_data.sh")
    
  root_block_device {
        volume_size = var.volume_size
        volume_type = "gp2"
  }
    tags = {
        Name = "${var.instance_name}-${count.index + 1}"
    } 
}