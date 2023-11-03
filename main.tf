terraform {
  required_version = ">= 0.13.1"

  required_providers {
    shoreline = {
      source  = "shorelinesoftware/shoreline"
      version = ">= 1.11.0"
    }
  }
}

provider "shoreline" {
  retries = 2
  debug = true
}

module "postgresql_replication_inconsistencies" {
  source    = "./modules/postgresql_replication_inconsistencies"

  providers = {
    shoreline = shoreline
  }
}