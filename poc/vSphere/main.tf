terraform {
  required_providers {
    vsphere = {
      source  = "hashicorp/vsphere"
      version = "2.0.2"
    }
  }
}

provider "vsphere" {
  vsphere_server       = "10.225.3.223"
  user                 = "administrator@vsphere.local"
  password             = "VMware1!"
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "Datacenter"
}
data "vsphere_datastore" "datastore" {
  name          = "Datastore-10.225.3.224"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_network" "network" {
  name          = "VMNetwork-PortGroup"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_compute_cluster" "compute_cluster" {
  name          = "Cluster"
  datacenter_id = data.vsphere_datacenter.dc.id
}
data "vsphere_content_library" "this" {
  name = "Cava Templates"
}
data "vsphere_content_library_item" "CentOS8x64" {
  library_id = data.vsphere_content_library.this.id
  name       = "CentOS8x64"
  type = "ovf"

}

data "vsphere_virtual_machine" "template" {
  name          = "template"
  datacenter_id = data.vsphere_datacenter.dc.id

}

resource "vsphere_resource_pool" "pool" {
  name                    = "terraform-resource-pool-test"
  parent_resource_pool_id = data.vsphere_compute_cluster.compute_cluster.resource_pool_id
}

resource "vsphere_virtual_machine" "vm" {
  name = var.vm_name

  resource_pool_id = resource.vsphere_resource_pool.pool.id
  datastore_id     = data.vsphere_datastore.datastore.id

  disk {
    label = "disk0"
    size  = 20
  }
  depends_on = [
    data.vsphere_content_library_item.CentOS8x64
  ]
}

