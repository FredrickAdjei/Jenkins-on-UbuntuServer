resource "aws_instance" "jenkins" {
    ami = data.aws_ami.ubuntu.id
    instance_type = var.ec2type
    subnet_id = aws_subnet.mainsub["10.0.1.0/24"].id 
    vpc_security_group_ids = [aws_security_group.jenans.id]
    key_name = "mabr3"




    provisioner "remote-exec" {
        inline = [
        "sudo yum install -y jenkins java-11-openjdk-devel",
        "sudo yum -y install wget",
        "sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo",
        "sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key",
        "sudo yum upgrade -y",
        "sudo yum install jenkins -y",
        "sudo systemctl start jenkins",
        "sudo yum update -y",
        "sudo apt install ansible",
        ]


    connection {
        type        = "ssh"
        host        = self.private_ip
        user        = "root"
        private_key = file("./mabr3.pem")
        }

    }

  
}


resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr
  
}



data "aws_ami" "ubuntu" {
    most_recent = true
    owners = [ "amazon" ]
  
  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]

  }
}

locals {
  inbound_ports = [22,80,443]
  outbound_ports = [22,80,443]

}


resource "aws_security_group" "jenans" {
    name = "lockeddown"
    description = "yepo"
    vpc_id = aws_vpc.vpc.id


    dynamic "ingress" {
        for_each = local.inbound_ports
        content {
            from_port = ingress.value
            to_port = ingress.value
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
          
        }

    }
    
    dynamic "egress" {
        for_each = [0]
        content{
            from_port = 0
            to_port = 0
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
        }
    }
 
    }

  
resource "aws_subnet" "mainsub" {
    for_each = toset(var.vpc_subnets)
    cidr_block = each.value
    vpc_id = aws_vpc.vpc.id
  
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

   tags = {
    Name = "InternetGateway"
  }
  
  }

  
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

}


resource "aws_route" "rut" {
  route_table_id = aws_route_table.rtb.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
  
}


resource "aws_route_table_association" "publicroute" {
  subnet_id = aws_subnet.mainsub["10.0.1.0/24"].id 
  route_table_id = aws_route_table.rtb.id

  
}

locals {
  suney =
}