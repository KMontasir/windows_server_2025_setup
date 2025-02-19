# Installation du role Active Directory Domain Services
# Installe les outils necessaires pour la gestion du domaine
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# Configuration du serveur DNS
# Redefinit l'adresse DNS du serveur a "127.0.0.1"
Set-DnsClientServerAddress -InterfaceAlias $PDC_InterfaceAlias -ServerAddresses "127.0.0.1"

# Creation de la foret Active Directory
# Cree une nouvelle foret Active Directory avec les parametres specifies
Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $NetbiosName `
    -ForestMode $ForestMode `
    -DomainMode $DomainMode `
    -SafeModeAdministratorPassword $SafeModePassword `
    -DatabasePath "$Sys_Partition\Windows\NTDS" `
    -LogPath "$Sys_Partition\Windows\NTDS" `
    -SysvolPath "$Sys_Partition\Windows\SYSVOL" `
    -CreateDnsDelegation:$false `
    -Confirm:$false `
    -Force
