# Configuration du reseau
# Desactivation de IPv6
Get-NetAdapter | ForEach-Object {
    Disable-NetAdapterBinding -Name $_.Name -ComponentID ms_tcpip6
}

# Configuration des parametres reseau
Get-NetAdapter | ForEach-Object {
    Set-NetIPInterface -InterfaceAlias $_.Name -Dhcp Disabled
}

# Demarrage du service SSH
# Demarre le service SSH et le configure pour un demarrage automatique
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# Configuration du pare-feu pour SSH
# Si la regle de pare-feu SSH n'existe pas, elle est ajoutee
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort $SDC_SSh_Port -Profile Any
}

# Renommage de l'ordinateur
# Change le nom de la machine
Rename-Computer -NewName $SDC_Hostname -Restart

# Joindre le serveur au domaine
# Ajoute la machine au domaine specifie et redemarre
#Add-Computer -DomainName $DomainName -Restart
