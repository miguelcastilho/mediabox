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
     service  = "http://jellyseerr:5055"
   }
   ingress_rule {
     hostname = "${cloudflare_record.jellyfin.hostname}"
     service  = "http://jellyfin:8096"
   }
   ingress_rule {
     hostname = "${cloudflare_record.homeassistant.hostname}"
     service  = "http://homeassistant:8123"
   }
   ingress_rule {
     service  = "http_status:404"
   }
  }
}

# Create LXC containers
resource "proxmox_lxc" "adguard" {
  target_node   = "desktop"
  vmid          = 100
  hostname      = "adguard"
  ostemplate    = var.lxc_base_image
  unprivileged  = true
  rootfs {
    storage = "local-lvm"
    size    = "2G"
  }
  cores         = 1
  memory        = 256
  network {
    name    = "eth0"
    bridge  = "vmbr0"
    gw      = "192.168.1.1"
    ip      = "192.168.1.100/24"
  }
  ssh_public_keys = var.ssh_public_key
  onboot          = true
  start           = true

  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbooks.adguard} --vault-password-file .vault_pass.txt"
  }
}

resource "proxmox_lxc" "tailscale" {
  target_node   = "desktop"
  vmid          = 102
  hostname      = "tailscale"
  ostemplate    = var.lxc_base_image
  unprivileged  = true
  rootfs {
    storage = "local-lvm"
    size    = "2G"
  }
  cores         = 1
  memory        = 128
  network {
    name    = "eth0"
    bridge  = "vmbr0"
    gw      = "192.168.1.1"
    ip      = "192.168.1.102/24"
  }
  ssh_public_keys = var.ssh_public_key
  onboot          = true
  start           = true

  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbooks.tailscale} --vault-password-file .vault_pass.txt"
  }
}

resource "proxmox_lxc" "uptime_kuma" {
  target_node   = "desktop"
  vmid          = 103
  hostname      = "uptime-kuma"
  ostemplate    = var.lxc_base_image
  unprivileged  = true
  rootfs {
    storage = "local-lvm"
    size    = "3G"
  }
  cores         = 1
  memory        = 512
  network {
    name    = "eth0"
    bridge  = "vmbr0"
    gw      = "192.168.1.1"
    ip      = "192.168.1.103/24"
  }
  ssh_public_keys = var.ssh_public_key
  onboot          = true
  start           = true

  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbooks.uptime_kuma} --vault-password-file .vault_pass.txt"
  }
}

# Create VMs
resource "proxmox_vm_qemu" "mediabox" {
  target_node              = "desktop"
  vmid                     = 101
  name                     = "mediabox"
  clone                    = var.vm_base_image
  agent                    = 1
  os_type                  = "cloud-init"
  cloudinit_cdrom_storage  = "local-lvm"
  cores                    = 1
  sockets                  = 4
  cpu                      = "host"
  numa                     = false
  memory                   = 32768
  balloon                  = 32768
  scsihw                   = "virtio-scsi-pci"
  bootdisk                 = "scsi0"
  onboot                   = true
  full_clone               = false
  disks {
    scsi {
      scsi0 {
        disk {
          size    = 50
          storage = "local-lvm"
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
  ipconfig0 = "ip=192.168.1.101/24,gw=192.168.1.1"
  sshkeys   = var.ssh_public_key

  provisioner "local-exec" {
    command = "ansible-galaxy install -r ${var.ansible_requirements}"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i ${var.ansible_inventory} ${var.ansible_playbooks.mediabox} --vault-password-file .vault_pass.txt"
  }
}

# Creates DNS records
resource "cloudflare_record" "pve" {
  zone_id = var.cloudflare_zone_id
  name    = "pve"
  value   = "${var.proxmox_ip_address}"
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "adguard" {
  zone_id = var.cloudflare_zone_id
  name    = "adguard"
  value   = "192.168.1.100" # Can't retrieve the value directly from the lxc. The lxc does not export values
  type    = "A"
  proxied = false
}

resource "cloudflare_record" "casaos" {
  zone_id = var.cloudflare_zone_id
  name    = "casaos"
  value   = "${proxmox_vm_qemu.mediabox.default_ipv4_address}"
  type    = "A"
  proxied = false
}