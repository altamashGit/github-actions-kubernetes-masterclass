variable "aws_region" {
    description = "The AWs region to deploy the ec2 instance"
    type = string
    default = "ap-south-1"
}

variable "instace_type" {
    description = "The type of instance to start"
    type        = string
    default     = "t2.medium"  
}

variable "ami_id" {
    description = "The AMI ID to use for the instance"
    type        = string
    default     = "ami-09ed39e30153c3bf9"
  
}

# variable "key_name" {
#   default = "hackathon-key"
# }

# variable "key_path" {
#     description = "The path to the SSH key pair for accessing the instance"
#     type        = string
#     default     = "/c/Users/altam/github-actions-kubernetes-masterclass/hackathon.pub"  
# }

variable "server_count" {
    description = "The number of instances to create"
    type        = number
    default     = 1
  
}


variable "instance_name" {
    description = "The name to assign to the instance"
    type        = string
    default     = "Terraform-EC2-Instance"
  
}

variable "volume_size" {
    description = "The size of the EBS volume in GB"
    type        = number
    default     = 30
}