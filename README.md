
# AD-Deployment-PowerShell

Script PowerShell de déploiement automatisé d'un environnement Active Directory sous Windows Server.

## Contexte
Projet réalisé dans le cadre de ma formation Bachelor DSNS (Cybersécurité) à l'ESIEE-IT.  
Objectif : automatiser le déploiement complet d'un AD depuis zéro via PowerShell.

## Environnement
- Windows Server 2016 (VM VirtualBox)
- PowerShell 5.1
- Rôle AD DS + DNS

## Ce que fait le script
- Installation du rôle AD DS
- Promotion du serveur en contrôleur de domaine
- Création des OUs (Utilisateurs, Groupes, Ordinateurs)
- Création des utilisateurs avec mot de passe sécurisé
- Création des groupes et affectation des membres
- Création et liaison d'une GPO de sécurité (désactivation panneau de configuration)
- Rapport final de déploiement

## Utilisation
```powershell
Set-ExecutionPolicy Unrestricted -Force
.\Deploy-AD.ps1
```

## Résultat
<img width="1010" height="851" alt="readme adds" src="https://github.com/user-attachments/assets/bbbd84d1-a5bc-4fa6-8c71-74103e5bb940" />
## Auteur
Lucas Bigot — [ESIEE-IT](https://www.esiee-it.fr) | Bachelor DSNS 
