output "terraform_ec2_instance" {
  value = aws_instance.terraform_ec2_instance.public_ip
}

output "instance_public_dns" {
  value = aws_instance.terraform_ec2_instance.public_dns
}

output "instance_id" {
  value = aws_instance.terraform_ec2_instance.id
  }