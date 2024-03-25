
resource "aws_vpc" "vpc1" {
 cidr_block = "192.168.0.0/16" 
 instance_tenancy = "default"
 tags = {
    Name = "Terraform-vpc"
    env = "dev"
    Team = "DevOps"
 }
}
resource "aws_internet_gateway" "gwy1" {
  vpc_id = aws_vpc.vpc1.id
}

resource "aws_subnet" "public1" {
    availability_zone = "us-east-1a"
    cidr_block = "192.168.1.0/24"
    map_public_ip_on_launch = true
    vpc_id = aws_vpc.vpc1.id
    tags={
        Name = "public-subnet-1"
        env = "dev"
        map_public_ip_on_launch = true
    }

  
}
resource "aws_subnet" "public2" {
    availability_zone = "us-east-1b"
    cidr_block = "192.168.2.0/24"
    vpc_id = aws_vpc.vpc1.id
    map_public_ip_on_launch = true
    tags={
        Name = "public-subnet-2"
        env = "dev"
        map_public_ip_on_launch = true
    }
  
}


resource "aws_subnet" "private1" {
    availability_zone = "us-east-1a"
    cidr_block = "192.168.3.0/24"
    vpc_id = aws_vpc.vpc1.id
    tags={
        Name = "private-subnet-1"
        env = "dev"
    } 
}
resource "aws_subnet" "private2" {
    availability_zone = "us-east-1b"
    cidr_block = "192.168.4.0/24"
    vpc_id = aws_vpc.vpc1.id
    tags={
        Name = "private-subnet-2"
        env = "dev"
    }
  
}

resource "aws_eip" "eip" {
  
}
resource "aws_nat_gateway" "nat1" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.public1.id
}


resource "aws_route_table" "rtpublic" {
 vpc_id = aws_vpc.vpc1.id 
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gwy1.id
 }
}



resource "aws_route_table" "rtprivate" {
 vpc_id = aws_vpc.vpc1.id 
 route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat1.id
 }
}



resource "aws_route_table_association" "rta1" {
  subnet_id = aws_subnet.private1.id
  route_table_id = aws_route_table.rtprivate.id
}
resource "aws_route_table_association" "rta2" {
  subnet_id = aws_subnet.private2.id
  route_table_id = aws_route_table.rtprivate.id
}

resource "aws_route_table_association" "rta3" {
  subnet_id = aws_subnet.public1.id
  route_table_id = aws_route_table.rtpublic.id
}
resource "aws_route_table_association" "rta4" {
  subnet_id = aws_subnet.public2.id
  route_table_id = aws_route_table.rtpublic.id
}







resource "aws_security_group" "sg1" {
    name = "sg1"
    description = "Allow ssh and httpd"
    vpc_id = aws_vpc.vpc1.id
    
    
    ingress {
        description = "allow http"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        #cidr_blocks = ["0.0.0.0/0"]
      
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  tags= {
    env = "Dev"
    created-by-terraform = "yes"
  }

  
}
resource "aws_security_group" "sg2" {
    name = "Terraform-sg-lb"
    description = "Allow ssh and httpd"
    vpc_id = aws_vpc.vpc1.id
    
    ingress {
        description = "allow http"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
  tags= {
    env = "Dev"
  } 
}



resource "aws_instance" "server1" {
  ami = "ami-02d7fd1c2af6eead0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.sg1.id ]
  availability_zone = "us-east-1a"
  subnet_id = aws_subnet.private1.id
  user_data = file("code.sh")
  tags={
    Name = "webserver-1"
  }

}
resource "aws_instance" "server2" {
  ami = "ami-02d7fd1c2af6eead0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.sg1.id ]
  availability_zone = "us-east-1b"
  subnet_id = aws_subnet.private2.id
  user_data = file("code.sh")
  tags={
    Name = "webserver-2"
  }

}

