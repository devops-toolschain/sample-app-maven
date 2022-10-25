# module "pub_rg" {
#   source   = "github.com/devops-toolschain/azure-terraform-modules.git//az-resource-group"
#   name     = "pub"
#   location = var.location
#   tags     = var.tags
# }

# module "pub_vnet" {
#   source              = "github.com/devops-toolschain/azure-terraform-modules.git//az-vnet"
#   name                = "pub"
#   resource_group_name = module.pub_rg.name
#   location            = var.location
#   address_space       = ["10.0.0.0/16"]
#   tags                = var.tags
# }

# module "pub_vnet_subnet" {
#   source               = "github.com/devops-toolschain/azure-terraform-modules.git//az-vnet-subnet"
#   name                 = "pub"
#   resource_group_name  = module.pub_rg.name
#   virtual_network_name = module.pub_vnet.name
#   address_prefixes     = ["10.0.0.0/24"]
# }
