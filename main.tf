terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.23.0"
    }
  }
}

provider "digitalocean" {
  token = "dop_v1_ea3f0e5518eb2cce881549a46417fe8356a1b8abf7d069bc81718863c1ccf760"
}

# Create a new Web Droplet in the nyc2 region
resource "digitalocean_droplet" "Jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "Jenkins.vm"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.jornada.id]
}

data "digitalocean_ssh_key" "jornada" {
  name = "jornada"
}

resource "digitalocean_kubernetes_cluster" "k8s" {
  name    = "k8s"
  region  = "nyc1"
  version = "1.24.4-do.0"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

variable "region" {
  default = ""
}

output "jenkins_ip"{
    value = digitalocean_droplet.Jenkins.ipv4_address
}

resource "local_file" "foo" {
    content = digitalocean_kubernetes_cluster.k8s.kube_config.0.raw_config
    filename = "kube_config.yaml"
  
}