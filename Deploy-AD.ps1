# ============================================================
# Deploy-AD.ps1
# Déploiement automatisé Active Directory — lucas.local
# Auteur : Lucas Bigot | ESIEE-IT | Bachelor DSNS Cybersécurité
# ============================================================

# --- VARIABLES ---
$DomainName     = "lucas.local"
$NetbiosName    = "LUCAS"
$DSRMPassword   = "Admin123!"
$DefaultPwd     = "Azerty123!"

# --- 1. INSTALLATION AD DS ---
Write-Host "[*] Installation du rôle AD DS..." -ForegroundColor Cyan
Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

# --- 2. PROMOTION EN CONTROLEUR DE DOMAINE ---
Write-Host "[*] Promotion en contrôleur de domaine..." -ForegroundColor Cyan
Install-ADDSForest `
    -DomainName $DomainName `
    -DomainNetbiosName $NetbiosName `
    -InstallDns:$true `
    -SafeModeAdministratorPassword (ConvertTo-SecureString $DSRMPassword -AsPlainText -Force) `
    -Force:$true

# ?? Le serveur redémarre ici automatiquement.
# Relancer le script depuis l'étape 3 après le redémarrage.

# --- 3. CREATION DES OUs ---
Write-Host "[*] Création des OUs..." -ForegroundColor Cyan
$OUs = @("Utilisateurs", "Groupes", "Ordinateurs")
foreach ($OU in $OUs) {
    New-ADOrganizationalUnit -Name $OU -Path "DC=lucas,DC=local" -ErrorAction SilentlyContinue
    Write-Host "  [+] OU '$OU' créée" -ForegroundColor Green
}

# --- 4. CREATION DES UTILISATEURS ---
Write-Host "[*] Création des utilisateurs..." -ForegroundColor Cyan
$Users = @(
    @{ Prenom="Jean";  Nom="Dupont"; Login="jdupont" },
    @{ Prenom="Marie"; Nom="Martin"; Login="mmartin" },
    @{ Prenom="Lucas"; Nom="Admin";  Login="ladmin"  }
)

foreach ($U in $Users) {
    New-ADUser `
        -Name "$($U.Prenom) $($U.Nom)" `
        -GivenName $U.Prenom `
        -Surname $U.Nom `
        -SamAccountName $U.Login `
        -UserPrincipalName "$($U.Login)@$DomainName" `
        -Path "OU=Utilisateurs,DC=lucas,DC=local" `
        -AccountPassword (ConvertTo-SecureString $DefaultPwd -AsPlainText -Force) `
        -Enabled $true `
        -ErrorAction SilentlyContinue
    Write-Host "  [+] Utilisateur '$($U.Prenom) $($U.Nom)' créé" -ForegroundColor Green
}

# --- 5. CREATION DES GROUPES ---
Write-Host "[*] Création des groupes..." -ForegroundColor Cyan
New-ADGroup -Name "GRP_Informatique" -GroupScope Global -Path "OU=Groupes,DC=lucas,DC=local" -ErrorAction SilentlyContinue
New-ADGroup -Name "GRP_RH"           -GroupScope Global -Path "OU=Groupes,DC=lucas,DC=local" -ErrorAction SilentlyContinue
Write-Host "  [+] Groupes GRP_Informatique et GRP_RH créés" -ForegroundColor Green

# --- 6. AFFECTATION DES UTILISATEURS AUX GROUPES ---
Write-Host "[*] Affectation des utilisateurs aux groupes..." -ForegroundColor Cyan
Add-ADGroupMember -Identity "GRP_Informatique" -Members "ladmin","jdupont"
Add-ADGroupMember -Identity "GRP_RH"           -Members "mmartin"
Write-Host "  [+] Membres ajoutés" -ForegroundColor Green

# --- 7. CREATION ET LIAISON GPO ---
Write-Host "[*] Création de la GPO de sécurité..." -ForegroundColor Cyan
New-GPO -Name "GPO_Securite" | New-GPLink -Target "DC=lucas,DC=local"
Set-GPRegistryValue -Name "GPO_Securite" `
    -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" `
    -ValueName "NoControlPanel" -Type DWord -Value 1
Write-Host "  [+] GPO_Securite créée et liée au domaine" -ForegroundColor Green

# --- 8. RAPPORT FINAL ---
Write-Host "`n========== DÉPLOIEMENT TERMINÉ ==========" -ForegroundColor Yellow
Write-Host "OUs      :" (Get-ADOrganizationalUnit -Filter * | Where-Object {$_.Name -in $OUs} | Measure-Object).Count
Write-Host "Users    :" (Get-ADUser -Filter * | Where-Object {$_.SamAccountName -in @("jdupont","mmartin","ladmin")} | Measure-Object).Count
Write-Host "Groupes  :" (Get-ADGroup -Filter {Name -like "GRP_*"} | Measure-Object).Count
Write-Host "GPO      :" (Get-GPO -Name "GPO_Securite").DisplayName
Write-Host "=========================================" -ForegroundColor Yellow