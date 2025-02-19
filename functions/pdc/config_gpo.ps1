# Importation des variables
#. .\variables.ps1

function set_all_gpos_and_apply {
    # Creer et configurer le GPO pour la securite des comptes utilisateurs
    $gpo_user_account_security = New-GPO -Name "gpo_user_account_security" -Comment "GPO to secure user accounts"
    Set-GPRegistryValue -Name "gpo_user_account_security" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "PasswordComplexity" -Type DWord -Value 1  # Activer la complexite des mots de passe
    Set-GPRegistryValue -Name "gpo_user_account_security" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "MaximumPasswordAge" -Type DWord -Value 90  # Expiration des mots de passe tous les 90 jours
    Set-GPRegistryValue -Name "gpo_user_account_security" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "AccountLockoutThreshold" -Type DWord -Value 5  # Blocage des comptes apres 5 tentatives echouees
    Set-GPRegistryValue -Name "gpo_user_account_security" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "DisablePasswordCaching" -Type DWord -Value 1  # Interdire le stockage des mots de passe en local

    # Creer et configurer le GPO pour la securisation des postes clients
    $gpo_client_workstation_security = New-GPO -Name "gpo_client_workstation_security" -Comment "GPO to secure client workstations"
    Set-GPRegistryValue -Name "gpo_client_workstation_security" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "DisableUSB" -Type DWord -Value 1  # Desactiver les ports USB (sauf exceptions IT)
    Set-GPRegistryValue -Name "gpo_client_workstation_security" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\Installer" -ValueName "DisableMSI" -Type DWord -Value 1  # Desactiver l'installation de logiciels non approuves
    Set-GPRegistryValue -Name "gpo_client_workstation_security" -Key "HKLM\SOFTWARE\Policies\Microsoft\FVE" -ValueName "EnableBDE" -Type DWord -Value 1  # Activer le chiffrement BitLocker
    Set-GPRegistryValue -Name "gpo_client_workstation_security" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -ValueName "AutomaticUpdates" -Type DWord -Value 4  # Forcer la mise a jour automatique via WSUS

    # Creer et configurer le GPO pour la securisation des connexions
    $gpo_connection_security = New-GPO -Name "gpo_connection_security" -Comment "GPO to secure connections"
    Set-GPRegistryValue -Name "gpo_connection_security" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "KerberosOnly" -Type DWord -Value 1  # Forcer la connexion via Kerberos uniquement
    Set-GPRegistryValue -Name "gpo_connection_security" -Key "HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services" -ValueName "AdminTS" -Type DWord -Value 0  # Interdire l'utilisation de comptes administrateurs pour les connexions RDP
    Set-GPRegistryValue -Name "gpo_connection_security" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "AuditLogonEvents" -Type DWord -Value 1  # Activer l'audit des connexions reussies et echouees

    # Creer et configurer le GPO pour les services generaux
    $gpo_service_general = New-GPO -Name "gpo_service_general" -Comment "GPO for Service General"
    Set-GPRegistryValue -Name "gpo_service_general" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "NoControlPanel" -Type DWord -Value 1  # Limiter les droits des utilisateurs : Aucun acces aux parametres systeme
    Set-GPRegistryValue -Name "gpo_service_general" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -ValueName "RedirectFolders" -Type DWord -Value 1  # Forcer la redirection des documents et bureau vers un serveur centralise
    Set-GPRegistryValue -Name "gpo_service_general" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "EnableLUA" -Type DWord -Value 1  # Desactiver l'execution de scripts non signes

    # Creer et configurer le GPO pour les services de production
    $gpo_service_production = New-GPO -Name "gpo_service_production" -Comment "GPO for Service Production"
    Set-GPRegistryValue -Name "gpo_service_production" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "RestrictSystemAccess" -Type DWord -Value 1  # Restreindre l'acces aux systemes critiques
    Set-GPRegistryValue -Name "gpo_service_production" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "NoAdminOnDesktop" -Type DWord -Value 1  # Interdiction des connexions administratives sur les postes utilisateurs
    Set-GPRegistryValue -Name "gpo_service_production" -Key "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "InactiveAccountsLockout" -Type DWord -Value 30  # Desactivation des comptes inactifs apres 30 jours

    # Creer et configurer le GPO pour les serveurs
    $gpo_server_security = New-GPO -Name "gpo_server_security" -Comment "GPO for Server Security"
    Set-GPRegistryValue -Name "gpo_server_security" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "RDPSecurityLevel" -Type DWord -Value 1  # Autoriser uniquement les connexions RDP via bastion securise
    Set-GPRegistryValue -Name "gpo_server_security" -Key "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "SMB1" -Type DWord -Value 0  # Desactiver SMBv1
    Set-GPRegistryValue -Name "gpo_server_security" -Key "HKLM\Software\Policies\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "RequireEncryption" -Type DWord -Value 1  # Chiffrement obligatoire pour toutes les communications internes

    # Fonction pour appliquer les GPOs aux OUs ou au domaine
    function apply_gpo_to_ou {
        param (
            [string]$gpo_name,  # Nom du GPO a appliquer
            [string]$ou_path    # Chemin de l'OU ou du domaine ou appliquer le GPO
        )

        # Verifier si le GPO existe
        $gpo = Get-GPO -Name $gpo_name -ErrorAction SilentlyContinue
        if ($gpo -eq $null) {
            Write-Host "Le GPO '$gpo_name' n'existe pas." -ForegroundColor Red
            return
        }

        # Appliquer le GPO a l'OU ou au domaine
        try {
            # Appliquer le GPO a l'OU ou au domaine
            New-GPLink -Name $gpo_name -Target $ou_path
            Write-Host "Le GPO '$gpo_name' a ete applique a l'OU/domaine '$ou_path' avec succes." -ForegroundColor Green
        } catch {
            Write-Host "Erreur lors de l'application du GPO '$gpo_name' a '$ou_path': $_" -ForegroundColor Red
        }
    }

    # Appliquer les GPOs aux OUs specifiees
    apply_gpo_to_ou -gpo_name "gpo_user_account_security" -ou_path "OU=Entreprise,DC=SUN,DC=COM"
    apply_gpo_to_ou -gpo_name "gpo_connection_security" -ou_path "OU=Entreprise,DC=SUN,DC=COM"
    apply_gpo_to_ou -gpo_name "gpo_client_workstation_security" -ou_path "OU=Postes_IT,OU=Entreprise,DC=SUN,DC=COM"
    apply_gpo_to_ou -gpo_name "gpo_service_general" -ou_path "OU=General,OU=Entreprise,DC=SUN,DC=COM"
    apply_gpo_to_ou -gpo_name "gpo_service_production" -ou_path "OU=Production,OU=Entreprise,DC=SUN,DC=COM"
    apply_gpo_to_ou -gpo_name "gpo_server_security" -ou_path "OU=Serveurs,OU=Entreprise,DC=SUN,DC=COM"

}

set_all_gpos_and_apply