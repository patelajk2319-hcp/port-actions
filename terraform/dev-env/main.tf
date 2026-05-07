terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
    port = {
      source  = "port-labs/port-labs"
      version = "~> 2.4.0"
    }
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = "us-central1"
  zone    = "us-central1-a"
}

provider "port" {
  client_id = var.port_client_id
  secret    = var.port_client_secret
  base_url  = "https://api.port.io"
}

# ── GCP: small VM to represent the dev environment ────────────────────────────

resource "google_compute_instance" "dev_env" {
  name         = var.environment_name
  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
      size  = 10
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata = {
    service    = var.service_id
    created-by = "port-self-service"
    ttl        = var.ttl
  }

  labels = {
    service     = var.service_id
    environment = "dev"
    ttl         = replace(var.ttl, "h", "h")
  }
}

# ── Port: register the new environment in the catalog ─────────────────────────

locals {
  ttl_minutes = tonumber(replace(var.ttl, "m", ""))
  ttl_expiry  = timeadd(timestamp(), "${local.ttl_minutes}m")
}

resource "port_entity" "dev_env" {
  blueprint  = "environment"
  identifier = var.environment_name
  title      = "${var.service_id} — ${var.environment_name}"

  properties = {
    string_props = {
      "env_type"   = "dev"
      "cluster"    = "gcp-${var.gcp_project_id}"
      "namespace"  = var.environment_name
      "status"     = "Running"
      "image_tag"  = var.base_branch
      "ttl_expiry" = local.ttl_expiry

    }
    number_props = {
      "replica_count" = 1
    }
    boolean_props = {
      "auto_sync_enabled" = false
    }
  }

  relations = {
    single_relations = {
      "service" = var.service_id
    }
  }
}
