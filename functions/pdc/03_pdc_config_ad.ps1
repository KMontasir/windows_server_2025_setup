# Configuration DNS pour la zone inverse
# Ajoute une zone inverse dans le serveur DNS
Add-DnsServerPrimaryZone -NetworkId $Network -DynamicUpdate Secure -ReplicationScope "Domain"

# Creation des enregistrements DNS
# Cree un enregistrement PTR pour le serveur principal
Add-DnsServerResourceRecordPtr -Name $PrimaryDNS_LastOctet -ZoneName $ReverseZone -PtrDomainName "${PDC_Hostname}.${DomainName}"

# Enregistre le second serveur DNS
# Création d'un enregistrement A pour le serveur secondaire DNS
Add-DnsServerResourceRecordA -Name $SDC_Hostname -ZoneName $DomainName -IPv4Address $SecondaryDNS -TimeToLive $Record_TimeToLive -PassThru

# Ajouter un enregistrement NS pour le serveur secondaire dans la zone DNS principale
Add-DnsServerResourceRecord -Name "@" -NS -ZoneName $DomainName -NameServer "$SDC_Hostname.$DomainName" -PassThru

# Ajouter un enregistrement NS pour le serveur secondaire dans la zone de recherche inversée
Add-DnsServerResourceRecord -Name "@" -NS -ZoneName $ReverseZone -NameServer "$SDC_Hostname.$DomainName" -PassThru

# Ajouter manuellement l'enregistrement PTR pour le serveur secondaire dans la zone inverse
Add-DnsServerResourceRecord -Name $SecondaryDNS_LastOctet -PTR -ZoneName $ReverseZone -PtrDomainName "$SDC_Hostname.$DomainName" -PassThru

# Execution des scripts supplementaires
.\functions\pdc\config_adds.ps1
#.\functions\pdc\config_gpo.ps1
