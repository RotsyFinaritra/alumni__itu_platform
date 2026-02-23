# Guide d'Utilisation du Framework APJ

## Table des Matières
1. [Architecture Générale](#1-architecture-générale)
2. [Structure du Projet](#2-structure-du-projet)
3. [Configuration](#3-configuration)
4. [Créer un Bean (Entité/Modèle)](#4-créer-un-bean-entitémodèle)
5. [Pages JSP - CRUD Complet](#5-pages-jsp---crud-complet)
6. [Système de Navigation et Menus](#6-système-de-navigation-et-menus)
7. [Le Routeur Central : apresTarif.jsp](#7-le-routeur-central--aprestarif-jsp)
8. [Authentification et Sécurité](#8-authentification-et-sécurité)
9. [Classes Framework Clés](#9-classes-framework-clés)
10. [Build et Déploiement](#10-build-et-déploiement)
11. [Recette pour Créer un Nouveau Module](#11-recette-pour-créer-un-nouveau-module)
12. [Pièges et Limitations Connues](#12-pièges-et-limitations-connues-du-framework-apj)

---

## 1. Architecture Générale

Le framework APJ suit une architecture Java EE classique à 3 tiers :

```
┌─────────────────────────────────────────────────────┐
│                   PRÉSENTATION (WAR)                │
│  JSP Pages + CSS/JS (AdminLTE/Bootstrap)            │
│  teamTask-war/web/pages/                            │
├─────────────────────────────────────────────────────┤
│               LOGIQUE MÉTIER (EJB JAR)              │
│  Beans, Services, UserEJB (Stateful Session Bean)   │
│  teamTask-ejb/src/java/                             │
├─────────────────────────────────────────────────────┤
│              BASE DE DONNÉES (PostgreSQL)            │
│  Connexion via apj.properties                       │
│  ORM automatique via ClassMAPTable                  │
└─────────────────────────────────────────────────────┘
```

**Serveur d'application** : WildFly (JBoss)  
**Base de données** : PostgreSQL  
**Frontend** : AdminLTE + Bootstrap 3 + jQuery  
**Build** : Apache Ant  

---

## 2. Structure du Projet

```
alumni_itu_platform/
├── build.xml                          # Script Ant principal de build/deploy
├── teamTask-ejb/                      # MODULE EJB (logique métier + beans)
│   ├── build.xml
│   └── src/java/
│       ├── apj.properties             # ⚡ Connexion BDD
│       ├── project.properties         # Config projet
│       ├── bean/                      # 📦 Vos entités (ClassMAPTable)
│       ├── configuration/             # Config métier
│       ├── constanteAcade/            # Constantes projet
│       ├── user/                      # UserEJB - Session Bean (NE PAS TOUCHER)
│       ├── utils/                     # Utilitaires projet
│       ├── utilitaireAcade/           # Utilitaires métier
│       ├── utilisateurAcade/          # Gestion utilisateurs
│       ├── web/                       # Singletons, WebSockets
│       ├── fichier/                   # Gestion fichiers joints
│       └── ressources/               # i18n (text.properties)
│
├── teamTask-war/                      # MODULE WAR (présentation)
│   ├── build.xml
│   ├── src/java/                      # Servlets (filemanager, chart, etc.)
│   └── web/
│       ├── index.jsp                  # Page de login
│       ├── pages/
│       │   ├── module.jsp             # 🎯 PAGE MAÎTRE (layout principal)
│       │   ├── testLogin.jsp          # Traitement login
│       │   ├── security-login.jsp     # Guard de sécurité
│       │   ├── deconnexion.jsp        # Déconnexion
│       │   ├── accueil.jsp            # Page d'accueil après login
│       │   ├── apresTarif.jsp         # 🔄 ROUTEUR CRUD (insert/update/delete/valider)
│       │   ├── elements/
│       │   │   ├── header.jsp         # En-tête (navbar)
│       │   │   ├── footer.jsp         # Pied de page
│       │   │   ├── css.jsp            # Inclusions CSS
│       │   │   ├── js.jsp             # Inclusions JS
│       │   │   ├── panel.jsp          # Panel latéral
│       │   │   └── menu/
│       │   │       └── module.jsp     # Menu dynamique sidebar
│       │   ├── menu/                  # CRUD des menus (admin)
│       │   └── [vos-modules]/         # 📁 Vos pages métier ici
│       ├── assets/                    # CSS/JS/images personnalisés
│       ├── bootstrap/                 # Bootstrap 3
│       ├── dist/                      # AdminLTE
│       └── plugins/                   # Plugins jQuery
│
├── front/                             # MODULE FRONT (WAR secondaire, optionnel)
│   └── (même structure que teamTask-war)
│
└── build-file/                        # Fichiers de build compilés
    ├── lib/                           # JARs des librairies
    └── ear/                           # EAR généré
```

---

## 3. Configuration

### 3.1 Connexion Base de Données (`teamTask-ejb/src/java/apj.properties`)

```properties
apj.connection.url=jdbc:postgresql://localhost:5432/NOM_DE_VOTRE_BDD
apj.connection.user=postgres
apj.connection.password=root
apj.connection.driver=org.postgresql.Driver
```

### 3.2 Déploiement (`build.xml` racine)

Modifier la propriété `deploy.dir` pour pointer vers votre WildFly :
```xml
<property name="deploy.dir" value="/chemin/vers/wildfly/standalone/deployments/"/>
```

Le WAR sera déployé sous le nom défini dans le build.xml (ex: `donation.war` → changer en `alumni.war`).

---

## 4. Créer un Bean (Entité/Modèle)

Chaque table de la BDD correspond à une classe Java qui **étend `ClassMAPTable`**.

### 4.1 Structure d'un Bean de Base

```java
package bean;

import java.sql.Connection;
import java.sql.Date;

public class MonEntite extends ClassMAPTable {
    // 1. Attributs = colonnes de la table (mêmes noms!)
    String id;
    String nom;
    String description;
    Date dateCreation;
    double montant;
    String idCategorie;  // clé étrangère

    // 2. Constructeur : définir le nom de la table
    public MonEntite() {
        setNomTable("MON_ENTITE");  // nom exact de la table PostgreSQL
    }

    // 3. OBLIGATOIRE : retourner la valeur de la clé primaire
    @Override
    public String getTuppleID() {
        return getId();
    }

    // 4. OBLIGATOIRE : retourner le nom de l'attribut clé primaire
    @Override
    public String getAttributIDName() {
        return "id";
    }

    // 5. OBLIGATOIRE : construire la clé primaire via séquence PostgreSQL
    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PRE", "NOM_SEQUENCE_POSTGRESQL");
        // "PRE" = préfixe de l'ID (ex: "DON" → DON0001, DON0002...)
        // "NOM_SEQUENCE_POSTGRESQL" = nom de la fonction/séquence dans la BDD
        this.setId(makePK(c));
    }

    // 6. OPTIONNEL : rendre l'entité indexable pour recherche globale
    @Override
    public boolean getEstIndexable() {
        return true;
    }

    // 7. OPTIONNEL : texte pour la remarque/recherche globale
    @Override
    public String rajoutRemarque(Connection c) throws Exception {
        return getNom() + " " + getDescription();
    }

    // 8. Getters/Setters pour TOUS les attributs
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }
    // ... etc pour chaque attribut
}
```

### 4.2 Bean avec Vue (LibCPL) - Pour les Listes avec Libellés

Quand vous avez des clés étrangères et voulez afficher les libellés dans les listes :

```java
package bean;

public class MonEntiteLibCPL extends MonEntite {
    // Attributs supplémentaires = colonnes de la VUE SQL
    String idCategorieLib;  // libellé de la catégorie (JOIN)
    double total;           // champ calculé

    public MonEntiteLibCPL() {
        setNomTable("monentitelibcpl");  // nom de la VUE PostgreSQL
    }

    // Getters/Setters
    public String getIdCategorieLib() { return idCategorieLib; }
    public void setIdCategorieLib(String v) { this.idCategorieLib = v; }
}
```

### 4.3 SQL correspondant

```sql
-- Table
CREATE TABLE MON_ENTITE (
    id VARCHAR(20) PRIMARY KEY,
    nom VARCHAR(200),
    description TEXT,
    date_creation DATE,
    montant NUMERIC(15,2),
    id_categorie VARCHAR(20) REFERENCES CATEGORIE(id)
);

-- Séquence pour générer les IDs
CREATE OR REPLACE FUNCTION NOM_SEQUENCE_POSTGRESQL() RETURNS VARCHAR AS $$
DECLARE
    result VARCHAR;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(id FROM 4) AS INTEGER)), 0) + 1 
    INTO result FROM MON_ENTITE;
    RETURN LPAD(result::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

-- Vue pour les listes avec libellés
CREATE OR REPLACE VIEW monentitelibcpl AS
SELECT e.*, c.val AS idCategorieLib
FROM MON_ENTITE e
LEFT JOIN CATEGORIE c ON e.id_categorie = c.id;
```

### 4.4 Correspondance Attributs Java ↔ Colonnes SQL

| Type Java        | Type PostgreSQL     | Notes                          |
|-----------------|--------------------|---------------------------------|
| `String`        | `VARCHAR`, `TEXT`   | Le plus courant                |
| `double`        | `NUMERIC`, `FLOAT` | Pour les montants              |
| `int`           | `INTEGER`          | Pour les quantités entières    |
| `java.sql.Date` | `DATE`             | Format date                    |
| `java.sql.Timestamp` | `TIMESTAMP`   | Date + heure                   |

**IMPORTANT** : Les noms des attributs Java doivent correspondre EXACTEMENT aux noms des colonnes SQL (le framework fait un mapping automatique par réflexion).

---

## 5. Pages JSP - CRUD Complet

Le framework fournit des classes d'affichage qui génèrent automatiquement le HTML.

### 5.1 Page de Saisie (INSERT) - `monmodule-saisie.jsp`

```jsp
<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%
    try {
        // 1. Créer l'objet bean
        MonEntite a = new MonEntite();
        
        // 2. Créer le PageInsert
        PageInsert pi = new PageInsert(a, request, (user.UserEJB) session.getValue("u"));
        pi.setLien((String) session.getValue("lien"));
        
        // 3. OPTIONNEL : Créer des listes déroulantes pour les clés étrangères
        Liste[] listes = new Liste[1];
        TypeObjet categ = new TypeObjet();
        categ.setNomTable("categorie");  // table de référence
        listes[0] = new Liste("idCategorie", categ, "val", "id");
        // Paramètres: (nomAttributBean, objetReference, colonneAffichée, colonneValeur)
        pi.getFormu().changerEnChamp(listes);
        
        // 4. Personnaliser les libellés des champs
        pi.getFormu().getChamp("nom").setLibelle("Nom complet");
        pi.getFormu().getChamp("dateCreation").setLibelle("Date");
        pi.getFormu().getChamp("dateCreation").setDefaut(Utilitaire.dateDuJour());
        pi.getFormu().getChamp("description").setLibelle("Description");
        pi.getFormu().getChamp("montant").setLibelle("Montant (Ar)");
        pi.getFormu().getChamp("idCategorie").setLibelle("Catégorie");
        
        // 5. OPTIONNEL : Définir l'ordre d'affichage des champs
        String[] ordre = {"nom", "description", "montant", "idCategorie", "dateCreation"};
        pi.getFormu().setOrdre(ordre);
        
        // 6. Préparer et générer le HTML
        pi.preparerDataFormu();
        pi.getFormu().makeHtmlInsertTabIndex();
        
        // 7. Variables de navigation
        String classe = "bean.MonEntite";            // Classe Java complète
        String butApresPost = "monmodule/monmodule-fiche.jsp";  // Page après insert
        String nomTable = "MON_ENTITE";              // Nom table SQL
%>
<div class="content-wrapper">
    <h1 align="center">Saisie Mon Entité</h1>
    <form action="<%=pi.getLien()%>?but=apresTarif.jsp" method="post" data-parsley-validate>
        <%
            out.println(pi.getFormu().getHtmlInsert());
        %>
        <!-- CHAMPS CACHÉS OBLIGATOIRES -->
        <input name="acte" type="hidden" value="insert">
        <input name="bute" type="hidden" value="<%= butApresPost %>">
        <input name="classe" type="hidden" value="<%= classe %>">
        <input name="nomtable" type="hidden" value="<%= nomTable %>">
    </form>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
```

**Les champs cachés sont ESSENTIELS** :
- `acte` : l'opération (`insert`, `update`, `delete`, `valider`, etc.)
- `bute` : la page de redirection après l'opération
- `classe` : le nom complet de la classe Java (package.NomClasse)
- `nomtable` : le nom de la table SQL

### 5.2 Page de Liste (SELECT/RECHERCHE) - `monmodule-liste.jsp`

```jsp
<%@page import="affichage.PageRecherche"%>
<%@ page import="bean.MonEntiteLibCPL" %>
<%@ page import="utilitaire.Utilitaire" %>
<%
    try {
        // 1. Utiliser le bean LibCPL (vue avec libellés)
        MonEntiteLibCPL t = new MonEntiteLibCPL();
        
        // 2. Définir les critères de recherche
        String listeCrt[] = {"id", "nom", "dateCreation", "idCategorieLib"};
        
        // 3. Définir les critères de type intervalle (date, nombre)
        String listeInt[] = {"dateCreation"};  // génère dateCreation1 et dateCreation2 (min/max)
        
        // 4. Définir les colonnes du tableau résultat
        String libEntete[] = {"dateCreation", "nom", "description", "idCategorieLib", "montant"};
        
        // 5. Créer le PageRecherche
        // Params: (bean, request, criteres, intervalles, nbColonnesCritere, colonnesTableau, nbColonnes)
        PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
        pr.setTitre("Liste de mes entités");
        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setLien((String) session.getValue("lien"));
        pr.setApres("monmodule/monmodule-liste.jsp");  // page courante (pour le formulaire de recherche)
        
        // 6. Personnaliser les libellés des critères
        pr.getFormu().getChamp("dateCreation1").setLibelle("Date Min");
        pr.getFormu().getChamp("dateCreation2").setLibelle("Date Max");
        pr.getFormu().getChamp("dateCreation1").setDefaut(Utilitaire.getDebutAnnee(Utilitaire.getAnnee(Utilitaire.dateDuJour())));
        pr.getFormu().getChamp("dateCreation2").setDefaut(Utilitaire.dateDuJour());
        pr.getFormu().getChamp("idCategorieLib").setLibelle("Catégorie");
        
        // 7. Nombre de résultats par page
        pr.setNpp(50);
        
        // 8. Colonnes de somme (optionnel)
        String[] colSomme = {"montant"};
        pr.creerObjetPage(libEntete, colSomme);
        
        // 9. Liens cliquables dans le tableau
        String lienTableau[] = {pr.getLien() + "?but=monmodule/monmodule-fiche.jsp"};
        String colonneLien[] = {"id"};  // colonne qui sert de lien
        pr.getTableau().setLien(lienTableau);
        pr.getTableau().setColonneLien(colonneLien);
        
        // 10. Libellés d'en-tête affichés (peut différer des noms d'attributs)
        String libEnteteAffiche[] = {"Date", "Nom", "Description", "Catégorie", "Montant"};
        pr.getTableau().setLibelleAffiche(libEnteteAffiche);
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><%= pr.getTitre() %></h1>
    </section>
    <section class="content">
        <!-- Formulaire de recherche -->
        <form action="<%=pr.getLien()%>?but=<%= pr.getApres() %>" method="post">
            <% out.println(pr.getFormu().getHtmlEnsemble()); %>
        </form>
        <!-- Tableau récapitulatif (sommes) -->
        <% out.println(pr.getTableauRecap().getHtml()); %>
        <br>
        <!-- Tableau de résultats -->
        <% 
            out.println(pr.getTableau().getHtml());
            out.println(pr.getBasPage());  // pagination
        %>
    </section>
</div>
<%
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
```

### 5.3 Page de Consultation (FICHE) - `monmodule-fiche.jsp`

```jsp
<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="affichage.*" %>
<%
    try {
        // 1. Créer le bean
        MonEntite monEntite = new MonEntite();
        
        // 2. Créer le PageConsulte (charge automatiquement les données via l'ID dans l'URL)
        PageConsulte pc = new PageConsulte(monEntite, request, (user.UserEJB) session.getValue("u"));
        pc.setTitre("Fiche Mon Entité");
        
        // 3. L'objet chargé depuis la BDD
        monEntite = (MonEntite) pc.getBase();
        String id = monEntite.getId();
        
        // 4. Personnaliser les libellés
        pc.getChampByName("nom").setLibelle("Nom");
        pc.getChampByName("description").setLibelle("Description");
        
        // 5. Page de modification
        String pageModif = "monmodule/monmodule-saisie.jsp";
%>
<div class="content-wrapper">
    <h1 class="box-title"><%= pc.getTitre() %></h1>
    <div class="row m-0">
        <div class="col-md-6 nopadding">
            <div class="box-fiche">
                <div class="box">
                    <div class="box-body">
                        <!-- Affichage automatique des champs -->
                        <% out.println(pc.getHtml()); %>
                        <br/>
                        <div class="box-footer">
                            <!-- Bouton Modifier -->
                            <a class="btn btn-secondary pull-right"
                               href="<%=(String) session.getValue("lien") + "?acte=update&classe=bean.MonEntite&nomtable=MON_ENTITE&but=monmodule/monmodule-saisie.jsp&id=" + id%>"
                               style="margin-right: 10px">
                                Modifier
                            </a>
                            <!-- Bouton Supprimer -->
                            <a class="btn btn-danger"
                               href="<%=(String) session.getValue("lien") + "?but=apresTarif.jsp&acte=delete&classe=bean.MonEntite&nomtable=MON_ENTITE&bute=monmodule/monmodule-liste.jsp&id=" + id%>"
                               style="margin-right: 10px">
                                Supprimer
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<%
    } catch(Exception e) {
        e.printStackTrace();
    }
%>
```

### 5.4 Page d'Analyse Croisée (GROUPE) - `monmodule-analyse.jsp`

```jsp
<%@page import="utilitaire.*"%>
<%@page import="affichage.*"%>
<%@ page import="bean.MonEntiteLibCPL" %>
<%
    try {
        MonEntiteLibCPL mvt = new MonEntiteLibCPL();
        
        String listeCrt[] = {"id", "dateCreation", "nom", "idCategorieLib"};
        String listeInt[] = {"dateCreation"};
        String[] pourcentage = {};
        String[] colGr = {"idCategorieLib"};          // colonnes de groupement (lignes)
        String[] colGrCol = {"nom"};                   // colonnes croisées (colonnes)
        String somDefaut[] = {"montant"};              // colonnes à sommer
        
        PageRechercheGroupe pr = new PageRechercheGroupe(
            mvt, request, listeCrt, listeInt, 3,
            colGr, somDefaut, pourcentage,
            colGr.length, somDefaut.length
        );
        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setLien((String) session.getValue("lien"));
        pr.setApres("monmodule/monmodule-analyse.jsp");
        pr.setNpp(500);
        // Crée le tableau croisé avec lien de drill-down
        pr.creerObjetPageCroise(colGrCol, pr.getLien() + "?but=monmodule/monmodule-liste.jsp");
%>
<div class="content-wrapper">
    <section class="content-header"><h1>Analyse</h1></section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=monmodule/monmodule-analyse.jsp" method="post" name="analyse">
            <% out.println(pr.getFormu().getHtmlEnsemble()); %>
        </form>
        <br>
        <% out.println(pr.getTableauRecap().getHtml()); %>
        <br>
        <% out.println(pr.getTableau().getHtml()); out.println(pr.getBasPage()); %>
    </section>
</div>
<%
    } catch(Exception e) { e.printStackTrace(); }
%>
```

---

## 6. Système de Navigation et Menus

### 6.1 Structure de Navigation

La navigation fonctionne via `module.jsp` qui est la page maître :

```
index.jsp (login) 
  → testLogin.jsp (authentification)
    → module.jsp?but=accueil.jsp (page maître)
        ├── header.jsp (navbar)
        ├── menu/module.jsp (sidebar avec MenuDynamique)
        ├── [contenu dynamique via paramètre "but"]
        ├── footer.jsp
        └── panel.jsp
```

### 6.2 Comment Naviguer

Tous les liens suivent ce pattern :
```
module.jsp?but=dossier/page.jsp&currentMenu=MENU_ID
```

- `but` : la page JSP à inclure comme contenu
- `currentMenu` : l'ID du menu actif (pour le surlignage dans la sidebar)

### 6.3 Menus Dynamiques (Base de données)

Les menus sont stockés dans la table `menu_dynamique` et gérés via l'admin (pages `menu/`).

Structure de la table menu_dynamique :
| Colonne   | Description                              |
|-----------|------------------------------------------|
| id        | Identifiant unique                       |
| libelle   | Texte affiché                            |
| icone     | Classe CSS de l'icône (Font Awesome)     |
| href      | Lien cible (ex: `monmodule/liste.jsp`)   |
| rang      | Ordre d'affichage                        |
| niveau    | Niveau de profondeur (1=racine, 2=sous-menu) |
| id_pere   | ID du menu parent (pour sous-menus)      |

---

## 7. Le Routeur Central : `apresTarif.jsp`

C'est la page qui traite TOUTES les opérations CRUD. Elle reçoit les formulaires et exécute l'action correspondante.

### Actions disponibles (paramètre `acte`) :

| `acte`          | Description                                    |
|----------------|------------------------------------------------|
| `insert`       | Créer un nouvel objet                          |
| `update`       | Modifier un objet existant                      |
| `delete`       | Supprimer un objet                              |
| `valider`      | Valider/viser un objet                          |
| `annuler`      | Annuler un objet                                |
| `cloturer`     | Clôturer un objet                               |
| `finaliser`    | Finaliser un objet                              |
| `dupliquer`    | Dupliquer un objet                              |
| `insertUser`   | Créer un utilisateur                            |
| `updatevalider`| Modifier puis valider                           |
| `savevalider`  | Sauvegarder puis valider                        |
| `deleteFille`  | Supprimer un objet fille                        |
| `annulerVisa`  | Annuler un visa                                 |

### Flux d'un INSERT :

```
1. Formulaire JSP → POST → apresTarif.jsp
2. apresTarif.jsp lit les paramètres (acte, classe, nomtable, bute)
3. Instancie la classe via Class.forName(classe).newInstance()
4. Crée un PageInsert pour mapper les paramètres HTTP → attributs Java
5. Appelle u.createObject(f) via le UserEJB
6. Redirige vers la page "bute" avec l'ID créé
```

### Flux d'un DELETE :

```
<a href="lien?but=apresTarif.jsp&acte=delete&classe=bean.MonEntite&nomtable=MON_ENTITE&bute=monmodule/monmodule-liste.jsp&id=XXX">
```

---

## 8. Authentification et Sécurité

### 8.1 Login (`index.jsp` → `testLogin.jsp`)

```
1. index.jsp : formulaire avec "identifiant" et "passe"
2. testLogin.jsp :
   - Lookup EJB : u = UserEJBClient.lookupUserEJBBeanLocal()
   - Authentification : u.testLogin(username, pwd)
   - Stockage session : session.setAttribute("u", u)
   - Récupération utilisateur : ut = u.getUser() → MapUtilisateur
   - Redirection par rôle (superUser, dg, visiteur, etc.)
```

### 8.2 Sécurité des pages (`security-login.jsp`)

Chaque page protégée inclut `security-login.jsp` qui vérifie :
```java
if(session.getAttribute("u") == null) {
    response.sendRedirect("index.jsp");  // redirection vers login
    return;
}
```

### 8.3 Page d'accueil par défaut après login

Dans `testLogin.jsp`, modifier le `queryString` :
```java
queryString = "but=accueil.jsp";  // changer ici pour votre page d'accueil
```

---

## 9. Classes Framework Clés

### Classes de bean (package `bean.*` du framework APJ) :

| Classe            | Description                                     |
|------------------|-------------------------------------------------|
| `ClassMAPTable`  | **Classe mère de tous les beans.** Mapping automatique Java↔SQL |
| `ClassEtat`      | Étend ClassMAPTable, ajoute gestion des états (créé, validé, etc.) |
| `ClassUser`      | Étend ClassMAPTable, ajoute le champ `iduser`   |
| `TypeObjet`      | Bean générique (id, val, desce) pour tables de référence |
| `CGenUtil`       | Utilitaire statique pour requêtes SQL (`rechercher()`, etc.) |

### Classes d'affichage (package `affichage.*` du framework) :

| Classe               | Description                                       |
|---------------------|--------------------------------------------------|
| `PageInsert`        | Génère un formulaire d'insertion/modification      |
| `PageConsulte`      | Génère une fiche de consultation                   |
| `PageRecherche`     | Génère un formulaire de recherche + tableau résultat |
| `PageRechercheGroupe` | Génère un tableau croisé dynamique (analyse)     |
| `Liste`             | Transforme un champ en liste déroulante            |
| `PageInsertMultiple`| Formulaire avec lignes multiples                   |

### Méthodes clés de `UserEJB` :

| Méthode                  | Description                              |
|-------------------------|------------------------------------------|
| `createObject(o)`       | INSERT dans la BDD                       |
| `updateObject(o)`       | UPDATE dans la BDD                       |
| `deleteObject(o)`       | DELETE de la BDD                         |
| `validerObject(o)`      | Changer l'état → validé                  |
| `annulerObject(o)`      | Annuler un objet                         |
| `cloturerObject(o)`     | Clôturer un objet                        |
| `getDataPage(...)`      | Recherche paginée                        |
| `getDataPageGroupe(...)` | Recherche groupée/croisée               |
| `getData(e, req, c)`    | Requête libre                            |
| `testLogin(user, pwd)`  | Authentifier un utilisateur              |
| `getUser()`             | Obtenir le MapUtilisateur connecté       |

### Utilitaires :

| Classe              | Méthodes utiles                                  |
|--------------------|--------------------------------------------------|
| `Utilitaire`       | `dateDuJour()`, `split()`, `getAnnee()`, `getDebutAnnee()` |
| `UtilitaireAcade`  | `champNull()`, `getAnneeEnCours()`, `stringToInt()` |
| `CGenUtil`         | `rechercher(bean, null, null, whereClause)` - recherche SQL |

### `CGenUtil.rechercher()` - Recherche directe :

```java
// Rechercher tous les objets d'un type
MonEntite filtre = new MonEntite();
MonEntite[] resultats = (MonEntite[]) CGenUtil.rechercher(filtre, null, null, "");

// Avec clause WHERE personnalisée
MonEntite[] resultats = (MonEntite[]) CGenUtil.rechercher(filtre, null, null, 
    " AND id_categorie = 'CAT001' ORDER BY nom ASC");
```

---

## 10. Build et Déploiement

### Build avec Ant :

```bash
cd /chemin/vers/projet
ant deploy
```

Le script Ant fait :
1. **clean** : supprime les anciens builds
2. **init** : crée les répertoires, copie les ressources web
3. **compile** : compile les classes EJB (`teamTask-ejb/src/java`)
4. **buildEjbJar** : crée le JAR EJB, le copie dans WEB-INF/lib des WARs
5. **compileWar** : compile les classes WAR (`teamTask-war/src/java`)
6. **copieProperties** : copie les fichiers i18n
7. **deploy** : copie le WAR explosé vers WildFly

### Modifier le nom du déploiement :

Dans `build.xml` (racine), changer :
```xml
<copy todir="${deploy.dir}/alumni.war">  <!-- changer le nom ici -->
```

---

## 11. Recette pour Créer un Nouveau Module

### Étape 1 : Créer la table SQL

```sql
CREATE TABLE mon_module (
    id VARCHAR(20) PRIMARY KEY,
    nom VARCHAR(200),
    description TEXT,
    -- ... autres colonnes
);

CREATE OR REPLACE FUNCTION getseqmonmodule() RETURNS VARCHAR AS $$
DECLARE r VARCHAR;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(id FROM 4) AS INTEGER)), 0) + 1 INTO r FROM mon_module;
    RETURN LPAD(r::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;
```

### Étape 2 : Créer le Bean Java

Fichier : `teamTask-ejb/src/java/bean/MonModule.java`

### Étape 3 : Créer les pages JSP

Dossier : `teamTask-war/web/pages/monmodule/`
- `monmodule-saisie.jsp` (INSERT/UPDATE)
- `monmodule-liste.jsp` (LISTE)
- `monmodule-fiche.jsp` (FICHE/CONSULTATION)

### Étape 4 : Ajouter au menu

Via l'interface admin (`menu/menu-saisie.jsp`) ou directement en SQL :
```sql
INSERT INTO menu_dynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENALUM01', 'Mon Module', 'fa fa-list', 'monmodule/monmodule-liste.jsp', 1, 2, 'MENU_PARENT_ID');
```

### Étape 5 : Personnaliser l'accueil

Modifier `accueil.jsp` et `testLogin.jsp` (queryString par défaut).

---

## 12. Pièges et Limitations Connues du Framework APJ

### 12.1 Types Java supportés dans les Beans (ClassMAPTable)

**⚠️ CRITIQUE : Ne JAMAIS utiliser `boolean` dans un bean APJ.**

La méthode `Champ.javaToSql()` ne contient aucun mapping pour le type Java `boolean`.
Quand un champ `boolean` est rencontré, `Champ.type` (le type SQL) reste `null`.
Puis `makeWhere()` (version compilée dans `apj-core.jar`) appelle
`ch[k].getTypeColonne().compareToIgnoreCase("timestamp")` → **NullPointerException**.

**Types supportés par `javaToSql()`** :
- `java.lang.String` / `char` → `Varchar2`
- `int` / `float` / `Double` → `Number`
- `java.sql.Date` → `Date`
- `java.sql.Time` → `Time`
- `java.sql.Timestamp` → `Timestamp(6)`
- `java.io.InputStream` → `blob`
- `org.postgis.PGgeometry` → `geometry`

**Solution pour les champs booléens** : utiliser `int` (0 = false, 1 = true) et `INTEGER` en SQL.

### 12.2 `CGenUtil.rechercher()` — le paramètre `apresWhere`

```java
// ✅ CORRECT : apresWhere doit être "" (chaîne vide), jamais null
Object[] result = CGenUtil.rechercher(filtre, null, null, "");

// ✅ CORRECT : avec une condition supplémentaire
Object[] result = CGenUtil.rechercher(filtre, null, null, " AND refuser = " + id);

// ❌ FAUX (ambiguïté de surcharge) :
Object[] result = CGenUtil.rechercher(filtre, null, null, null);
```

Passer `null` comme `apresWhere` rend l'appel ambigu pour le compilateur Java
(plusieurs surcharges de `rechercher` matchent).

### 12.3 `makeWhere()` et les colonnes INTEGER / primitives

`makeWhere()` ignore les champs dont le type Java est `int`, `double` ou `short`
(`testNombre = true` → le champ est sauté). Cela signifie :

- Un champ `int idutilisateur = 0` ne sera **jamais** inclus dans le WHERE généré.
- Pour filtrer sur un champ entier, **il faut passer la condition dans `apresWhere`** :
  ```java
  CGenUtil.rechercher(filtre, null, null, " AND idutilisateur = " + valeur);
  ```

De plus, `makeWhere()` applique `upper()` sur les valeurs `String` non-vides.
Si la colonne PostgreSQL est de type `INTEGER` mais le champ Java est `String`
(comme `refuser` dans `Utilisateur`), cela génère `upper(refuser)` →
**Erreur PostgreSQL : `function upper(integer) does not exist`**.

**Solution** : ne pas utiliser `makeWhere` pour ces cas ; passer par `apresWhere` direct.

### 12.4 `getValeurFieldByMethod()` — Réflexion sur les getters

CGenUtil construit le nom du getter comme `"get" + capitalize(nomChamp)`.
Il ne tente **jamais** le préfixe `is` (convention Java pour les booleans).
- Pour un champ `visible`, il cherche `getVisible()` et non `isVisible()`.
- Raison supplémentaire de ne pas utiliser `boolean` : la convention de nommage
  `isXxx()` n'est pas supportée par CGenUtil.

Le fallback est case-insensitive : `getNomchamp` trouvera `getNomChamp()`.

### 12.5 `PageConsulte.getChampByName()` — Toujours null-safe

`getChampByName(nom)` retourne `null` si le champ n'existe pas dans le formulaire.
Toujours vérifier avant d'appeler une méthode dessus :
```java
Champ c = pc.getChampByName("rang");
if (c != null) { c.setVisible(false); }
```

### 12.6 `module.jsp` — Gestion d'erreurs

Dans les blocs `catch`, `e.getMessage()` peut retourner `null`.
Ne jamais appeler `.toUpperCase()` ou autre méthode sur le résultat sans vérifier :
```java
String msg = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
```

### 12.7 `UserEJB` — Accès à l'identifiant utilisateur

`UserEJB` n'a pas de méthode `getRefuser()`. Pour obtenir l'ID de l'utilisateur :
```java
String refuser = u.getUser().getTuppleID();
```

### 12.8 Identifiants Java — Pas de caractères accentués

Le compilateur JSP (JDT) ne supporte pas les caractères accentués dans les noms
de variables (`champsContrôlés`). Utiliser uniquement des caractères ASCII

### 12.9 Listes déroulantes (FK) — `changerEnChamp()`, pas `setListe()`

`affichage.Champ` n'a **pas** de méthode `setListe()`. La classe `Liste extends Champ` :
c'est un type de Champ, pas un attribut qu'on met sur un Champ.

Pour transformer un champ texte en liste déroulante, il faut créer un tableau de `Liste`
et appeler `changerEnChamp()` qui **remplace** les Champ correspondants :
```java
Liste[] listes = new Liste[2];
listes[0] = new Liste("idpromotion", new Promotion(), "libelle", "id");
listes[1] = new Liste("idtypeutilisateur", new TypeUtilisateur(), "libelle", "id");
pi.getFormu().changerEnChamp(listes);

// On peut ensuite modifier les libellés APRÈS changerEnChamp
pi.getFormu().getChamp("idpromotion").setLibelle("Promotion");
```

### 12.10 Chargement AJAX de fragments — Éviter `module.jsp`

`module.jsp` est la page maître qui inclut le layout complet (header, sidebar, JS, CSS).
Si on charge un onglet via AJAX avec `$.get(lien + "?but=page.jsp")`, le contenu
retourné contient tout le layout → double sidebar, double barre de recherche.

Pour charger un fragment HTML (onglet, popup), utiliser le chemin direct du JSP :
```java
// ❌ FAUX : charge la page via module.jsp (layout complet)
data-url="<%= lien %>?but=profil/parcours-tab.jsp"

// ✅ CORRECT : charge uniquement le fragment JSP
data-url="<%= request.getContextPath() %>/pages/profil/parcours-tab.jsp?refuser=<%= refuser %>"
```
(`champsControles`).

---

## Résumé des Conventions

| Élément               | Convention                                           |
|----------------------|-----------------------------------------------------|
| Package beans         | `bean.*` dans `teamTask-ejb/src/java/bean/`         |
| Nom table             | MAJUSCULES dans SQL, setCamelCase dans Java          |
| Clé primaire          | Toujours `String id` avec séquence                  |
| Pages JSP             | `dossier/module-action.jsp` (ex: `donation/donation-saisie.jsp`) |
| Formulaire POST       | Toujours vers `apresTarif.jsp`                      |
| Champs cachés         | `acte`, `bute`, `classe`, `nomtable` OBLIGATOIRES   |
| Listes (FK)           | `new Liste("attribut", typeObjet, "val", "id")`     |
| Vues SQL              | Suffixe `libcpl` pour les vues avec jointures        |
| Séquences             | Fonction PostgreSQL retournant le prochain numéro    |
| **Types beans**       | **String, int, double, Date, Timestamp — JAMAIS boolean** |
| **apresWhere**        | **Toujours `""` minimum, jamais `null`**            |
| **Filtres int**       | **Toujours via `apresWhere`, pas via le bean filtre** |
