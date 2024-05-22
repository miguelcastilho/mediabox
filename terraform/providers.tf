terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc1"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.31.0"
    }
    random = {
      source = "hashicorp/random"
    }
    ansible ={
      source = "nbering/ansible"
    }
  }
}

provider "proxmox" {
  pm_api_url = var.proxmox_api_url
  pm_api_token_id = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
}

provider "cloudflare" {
    api_token = var.cloudflare_token
}