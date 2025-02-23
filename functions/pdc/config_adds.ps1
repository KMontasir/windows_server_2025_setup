# Configuration OU
$rootOUName = "Entreprise" # Nom de l'OU principale
$rootOU = "OU=$rootOUName,$domain" # Chemin de l'OU principale
$subOUs = @("Utilisateurs", "Ordinateurs", "Groupes", "GPOs") # Sous-OU
$techUOs = @("Serveurs", "Admins", "Groupes_Generaux", "Postes_IT") # OU Techniques Globales
$ouPath = "OU=Utilisateurs,OU=$user.Service,$rootOU" # Construire le chemin d'OU pour l'utilisateur

# Adaptation du format du domaine
$DomainFQDN = $DomainName.ToLower()

# Création de l'OU principale
New-ADOrganizationalUnit -Name $rootOUName -Path $domain -ProtectedFromAccidentalDeletion $true

# Création des OU Techniques Globales
foreach ($techUO in $techUOs) {
    New-ADOrganizationalUnit -Name $techUO -Path $rootOU -ProtectedFromAccidentalDeletion $true
}

# Création des OU par service
$services = $users.Service | Sort-Object -Unique
foreach ($service in $services) {
    # Création de l'OU pour le service
    New-ADOrganizationalUnit -Name $service -Path $rootOU -ProtectedFromAccidentalDeletion $true

    # Création d'une liste temporaire des sous-OU
    $subOUsTemp = $subOUs
    if ($service -eq "Developpement") {
        $subOUsTemp += "Serveurs"
    }

    # Création des sous-OU
    foreach ($subOU in $subOUsTemp) {
        New-ADOrganizationalUnit -Name $subOU -Path "OU=$service,$rootOU" -ProtectedFromAccidentalDeletion $true
    }
}

# Ajout des utilisateurs depuis le fichier CSV
foreach ($user in $users) {
    # Définition correcte de l'OU de l'utilisateur
    $ouPath = "OU=$($user.Service),$rootOU"

    # Affichage pour debug
    Write-Host "OU Path: $ouPath"

    # Construction de l'identifiant utilisateur
    $identifiant = "$($user.Prenom).$($user.Nom)"

    # Création de l'utilisateur dans l'Active Directory
    New-ADUser -Name "$($user.Nom) $($user.Prenom)" `
               -GivenName $user.Prenom `
               -Surname $user.Nom `
               -SamAccountName $identifiant `
               -UserPrincipalName "$identifiant@$DomainFQDN" `
               -Path $ouPath `
               -AccountPassword (ConvertTo-SecureString -AsPlainText $mdp -Force) `
               -CannotChangePassword $false `
               -Enabled $true `
               -ChangePasswordAtLogon $true
}

Write-Host "Structure AD et utilisateurs créés avec succès !"
