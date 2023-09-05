variable "ec2type" {
    type = list
    default = ["t2.micro","t3.medium"]
  
}

variable "vpc_cidr" {
    default = "10.0.0.0/16"
}


variable "vpc_subnets" {
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}