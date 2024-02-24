# Define a security group for Docker-Traefik
resource "aws_security_group" "docker-traefik" {
    name = "docker-traefik-sg"
    description = "group for docker-traefik node"
    
    # Associate the security group with the specified VPC
    vpc_id = aws_vpc.example-vpc.id

    # Define ingress rules to allow traffic into the security group

    # Rule: Allow SSH from home 
    ingress {
        description = "Allow SSH from home"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.personalssh]
    }

    # Rule: Allow HTTP (Port 80) from anywhere
    ingress {
        description = "Allow 80 from anywhere"
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Rule: Allow HTTPS (Port 443) from anywhere
    ingress {
        description = "Allow 443 from anywhere"
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    # Define egress rules to allow traffic to leave the security group
    
    # Rule: Allow all outbound traffic
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
