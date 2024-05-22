variable "cloudflare_zone_id" {
  description = "Zone ID of your domain"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Account ID for your Cloudflare account"
  type        = string
  sensitive   = true
}

variable "cloudflare_tunnel_name" {
  description = "Name for cloudflare tunnel"
  type        = string
  default     = "Terraform mediabox tunnel"
}

variable "cloudflare_token" {
  description = "Cloudflare API token created at https://dash.cloudflare.com/profile/api-tokens"
  type        = string
  sensitive   = true
}

variable "proxmox_ip_address" {
  description = "proxmox ip address"
  type        = string
}

variable "proxmox_api_url" {
  description = "proxmox api url"
  type        = string
}

variable "proxmox_api_token_id" {
  description = "proxmox api token id"
  type        = string
  sensitive   = true
}

variable "proxmox_api_token_secret" {
  description = "proxmox api token secret"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "SSH public key for VMs"
  type        = string
}

variable "lxc_base_image" {
  description = "template to clone"
  type        = string
  default     = "local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst"
}

variable "vm_base_image" {
  description = "Base image for VM cloning"
  type        = string
  default     = "ubuntu-noble-server-cloud"
}

variable "ansible_inventory" {
  description = "Ansible inventory file path"
  type        = string
  default     = "../ansible/inventory/hosts.yml"
}

variable "ansible_requirements" {
  description = "Ansible requirements file path"
  type        = string
  default     = "../ansible/requirements.yml"
}

variable "ansible_playbooks" {
  description = "Mapping of VM names to their respective Ansible playbooks"
  type        = map(string)
  default     = {
    adguard  = "../ansible/adguard.yml"
    mediabox = "../ansible/mediabox.yml"
    tailscale = "../ansible/tailscale.yml"
    uptime_kuma = "../ansible/uptime_kuma.yml"
  }
}