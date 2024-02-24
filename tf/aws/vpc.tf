# Create a Virtual Private Cloud (VPC)
resource "aws_vpc" "example-vpc" {
    cidr_block  =   "10.0.0.0/16"
    enable_dns_support = true
    enable_dns_hostnames = true
    
    # Add tags to identify and label the VPC
    tags = {
        Name = "example-vpc"
    }
}

# Create an Internet Gateway (IGW) and associate it with the VPC
resource "aws_internet_gateway" "example-igw" {
    vpc_id = aws_vpc.example-vpc.id
}

# Create a Subnet within the VPC
resource "aws_subnet" "example-subnet" {
    vpc_id = aws_vpc.example-vpc.id
    cidr_block = "10.0.1.0/24"
}

# Create a Route Table for routing traffic within the VPC
resource "aws_route_table" "example-routing" {
    vpc_id = aws_vpc.example-vpc.id
    
    # Define a default route to the Internet Gateway for outbound traffic
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.example-igw.id
    }
    
    # Add tags to identify and label the Route Table
    tags = {
      Name = "example-routing"
    }
}

# Set the default route table for the VPC
resource "aws_main_route_table_association" "example-mainroutetable" {
    vpc_id = aws_vpc.example-vpc.id
    route_table_id = aws_route_table.example-routing.id
}
