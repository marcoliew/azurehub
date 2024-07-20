terraform {
  required_providers {
    azurerm = {
      source                = "hashicorp/azurerm"
      version               = "=3.78.0"
    }
  }
}
    
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "lawsrg" {

  name     = "${var.region}-${var.env}-lawsrg" 
  location = var.location

  tags = var.tags
}

variable "region" {
  description = "Name of region."
  default = "aue"
}

variable "env" {
  description = "Name of the env"
  default = "shared"
}

variable "location" {
  description = "Azure location where resources should be deployed."
  default = "australiaeast"
}

variable "tags" {
  description = "Tags to apply to all resources created."
  type        = map(string)
  default     = {
    name = ""
    environment = "prod"
    purpose = "centralised log analytics solutions"
    OperationsTeam = "ictops"
    applicationContext = "azlza"
  }
}