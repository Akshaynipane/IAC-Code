# Configure the Azure Provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {}
}

# Variables
variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "rg-storage-example"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "East US"
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique, 3-24 chars, lowercase alphanumeric)"
  type        = string
  default     = "stexample001"
}

variable "account_tier" {
  description = "Storage account tier (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage account replication type (LRS, GRS, RAGRS, ZRS, GZRS, RAGZRS)"
  type        = string
  default     = "LRS"
}

variable "container_name" {
  description = "Name of the blob container"
  type        = string
  default     = "data-container"
}

variable "container_access_type" {
  description = "Access level for the container (private, blob, or container)"
  type        = string
  default     = "private"
}

variable "enable_https_traffic_only" {
  description = "Enable HTTPS traffic only"
  type        = bool
  default     = true
}

variable "min_tls_version" {
  description = "Minimum TLS version"
  type        = string
  default     = "TLS1_2"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  
  # Security settings
  enable_https_traffic_only       = var.enable_https_traffic_only
  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = false
  
  # Blob properties
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 7
    }
    
    container_delete_retention_policy {
      days = 7
    }
  }
  
  # Network rules
  network_rules {
    default_action = "Deny"
    bypass         = ["AzureServices"]
    
    # Add your IP addresses here
    # ip_rules = ["x.x.x.x"]
  }
  
  tags = var.tags
}

# Blob Container
resource "azurerm_storage_container" "container" {
  name                  = var.container_name
  storage_account_name  = azurerm_storage_account.storage.name
  container_access_type = var.container_access_type
}

# Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.storage.name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.storage.id
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint"
  value       = azurerm_storage_account.storage.primary_blob_endpoint
}

output "primary_access_key" {
  description = "Primary access key for the storage account"
  value       = azurerm_storage_account.storage.primary_access_key
  sensitive   = true
}

output "container_name" {
  description = "Name of the blob container"
  value       = azurerm_storage_container.container.name
}

output "container_id" {
  description = "ID of the blob container"
  value       = azurerm_storage_container.container.id
}