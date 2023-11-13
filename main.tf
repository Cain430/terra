#virtualbox

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }

  required_providers {
    vagrant = {
      source  = "HashiCorp/Vagrant"
      version = " 2.3.7"
    }
  }
}

variable "instance_size" {
  description = "Size of the virtual machine"
  type        = string
  default     = "Standard_DS1_v2"
}

variable "vnet_cidr" {
  description = "CIDR block for the virtual network"
  type        = string
  default     = "192.168.2.0/24"
}

resource "vagrant_box" "boxx" {
  name        = "ubuntu/bionic64"
  description = "Ubuntu 18.04 LTS"
}

resource "vagrant_vm" "example" {
  box = vagrant_box.boxx.id

  vm {
    box_version = vagrant_box.boxx.version
    name        = "vagrant"
  }

  network {
    private_network {
      type = "dhcp"
    }

    public_network {
      type = "dhcp"
    }
  }
}


output "public_ip" {
  value = vagrant_vm.example.network_interface.0.address
}
