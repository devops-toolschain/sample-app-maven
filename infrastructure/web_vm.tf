module "web_nsg" {
  source               = "github.com/devops-toolschain/azure-terraform-modules.git//az-nsg-vm"
  resource_group_name  = module.pub_rg.name
  location             = var.location
  virtual_machine_name = local.vm_name
  tags                 = var.tags
}

module "vm_nsg_rules" {
  source                      = "github.com/devops-toolschain/azure-terraform-modules.git//az-nsg-security-rule"
  resource_group_name         = module.pub_rg.name
  network_security_group_name = module.web_nsg.name
  nsg_rules_prefix_range      = local.web_nsg_rules
}

module "pub_publicip" {
    source                = "github.com/devops-toolschain/azure-terraform-modules.git//az-publicip"
    publicip_label        = local.vm_name
    resource_group_name   = module.pub_rg.name
    location              = var.location
    sku                   = "Standard"
    allocation_method     = "Static"
    tags                  = var.web_vm_tags
}

module "web_vm_nic" {
  source                        = "github.com/devops-toolschain/azure-terraform-modules.git//az-vm-nic"
  virtual_machine_name          = "spring-app-vm"
  resource_group_name           = module.pub_rg.name
  location                      = var.location
  network_security_group_id     = module.pub_nsg.id
  subnet_id                     = module.pub_vnet_subnet.id
  private_ip_address            = null
  private_ip_address_allocation = "Dynamic"
  public_ip_address_id          = module.pub_publicip.id
  enable_accelerated_networking = "false"
  tags                          = var.web_vm_tags
}

# # Create Virtual Machine
module "web_vm" {
  source = "github.com/devops-toolschain/azure-terraform-modules.git//az-vm-linux"

  # Common configuration
  vm_name             = local.vm_name
  computer_name       = local.vm_name
  resource_group_name = module.pub_rg.name
  location            = var.location

  admin_username = "azureadmin"
  ssh_public_key = file("ssh_keys/id_pub_project.pub")

  # NIC configurtion
  network_interface_ids = [module.web_vm_nic.id]

  # VM configuration
  vm_size                = local.vm_size
  os_disk                = var.os_disk
  source_image_reference = var.source_image_reference
  tags                   = var.web_vm_tags
}