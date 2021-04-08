
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
  name        = "${var.environment}-sg-ssh"
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

resource "aws_security_group" "web-access" {
  name        = "${var.environment}-sg-web"
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

resource "aws_security_group" "winrm-access" {
  name        = "${var.environment}-sg-win"
  description = "winrm (ports 5985 5986) and rdp(3389) access"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port   = "5985"
    to_port     = "5985"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "5986"
    to_port     = "5986"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = "3389"
    to_port     = "3389"
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
    Name        = "${var.environment}-sg-winrm"
  }
}


resource "aws_security_group" "smb-access" {
  name        = "${var.environment}-sg-smb"
  description = "smb (137-139) access"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port   = "137"
    to_port     = "137"
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  ingress {
    from_port   = "138"
    to_port     = "138"
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  ingress {
    from_port   = "139"
    to_port     = "139"
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  ingress {
    from_port   = "445"
    to_port     = "445"
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.vpc.cidr_block]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Environment = var.environment
    Name        = "${var.environment}-sg-smb"
  }
}


// EC2 instance - LAMP
resource "aws_instance" "lamp" {
  count                  = var.number_of_instances
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  subnet_id              = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.ssh-access.id, aws_security_group.web-access.id, aws_security_group.smb-access.id]
  tags = {
    Name        = "${var.environment}-lamp"
    Environment = var.environment
  }
  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> ../ansible/lamp"
  }
  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> ../ansible/logs"
  }
  lifecycle {
    create_before_destroy = true
  }
}

// EC2 instance - Windows Server 2019
resource "aws_instance" "win_server_2019" {
  ami                    = var.win_ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  get_password_data      = true
  subnet_id              = aws_subnet.public_subnet[0].id
  vpc_security_group_ids = [aws_security_group.winrm-access.id]
  user_data              = <<EOF
  <powershell>
  $url = "https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1"
  $file = "$env:temp\ConfigureRemotingForAnsible.ps1"
  (New-Object -TypeName System.Net.WebClient).DownloadFile($url, $file)
  powershell.exe -ExecutionPolicy ByPass -File $file
  </powershell>
  EOF

  provisioner "local-exec" {
    command = "echo ${self.public_ip} >> ../ansible/winserver"
  }

  provisioner "local-exec" {
    command = "echo '${rsadecrypt(self.password_data, file(var.key_path))}' >> ../outputs/Administrator_password"
  }
  tags = {
    Name        = "${var.environment}-win_server_2019"
    Environment = var.environment
  }
  lifecycle {
    create_before_destroy = true
  }
}

# Load balancer and stickiness policy
resource "aws_elb" "lb" {
  subnets                   = aws_subnet.public_subnet.*.id
  security_groups           = [aws_security_group.web-access.id]
  instances                 = aws_instance.lamp.*.id
  cross_zone_load_balancing = true

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    target              = "HTTP:80/"
    interval            = 300
  }
}

resource "aws_lb_cookie_stickiness_policy" "lb-stickiness" {
  name                     = "lb-policy"
  load_balancer            = aws_elb.lb.id
  lb_port                  = 80
  cookie_expiration_period = 600
}
