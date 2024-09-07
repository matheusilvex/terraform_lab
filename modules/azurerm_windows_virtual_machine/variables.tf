variable vm_prefix{
    type = string
    description = "Nome da Interface"
}

variable rg_location{
    type = string
    description = "Localização do Resource Group"
}

variable rg_name{
    type = string
    default = "Nome do Resource Group"
}

variable vnet_snet-id{
    type = string
    description = "ID da Subnet"
}

variable enableAutoShutdown{
    type = bool
    description = "Valida se ativa AutoShutdown"
    default = true
}