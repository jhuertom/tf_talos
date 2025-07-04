terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "~> 0.69"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.5.0"
    }
  }
}

provider "proxmox" {
  endpoint  = var.pve_host_address
  username = var.pve_user
  password = var.pve_password 
  insecure  = true
}