# Plan de Migration APJ - Alumni ITU Platform

> **Date** : 25 février 2026  
> **Objectif** : Migrer les pages JSP **du module alumni** qui n'utilisent pas encore la structure APJ  
> **Scope** : Uniquement les modules alumni — Profil, Annuaire, Modération, Inscription, Accueil

---

## 1. État des Lieux — Modules Alumni

### Pages alumni DÉJÀ conformes APJ ✅

| Module | Page | Classe APJ utilisée |
|--------|------|---------------------|
| **Profil** | `profil/competence-saisie.jsp` | `PageInsertMultiple` |
| **Profil** | `profil/specialite-saisie.jsp` | `PageInsertMultiple` |
| **Profil** | `profil/parcours-saisie.jsp` | `PageInsertMultiple` |
| **Profil** | `profil/experience-saisie.jsp` | `PageInsertMultiple` |
| **Profil** | `profil/mon-profil-saisie.jsp` | `PageInsert` |
| **Profil** | `profil/mon-profil.jsp` | `PageConsulte` |
| **Profil** | `profil/reseau-saisie.jsp` | `PageInsert` |
| **Profil** | `profil/experience-edit.jsp` | `PageInsert` (mode update) |
| **Profil** | `profil/parcours-edit.jsp` | `PageInsert` (mode update) |
| **Catégorie** | `categorie/categorie-fiche.jsp` | `PageConsulte` |
| **Catégorie** | `categorie/categorie-liste.jsp` | `PageRecherche` |
| **Catégorie** | `categorie/categorie-saisie.jsp` | `PageInsert` |
| **Annuaire** | `annuaire/annuaire-liste.jsp` | `PageRecherche` |
| **Recherche** | `recherche-global.jsp` | `PageRecherche` |

### Pages alumni UTILITAIRES / TRAITEMENT (pas à migrer) ⏭️

| Page | Rôle |
|------|------|
| `profil/save-competences-apj.jsp` | Sauvegarde compétences |
| `profil/save-competences.jsp` | Sauvegarde compétences (ancienne) |
| `profil/save-experience-apj.jsp` | Sauvegarde expériences |
| `profil/save-parcours-apj.jsp` | Sauvegarde parcours |
| `profil/save-specialites-apj.jsp` | Sauvegarde spécialités |
| `profil/toggle-visibilite.jsp` | Toggle AJAX visibilité |
| `profil/update-profil.jsp` | Traitement mise à jour profil |
| `moderation/moderation-action.jsp` | Traitement actions modération |
| `testLogin.jsp` | Traitement d'authentification |
| `testRegister.jsp` | Traitement d'inscription |

---

## 2. Pages Alumni à Migrer vers APJ 🔴

### 2.1 — `profil/competence-tab.jsp` (Fragment liste)

- **Type actuel** : Fragment d'onglet inclus dans `mon-profil.jsp`
- **Implémentation actuelle** : `CGenUtil.rechercher()` brut + HTML manuel (liste de compétences et spécialités avec badges)
- **Lignes** : 127 lignes
- **Classe APJ cible** : Aucune (fragment embedded) — **conserver le HTML custom + couche CSS**
- **Priorité** : ⬜ Basse
- **Justification** : Fragment d'onglet inclus via `jsp:include`. Le rendu (badges, cards) est spécifique et ne correspond pas à un tableau standard APJ.
- **Action** : Extraire les styles inline dans un fichier `profil-tabs.css` partagé

### 2.2 — `profil/experience-tab.jsp` (Fragment liste)

- **Type actuel** : Fragment d'onglet — liste d'expériences avec boutons edit/delete
- **Implémentation actuelle** : `CGenUtil.rechercher()` brut + HTML manuel
- **Lignes** : 146 lignes
- **Classe APJ cible** : Aucune — **conserver custom + couche CSS**
- **Priorité** : ⬜ Basse
- **Action** : Mutualiser les styles dans `profil-tabs.css`

### 2.3 — `profil/parcours-tab.jsp` (Fragment liste)

- **Type actuel** : Fragment d'onglet — liste parcours académiques
- **Implémentation actuelle** : `CGenUtil.rechercher()` brut + HTML manuel
- **Lignes** : 142 lignes
- **Classe APJ cible** : Aucune — **conserver custom + couche CSS**
- **Priorité** : ⬜ Basse
- **Action** : Mutualiser CSS dans `profil-tabs.css`

### 2.4 — `profil/reseaux-tab.jsp` (Fragment liste)

- **Type actuel** : Fragment d'onglet — liste réseaux sociaux
- **Implémentation actuelle** : `CGenUtil.rechercher()` brut + HTML manuel
- **Lignes** : 119 lignes
- **Classe APJ cible** : Aucune — **conserver custom + couche CSS**
- **Priorité** : ⬜ Basse
- **Action** : Mutualiser CSS dans `profil-tabs.css`

### 2.5 — `profil/visibilite.jsp` (Formulaire settings) ⭐ ✅ MIGRÉ APJ

- **Type actuel** : Page formulaire APJ — configuration de la visibilité des champs du profil
- **Implémentation** : `PageUpdate` sur vue pivot `v_visibilite_config` + `Liste` (Visible/Masqué) + sauvegarde via `VisibiliteService`
- **Classe APJ** : `PageUpdate` avec bean `VisibiliteConfig`
- **Statut** : ✅ Migré — vue SQL + bean + JSP PageUpdate
- **Fichiers créés** : `BDD/2026-02-25-Rotsy-1.sql`, `utilisateurAcade/VisibiliteConfig.java`

### 2.8 — `moderation/moderation-liste.jsp` (Liste custom) ⭐⭐

- **Type actuel** : Page de liste avec recherche
- **Implémentation actuelle** : Utilise **`PageRecherche` pour les données**, mais le rendu HTML est **entièrement custom** (cards utilisateur avec photo, badges, boutons d'action). N'utilise PAS `pr.getTableau().getHtml()`.
- **Lignes** : 508 lignes
- **Classe APJ cible** : `PageRecherche` (déjà en place pour les données, compléter le rendu)
- **Priorité** : 🟡 Moyenne
- **Option A — Full APJ** : Remplacer le HTML custom par `pr.getTableau().getHtml()` + couche CSS
- **Option B — Hybrid (recommandée)** : Garder les cards + utiliser `pr.getFormu().getHtmlEnsemble()` pour la recherche et `pr.getBasPage()` pour la pagination
- **Action** : Extraire les ~200 lignes de CSS inline dans `moderation-liste.css`

### 2.9 — `moderation/moderation-historique.jsp` (Liste custom) ⭐⭐

- **Type actuel** : Page de liste historique de modération
- **Implémentation actuelle** : Utilise **`PageRecherche` pour les données**, mais le rendu est un tableau HTML custom. N'utilise PAS `pr.getTableau().getHtml()`.
- **Lignes** : 180 lignes
- **Classe APJ cible** : `PageRecherche` (compléter le rendu standard)
- **Priorité** : 🟢 Haute
- **Plan** :
  1. Remplacer le tableau HTML custom par `pr.getTableau().getHtml()` et `pr.getBasPage()`
  2. Configurer les labels avec `pr.getTableau().setLibelleAffiche(...)`
  3. Ajouter une couche CSS pour harmoniser le rendu

### 2.10 — `accueil.jsp` (Dashboard)

- **Type actuel** : Page d'accueil avec cartes de navigation vers les modules
- **Implémentation actuelle** : HTML/CSS statique, aucune logique Java
- **Lignes** : 83 lignes
- **Classe APJ cible** : Aucune — page statique, pas de données
- **Priorité** : ⬜ Hors scope APJ
- **Action** : CSS déjà externalisé dans `accueil.css` ✅

### 2.11 — `inscription.jsp` (Formulaire d'inscription) ⭐⭐

- **Type actuel** : Page d'inscription standalone (hors module.jsp)
- **Implémentation actuelle** : HTML/CSS/JS — wizard multi-étapes, upload photo, post vers `testRegister.jsp`
- **Lignes** : 321 lignes
- **Classe APJ cible** : Garder custom — standalone hors module.jsp, wizard multi-step incompatible avec PageInsert
- **Priorité** : 🟡 Moyenne
- **Action** : CSS déjà dans `refontlogin.css` et `api-global-style.css`

---

## 3. Résumé des Actions Alumni

### Migrations APJ à effectuer

| # | Page | Action | Priorité | Statut |
|---|------|--------|----------|--------|
| 1 | `moderation/moderation-historique.jsp` | Compléter → `pr.getTableau().getHtml()` + `pr.getBasPage()` | 🟢 Haute | ✅ Fait |
| 2 | `moderation/moderation-liste.jsp` | Compléter : `pr.getFormu().getHtmlEnsemble()` pour recherche + CSS externe | 🟡 Moyenne | ✅ Fait |
| 5 | `profil/visibilite.jsp` | Migration complète → `PageUpdate` + vue pivot `v_visibilite_config` | 🟡 Moyenne | ✅ Fait |

### Actions CSS (couche de style, pas de migration APJ)

| # | Page(s) | Action | Statut |
|---|---------|--------|--------|
| 3 | `profil/competence-tab.jsp`, `experience-tab.jsp`, `parcours-tab.jsp`, `reseaux-tab.jsp` | Créer `profil-tabs.css` et extraire les styles inline (~200 lignes) | ✅ Fait |
| 4 | `moderation/moderation-liste.jsp` | Créer `moderation-liste.css` (~200 lignes inline) | ✅ Fait |

### Pages alumni sans action nécessaire

| Page | Raison |
|------|--------|
| `accueil.jsp` | Dashboard statique, CSS déjà externe |
| `inscription.jsp` | Standalone, wizard multi-step, CSS déjà externe |
| `chatbot/chat.jsp` | Widget JS interactif, pas de données DB |

---

## 4. Plan d'Exécution par Étapes

### Étape 1 — Extraction CSS (prérequis, 0 risque) ✅ FAIT

Fichiers CSS créés :

```
alumni-war/web/assets/css/
├── profil-tabs.css          ← styles des 4 onglets profil       ✅
├── profil-visibilite.css    ← styles page visibilité            ✅
└── moderation-liste.css     ← styles liste modération           ✅
```

Pages mises à jour avec `<link>` externe : `competence-tab.jsp`, `experience-tab.jsp`, `parcours-tab.jsp`, `reseaux-tab.jsp`, `visibilite.jsp`, `moderation-liste.jsp`.

### Étape 2 — Migration `moderation-historique.jsp` ✅ FAIT

Migration complète vers APJ standard :
- Tableau HTML custom (~60 lignes) remplacé par `pr.getTableau().getHtml()` + `pr.getBasPage()`
- Recherche : `pr.getFormu().getHtmlEnsemble()` dans un `<form>`
- Labels configurés via `pr.getTableau().setLibelleAffiche()`
- Liens cliquables sur colonne utilisateur via `pr.getTableau().setLien()` + `setColonneLien()`
- CSS inline supprimé (badges action custom remplacés par rendu APJ standard)

### Étape 3 — Compléter `moderation-liste.jsp` (hybrid) ✅ FAIT

Migration hybride effectuée :
- Recherche : `pr.getFormu().getHtmlEnsemble()` dans un `<form>` (remplace `pr.getFormu().getHtml()`)
- ~200 lignes CSS inline extraites dans `moderation-liste.css`
- Rendu cards utilisateur conservé (design volontaire)
- Pagination via `pr.getPagination()` conservée
- Modal ban + JavaScript conservés

---

## 5. Statistiques Alumni

| Catégorie | Nombre de pages |
|-----------|----------------|
| **Conformes APJ** | 22 pages alumni (19 + 3 migrées) |
| **Custom justifié (CSS externalisé)** | 4 pages (4 tabs profil) |
| **Hors scope APJ** | 3 pages (accueil, inscription, chatbot) |
| **Utilitaires/traitement** | 10 pages |

> **Conclusion** : Migration terminée. Les 2 pages de modération ont été complétées en APJ standard/hybride. La page visibilité a été migrée en PageUpdate avec vue pivot. Les 4 tabs profil custom ont eu leur CSS externalisé. **Aucune action APJ restante sur les modules alumni.**

---

## 6. Résumé de la Migration (25 février 2026)

### Fichiers créés
| Fichier | Lignes | Contenu |
|---------|--------|---------|
| `assets/css/profil-tabs.css` | ~160 | Styles consolidés des 4 onglets profil |
| `assets/css/moderation-liste.css` | ~220 | Styles liste modération (cards, badges, modal) |
| `BDD/2026-02-25-Rotsy-1.sql` | ~18 | Vue pivot `v_visibilite_config` |
| `utilisateurAcade/VisibiliteConfig.java` | ~115 | Bean APJ pour la vue pivot visibilité |

### Fichiers modifiés
| Fichier | Changement principal |
|---------|---------------------|
| `profil/competence-tab.jsp` | `<style>` inline → `<link>` vers `profil-tabs.css` |
| `profil/experience-tab.jsp` | `<style>` inline → `<link>` vers `profil-tabs.css` |
| `profil/parcours-tab.jsp` | `<style>` inline → `<link>` vers `profil-tabs.css` |
| `profil/reseaux-tab.jsp` | `<style>` inline → `<link>` vers `profil-tabs.css` |
| `profil/visibilite.jsp` | Full APJ : `PageUpdate` + `Liste` (Visible/Masqué) + `VisibiliteService` pour save |
| `moderation/moderation-historique.jsp` | Full APJ : `getTableau().getHtml()` + `getBasPage()` |
| `moderation/moderation-liste.jsp` | Hybrid APJ : `getHtmlEnsemble()` + CSS externe |
