# CONFIGURATION ENVIRONNEMENT ACTIVE DIRECTORY

## PRÉSENTATION
Ce programme est concue pour fonctionner dans des environnement Windows PowerShell (y compris les environnements sans bureau).

Ce programme permet :
1) La configuration de base des machines
2) L'installation de services (AD-DS, DNS, DHCP);
3) La promotion de contrôleurs de domaine (principal et secondaire)
4) La création d'OUs, de Groupes, d'Utilisateur, de GPOs dans l'Active Directory;

### Forêt, Domaine et Contrôleur de domaine
Ce programme permet la création/configuration :
1) de forêts;
2) de contrôleurs de domaine principal;
3) de contrôleurs de domaine secondaire;
4) de postes d'administration.

### Annuaire LDAP
Ce programme permet d'alimenter l'annuaire avec la création :
1) d'OUs;
2) de Groupes;
3) d'Utilisateurs;
4) de GPOs.

### DNS
Ce programme permet configurer le service DNS :
1) Création des Zones directes et inversées;
2) Création des enregistrements A et PTR;
3) Création des enregistrements NS;

### DHCP
Ce programme permet configurer le service DHCP :
1) Création de Plages d'adresses;
2) Configuration des options clients;

## UTILISATION
1) Prérequis :
- Une machine s'exécutant sous Windows Server (2016 ou ulterieur) ou Windows 10/11;
- Un utilisateur avec les privilège "Administrateurs";
- Modifier les variables dans le fichier **`variables.ps1`**
- Autoriser l'exécution de script PowerShell (.ps1);
```powershell
Set-ExecutionPolicy Unrestricted
```

2) Exécution :
- Se déplacer dans le répertoire :
```powershell
Set-Location <chemin_vers_le_programme>\KM_SUN_WinSrv\
```
- Exécuter le programme :
```powershell
.\Deploy_WinSrv_KM.ps1
```

## Auteurs
[KHOULKHALI Montasir]
[17/02/2025]

Merci d'avoir choisi cette méthode. Bonne chance !
