#A record for "www.traefik.DOMAIN.com"
resource "cloudflare_record" "example" {
  allow_overwrite = "true"
  zone_id = var.zoneid 
  name    = "traefik"
  value   = var.traefiknode
  type    = "A"
  ttl     = "1" 
  proxied = "true" #allows you to route your website's traffic through Cloudflare's global network, providing various benefits such as improved performance, security, and reliability.
}

#A record for root "DOMAIN.com"
resource "cloudflare_record" "example1" {
  allow_overwrite = "true"
  zone_id = var.zoneid 
  name    = "@"
  value   = var.traefiknode 
  type    = "A"
  ttl     = "1" 
  proxied = "true" #allows you to route your website's traffic through Cloudflare's global network, providing various benefits such as improved performance, security, and reliability.
}