resource "azurerm_resource_group" "aks-rg" {
  name     = "var.resource_group_name"
  location = "var.location"
}

resource "azurerm_container_registry" "acr123123" {
  name                = "acr123123"
  resource_group_name = azurerm_resource_group.aks-rg.name
  location            = var.location
  sku                 = "Standard"
  admin_enabled       = false
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "var.cluster_name"
  kubernetes_version  = "var.kubernetes_version"
  location            =  var.location
  resource_group_name = "azurerm_resource_group.aks-rg.name"
  dns_prefix          = "my-aks-cluster"


  default_node_pool {
    name                = "system"
    node_count          = 1
    vm_size             = "Standard_DS2_v2"
    type                = "VirtualMachineScaleSets"
    zones  = [1, 2, 3]
    enable_auto_scaling = false
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    load_balancer_sku = "standard"
    network_plugin    = "kubenet" 
  }
}


resource "azurerm_role_assignment" "role_acrpull" {
  scope                            = azurerm_container_registry.acr123123.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity.0.object_id
  skip_service_principal_aad_check = true
}
