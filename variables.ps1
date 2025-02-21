#A faire en avant
#New-NetIPAddress -InterfaceAlias $PDC_InterfaceAlias -IPAddress $PDC_IPAddress -PrefixLength $PDC_PrefixLength -DefaultGateway $PDC_DefaultGateway
#Set-DnsClientServerAddress -InterfaceAlias $PDC_InterfaceAlias -ServerAddresses $PDC_DnsServernew

#New-NetIPAddress -InterfaceAlias $SDC_InterfaceAlias -IPAddress $SDC_IPAddress -PrefixLength $SDC_PrefixLength -DefaultGateway $SDC_DefaultGateway
#Set-DnsClientServerAddress -InterfaceAlias $SDC_InterfaceAlias -ServerAddresses $SDC_DnsServer

# Disque
$Sys_Partition = "C:"

# Domaine
$Network = "192.168.100.0/24"
$DomainName = "SUN.COM"
$NetbiosName = "SUN"
$ForestMode = "Win2025"
$DomainMode = "Win2025"
$domain = "DC=SUN,DC=COM"
$SafeModePassword = ConvertTo-SecureString -String "Azerty/123" -AsPlainText -Force

# DNS Configuration
$ReverseZone = "100.168.192.in-addr.arpa"
$PrimaryDNS = "192.168.100.20"
$SecondaryDNS = "192.168.100.25"
$PrimaryDNS_LastOctet = ($PrimaryDNS -split "\.")[3]
$SecondaryDNS_LastOctet = ($SecondaryDNS -split "\.")[3]
$Record_TimeToLive = "01:00:00"

# Configuration Reseau PDC
$PDC_Hostname = "pdc"
$PDC_InterfaceAlias = "Ethernet"
$PDC_IPAddress = "192.168.100.20"
$PDC_PrefixLength = 24
$PDC_DefaultGateway = "192.168.100.1"
$PDC_DnsServer = "192.168.100.20"
$PDC_SSh_Port = "22"

# Configuration Reseau SDC
$SDC_Hostname = "sdc"
$SDC_InterfaceAlias = "Ethernet"
$SDC_IPAddress = "192.168.100.25"
$SDC_PrefixLength = 24
$SDC_DefaultGateway = "192.168.100.1"
$SDC_DnsServer = "192.168.100.25"
$SDC_SSh_Port = "22"

# Définition des variables DHCP
$ScopeName = "SUN_SCOPE"
$ScopeStart = "192.168.100.150"
$ScopeEnd = "192.168.100.254"
$SubnetMask = "255.255.255.0"
$DnsServers = "$PrimaryDNS,$SecondaryDNS"

# Configuration OU
$rootOUName = "Entreprise" # Nom de l'OU principale
$rootOU = "OU=$rootOUName,$domain" # Chemin de l'OU principale
$subOUs = @("Utilisateurs", "Ordinateurs", "Groupes", "GPOs") # Sous-OU
$techUOs = @("Serveurs", "Admins", "Groupes_Generaux", "Postes_IT") # OU Techniques Globales
$ouPath = "OU=Utilisateurs,OU=$user.Service,$rootOU" # Construire le chemin d'OU pour l'utilisateur

# Configuration utilisateurs
$mdp = "Azerty/123" # Le mot de passe par defaut pour les utilisateurs
$csvFile = ".\users.csv" # Chemin du fichier CSV
$users = Import-Csv -Path $csvFile -Delimiter ';' -Encoding UTF8 # Chargement des utilisateurs depuis le CSV avec le separateur ";"
