# We strongly recommend using the required_providers block to set the
# Azure Provider source and version being used
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "kiran-k8s" {
  name     = "kiran-k8s-rg"
  location = "West Europe"
}

resource "azurerm_virtual_network" "kiran-k8s" {
  name                = "kiran-k8s-vnet"
  location            = azurerm_resource_group.kiran-k8s.location
  resource_group_name = azurerm_resource_group.kiran-k8s.name
  address_space       = ["10.0.0.0/16"]
#  dns_servers         = ["10.0.0.4", "10.0.0.5"]
  tags = {
    Environment = "Certification"
  }
}
