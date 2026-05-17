output "instance_public_ips" {
  value = aws_instance.terraform_ec2_instance.public_ip
}

output "instance_public_dns" {
  value = aws_instance.my_instance.public_dns
}

output "instance_id" {
  value = aws_instance.my_instance.id
  }