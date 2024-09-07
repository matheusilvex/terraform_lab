output "NomeVM"{
    depends_on = [module.windows_vm]
    value = module.windows_vm[*].nameVM
}

output "PublicIPVM"{
    depends_on = [module.windows_vm]
    value = module.windows_vm[*].public_ip
}
