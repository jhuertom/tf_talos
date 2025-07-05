###################################################
# DEFINE VARS
###################################################
locals {
  talos = {
    version = "v1.10.4"
  }
  talos_nodes = ["jacinta", "antonio", "roman"]
  talos_gateway = "192.168.2.1"
  talos_dns = "192.168.3.10"
  cluster_name = "homelab"

  talos_config = {
    talos_vms = {
      talos_cp_01 = {
        name       = "talos-cp-01"
        role       = "controlplane"
        node       = "jacinta"
        ip_addr    = "192.168.3.40"
        cores      = 2
        memory     = 4096
        disk_size  = 20
      }
      talos_worker_01 = {
        name       = "talos-worker-01"
        role       = "worker"
        node       = "jacinta"
        ip_addr    = "192.168.3.50"
        cores      = 4
        memory     = 4096
        disk_size  = 20
      }
      talos_cp_02 = {
        name       = "talos-cp-02"
        role       = "controlplane"
        node       = "roman"
        ip_addr    = "192.168.3.41"
        cores      = 2
        memory     = 4096
        disk_size  = 20
      }
      talos_worker_02 = {
        name       = "talos-worker-02"
        role       = "worker"
        node       = "roman"
        ip_addr    = "192.168.3.51"
        cores      = 4
        memory     = 4096
        disk_size  = 20
      }
      talos_cp_03 = {
        name       = "talos-cp-03"
        role       = "controlplane"
        node       = "antonio"
        ip_addr    = "192.168.3.42"
        cores      = 2
        memory     = 4096
        disk_size  = 20
      }
      talos_worker_03 = {
        name       = "talos-worker-03"
        role       = "worker"
        node       = "antonio"
        ip_addr    = "192.168.3.52"
        cores      = 4
        memory     = 4096
        disk_size  = 20
      }
    }
  }
  
  rancher_config = {
    talos_vms = {
      talos_cp_01 = {
        name       = "rancher-cp-01"
        role       = "controlplane"
        node       = "jacinta"
        ip_addr    = "192.168.3.20"
        cores      = 2
        memory     = 4096
        disk_size  = 20
      }
      talos_worker_01 = {
        name       = "rancher-worker-01"
        role       = "worker"
        node       = "jacinta"
        ip_addr    = "192.168.3.30"
        cores      = 4
        memory     = 4096
        disk_size  = 20
      }
    }
  }

  # Configuración del cluster basada en el workspace
  cluster_config = terraform.workspace == "rancher" ? local.rancher_config : local.talos_config
  talos_vms = local.cluster_config.talos_vms
  
  # Obtener la clave del primer control plane para referencias
  control_plane_key = [for k, v in local.talos_vms : k if v.role == "controlplane"][0]
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