terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 0.11"
    }
  }
  backend "azurerm" {
    resource_group_name = var.bkstrgrg
    storage_account_name = var.bkstrg
    container_name = var.bkcontainer
    key = var.bkstrgkey
  }
}

provider "azurerm" {    
  features {}    
}

resource "azurerm_resource_group" "resource_group" {
  name     = "app-service-rg"
  location = "East US"
}
