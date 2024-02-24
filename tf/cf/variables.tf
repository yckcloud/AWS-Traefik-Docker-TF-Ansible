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
