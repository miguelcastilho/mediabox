terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "3.0.1-rc4"
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
    tailscale = {
      source = "tailscale/tailscale"
      version = "0.17.2"
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

provider "tailscale" {
  api_key = "tskey-api-k5t268bpQ421CNTRL-PCDgoMHYWKj75khFsg1uSjS7qWPUDzrWQ"
  tailnet = "tail689fb.ts.net"
}