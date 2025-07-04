###################################################
# DEFINE VARS
###################################################
locals {
  talos = {
    version = "v1.10.4"
  }
  talos_nodes = ["jacinta", "antonio", "roman"]
  cluster_name = "homelab"
  talos_gateway = "192.168.2.1"
  talos_vms = {
    talos_cp_01 = {
      name       = "talos-cp-01"
      role       = "controlplane"
      node       = "jacinta"
      ip_addr    = "192.168.2.180"
      cores      = 2
      memory     = 4096
      disk_size  = 20
    }
    talos_worker_01 = {
      name       = "talos-worker-01"
      role       = "worker"
      node       = "jacinta"
      ip_addr    = "192.168.2.190"
      cores      = 4
      memory     = 4096
      disk_size  = 20
    }
    talos_cp_02 = {
      name       = "talos-cp-02"
      role       = "controlplane"
      node       = "roman"
      ip_addr    = "192.168.2.181"
      cores      = 2
      memory     = 4096
      disk_size  = 20
    }
    talos_worker_02 = {
      name       = "talos-worker-02"
      role       = "worker"
      node       = "roman"
      ip_addr    = "192.168.2.191"
      cores      = 4
      memory     = 4096
      disk_size  = 20
    }
    talos_cp_03 = {
      name       = "talos-cp-03"
      role       = "controlplane"
      node       = "antonio"
      ip_addr    = "192.168.2.182"
      cores      = 2
      memory     = 4096
      disk_size  = 20
    }
    talos_worker_03 = {
      name       = "talos-worker-03"
      role       = "worker"
      node       = "antonio"
      ip_addr    = "192.168.2.192"
      cores      = 4
      memory     = 4096
      disk_size  = 20
    }
  }
}

variable "pve_host_address" {
  type = string
}
variable "pve_user" {
  type = string
}
variable "pve_password" {
  type = string
}