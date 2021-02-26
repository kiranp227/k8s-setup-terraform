variable "prefix" {
  default = "kiran-k8s"
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.kiran-k8s.name
  virtual_network_name = azurerm_virtual_network.kiran-k8s.name
  address_prefixes     = ["10.0.3.0/24"]
}


resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.kiran-k8s.location
  resource_group_name = azurerm_resource_group.kiran-k8s.name

  ip_configuration {
    name                          = "testconfiguration1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.3.9"
    public_ip_address_id          = azurerm_public_ip.example.id
  }
}

resource "azurerm_virtual_machine" "main" {
  name                  = "${var.prefix}-master1"
  location              = azurerm_resource_group.kiran-k8s.location
  resource_group_name   = azurerm_resource_group.kiran-k8s.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_B2s"
#  boot_diagnostics      = enabled
  boot_diagnostics {
        enabled     = true
        storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
  }
  # Uncomment this line to delete the OS disk automatically when deleting the VM
  delete_os_disk_on_termination = true

  # Uncomment this line to delete the data disks automatically when deleting the VM
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "k8smaster1"
    admin_username = "testadmin"
    admin_password = "Password1234!"

#   passing filebase64 to encode script
    custom_data = filebase64("scripts/k8s-master1.sh")

#   custom_data    = "apt-get update \n swapoff -a"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  tags = {
    environment = "staging"
  }
}

resource "azurerm_public_ip" "example" {
  name                = "acceptanceTestPublicIp1"
  resource_group_name = azurerm_resource_group.kiran-k8s.name
  location            = azurerm_resource_group.kiran-k8s.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}


resource "azurerm_network_security_group" "myterraformnsg" {
    name                = "myNetworkSecurityGroup"
    location            = azurerm_resource_group.kiran-k8s.location
    resource_group_name = azurerm_resource_group.kiran-k8s.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Terraform Demo"
    }
}

resource "azurerm_network_interface_security_group_association" "example" {
    network_interface_id = azurerm_network_interface.main.id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}
