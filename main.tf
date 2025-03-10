# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Create a resource group for the AKS cluster
resource "azurerm_resource_group" "aks_rg" {
  name     = "cst8918-w25-h09-rg"
  location = "canadacentral"
}

# Get latest Kubernetes version available
data "azurerm_kubernetes_service_versions" "current" {
  location = azurerm_resource_group.aks_rg.location
}

# Create AKS cluster
resource "azurerm_kubernetes_cluster" "app" {
  name                = "cst8918-w25-h09-aks"
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = "cst8918-w25-h09"
  kubernetes_version  = data.azurerm_kubernetes_service_versions.current.latest_version

  default_node_pool {
    name                = "default"
    vm_size             = "Standard_B2s"
    min_count           = 1
    max_count           = 3
    enable_auto_scaling = true
    type                = "VirtualMachineScaleSets"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Development"
    Project     = "CST8918-H09"
  }
}

# Output the kubeconfig
output "kube_config" {
  value = azurerm_kubernetes_cluster.app.kube_config_raw
  sensitive = true
}

# Output the host
output "host" {
  value = azurerm_kubernetes_cluster.app.kube_config.0.host
  sensitive = true
} 