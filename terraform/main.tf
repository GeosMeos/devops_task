
data "aws_availability_zones" "available" {}

//VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  }
}

// Internet gateway for the public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

// Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name        = "${var.environment}-nat_eip"
    Environment = var.environment
  }
}

// NAT
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name        = "${var.environment}-nat"
    Environment = var.environment
  }
}

// Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.environment}-public-subnet-${count.index}"
    Environment = var.environment
    Type        = "Public"
  }
}

// Private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name        = "${var.environment}-private-subnet-${count.index}"
    Environment = var.environment
    Type        = "Private"
  }
}

// Routing table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-private-route-table"
    Environment = var.environment
  }
}

// Routing table for public subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = var.environment
  }
}
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

// Route table associations
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

// Security groups
resource "aws_security_group" "ssh-access" {
  name        = "${var.environment}-sg"
  description = "SSH (port 22) access"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = var.environment
    Name        = "${var.environment}-sg-ssh"
  }
}

// Security groups
resource "aws_security_group" "web-access" {
  name        = "${var.environment}-sg"
  description = "web (port 80) access"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = var.environment
    Name        = "${var.environment}-sg-web"
  }
}

// EC2 instance - LAMP
resource "aws_instance" "lamp" {
  count                  = length(var.public_subnets_cidr)
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = element(aws_subnet.public_subnet.*.id, count.index)
  vpc_security_group_ids = [aws_security_group.ssh-access.id, aws_security_group.web-access.id]
  tags = {
    Name        = "${var.environment}-lamp"
    Environment = var.environment
  }
  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> ../ansible/hosts"
  }
  /*
  provisioner "local-exec" {
    command = <<EOF
    sleep 120;
    ssh -o StrictHostKeyChecking=no -i ${var.key_path} ubuntu@${aws_instance.lamp.*.public_ip} sudo apt-get install python -y;
    ansible-playbook -i ansible/hosts ansible/roles/lamp.yaml
    EOF
  }
*/
}

// EC2 instance - Windows Server 2019
resource "aws_instance" "win_server_2019" {
  ami                    = var.win_ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  get_password_data      = true
  subnet_id              = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.ssh-access.id]
  tags = {
    Name        = "${var.environment}-win_server_2019"
    Environment = var.environment
  }
}
