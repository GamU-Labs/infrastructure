terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

data "digitalocean_ssh_key" "main" {
  name = var.ssh_key_name
}

resource "digitalocean_droplet" "app" {
  image     = "ubuntu-22-04-x64"
  name      = "${var.project_name}-${var.environment}"
  region    = var.region
  size      = var.droplet_size
  ssh_keys  = [data.digitalocean_ssh_key.main.id]
  user_data = file("${path.module}/cloud-init.yaml")

  tags = ["${var.project_name}", var.environment, "capstone"]
}

resource "digitalocean_firewall" "web" {
  name = "${var.project_name}-${var.environment}-firewall"

  droplet_ids = [digitalocean_droplet.app.id]

  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "3000"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

resource "digitalocean_project_resources" "main" {
  count     = var.do_project_id != "" ? 1 : 0
  project   = var.do_project_id
  resources = [
    digitalocean_droplet.app.urn,
    digitalocean_firewall.web.urn,
  ]
}
