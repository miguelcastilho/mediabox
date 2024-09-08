######### Cloudflared
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





######### AdGuard
resource "proxmox_lxc" "adguard" {
  target_node   = var.adguard_node
  vmid          = var.adguard_vm_id
  hostname      = var.adguard_hostname
  ostemplate    = var.lxc_base_image
  unprivileged  = true
  rootfs {
    storage = var.adguard_storage
    size    = var.adguard_storage_size
  }
  cores         = var.adguard_cores
  memory        = var.adguard_memory
  network {
    name    = "eth0"
    bridge  = "vmbr0"
    gw      = var.gateway_ip_address
    ip      = "${var.adguard_ip_address}${var.netmask}"
  }
  ssh_public_keys = var.ssh_public_key
  onboot          = true
  start           = true

  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbooks.adguard} --vault-password-file .vault_pass.txt"
  }
}

# Create the DNS record
resource "cloudflare_record" "adguard" {
  zone_id = var.cloudflare_zone_id
  name    = var.adguard_hostname
  value   = var.adguard_ip_address
  type    = "A"
  proxied = false
}




###### Tailscale
resource "tailscale_tailnet_key" "tailscale_key" {
  reusable      = true
  ephemeral     = true
  preauthorized = true
  description   = "terraform"
  recreate_if_invalid = "always"
}

resource "proxmox_lxc" "tailscale" {
  target_node   = var.tailscale_node
  vmid          = var.tailscale_vm_id
  hostname      = var.tailscale_hostname
  ostemplate    = var.lxc_base_image
  unprivileged  = true
  rootfs {
    storage = var.tailscale_storage
    size    = var.tailscale_storage_size
  }
  cores         = var.tailscale_cores
  memory        = var.tailscale_memory
  network {
    name    = "eth0"
    bridge  = "vmbr0"
    gw      = var.gateway_ip_address
    ip      = "${var.tailscale_ip_address}${var.netmask}"
  }
  ssh_public_keys = var.ssh_public_key
  onboot          = true
  start           = true

  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbooks.tailscale} --vault-password-file .vault_pass.txt"
  }
}






##### Uptime Kuma

resource "proxmox_lxc" "uptime_kuma" {
  target_node   = var.uptimekuma_node
  vmid          = var.uptimekuma_vm_id
  hostname      = var.uptimekuma_hostname
  ostemplate    = var.lxc_base_image
  unprivileged  = true
  rootfs {
    storage = var.uptimekuma_storage
    size    = var.uptimekuma_storage_size
  }
  cores         = var.uptimekuma_cores
  memory        = var.uptimekuma_memory
  network {
    name    = "eth0"
    bridge  = "vmbr0"
    gw      = var.gateway_ip_address
    ip      = "${var.uptimekuma_ip_address}${var.netmask}"
  }
  ssh_public_keys = var.ssh_public_key
  onboot          = true
  start           = true

  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbooks.uptime_kuma} --vault-password-file .vault_pass.txt"
  }
}

# Create the DNS record
resource "cloudflare_record" "uptime_kuma" {
  zone_id = var.cloudflare_zone_id
  name    = var.uptimekuma_hostname
  value   = var.uptimekuma_ip_address
  type    = "A"
  proxied = false
}





##### Mediabox
resource "proxmox_vm_qemu" "mediabox" {
  target_node              = var.mediabox_node
  vmid                     = var.mediabox_vm_id
  name                     = var.mediabox_hostname
  clone                    = var.mediabox_vm_base_image
  agent                    = 1
  os_type                  = "cloud-init"
  cloudinit_cdrom_storage  = var.mediabox_storage
  cores                    = var.mediabox_cores
  sockets                  = var.mediabox_sockets
  cpu                      = "host"
  numa                     = false
  memory                   = var.mediabox_memory
  balloon                  = var.mediabox_memory
  scsihw                   = "virtio-scsi-pci"
  bootdisk                 = "scsi0"
  onboot                   = true
  full_clone               = false
  disks {
    scsi {
      scsi0 {
        disk {
          size    = var.mediabox_storage_size
          storage = var.mediabox_storage
          backup  = true
          discard = true
        }
      }
    }
  }
  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
  ipconfig0 = "ip=${var.mediabox_ip_address}${var.netmask},gw=${var.gateway_ip_address}"
  sshkeys   = var.ssh_public_key

  provisioner "local-exec" {
    command = "ansible-galaxy install -r ${var.ansible_requirements}"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbooks.mediabox} --vault-password-file .vault_pass.txt"
  }
}

# Create the DNS record
resource "cloudflare_record" "casaos" {
  zone_id = var.cloudflare_zone_id
  name    = var.casaos_dns_name
  value   = var.casaos_ip_address
  type    = "A"
  proxied = false
}

# Creates DNS records
resource "cloudflare_record" "pve" {
  zone_id = var.cloudflare_zone_id
  name    = var.proxmox_name
  value   = var.proxmox_ip_address
  type    = "A"
  proxied = false
}



