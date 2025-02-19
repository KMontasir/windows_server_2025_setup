# Importation des variables
#. .\variables.ps1

# Installation du role Active Directory Domain Services
Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

# Configuration du serveur DNS
Set-DnsClientServerAddress -InterfaceAlias $SDC_InterfaceAlias -ServerAddresses "$PrimaryDNS, 127.0.0.1"

# Promotion en controleur de domaine secondaire
Install-ADDSDomainController `
    -DomainName $DomainName `
    -ReplicationSourceDC $PDC_Hostname `
    -DatabasePath "$Sys_Partition\Windows\NTDS" `
    -LogPath "$Sys_Partition\Windows\NTDS" `
    -SysvolPath "$Sys_Partition\Windows\SYSVOL" `
    -SafeModeAdministratorPassword $SafeModePassword `
    -Force

# Creation de la zone inverse DNS
Add-DnsServerSecondaryZone -Name $ReverseZone -ZoneFile "$ReverseZone.dns" -MasterServers $SDC_DnsServer -PassThru

# Verification de la replication
repadmin /replsummary
