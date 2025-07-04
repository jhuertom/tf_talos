###################################################
# DOWNLOAD TALOS IMAGE
###################################################
resource "proxmox_virtual_environment_download_file" "talos_nocloud_image" {
  for_each                = toset(local.talos_nodes)
  content_type            = "iso"
  datastore_id            = "local"
  node_name               = each.key
  file_name               = "talos-${local.talos.version}-nocloud-amd64-${terraform.workspace}.img"
  url                     = "https://factory.talos.dev/image/787b79bb847a07ebb9ae37396d015617266b1cef861107eaec85968ad7b40618/${local.talos.version}/nocloud-amd64.raw.gz"
  decompression_algorithm = "gz"
  overwrite               = true
}

###################################################
# VM CREATE
###################################################
resource "proxmox_virtual_environment_vm" "talos" {
  for_each    = local.talos_vms

  name        = each.value.name
  description = "Managed by Terraform - ${terraform.workspace}"
  tags        = ["terraform", terraform.workspace]
  node_name   = each.value.node
  on_boot     = true

  cpu {
    cores = each.value.cores
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = each.value.memory
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local"
    file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image[each.value.node].id
    file_format  = "raw"
    interface    = "virtio0"
    size         = each.value.disk_size
  }

  operating_system {
    type = "l26"
  }

  initialization {
    datastore_id = "local"
    ip_config {
      ipv4 {
        address = "${each.value.ip_addr}/24"
        gateway = local.talos_gateway
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }
}

###################################################
# CLUSTER CREATION
###################################################
resource "talos_machine_secrets" "machine_secrets" {
  # Agregar un sufijo único por workspace
  depends_on = [time_sleep.wait_for_vms]
}

# Agregar un recurso de espera para asegurar que las VMs estén listas
resource "time_sleep" "wait_for_vms" {
  depends_on = [proxmox_virtual_environment_vm.talos]
  create_duration = "30s"
}

data "talos_client_configuration" "talosconfig" {
  depends_on           = [talos_machine_secrets.machine_secrets]
  cluster_name         = "${local.cluster_name}-${terraform.workspace}"
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [for vm in local.talos_vms : vm.ip_addr if vm.role == "controlplane"]
}

data "talos_machine_configuration" "machineconfig" {
  for_each = local.talos_vms

  depends_on       = [talos_machine_secrets.machine_secrets]
  cluster_name     = "${local.cluster_name}-${terraform.workspace}"
  cluster_endpoint = "https://${local.talos_vms[local.control_plane_key].ip_addr}:6443"
  machine_type     = each.value.role
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

resource "talos_machine_configuration_apply" "apply" {
  for_each = local.talos_vms

  depends_on = [
    proxmox_virtual_environment_vm.talos,
    time_sleep.wait_for_vms
  ]

  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig[each.key].machine_configuration
  node                        = each.value.ip_addr
}

resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [talos_machine_configuration_apply.apply]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.talos_vms[local.control_plane_key].ip_addr
  
}

data "talos_cluster_health" "health" {
  depends_on           = [talos_machine_bootstrap.bootstrap]
  client_configuration = data.talos_client_configuration.talosconfig.client_configuration
  control_plane_nodes  = [for vm in local.talos_vms : vm.ip_addr if vm.role == "controlplane"]
  worker_nodes         = [for vm in local.talos_vms : vm.ip_addr if vm.role == "worker"]
  endpoints            = data.talos_client_configuration.talosconfig.endpoints
}

data "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [data.talos_cluster_health.health]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = local.talos_vms[local.control_plane_key].ip_addr

}

output "talosconfig" {
  value     = data.talos_client_configuration.talosconfig.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  sensitive = true
}

resource "local_file" "kubeconfig" {
  depends_on = [data.talos_cluster_kubeconfig.kubeconfig]
  content    = data.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
  filename   = "${path.module}/kubeconfig-${terraform.workspace}.yaml"
}