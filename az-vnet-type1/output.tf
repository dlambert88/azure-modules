output "resource_group_name" {
  description = "The name of the resource group in which resources are created"
  value       = element(coalescelist(data.azurerm_resource_group.rg.*.name, azurerm_resource_group.rg.*.name, [""]), 0)
}

output "resrouce_group_id" {
  description = "The id of the resource group in which resources are created"
  value       = element(coalescelist(data.azurerm_resource_group.rg.*.id, azurerm_resource_group.rg.*.id, [""]), 0)
}

output "resource_group_location" {
  description = "The location of the resource group in which resources are created"
  value       = element(coalescelist(data.azurerm_resource_group.rg.*.location, azurerm_resource_group.rg.*.location, [""]), 0)
}

output "virtual_network_name" {
  description = "The name of the virtual network"
  value       = element(concat(azurerm_virtual_network.vnet.*.name, [""]), 0)
}

output "virtual_network_id" {
  description = "The id of the virtual network"
  value       = element(concat(azurerm_virtual_network.vnet.*.id, [""]), 0)
}

output "virtual_network_address_space" {
  description = "List of address spaces that are used the virtual network."
  value       = element(coalescelist(azurerm_virtual_network.vnet.*.address_space, [""]), 0)
}

output "subnet_ids" {
  description = "List of IDs of subnets"
  value       = flatten(concat([for s in azurerm_subnet.snet : s.id],))
}

output "subnet_address_prefixes" {
  description = "List of address prefix for subnets"
  value       = flatten(concat([for s in azurerm_subnet.snet : s.address_prefixes],))
}