locals {

  vm_name = "web-vm"
  ansible_vm_name = "ansible_vm"
  vm_size = "Standard_D2s_v3"

  web_nsg_rules = {
    allow_ssh = {
      name                       = "allow-ssh"
      priority                   = "100"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "${chomp(data.http.myip.response_body)}/32"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "22"
      description                = "Allow port 22"
    }

    allow_80 = {
      name                       = "allow-80"
      priority                   = "110"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "80"
      description                = "Allow port 80"
    }

    allow_443 = {
      name                       = "allow-443"
      priority                   = "120"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "443"
      description                = "Allow port 443"
    }

    allow_8080 = {
      name                       = "allow-8080"
      priority                   = "130"
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_address_prefix      = "*"
      source_port_range          = "*"
      destination_address_prefix = "*"
      destination_port_range     = "8080"
      description                = "Allow port 8080"
    }
  }

  # ansible_nsg_rules = {
  #   allow_ssh = {
  #     name                       = "allow-ssh"
  #     priority                   = "100"
  #     direction                  = "Inbound"
  #     access                     = "Allow"
  #     protocol                   = "Tcp"
  #     source_address_prefix      = "*"
  #     source_port_range          = "*"
  #     destination_address_prefix = "*"
  #     destination_port_range     = "22"
  #     description                = "Allow port 22"
  #   }
  # }
}

variable "os_disk" {
  type = object({
    caching              = string
    storage_account_type = string
    disk_size_gb         = string
  })
  default = {
    caching              = "ReadOnly"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = "30"
  }
}

variable "source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

variable "location" {
  type    = string
  default = "UK South"
}

variable "env" {
  type = string
}

variable "tags" {
  type = map(string)
  default = {
    project = "Publicis"
  }
}

variable "web_vm_tags" {
  type = map(string)
  default = {
    project = "Publicis"
    group = "web"
  }
}

# variable "ansible_vm_tags" {
#   type = map(string)
#   default = {
#     project = "Publicis"
#     group = "ansible"
#   }
# }