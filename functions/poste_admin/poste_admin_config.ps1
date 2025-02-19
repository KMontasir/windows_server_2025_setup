# Vérifier si les outils RSAT pour la gestion des domaines Active Directory sont installés
$rsatADInstalled = Get-WindowsCapability -Online | Where-Object {$_.Name -like 'Rsat.ActiveDirectory.DS-LDS.Tools*' -and $_.State -eq 'Installed'}

if (-not $rsatADInstalled) {
    # Installer les outils RSAT pour la gestion des domaines Active Directory
    Add-WindowsCapability -Online -Name Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0
}

# Vérifier si les outils RSAT pour la gestion du DNS sont installés
$rsatDNSInstalled = Get-WindowsCapability -Online | Where-Object {$_.Name -like 'Rsat.Dns.Tools*' -and $_.State -eq 'Installed'}

if (-not $rsatDNSInstalled) {
    # Installer les outils RSAT pour la gestion du DNS
    Add-WindowsCapability -Online -Name Rsat.Dns.Tools~~~~0.0.1.0
}

# Vérifier si les outils RSAT pour la gestion du DHCP sont installés
$rsatDHCPInstalled = Get-WindowsCapability -Online | Where-Object {$_.Name -like 'Rsat.DHCP.Tools*' -and $_.State -eq 'Installed'}

if (-not $rsatDHCPInstalled) {
    # Installer les outils RSAT pour la gestion du DHCP
    Add-WindowsCapability -Online -Name Rsat.DHCP.Tools~~~~0.0.1.0
}

# Vérifier si les outils RSAT pour la gestion des GPO sont installés
$rsatGPOInstalled = Get-WindowsCapability -Online | Where-Object {$_.Name -like 'Rsat.GroupPolicy.Management.Tools*' -and $_.State -eq 'Installed'}

if (-not $rsatGPOInstalled) {
    # Installer les outils RSAT pour la gestion des GPO
    Add-WindowsCapability -Online -Name Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0
}

# Chemins vers les outils RSAT
$adToolsPath = "$env:windir\System32\dsa.msc"
$dnsToolsPath = "$env:windir\System32\dnsmgmt.msc"
$dhcpToolsPath = "$env:windir\System32\dhcpmgmt.msc"
$gpoToolsPath = "$env:windir\System32\gpmc.msc"

# Obtenir le chemin du bureau de l'utilisateur
$desktopPath = [System.Environment]::GetFolderPath("Desktop")

# Créer des raccourcis sur le bureau avec des noms personnalisés
$WshShell = New-Object -ComObject WScript.Shell

$Shortcut = $WshShell.CreateShortcut("$desktopPath\AD.msc.lnk")
$Shortcut.TargetPath = $adToolsPath
$Shortcut.Save()
Rename-Item -Path "$desktopPath\AD.msc.lnk" -NewName "Outils RSAT Active Directory.lnk"

$Shortcut = $WshShell.CreateShortcut("$desktopPath\DNS.msc.lnk")
$Shortcut.TargetPath = $dnsToolsPath
$Shortcut.Save()
Rename-Item -Path "$desktopPath\DNS.msc.lnk" -NewName "Outils RSAT DNS.lnk"

$Shortcut = $WshShell.CreateShortcut("$desktopPath\DHCP.msc.lnk")
$Shortcut.TargetPath = $dhcpToolsPath
$Shortcut.Save()
Rename-Item -Path "$desktopPath\DHCP.msc.lnk" -NewName "Outils RSAT DHCP.lnk"

$Shortcut = $WshShell.CreateShortcut("$desktopPath\GPO.msc.lnk")
$Shortcut.TargetPath = $gpoToolsPath
$Shortcut.Save()
Rename-Item -Path "$desktopPath\GPO.msc.lnk" -NewName "Outils RSAT GPO.lnk"

# Actualiser le bureau en utilisant l'API Windows
Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public class Win32Utils
    {
        [DllImport("shell32.dll")]
        public static extern void SHChangeNotify(uint wEventId, uint uFlags, IntPtr dwItem1, IntPtr dwItem2);
    }
"@ 

# Actualiser le bureau
[Win32Utils]::SHChangeNotify(0x8000000, 0x1000, [IntPtr]::Zero, [IntPtr]::Zero)
