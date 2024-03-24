# Create Resource Group [Default = true]
resource "azurerm_resource_group" "rg" {
  count    = var.create_resource_group ? 1 : 0
  name     = var.resource_group_name
  location = var.location
  tags     = merge({ "Name" = format("%s", var.resource_group_name) }, var.tags, )
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = var.virtual_network_address_space
  dns_servers         = var.dns_servers
  tags                = merge({ "Name" = format("%s", var.virtual_network_name) }, var.tags, )
  depends_on = [azurerm_resource_group.rg]
}

# Sub Network
resource "azurerm_subnet" "snet" {
  for_each                                      = var.subnet
  name                                          = each.value.subnet_name
  resource_group_name                           = local.resource_group_name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
  address_prefixes                              = each.value.subnet_address_prefix
  service_endpoints                             = lookup(each.value, "service_endpoints", [])
  service_endpoint_policy_ids                   = lookup(each.value, "service_endpoint_policy_ids", null)
  private_endpoint_network_policies_enabled     = lookup(each.value, "private_endpoint_network_policies_enabled", null)
  private_link_service_network_policies_enabled = lookup(each.value, "private_link_service_network_policies_enabled", null)

  dynamic "delegation" {
    for_each = lookup(each.value, "delegation", {}) != {} ? [1] : []
    content {
      name = lookup(each.value.delegation, "name", null)
      service_delegation {
        name    = lookup(each.value.delegation.service_delegation, "name", null)
        actions = lookup(each.value.delegation.service_delegation, "actions", null)
      }
    }
  }

  depends_on = [ azurerm_virtual_network.vnet ]
}

# Route Table [Automated]
# RT will be created, but does not need to be used unless specified for poject
resource "azurerm_route_table" "rt" {
  for_each            = var.subnet
  name                = lower("rt-${var.virtual_network_name}-${each.key}")
  resource_group_name = local.resource_group_name
  location            = local.location

  dynamic "route" {
    for_each = lookup(each.value, "route", [])
    content {
      name                   = route.value[0] == "" ? "default" : route.value[0]
      address_prefix         = route.value[1] == "" ? "0.0.0.0/0" : route.value[1]
      next_hop_type          = route.value[2] == "" ? "VirtualAppliance" : route.value[2]
      next_hop_in_ip_address = route.value[3] == "" ? null : route.value[3]
    }
  }

  depends_on = [ azurerm_subnet.snet ]
}

resource "azurerm_subnet_route_table_association" "rt-association" {
  for_each        = var.subnet
  subnet_id       = azurerm_subnet.snet[each.key].id
  route_table_id  = azurerm_route_table.rt[each.key].id

  depends_on = [ azurerm_route_table.rt ]
}