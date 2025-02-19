# Creation de l'OU principale
New-ADOrganizationalUnit -Name $rootOUName -Path $domain -ProtectedFromAccidentalDeletion $true

# Creation des UO Techniques Globales
foreach ($techUO in $techUOs) {
    New-ADOrganizationalUnit -Name $techUO -Path $rootOU -ProtectedFromAccidentalDeletion $true
}

# Creation des UO par service
$services = $users.Service | Sort-Object -Unique
foreach ($service in $services) {
    # Creation de l'UO pour le service
    New-ADOrganizationalUnit -Name $service -Path $rootOU -ProtectedFromAccidentalDeletion $true

    # Creation des sous-UO
    if ($service -eq "Developpement") {
        $subOUs += "Serveurs"
    }

    foreach ($subOU in $subOUs) {
        New-ADOrganizationalUnit -Name $subOU -Path "OU=$service,$rootOU" -ProtectedFromAccidentalDeletion $true
    }
}

# Ajout des utilisateurs depuis le fichier CSV
foreach ($user in $users) {
    # Construire le chemin d'OU pour l'utilisateur
    $ouPath = "OU=Utilisateurs,OU=$user.Service,$rootOU"
    
    # Afficher pour deboguer
    Write-Host "OU Path: $ouPath"

    # Construction de l'identifiant
    $identifiant = "$($user.Prenom).$($user.Nom)"
    
    # Creation de l'utilisateur
    New-ADUser -Name "$($user.Nom) $($user.Prenom)" `
               -GivenName $user.Prenom `
               -Surname $user.Nom `
               -SamAccountName $identifiant `
               -UserPrincipalName "$identifiant@$domaine" `
               -Path $ouPath `
               -AccountPassword (ConvertTo-SecureString -AsPlainText $mdp -Force) `
               -CannotChangePassword $true `
               -Enabled $true `
               -ChangePasswordAtLogon $true
}

Write-Host "Structure AD et utilisateurs crees avec succes !"
