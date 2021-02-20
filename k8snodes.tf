resource "azurerm_virtual_machine" "node" {
  name                  = "${var.prefix}-node"
  location              = azurerm_resource_group.kiran-k8s.location
  resource_group_name   = azurerm_resource_group.kiran-k8s.name
  network_interface_ids = [azurerm_network_interface.main.id]
  vm_size               = "Standard_B1s"
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
    name              = "myosdisknode1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "k8snode1"
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
  depends_on = [azurerm_virtual_machine.main]
}

resource "azurerm_network_interface" "node1" {
  name                = "${var.prefix}-node1-nic"
  location            = azurerm_resource_group.kiran-k8s.location
  resource_group_name = azurerm_resource_group.kiran-k8s.name

  ip_configuration {
    name                          = "testconfiguration-node1"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.node1.id
  }
}

resource "azurerm_public_ip" "node1" {
  name                = "acceptanceTest-node1-PublicIp1"
  resource_group_name = azurerm_resource_group.kiran-k8s.name
  location            = azurerm_resource_group.kiran-k8s.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}