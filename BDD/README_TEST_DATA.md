# 🗄️ Données de Test - Alumni ITU Platform

## 📋 Vue d'ensemble

Ce document décrit les données de test insérées dans la base de données pour faciliter le développement et les tests.

## 👥 Comptes utilisateurs de test

### 🔐 Informations de connexion

**IMPORTANT** : Tous les mots de passe sont **`test123`** (chiffré avec niveau=5, croissante=0)

| Login | Mot de passe | Nom complet | Rôle | Type | ETU |
|-------|--------------|-------------|------|------|-----|
| `admin` | `admin` | Admin Super | Administrateur | Admin | - |
| `jean.rakoto` | `test123` | RAKOTO Jean | Alumni | Alumni | ETU001234 |
| `marie.razaf` | `test123` | RAZAFINDRAKOTO Marie | Alumni | Alumni | ETU002345 |
| `paul.andriam` | `test123` | ANDRIAMIHAJA Paul | Étudiant | Étudiant | ETU003456 |
| `sophie.raja` | `test123` | RAJAONAH Sophie | Alumni | Alumni | ETU004567 |
| `luc.rakotom` | `test123` | RAKOTOMALALA Luc | Administrateur | Enseignant | - |

---

## 📊 Détails des utilisateurs

### 1️⃣ **Admin** (Compte administrateur par défaut)
```
Login      : admin
Password   : admin
Nom        : Admin Super
Email      : admin@alumni-itu.mg
Rôle       : admin
Refuser    : 1
```
**Utilisation** : Compte super-admin pour la configuration du système

---

### 2️⃣ **Jean RAKOTO** (Alumni typique)
```
Login      : jean.rakoto
Password   : test123
Nom        : RAKOTO Jean
Email      : jean.rakoto@alumni-itu.mg
Téléphone  : 0340123456
Adresse    : Antananarivo, Madagascar
ETU        : ETU001234
Rôle       : alumni
Promotion  : Promotion 2023
Refuser    : 2
```
**Profil** :
- Spécialités : Développement Web, Data Science
- Compétences : Java, JavaScript, SQL
- Expériences :
  - Développeur Full Stack chez Nexah Madagascar (CDI, depuis juillet 2023)
  - Stagiaire Développeur chez Orange Madagascar (Stage, janv-juin 2023)
- Réseaux : LinkedIn, GitHub

---

### 3️⃣ **Marie RAZAFINDRAKOTO** (Alumni)
```
Login      : marie.razaf
Password   : test123
Nom        : RAZAFINDRAKOTO Marie
Email      : marie.razaf@alumni-itu.mg
Téléphone  : 0341234567
Adresse    : Fianarantsoa, Madagascar
ETU        : ETU002345
Rôle       : alumni
Promotion  : Promotion 2023
Refuser    : 3
```
**Profil** :
- Spécialités : Cybersécurité
- Compétences : Python, SQL
- Expériences :
  - Ingénieur Réseaux chez Telma Madagascar (CDD, depuis juillet 2023)
- Réseaux : LinkedIn

---

### 4️⃣ **Paul ANDRIAMIHAJA** (Étudiant actuel)
```
Login      : paul.andriam
Password   : test123
Nom        : ANDRIAMIHAJA Paul
Email      : paul.andriam@itu.mg
Téléphone  : 0342345678
Adresse    : Toamasina, Madagascar
ETU        : ETU003456
Rôle       : etudiant
Promotion  : Promotion 2025 (en cours)
Refuser    : 4
```
**Profil** :
- Spécialités : Aucune (étudiant en cours)
- Compétences : Aucune
- Expériences : Aucune

---

### 5️⃣ **Sophie RAJAONAH** (Alumni avec profil complet)
```
Login      : sophie.raja
Password   : test123
Nom        : RAJAONAH Sophie
Email      : sophie.raja@alumni-itu.mg
Téléphone  : 0343456789
Adresse    : 101 Rue de l'Université, Antananarivo
ETU        : ETU004567
Rôle       : alumni
Promotion  : Promotion 2024
Refuser    : 5
```
**Profil** :
- Spécialités : Intelligence Artificielle
- Compétences : Python, React
- Expériences :
  - Data Scientist chez Accenture Madagascar (CDI, depuis juillet 2024)
- Réseaux : GitHub, LinkedIn

---

### 6️⃣ **Luc RAKOTOMALALA** (Enseignant/Admin)
```
Login      : luc.rakotom
Password   : test123
Nom        : RAKOTOMALALA Luc
Email      : luc.rakotom@itu.mg
Téléphone  : 0344567890
Adresse    : Antananarivo
Rôle       : admin
Type       : Enseignant
Refuser    : 6
```
**Utilisation** : Compte enseignant avec droits administrateur

---

## 🎯 Utilisation pour tester la page profil

### Test 1 : Connexion et affichage
1. Connectez-vous avec `jean.rakoto` / `test123`
2. Accédez à : `http://localhost:8088/alumni/pages/module.jsp?but=profil/mon-profil.jsp&currentMenu=MENDYN001`
3. Vérifiez que les informations s'affichent :
   - ✅ Nom : RAKOTO
   - ✅ Prénom : Jean
   - ✅ ETU : ETU001234
   - ✅ Email : jean.rakoto@alumni-itu.mg
   - ✅ Téléphone : 0340123456
   - ✅ Adresse : Antananarivo, Madagascar

### Test 2 : Modification des informations
1. Cliquez sur "Modifier"
2. Changez le téléphone : `0340999888`
3. Changez l'adresse : `Nouvelle adresse, Antananarivo`
4. Cliquez sur "Enregistrer"
5. Vérifiez que les modifications sont sauvegardées

### Test 3 : Changement de mot de passe
1. Allez dans l'onglet "Sécurité"
2. Remplissez :
   - Mot de passe actuel : `test123`
   - Nouveau mot de passe : `nouveau123`
   - Confirmation : `nouveau123`
3. Cliquez sur "Modifier le mot de passe"
4. Déconnectez-vous
5. Reconnectez-vous avec `jean.rakoto` / `nouveau123`

### Test 4 : Test avec différents utilisateurs
- Testez avec `marie.razaf` / `test123` (profil différent)
- Testez avec `sophie.raja` / `test123` (profil complet)
- Testez avec `paul.andriam` / `test123` (étudiant sans expérience)

---

## 📦 Données de référence insérées

### Promotions
- PROM0001 : Promotion 2023 (année 2023)
- PROM0002 : Promotion 2024 (année 2024)
- PROM0003 : Promotion 2025 (année 2025)

### Types d'emploi
- TE0000001 : CDI
- TE0000002 : CDD
- TE0000003 : Stage
- TE0000004 : Freelance

### Spécialités
- SPEC0001 : Développement Web
- SPEC0002 : Data Science
- SPEC0003 : Cybersécurité
- SPEC0004 : Intelligence Artificielle
- SPEC0005 : Réseaux et Télécommunications

### Compétences
- COMP0001 : Java
- COMP0002 : Python
- COMP0003 : JavaScript
- COMP0004 : SQL
- COMP0005 : React
- COMP0006 : Spring Boot
- COMP0007 : Docker
- COMP0008 : Git

### Entreprises
- ENT0001 : Orange Madagascar
- ENT0002 : Telma Madagascar
- ENT0003 : Nexah Madagascar
- ENT0004 : BNI Madagascar
- ENT0005 : Accenture Madagascar

### Réseaux sociaux
- RS0001 : LinkedIn (fab fa-linkedin)
- RS0002 : GitHub (fab fa-github)
- RS0003 : Facebook (fab fa-facebook)
- RS0004 : Twitter (fab fa-twitter)

---

## 🚀 Comment insérer les données

### Option 1 : Script complet (création + données)
```bash
psql -U postgres -d alumni_itu -f BDD/2026-02-21-Rotsy-1.sql
```

### Option 2 : Données de test uniquement (BDD déjà créée)
```bash
psql -U postgres -d alumni_itu -f BDD/insert-test-data.sql
```

### Option 3 : Via pgAdmin
1. Ouvrez pgAdmin
2. Connectez-vous à votre serveur PostgreSQL
3. Sélectionnez la base de données `alumni_itu`
4. Cliquez sur "Query Tool"
5. Ouvrez le fichier `insert-test-data.sql`
6. Exécutez le script (F5)

---

## 🔍 Vérification des données

### Vérifier les utilisateurs créés
```sql
SELECT refuser, loginuser, nomuser, prenom, etu, mail, idrole 
FROM utilisateur 
ORDER BY refuser;
```

### Vérifier le cryptage des mots de passe
```sql
SELECT u.refuser, u.loginuser, u.pwduser, p.niveau, p.croissante
FROM utilisateur u
LEFT JOIN paramcrypt p ON p.idutilisateur = CAST(u.refuser AS VARCHAR)
ORDER BY u.refuser;
```

### Vérifier les menus disponibles
```sql
SELECT m.id, m.libelle, m.href, um.idrole
FROM menudynamique m
LEFT JOIN usermenu um ON um.idmenu = m.id
ORDER BY m.rang;
```

---

## 🐛 Dépannage

### Problème : "duplicate key value violates unique constraint"
**Cause** : Les données existent déjà dans la base
**Solution** :
```sql
-- Supprimer les données de test existantes
DELETE FROM utilisateur WHERE refuser BETWEEN 2 AND 6;
DELETE FROM paramcrypt WHERE id BETWEEN 'CRY0000002' AND 'CRY0000006';
-- Puis réexécuter le script
```

### Problème : "cannot connect to database"
**Cause** : PostgreSQL n'est pas démarré ou mauvais nom de base
**Solution** :
```bash
# Vérifier que PostgreSQL est démarré
pg_ctl status

# Vérifier que la base existe
psql -U postgres -l | grep alumni
```

### Problème : Login échoue avec les comptes de test
**Cause** : Problème de cryptage du mot de passe
**Solution** :
1. Vérifier que `paramcrypt` contient bien les entrées
2. Vérifier que le mot de passe est bien chiffré (`yjxy678` pour `test123`)
3. Tester avec le compte `admin` / `admin` qui fonctionne

---

## 📝 Notes importantes

1. **Mots de passe** : Tous les comptes de test utilisent le même mot de passe `test123` (chiffré = `yjxy678`)
2. **Cryptage** : Niveau 5, croissante 0 (chaque caractère +5 dans l'alphabet)
3. **Séquences** : Les séquences sont synchronisées pour éviter les conflits
4. **Menu** : Le menu "Mon Profil" est accessible à tous les rôles (admin, alumni, etudiant)

---

**Créé le** : 23 février 2026  
**Base de données** : PostgreSQL  
**Projet** : Alumni ITU Platform
