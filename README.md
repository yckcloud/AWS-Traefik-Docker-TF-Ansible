# Traefik Deployment with Docker-Compose, Cloudflare DNS, Using Terraform and Ansible on AWS
Terraform and Ansible code to deploy traefik on a ec2 instance and configure DNS.

## Prerequisites
- Cloudflare account and domain https://www.cloudflare.com/en-gb/
- AWS account https://aws.amazon.com/
- Terraform https://developer.hashicorp.com/terraform/install
- Ansible https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html
- Make sure existing DNS records don't exist for records we will be creating

## Terraform - Getting Started
Initialize Terraform in folders 'tf/aws' and 'tf/cf'
```bash
cd tf/aws
terraform init

cd ../cf (change to the directory named 'cf' that is one level up from the current directory)
terraform init

or 

cd ..
cd tf/cf
terraform init 
``` 
## Terraform - Setting Variables
I have 4 variable files that i need to configure.

- tf/aws/variables.tf
- tf/aws/secret.tfvars
- tf/cf/variables.tf
- tf/cf/secret.tfvars

### tf/aws/variables.tf
This file defines an AWS key pair for SSH, with sensitive information (such as public keys, region, access key, secret key, and personal SSH key) stored as variables.
The actual sensitive information is not stored directly in this file but in a separate file called secret.tfvars.

 ``` bash
# SSH Key pairs for instances
resource "aws_key_pair" "ssh-key" {
  # The name of the key pair
  key_name   = "example_terraform"
  # The public key value obtained from the variable "var.pubkey"
  public_key = var.pubkey
}

# Variables declaration
variable "pubkey" {
  # Description: The public key value for the SSH key pair
  sensitive = true
}

variable "region" {
  # Description: The AWS region where resources will be created
  sensitive = true
}

variable "accesskey" {
  # Description: The AWS access key for authentication
  sensitive = true
}

variable "secretkey" {
  # Description: The AWS secret key for authentication
  sensitive = true
}

variable "personalssh" {
   # Description: The personal SSH key value
   sensitive = true
}
```
### tf/aws/secret.tfvars
This file is used to store sensitive or confidential information for aws that is required by your Terraform configuration but should not be shared or exposed in your version control system. 

This separation of sensitive data into a secret.tfvars file enhances security by allowing you to share the main Terraform configuration files without exposing confidential information

``` bash
region = "fill with aws region"
accesskey = "fill with access key"
secretkey = "fill with secret key"
personalssh = "fill with personal IP"
pubkey = "fill with public ssh key"
```

### tf/cf/variables.tf
This file defines sensitive variables for an API token, a zone ID, and a Traefik node, indicating that their values should be treated with confidentiality.
```bash
variable "apitoken" {
    # Description: Cloudflare API token for authentication
    sensitive  = true
}

variable "zoneid" {
    # Description: Cloudflare Zone ID
    sensitive  = true
}

variable "traefiknode" {
    # Description: Traefik Node IP for DNS
    sensitive  = true
}

```

### tf/cf/secret.tfvars
This file is used to store sensitive or confidential information for cloudflare that is required by your Terraform configuration but should not be shared or exposed in your version control system. 

This separation of sensitive data into a secret.tfvars file enhances security by allowing you to share the main Terraform configuration files without exposing confidential information

```bash 
apitoken = "fill with cloudflare api token"
zoneid = "fill with cloudflare zone id"
traefiknode = "fill with ec2 node ip"
```
## Terraform - Deployment 
After setting the variables, I executed the Terraform code using the 'plan' and 'apply' command.

The 'terraform plan' command is used to preview the changes that terraform plans to make in the infrastructure and shows a summary of the changes.

The 'terraform apply' command is used to apply the changes proposed in the execution plan, it provides real time feedback on the progress of the changes being applied.

```bash
# Running in aws directory 
cd tf/aws
terraform plan -var-file=secret.tfvars
terraform apply var-file=secret.tfvars

# Running in cf directory
cd tf/cf
terraform plan -var-file=secret.tfvars
terraform apply var-file=secret.tfvars
```
## Ansible - Getting Started
I have a custom inventory file that i use for this ansible playbook instead of the default one. I have called this one 'inventory.ini'
```bash
# Custom ansible inventory file
[awsdockernodes]
ipaddressofnode
[awsdockernodes:vars]
ansible_connection=ssh
ansible_user=nameofsshuser
ansible_ssh_private_key_file=locationofprivatekey
```
Grouping nodes in my Ansible inventory file helps me organize infrastructure logically, simplify configuration, selectively target hosts, execute tasks in parallel, control access based on roles, handle dynamic inventories, and create modular playbooks for efficient and maintainable management.

## Ansible - Templates
In the templates folder located 'ansible/templates' I have two j2 files.

### ansible/templates/traefik.j2
traefik.j2 is my docker-compose file which i will be using. 
```bash

version: '3'

services:
  reverse-proxy:
    image: traefik:v2.10
    command:
      - --api.insecure=false
      - --providers.docker=true
      - --entrypoints.web.address=:80
      - --entrypoints.websecure.address=:443
      - --certificatesresolvers.myresolver.acme.httpchallenge=true
      - --certificatesresolvers.myresolver.acme.httpchallenge.entrypoint=web
      - --certificatesresolvers.myresolver.acme.email=email@outlook.com
      - --certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./letsencrypt:/letsencrypt
      - ./auth/htpasswd:/etc/traefik/.htpasswd
    networks:
      - customnetwork
    labels:
      - "traefik.http.middlewares.auth.basicauth.usersfile=/etc/traefik/.htpasswd"  # Specify the users file
      - "traefik.http.routers.dashboard.middlewares=auth"
      - "traefik.http.routers.dashboard.rule=Host(`traefik.domain.com`)"
      - "traefik.http.routers.dashboard.entrypoints=websecure"
      - "traefik.http.routers.dashboard.tls=true"
      - "traefik.http.routers.dashboard.tls.certresolver=myresolver"
      - "traefik.http.routers.dashboard.service=api@internal"
    

networks:
  customnetwork:
    external: true
```

### ansible/templates/htpasswd.j2
htpasswd.j2 is my password file for traefik.

```bash
administratoruser:encryptedpassword
```

## Ansible - Roles

I use Ansible roles to streamline my automation tasks. They offer a modular, reusable structure that enhances readability and maintenance. With role dependencies, parameterization, and customizable variables, I can easily adapt and reuse roles across different playbooks. This approach not only saves time but also ensures consistency in configurations, making updates and maintenance more efficient.

I have two roles in this playbook one which i called 'dependencies' and one called 'traefik'

### ansible/roles/dependencies/tasks/main.yml
```bash
---
# Update and upgrade packages
- name: Update and upgrade packages
  apt:
    update_cache: yes
    upgrade: yes
    cache_valid_time: 3600

# Install required packages
- name: Install required packages
  apt:
    name: "{{ item }}"
    state: present
  loop:
    - apt-transport-https
    - ca-certificates
    - curl
    - software-properties-common

# Add Docker GPG key
- name: Add Docker GPG key
  shell: >
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg |
    sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
- name: Add Docker repository
  apt_repository:
    repo: "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu {{ ansible_lsb.codename }} stable"
    state: present

# Update apt after adding Docker repository
- name: Update apt after adding Docker repository
  apt:
    update_cache: yes

# Install Docker
- name: Install Docker
  apt:
    name: 
      - docker-ce
      - docker-ce-cli
      - containerd.io
    state: present

# Install Docker Compose
- name: Install Docker Compose
  apt:
    name: docker-compose
    state: present
```
### ansible/roles/traefik/tasks/main.yml
```bash
#Setup Traefik with Docker Compose
  
# Description: Creates the directory /opt/docker/traefik to store Traefik configuration.  
- name: Create directory for Traefik
  file:
    path: /opt/docker/traefik
    state: directory
  become_user: root

 # Description: Creates the directory /opt/docker/traefik/auth to store Traefik password configuration.  
- name: Create directory for Traefik auth
  file:
    path: /opt/docker/traefik/auth
    state: directory
  become_user: root

# Description: Creates the file .htpasswd to store secure password
- name: Create file for Traefik auth password
  file:
    path: /opt/docker/traefik/auth/htpasswd
    state: touch
  become_user: root

# Description: Copies the template file htpasswd.j2 to create the password file for traefik
- name: Copy htpassword.js to .htpasswd
  template:
    src: ./templates/htpasswd.j2
    dest: /opt/docker/traefik/auth/htpasswd

# Description: Copies the template file traefik.j2 to create the Docker Compose configuration file docker-compose.yml in /opt/docker/traefik.
- name: Copy traefik.j2 to docker-compose.yml
  template:
    src: ./templates/traefik.j2
    dest: /opt/docker/traefik/docker-compose.yml
  become_user: root

- name: Create external network
  command: docker network create customnetwork
  become_user: root
  ignore_errors: true

# Description: Runs 'docker-compose up -d' to start Traefik in detached mode, ensuring that the command is executed in the /opt/docker/traefik directory.
- name: Run docker-compose up -d
  command: docker-compose up -d
  become_user: root
  args:
    chdir: /opt/docker/traefik
```

## Ansible - Deployment
In my Ansible playbook, I've configured tasks to run on hosts under the "awsdockernodes" group. I start by executing a role named "dependencies" using the include_role module. This role takes care of installing and configuring necessary dependencies for the system. I capture the result of this role's execution in the dependencies_result variable. Following that, I run another role called "traefik" using the same method. This role is probably responsible for setting up and configuring Traefik, a popular reverse proxy and load balancer. The outcome of this role is stored in the traefik_result variable. This sequential execution of roles allows me to modularly manage the configuration of my infrastructure on AWS Docker nodes.
```bash
---
- hosts: awsdockernodes
  become: true
  gather_facts: true
  order: sorted

  tasks:

    - name: Execute dependencies role
      include_role:
        name: dependencies
      vars:
      register: dependencies_result

    - name: Execute traefik role
      include_role:
        name: traefik
      vars:
      register: traefik_result
  ```

After configuring template files and inventory files and adjusting my roles to suit my environment, I run the ansible using
```bash
ansible-playbook -i inventory.ini master.yml
```

Thanks for reading and hopefully you can take something away from this! 

Note: Feel free to add additional steps to create dedicated user and secure ec2 even further by implementing additional security measures using iptables!
