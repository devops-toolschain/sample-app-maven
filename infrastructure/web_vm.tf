# data "http" "myip" {
#   url = "http://ipv4.icanhazip.com"
# }

# module "web_nsg" {
#   source               = "github.com/devops-toolschain/azure-terraform-modules.git//az-nsg-vm"
#   resource_group_name  = module.pub_rg.name
#   location             = var.location
#   virtual_machine_name = local.vm_name
#   tags                 = var.tags
# }

# module "web_nsg_rules" {
#   source                      = "github.com/devops-toolschain/azure-terraform-modules.git//az-nsg-security-rule"
#   resource_group_name         = module.pub_rg.name
#   network_security_group_name = module.web_nsg.name
#   nsg_rules_prefix_range      = local.web_nsg_rules
# }

# module "pub_publicip" {
#     source                = "github.com/devops-toolschain/azure-terraform-modules.git//az-publicip"
#     publicip_label        = local.vm_name
#     resource_group_name   = module.pub_rg.name
#     location              = var.location
#     sku                   = "Standard"
#     allocation_method     = "Static"
#     tags                  = var.web_vm_tags
# }

# module "web_vm_nic" {
#   source                        = "github.com/devops-toolschain/azure-terraform-modules.git//az-vm-nic"
#   virtual_machine_name          = "spring-app-vm"
#   resource_group_name           = module.pub_rg.name
#   location                      = var.location
#   network_security_group_id     = module.web_nsg.id
#   subnet_id                     = module.pub_vnet_subnet.id
#   private_ip_address            = null
#   private_ip_address_allocation = "Dynamic"
#   public_ip_address_id          = module.pub_publicip.id
#   enable_accelerated_networking = "false"
#   tags                          = var.web_vm_tags
# }

# # # Create Virtual Machine
# module "web_vm" {
#   source = "github.com/devops-toolschain/azure-terraform-modules.git//az-vm-linux"

#   # Common configuration
#   vm_name             = local.vm_name
#   computer_name       = "webvm"
#   resource_group_name = module.pub_rg.name
#   location            = var.location

#   admin_username = "azureadmin"
#   ssh_public_key = file("ssh_keys/id_pub_project.pub")

#   # NIC configurtion
#   network_interface_ids = [module.web_vm_nic.id]

#   # VM configuration
#   vm_size                = local.vm_size
#   os_disk                = var.os_disk
#   source_image_reference = var.source_image_reference
#   tags                   = var.web_vm_tags
# }

# resource "azurerm_log_analytics_workspace" "pub_law" {
#   name                      = "vmloganalytics"
#   resource_group_name       = module.pub_rg.name
#   location                  = var.location
#   sku                       = "PerGB2018"
#   retention_in_days         = 30
#   internet_ingestion_enabled= true
#   internet_query_enabled    = false
# }

# resource "azurerm_virtual_machine_extension" "web_vm_monitor" {
#   name                       = "DAExtension"
#   virtual_machine_id         = module.web_vm.vm_id
#   publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
#   type                       = "DependencyAgentLinux"
#   type_handler_version       = "9.5"
#   auto_upgrade_minor_version = true
# }

# resource "azurerm_virtual_machine_extension" "web_vm_monitor_oms" {
#   name                 = "OmsAgentForLinux"
#   virtual_machine_id   = module.web_vm.vm_id
#   publisher            = "Microsoft.EnterpriseCloud.Monitoring"
#   type                 = "OmsAgentForLinux"
#   type_handler_version = "1.12"
#   auto_upgrade_minor_version = true

#   settings = <<SETTINGS
#   {
#     "workspaceId": "${azurerm_log_analytics_workspace.pub_law.workspace_id}"
#   }
#   SETTINGS

#   protected_settings = <<PROTECTEDSETTINGS
#   {
#     "workspaceKey": "${azurerm_log_analytics_workspace.pub_law.primary_shared_key}"
#   }
#   PROTECTEDSETTINGS
# }