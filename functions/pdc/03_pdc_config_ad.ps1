# Configuration DNS pour la zone inverse
# Ajoute une zone inverse dans le serveur DNS
Add-DnsServerPrimaryZone -NetworkId $Network -DynamicUpdate Secure -ReplicationScope "Domain"

# Creation des enregistrements DNS
# Cree un enregistrement PTR pour le serveur principal
Add-DnsServerResourceRecordPtr -Name $PrimaryDNS_LastOctet -ZoneName $ReverseZone -PtrDomainName "${PDC_Hostname}.${DomainName}"

# Enregistre le second serveur DNS
# Cree un enregistrement A et un enregistrement NS pour le serveur secondaire DNS
Add-DnsServerResourceRecordA -Name $SDC_Hostname -ZoneName $DomainName -IPv4Address $SecondaryDNS -TimeToLive $Record_TimeToLive -CreatePtr -PassThru
Add-DnsServerResourceRecordNS -Name $DomainName -NameServer $SDC_Hostname -ZoneName $DomainName -TimeToLive $Record_TimeToLive -PassThru

# Execution des scripts supplementaires
.\functions\pdc\config_adds.ps1
#.\functions\pdc\config_gpo.ps1
