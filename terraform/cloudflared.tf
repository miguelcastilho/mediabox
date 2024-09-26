# Generates a 64-character secret for the cloudflared tunnel.
resource "random_id" "tunnel_secret" {
  byte_length = 64
}

# Creates a new locally-managed cloudflared tunnel
resource "cloudflare_tunnel" "mediabox" {
  account_id = var.cloudflare_account_id
  name       = var.cloudflare_tunnel_name
  secret     = random_id.tunnel_secret.b64_std
}

# Creates the CNAME records to route to the tunnel
resource "cloudflare_record" "jellyseerr" {
  zone_id = var.cloudflare_zone_id
  name    = "jellyseerr"
  value   = "${cloudflare_tunnel.mediabox.cname}"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "jellyfin" {
  zone_id = var.cloudflare_zone_id
  name    = "jellyfin"
  value   = "${cloudflare_tunnel.mediabox.cname}"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "homeassistant" {
  zone_id = var.cloudflare_zone_id
  name    = "homeassistant"
  value   = "${cloudflare_tunnel.mediabox.cname}"
  type    = "CNAME"
  proxied = true
}

# Creates the configuration for the tunnel.
resource "cloudflare_tunnel_config" "mediabox" {
  tunnel_id = cloudflare_tunnel.mediabox.id
  account_id = var.cloudflare_account_id
  config {
   ingress_rule {
     hostname = "${cloudflare_record.jellyseerr.hostname}"
     service  = "http://${var.mediabox_ip_address}:5055"
   }
   ingress_rule {
     hostname = "${cloudflare_record.jellyfin.hostname}"
     service  = "http://${var.mediabox_ip_address}:8096"
   }
   ingress_rule {
     hostname = "${cloudflare_record.homeassistant.hostname}"
     service  = "http://${var.mediabox_ip_address}:8123"
   }
   ingress_rule {
     service  = "http_status:404"
   }
  }
}

# Create the DNS records
resource "cloudflare_record" "adguard" {
  zone_id = var.cloudflare_zone_id
  name    = var.adguard_hostname
  value   = var.adguard_ip_address
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "uptime_kuma" {
  zone_id = var.cloudflare_zone_id
  name    = var.uptimekuma_dns
  value   = var.uptimekuma_ip_address
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "casaos" {
  zone_id = var.cloudflare_zone_id
  name    = var.casaos_dns_name
  value   = var.casaos_ip_address
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "pve" {
  zone_id = var.cloudflare_zone_id
  name    = var.proxmox_name
  value   = var.proxmox_ip_address
  type    = "A"
  proxied = false
}
