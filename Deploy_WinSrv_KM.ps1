# Importation des variables
. .\variables.ps1

function config_machine {
    # Menu principal
    Write-Host "`n*** MENU CONFIGURATION MACHINE SUN LILLE :" -BackgroundColor Blue -ForegroundColor White
    Write-Output "
    `n1 - Preparer le future Controleur de domaine principal
    `n2 - Configurer la foret sur le Contrôleur de domaine principal
    `n3 - Configurer l'annuaire LDAP
    `n4 - Preparer le future Controleur de domaine secondaire
    `n5 - Configurer le domaine sur le Contrôleur de domaine secondaire
    `n6 - Configurer un Poste Administrateur
    `n0 - Quitter `n"

    $choix = Read-Host "Configurer quel type de machine ? (0 pour quitter)"

    if ($choix -like "1")
        {.\functions\pdc\01_pdc_config_basic.ps1}

    elseif ($choix -like "2")
        {.\functions\pdc\02_pdc_config_ad_forest.ps1}

    elseif ($choix -like "3")
        {.\functions\pdc\03_pdc_config_ad.ps1}

    elseif ($choix -like "4")
        {.\functions\sdc\01_sdc_config_basic.ps1}

    elseif ($choix -like "5")
        {.\functions\sdc\02_sdc_config_ad.ps1}

    elseif ($choix -like "6")
        {.\functions\poste_admin\poste_admin_config.ps1}

    elseif ($choix -like "0")
        {Invoke-Expression -Command exit}

    else
        {Write-Warning "Erreur de choix !"
        config_machine}
}

config_machine
