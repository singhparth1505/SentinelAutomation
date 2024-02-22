terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.38.0"

    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
     resource_group {
       /* to delete the RG when it has resources which is not deployed through terraform 
       or any resource deployed as a consequence of any other resource through terraform */
      prevent_deletion_if_contains_resources = false
    }
  }

  #  subscription_id = "${var.subscription_id}"
  #  client_id       = "${var.client_id}"
  #  client_secret   = "${var.client_secret}"
  #  tenant_id       = "${var.tenant_id}"
}