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
    subscription_id = "3d880f72-1f4a-40d5-a0b1-1e9e121d3aca"
}
#az login --use-device-code --tenant "269190a9-559e-4525-9172-1caaaef5ec44"
/*Comando Para Logar na Conta de Teste.
$SecurePassword = convertto-securestring -AsPlainText -Force -String ('pc98Q~YuVgaVOsh-T.MrKIbjv~dlU0gZAQypZbh2')
$TenantId = '269190a9-559e-4525-9172-1caaaef5ec44'
$ApplicationId = '6b652547-8445-43a3-b22c-dd577ab187e2'
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $ApplicationId, $SecurePassword
Connect-AzAccount -ServicePrincipal -TenantId $TenantId -Credential $Credential
*/
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
    #admin_password      = 6chh+*O9mP)l7
}

data "external" "myPublicIP"{
    program = ["pwsh", "-Command", "curl 'http://myexternalip.com/json'"]
}

module "nsg"{
    source = "./modules/azurerm_network_security_group"
    rg_name = module.resource_group.resource_group_name
    rg_location = module.resource_group.resource_group_location
    nsg_prefix = module.resource_group.resource_group_name
    snet_id = module.virtual_network.snet_id
    publicIPsource = data.external.myPublicIP.result["ip"]
}