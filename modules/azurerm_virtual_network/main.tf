resource "azurerm_virtual_network" "virtual_network" {
  name                = "VNET-${var.vnet_name}"
  resource_group_name = var.rg_name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  #dns_servers = [var.dnsServer]
}

resource "azurerm_subnet" "subnet_network" {
  name                 = "SNET-${var.snet_name}"
  virtual_network_name = azurerm_virtual_network.virtual_network.name
  resource_group_name  = var.rg_name
  address_prefixes     = ["10.0.1.0/24"]
} 