provider "aws" {
  region     = "us-east-1"
  access_key = vars.aws_access_key
  secret_key = vars.aws_secret_key
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "myfirstVPC"
  }
}

resource "aws_subnet" "my_public_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  availability_zone       = "us-east-1a"
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_IGW"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.my_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Add a variable for the key pair if not already defined.
variable "key_name" {
  description = "Name of the EC2 Key Pair to enable SSH access."
  type        = string
}

# Create an EC2 instance in the public subnet.
resource "aws_instance" "my_ec2" {
  ami                         = "ami-0c55b159cbfafe1f0" # Replace with a valid AMI for your region.
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.my_public_subnet.id
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name = "MyEC2Instance"
  }
}

# Optional output to easily retrieve the instance details.
output "ec2_instance_id" {
  description = "The ID of the EC2 instance."
  value       = aws_instance.my_ec2.id
}

output "ec2_public_ip" {
  description = "The public IP address of the EC2 instance."
  value       = aws_instance.my_ec2.public_ip
}
