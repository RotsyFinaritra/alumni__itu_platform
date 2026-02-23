# 🚀 Guide de Test - Page de Profil

## ✅ Fichiers créés

Voici tous les fichiers qui ont été créés pour la page de profil :

### 📄 Pages JSP
1. **`alumni-war/web/pages/profil/mon-profil.jsp`**
   - Page principale du profil utilisateur
   - Affiche et permet de modifier les informations
   - Contient 3 onglets : Infos, Sécurité, Activité

2. **`alumni-war/web/pages/profil/change-password.jsp`**
   - Traitement du changement de mot de passe
   - Validation et cryptage
   - Redirection avec message

### 🎨 Styles
3. **`alumni-war/web/assets/css/profil.css`**
   - Tous les styles de la page profil
   - Design moderne et responsive
   - Animations et transitions

### 🖼️ Images
4. **`alumni-war/web/assets/img/default-avatar.png`**
   - Avatar par défaut (SVG)
   - Utilisé si l'utilisateur n'a pas de photo

### 📚 Documentation
5. **`alumni-war/web/pages/profil/README.md`**
   - Documentation complète de la fonctionnalité

---

## 🧪 Comment tester

### 1️⃣ **Démarrer le serveur**

Assurez-vous que votre serveur WildFly est démarré et que l'application est déployée.

### 2️⃣ **Se connecter**

Accédez à :
```
http://localhost:8088/alumni/
```

Connectez-vous avec vos identifiants.

### 3️⃣ **Accéder à la page profil**

#### Option A : URL directe
```
http://localhost:8088/alumni/pages/module.jsp?but=pages/profil/mon-profil.jsp&currentMenu=MENDYN001-1
```

#### Option B : Ajouter au menu (optionnel)
Modifiez le fichier de menu pour ajouter un lien :
```jsp
<a href="module.jsp?but=profil/mon-profil.jsp&currentMenu=MENDYN001-1">
    <i class="fa fa-user-circle"></i> Mon Profil
</a>
```

---

## 🎯 Tests à effectuer

### ✅ Test 1 : Affichage du profil

**Actions** :
1. Accéder à la page profil
2. Vérifier que les informations s'affichent correctement

**Résultat attendu** :
- ✅ Nom et prénom affichés
- ✅ Login affiché
- ✅ Email affiché (si renseigné)
- ✅ Téléphone affiché (si renseigné)
- ✅ Avatar par défaut ou photo utilisateur
- ✅ 3 onglets visibles

### ✅ Test 2 : Navigation entre onglets

**Actions** :
1. Cliquer sur l'onglet "Sécurité"
2. Cliquer sur l'onglet "Activité"
3. Revenir sur "Informations personnelles"

**Résultat attendu** :
- ✅ Les onglets changent sans rechargement
- ✅ Le contenu s'affiche correctement
- ✅ L'onglet actif est bien mis en surbrillance

### ✅ Test 3 : Modification des informations

**Actions** :
1. Dans l'onglet "Informations personnelles"
2. Cliquer sur le bouton "Modifier"
3. Modifier le téléphone : `0340123456`
4. Modifier l'adresse : `Antananarivo, Madagascar`
5. Cliquer sur "Enregistrer"

**Résultat attendu** :
- ✅ Les champs deviennent éditables
- ✅ Les boutons "Annuler" et "Enregistrer" apparaissent
- ✅ Après enregistrement, redirection vers la page profil
- ✅ Les modifications sont sauvegardées dans la BDD
- ✅ Les nouvelles valeurs s'affichent

### ✅ Test 4 : Annulation de modification

**Actions** :
1. Cliquer sur "Modifier"
2. Modifier un champ
3. Cliquer sur "Annuler"

**Résultat attendu** :
- ✅ La page se recharge
- ✅ Les modifications ne sont pas sauvegardées
- ✅ Les champs redeviennent non éditables

### ✅ Test 5 : Changement de mot de passe (succès)

**Actions** :
1. Aller dans l'onglet "Sécurité"
2. Remplir :
   - Mot de passe actuel : `votre_mdp_actuel`
   - Nouveau mot de passe : `nouveau123`
   - Confirmation : `nouveau123`
3. Cliquer sur "Modifier le mot de passe"

**Résultat attendu** :
- ✅ Message : "Mot de passe modifié avec succès !"
- ✅ Redirection vers la page profil
- ✅ Possibilité de se reconnecter avec le nouveau mot de passe

### ✅ Test 6 : Changement de mot de passe (erreurs)

#### Test 6a : Mots de passe ne correspondent pas
**Actions** :
- Nouveau mot de passe : `nouveau123`
- Confirmation : `nouveau456`
- Soumettre

**Résultat attendu** :
- ✅ Alert : "Les nouveaux mots de passe ne correspondent pas"
- ✅ Retour au formulaire

#### Test 6b : Mot de passe trop court
**Actions** :
- Nouveau mot de passe : `123`
- Soumettre

**Résultat attendu** :
- ✅ Alert : "Le mot de passe doit contenir au moins 6 caractères"

#### Test 6c : Ancien mot de passe incorrect
**Actions** :
- Mot de passe actuel : `mauvais_mdp`
- Soumettre

**Résultat attendu** :
- ✅ Alert : "L'ancien mot de passe est incorrect"

### ✅ Test 7 : Responsive design

**Actions** :
1. Redimensionner la fenêtre du navigateur
2. Tester sur mobile (F12 > mode responsive)

**Résultat attendu** :
- ✅ Sur desktop : Layout en 2 colonnes
- ✅ Sur tablette : Layout adapté
- ✅ Sur mobile : Layout en 1 colonne
- ✅ Onglets en mode vertical sur mobile
- ✅ Toutes les fonctionnalités accessibles

### ✅ Test 8 : Avatar par défaut

**Actions** :
1. Si l'utilisateur n'a pas de photo définie
2. Vérifier l'affichage

**Résultat attendu** :
- ✅ Avatar SVG par défaut s'affiche (icône utilisateur bleu)
- ✅ Pas d'erreur 404

---

## 🐛 Débogage

### Problème : Page ne s'affiche pas

**Vérifications** :
```bash
# 1. Vérifier que le fichier existe
ls alumni-war/web/pages/profil/mon-profil.jsp

# 2. Vérifier les logs du serveur
tail -f /chemin/vers/wildfly/standalone/log/server.log

# 3. Vérifier la compilation
# Regarder si des erreurs JSP apparaissent
```

**Solution** :
- Vérifier que le chemin dans l'URL est correct : `but=pages/profil/mon-profil.jsp`
- Vérifier que l'utilisateur est connecté (session valide)

### Problème : CSS ne s'applique pas

**Vérifications** :
```jsp
<!-- Vérifier dans le navigateur (F12 > Network) -->
<!-- Le fichier profil.css doit être chargé -->
```

**Solution** :
- Vider le cache du navigateur (Ctrl+F5)
- Vérifier que le fichier `assets/css/profil.css` existe
- Vérifier le chemin : `${pageContext.request.contextPath}/assets/css/profil.css`

### Problème : Données ne se sauvegardent pas

**Vérifications** :
```jsp
<!-- Vérifier dans les logs du serveur -->
<!-- Vérifier les paramètres du formulaire -->
```

**Solution** :
- Vérifier que `apresTarif.jsp` fonctionne correctement
- Vérifier les paramètres cachés du formulaire :
  - `acte=update`
  - `classe=utilisateurAcade.UtilisateurPg`
  - `nomtable=utilisateur`
- Vérifier que l'utilisateur a les droits de modification

### Problème : Erreur "ClassNotFoundException"

**Solution** :
```bash
# Vérifier que la classe UtilisateurPg existe
ls alumni-ejb/src/java/utilisateurAcade/UtilisateurPg.java

# Recompiler si nécessaire
cd /chemin/vers/projet
ant clean build deploy
```

---

## 📊 Données de test

### Table utilisateur

Exemple de données :
```sql
INSERT INTO utilisateur (
    loginuser, pwduser, nomuser, prenom, 
    mail, teluser, adruser, etu
) VALUES (
    'test.user', 
    'password123', 
    'RAZAFIMANDIMBY', 
    'Jean', 
    'jean@itu.mg', 
    '0340123456', 
    'Antananarivo', 
    'ETU001234'
);
```

---

## 🎨 Personnalisation rapide

### Changer la couleur principale

Éditez `assets/css/profil.css` :
```css
/* Ligne 88 : couleur des onglets actifs */
.tab-btn.active {
    color: #VOTRE_COULEUR;
    border-bottom-color: #VOTRE_COULEUR;
}

/* Ligne 51 : gradient de l'en-tête */
.profil-header-bg {
    background: linear-gradient(135deg, #VOTRE_COULEUR1 0%, #VOTRE_COULEUR2 100%);
}
```

### Ajouter un champ

Dans `mon-profil.jsp`, section formulaire :
```jsp
<div class="form-group">
    <label for="nouveau_champ">
        <i class="fa fa-star"></i> Mon Nouveau Champ
    </label>
    <input type="text" id="nouveau_champ" name="nouveau_champ" 
           value="<%=valeur%>" class="form-control" disabled>
</div>
```

---

## ✨ Fonctionnalités avancées (à venir)

- [ ] Upload de photo de profil avec servlet
- [ ] Historique d'activité depuis la BDD
- [ ] Statistiques réelles (tâches, projets)
- [ ] Export des données (RGPD)
- [ ] Notifications par email
- [ ] Double authentification (2FA)

---

## 📝 Checklist finale

Avant de considérer la page comme terminée :

- [x] Page profil créée et accessible
- [x] CSS appliqué et responsive
- [x] Affichage des informations utilisateur
- [x] Modification des informations fonctionnelle
- [x] Changement de mot de passe fonctionnel
- [x] Validation des formulaires
- [x] Gestion des erreurs
- [x] Design moderne et professionnel
- [x] Documentation complète
- [ ] Tests utilisateurs effectués
- [ ] Validation en production

---

**Bon test ! 🚀**
