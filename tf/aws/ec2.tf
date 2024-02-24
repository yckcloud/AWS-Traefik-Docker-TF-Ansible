# Define an AWS EC2 instance for the server - Node1
resource "aws_instance" "node1" {
  # Specify the Amazon Machine Image (AMI) for the instance (Ubuntu on free tier)
  ami                         = "ami-0e5f882be1900e43b"

  # Specify the instance type (t2.micro for free tier)
  instance_type               = "t2.micro"

  # Specify the key pair for SSH access
  key_name                    = aws_key_pair.ssh-key.key_name

  # Associate a public IP address with the instance
  associate_public_ip_address = true

  # Specify the subnet in which the instance will be launched
  subnet_id                   = aws_subnet.example-subnet.id

  # Specify the security group(s) associated with the instance
  vpc_security_group_ids      = [aws_security_group.docker-traefik.id]

  # Add tags to identify and label the EC2 instance
  tags = {
    Name = "example-node1"
  }
}
