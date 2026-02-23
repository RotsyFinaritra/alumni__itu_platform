# 👤 Page de Profil Utilisateur

## 📋 Description

Page de profil utilisateur moderne et interactive pour la plateforme Alumni ITU. Cette page permet aux utilisateurs de :
- Consulter et modifier leurs informations personnelles
- Changer leur mot de passe
- Voir leur activité récente
- Consulter leurs statistiques

## 🔗 URL d'accès

```
http://localhost:8088/alumni/pages/module.jsp?but=pages/profil/mon-profil.jsp&currentMenu=MENDYN001-1
```

## 📁 Fichiers créés

```
alumni-war/web/
├── pages/
│   └── profil/
│       ├── mon-profil.jsp          # Page principale du profil
│       └── change-password.jsp     # Traitement changement mot de passe
└── assets/
    ├── css/
    │   └── profil.css              # Styles de la page profil
    └── img/
        └── default-avatar.png      # Avatar par défaut (SVG)
```

## ✨ Fonctionnalités

### 1️⃣ Onglet "Informations personnelles"

**Affichage** :
- Nom et prénom
- Numéro ETU
- Login
- Email
- Téléphone
- Adresse

**Actions** :
- Cliquer sur "Modifier" pour activer l'édition
- Modifier les champs nécessaires
- Cliquer sur "Enregistrer" pour sauvegarder
- Cliquer sur "Annuler" pour annuler les modifications

**Formulaire** :
```jsp
<form action="<%=lien%>?but=apresTarif.jsp" method="post">
    <input name="acte" type="hidden" value="update">
    <input name="bute" type="hidden" value="profil/mon-profil.jsp">
    <input name="classe" type="hidden" value="utilisateurAcade.UtilisateurPg">
    <input name="nomtable" type="hidden" value="utilisateur">
    <input name="refuser" type="hidden" value="<%=refuser%>">
    
    <!-- Vos champs ici -->
</form>
```

### 2️⃣ Onglet "Sécurité"

**Changement de mot de passe** :
- Mot de passe actuel (vérifié)
- Nouveau mot de passe (minimum 6 caractères)
- Confirmation du nouveau mot de passe

**Sécurité** :
- Affichage du statut du compte
- Dernière connexion

### 3️⃣ Onglet "Activité"

**Activités récentes** :
- Timeline des dernières actions
- Connexions
- Modifications du profil

**Statistiques** :
- Tâches complétées
- Projets actifs
- Collaborations
- Taux de réussite

### 4️⃣ Photo de profil

**Upload** :
- Cliquer sur l'icône de caméra sur l'avatar
- Sélectionner une image
- Prévisualisation instantanée
- Sauvegarde automatique

## 🎨 Design

**Palette de couleurs** :
- Primaire : `#2B68D9` (Bleu)
- Secondaire : `#1e4ba3` (Bleu foncé)
- Texte : `#1C1F21` (Noir)
- Fond : `#f8f9fa` (Gris clair)
- Bordure : `#e9ecef` (Gris)

**Composants** :
- Cards avec ombre douce
- Onglets interactifs
- Formulaires stylisés
- Animations fluides
- Design responsive

## 🔧 Intégration

### Ajouter au menu

Modifiez le fichier de configuration du menu pour ajouter :

```jsp
<a href="module.jsp?but=profil/mon-profil.jsp&currentMenu=MENDYN001-1">
    <i class="fa fa-user-circle"></i>
    <span>Mon Profil</span>
</a>
```

### Structure de la base de données

Table `utilisateur` (utilisée) :
```sql
CREATE TABLE utilisateur (
    refuser SERIAL PRIMARY KEY,
    loginuser VARCHAR(100),
    pwduser VARCHAR(255),
    nomuser VARCHAR(100),
    prenom VARCHAR(100),
    mail VARCHAR(150),
    teluser VARCHAR(20),
    adruser TEXT,
    etu VARCHAR(50),
    photo VARCHAR(255),
    idtypeutilisateur VARCHAR(20),
    idpromotion VARCHAR(20),
    idrole VARCHAR(20)
);
```

## 🔐 Sécurité

**Vérifications** :
- Session utilisateur requise (`security-login.jsp`)
- Seul l'utilisateur connecté peut voir/modifier son profil
- Validation du mot de passe actuel avant changement
- Cryptage du mot de passe (via `UtilitaireAcade.crypte()`)
- Protection CSRF via session

## 📱 Responsive

La page est totalement responsive :
- **Desktop** : Layout en 2 colonnes
- **Tablette** : Layout adapté
- **Mobile** : Layout en 1 colonne, onglets verticaux

## 🚀 Utilisation

### Accéder à la page

```jsp
<a href="module.jsp?but=profil/mon-profil.jsp&currentMenu=MENDYN001-1">
    Mon Profil
</a>
```

### Modifier les informations

1. Ouvrir la page profil
2. Cliquer sur "Modifier"
3. Modifier les champs
4. Cliquer sur "Enregistrer"
5. Confirmation par redirection

### Changer le mot de passe

1. Aller dans l'onglet "Sécurité"
2. Remplir le formulaire :
   - Mot de passe actuel
   - Nouveau mot de passe
   - Confirmation
3. Cliquer sur "Modifier le mot de passe"
4. Confirmation par alert JavaScript

## 🎯 Points d'amélioration possibles

- [ ] Upload de photo avec gestion de fichiers (servlet)
- [ ] Historique d'activité depuis la base de données
- [ ] Statistiques réelles depuis la BDD
- [ ] Double authentification (2FA)
- [ ] Notifications par email
- [ ] Export des données personnelles (RGPD)
- [ ] Validation côté serveur plus robuste
- [ ] Gestion de sessions multiples

## 🐛 Dépannage

### Problème : "Utilisateur non trouvé"
**Solution** : Vérifier que la table `utilisateur` contient bien l'utilisateur connecté

### Problème : Photo ne s'affiche pas
**Solution** : Vérifier le chemin de la photo ou utiliser l'avatar par défaut

### Problème : Erreur lors du changement de mot de passe
**Solution** : Vérifier la méthode de cryptage `UtilitaireAcade.crypte()`

### Problème : Formulaire ne se sauvegarde pas
**Solution** : Vérifier que `apresTarif.jsp` est accessible et que les paramètres sont corrects

## 📝 Exemple de flux

```
1. Utilisateur clique sur "Mon Profil" dans le menu
   ↓
2. module.jsp charge profil/mon-profil.jsp
   ↓
3. Récupération des données depuis la BDD (table utilisateur)
   ↓
4. Affichage du profil avec 3 onglets
   ↓
5. Utilisateur modifie ses infos
   ↓
6. Soumission du formulaire vers apresTarif.jsp
   ↓
7. apresTarif.jsp traite la mise à jour (acte=update)
   ↓
8. Redirection vers profil/mon-profil.jsp avec données mises à jour
```

## 🎨 Personnalisation

### Modifier les couleurs

Éditez `assets/css/profil.css` :

```css
/* Couleur primaire */
background: #VOTRE_COULEUR;

/* Gradient de l'en-tête */
background: linear-gradient(135deg, #COULEUR1 0%, #COULEUR2 100%);
```

### Ajouter des champs

Dans `mon-profil.jsp`, ajouter dans la section formulaire :

```jsp
<div class="form-group">
    <label for="nouveau_champ">
        <i class="fa fa-icon"></i> Libellé
    </label>
    <input type="text" id="nouveau_champ" name="nouveau_champ" 
           value="<%=valeur%>" class="form-control" disabled>
</div>
```

## 📞 Support

Pour toute question ou amélioration, contactez l'équipe de développement.

---

**Créé le** : 23 février 2026  
**Version** : 1.0  
**Framework** : APJ (Alumni Platform Java)
