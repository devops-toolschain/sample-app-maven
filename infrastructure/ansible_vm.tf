module "ansible_nsg" {
  source               = "github.com/devops-toolschain/azure-terraform-modules.git//az-nsg-vm"
  resource_group_name  = module.pub_rg.name
  location             = var.location
  virtual_machine_name = local.ansible_vm_name
  tags                 = var.ansible_vm_tags
}

module "ansible_vm_nsg_rules" {
  source                      = "github.com/devops-toolschain/azure-terraform-modules.git//az-nsg-security-rule"
  resource_group_name         = module.pub_rg.name
  network_security_group_name = module.ansible_nsg.name
  nsg_rules_prefix_range      = local.ansible_nsg_rules
}

module "ansible_vm_nic" {
  source                        = "github.com/devops-toolschain/azure-terraform-modules.git//az-vm-nic"
  virtual_machine_name          = local.ansible_vm_name
  resource_group_name           = module.pub_rg.name
  location                      = var.location
  network_security_group_id     = module.ansible_nsg.id
  subnet_id                     = module.pub_vnet_subnet.id
  private_ip_address            = null
  private_ip_address_allocation = "Dynamic"
  public_ip_address_id          = null
  enable_accelerated_networking = "false"
  tags                          = var.ansible_vm_tags
}

# # Create Virtual Machine
module "asible_vm" {
  source = "github.com/devops-toolschain/azure-terraform-modules.git//az-vm-linux"

  # Common configuration
  vm_name             = local.ansible_vm_name
  computer_name       = local.ansible_vm_name
  resource_group_name = module.pub_rg.name
  location            = var.location

  admin_username = "azureadmin"
  ssh_public_key = file("ssh_keys/id_pub_project.pub")

  # NIC configurtion
  network_interface_ids = [module.ansible_vm_nic.id]

  # VM configuration
  vm_size                = local.vm_size
  os_disk                = var.os_disk
  source_image_reference = var.source_image_reference
  tags                   = var.ansible_vm_tags
}