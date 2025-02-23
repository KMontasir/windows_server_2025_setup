# Configuration DNS pour la zone inverse
# Ajoute une zone inverse dans le serveur DNS
Add-DnsServerPrimaryZone -NetworkId $Network -DynamicUpdate Secure -ReplicationScope "Domain"

# Creation des enregistrements DNS
# Cree un enregistrement PTR pour le serveur principal
Add-DnsServerResourceRecordPtr -Name $PrimaryDNS_LastOctet -ZoneName $ReverseZone -PtrDomainName "${PDC_Hostname}.${DomainName}"

# Enregistre le second serveur DNS
# Création d'un enregistrement A et PTR pour le serveur secondaire DNS
Add-DnsServerResourceRecordA -Name $SDC_Hostname -ZoneName $DomainName -IPv4Address $SecondaryDNS -TimeToLive $Record_TimeToLive -CreatePtr -PassThru

# Ajouter un enregistrement NS pour le serveur secondaire dans la zone DNS principale
Add-DnsServerResourceRecord -Name "@" -NS -ZoneName $DomainName -NameServer "$SDC_Hostname.$DomainName" -PassThru

# Ajouter un enregistrement NS pour le serveur secondaire dans la zone de recherche inversée
Add-DnsServerResourceRecord -Name "@" -NS -ZoneName $ReverseZone -NameServer "$SDC_Hostname.$DomainName" -PassThru

# Installation du rôle DHCP sur PDC
Install-WindowsFeature -Name 'DHCP' -IncludeManagementTools

# Autorisation du serveur DHCP dans Active Directory
Add-DhcpServerInDC -DnsName "$PDC_Hostname" -IPAddress "$PDC_IPAddress"

# Création de l'étendue DHCP
Add-DhcpServerv4Scope -Name $ScopeName -StartRange $ScopeStart -EndRange $ScopeEnd -SubnetMask $SubnetMask -State Active

# Configuration de la passerelle par défaut
Set-DhcpServerv4OptionValue -ScopeID $Network -OptionID 3 -Value $PDC_DefaultGateway

# Configuration des serveurs DNS
Set-DhcpServerv4OptionValue -ScopeID $Network -OptionID 6 -Value $DnsServers

# Configuration des serveurs de noms
Set-DhcpServerv4OptionValue -ScopeID $Network -OptionID 15 -Value $DomainName

# Activation du serveur DHCP
Set-DhcpServerSetting -DynamicUpdates Always -ConflictDetectionAttempts 2

# Démarrage du service DHCP
Start-Service -Name DHCPServer

# Vérification du statut du service
Get-Service -Name DHCPServer

# Vérification des étendues DHCP configurées
Get-DhcpServerv4Scope
