provider "azurerm" {
    features {
        virtual_machine{
            skip_shutdown_and_force_delete = true
            delete_os_disk_on_deletion = true
    }
        resource_group{
            prevent_deletion_if_contains_resources = false
        }
    }
    subscription_id = ""
}

module "resource_group"{
    source = "./modules/azurerm_resource_group"
    rg_name = "RG-Terraform-DEV"
}

module "virtual_network"{
    depends_on = [module.resource_group]
    source = "./modules/azurerm_virtual_network"
    rg_name = module.resource_group.resource_group_name
    vnet_name = "HUB-PRD"
    snet_name = "HUB-PRD"
    #dnsServer = module.windows_vm[1].private_ip
}

module "windows_vm"{
    depends_on = [module.virtual_network]
    source = "./modules/azurerm_windows_virtual_machine"
    count = 1 #Numero de VM que vai criar
    rg_name = module.resource_group.resource_group_name
    rg_location = module.resource_group.resource_group_location
    vm_prefix = "VM-DC${count.index}"
    vnet_snet-id = module.virtual_network.snet_id
    admin_name = "admt"
    admin_pass= "6chh+*O9mP)l7"
    
}

module "nsg"{
    source = "./modules/azurerm_network_security_group"
    rg_name = module.resource_group.resource_group_name
    rg_location = module.resource_group.resource_group_location
    nsg_prefix = module.resource_group.resource_group_name
    snet_id = module.virtual_network.snet_id
    publicIPsource = data.external.myPublicIP.result["ip"]
}

data "external" "myPublicIP"{
    program = ["pwsh", "-Command", "curl 'http://myexternalip.com/json'"]
}

#Install Active Directory on the DC0 VM
resource "azurerm_virtual_machine_extension" "install_ad" {
    name                 = "install_ad-ds"
# resource_group_name  = azurerm_resource_group.main.name
    virtual_machine_id   = module.windows_vm[0].vmID
    publisher            = "Microsoft.Compute"
    type                 = "CustomScriptExtension"
    type_handler_version = "1.9"

    protected_settings = <<SETTINGS
    {    
        "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.ADDS.rendered)}')) | Out-File -filepath createAD.ps1\" && powershell -ExecutionPolicy Unrestricted -File createAD.ps1 -Domain_DNSName ${data.template_file.ADDS.vars.Domain_DNSName} -SafeModeAdministratorPassword ${data.template_file.ADDS.vars.SafeModeAdministratorPassword}"
    }
    SETTINGS
}

#Variable input for the ADDS.ps1 script
data "template_file" "ADDS" {
    template = "${file("createAD.ps1")}"
    vars = {
        Domain_DNSName          = "${var.Domain_DNSName}"
        SafeModeAdministratorPassword = "${var.SafeModeAdministratorPassword}"
  }
}

