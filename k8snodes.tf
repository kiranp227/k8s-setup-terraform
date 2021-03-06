resource "azurerm_virtual_machine" "node1" {
  count                 = 2
  name                  = "${var.prefix}-node-${count.index}"
  location              = azurerm_resource_group.kiran-k8s.location
  resource_group_name   = azurerm_resource_group.kiran-k8s.name
  network_interface_ids = [azurerm_network_interface.node1[count.index].id]
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
    name              = "myosdisk${var.prefix}-node-${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "${var.prefix}-node-${count.index}"
    admin_username = "testadmin"
    admin_password = "Password1234!"

#   passing filebase64 to encode script
    custom_data = filebase64("scripts/k8s-node1.sh")

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
  count = 2
  name                = "${var.prefix}-node-${count.index}-nic"
  location            = azurerm_resource_group.kiran-k8s.location
  resource_group_name = azurerm_resource_group.kiran-k8s.name

  ip_configuration {
    name                          = "testconfiguration-node-${count.index}"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
#    public_ip_address_id          = "[azurerm_public_ip.node1[count.index].id]"
    public_ip_address_id          = "${element(azurerm_public_ip.node1.*.id, count.index)}"
  }
}

resource "azurerm_public_ip" "node1" {
  count= 2
  name                = "acceptanceTest-nodes-PublicIp-${count.index}"
  resource_group_name = azurerm_resource_group.kiran-k8s.name
  location            = azurerm_resource_group.kiran-k8s.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_interface_security_group_association" "nodes" {
    count = 2
    network_interface_id = azurerm_network_interface.node1[count.index].id
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}
