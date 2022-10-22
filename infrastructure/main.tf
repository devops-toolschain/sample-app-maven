# resource "azurerm_resource_group" "app_rg" {
#   name     = join("-", ["spring-boot-app-gradle-rg", var.env])
#   location = var.location
# }

module "pub_rg" {
  source   = "github.com/devops-toolschain/azure-terraform-modules.git//az-resource-group"
  name     = "pub"
  location = var.location
  tags     = var.tags
}

module "pub_vnet" {
  source              = "github.com/devops-toolschain/azure-terraform-modules.git//az-vnet"
  name                = "pub"
  resource_group_name = module.pub_rg.name
  location            = var.location
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

module "pub_vnet_subnet" {
  source               = "github.com/devops-toolschain/azure-terraform-modules.git//az-vnet-subnet"
  name                 = "pub"
  resource_group_name  = module.pub_rg.name
  virtual_network_name = module.pub_vnet.name
  address_prefixes     = ["10.0.0.0/24"]
}

module "pub_nsg" {
  source               = "github.com/devops-toolschain/azure-terraform-modules.git//az-nsg-vm"
  resource_group_name  = module.pub_rg.name
  location             = var.location
  virtual_machine_name = local.vm_name
  tags                 = var.tags
}

module "vm_nsg_rules" {
  source                      = "github.com/devops-toolschain/azure-terraform-modules.git//az-nsg-security-rule"
  resource_group_name         = module.pub_rg.name
  network_security_group_name = module.pub_nsg.name
  nsg_rules_prefix_range      = local.nsg_rules_range
}

module "pub_publicip" {
    source                = "github.com/devops-toolschain/azure-terraform-modules.git//az-publicip"
    publicip_label        = local.vm_name
    resource_group_name   = module.pub_rg.name
    location              = var.location
    sku                   = "Standard"
    allocation_method     = "Static"
    tags                  = var.tags
}

module "vm_nic" {
  source                        = "github.com/devops-toolschain/azure-terraform-modules.git//az-vm-nic"
  virtual_machine_name          = local.vm_name
  resource_group_name           = module.pub_rg.name
  location                      = var.location
  network_security_group_id     = module.pub_nsg.id
  subnet_id                     = module.pub_vnet_subnet.id
  private_ip_address            = null
  private_ip_address_allocation = "Dynamic"
  public_ip_address_id          = module.pub_publicip.id
  enable_accelerated_networking = "false"
  tags                          = var.tags
}

# # Create Virtual Machine
module "vm" {
  source = "github.com/devops-toolschain/azure-terraform-modules.git//az-vm-linux"

  # Common configuration
  vm_name             = local.vm_name
  resource_group_name = module.pub_rg.name
  location            = var.location

  admin_username = "azureadmin"
  ssh_public_key = file("ssh_keys/id_pub_project.pub")

  # NIC configurtion
  network_interface_ids = [module.vm_nic.id]

  # VM configuration
  vm_size                = local.vm_size
  os_disk                = var.os_disk
  source_image_reference = var.source_image_reference
  tags                   = var.tags
}

# # Create VM Extensions
# module "vm_extensions" {
#     source                  = "../../../modules/tf-az-vm-linux-extensions"
#     template_file_path      = "../../../modules/tf-az-vm-linux-extensions"
#     virtual_machine_names   = [module.vm.vm_name]
#     virtual_machine_ids     = [module.vm.vm_id]

#     symantec_agent_config   = local.symantec_agent_config

#     disk_encryption_config  = local.disk_encryption_config
#     diagnostic_agent_config =  local.diagnostic_agent_config
#     dependency_agent_config = local.dependency_agent_config
#     rapid7_agent_config     = local.rapid7_agent_config

#     log_analytics_workspace = local.log_analytics_workspace
# }
