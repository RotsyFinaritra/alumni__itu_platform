# KoloTV - Copilot Instructions

## Architecture Overview

KoloTV is a **Java EE broadcast/advertising management application** using the custom **APJ-Core ORM framework**.

### Project Structure
```
kolotv-ejb/src/java/     # Business logic beans (extend ClassMAPTable)
kolotv-war/web/pages/    # JSP views organized by module (vente/, client/, media/, etc.)
apj-core-update/         # Core framework: ORM (bean/), UI generation (affichage/)
apj-core2-update/        # Framework extensions: menu/, utilisateur/, web/servlet/
build-file/lib/          # JAR dependencies
bdd/                     # Versioned SQL migration scripts (YYYY/YYYY-MM-DD-description.sql)
```

### Key Framework Classes
- **`ClassMAPTable`** - Base class for ALL domain entities (ORM mapping)
- **`CGenUtil`** - Static CRUD utilities: `rechercher()`, `save()`, `insertBatch()`
- **`PageInsert/PageUpdate/PageRecherche`** - Auto-generate JSP forms and search pages
- **`AutoComplete`** servlet at `/autocomplete` - AJAX autocomplete for FK fields

## Build & Deploy

```bash
# Build and deploy to WildFly (single command)
ant -f build.xml

# Deploy path: D:\wildfly-10.1.0.Final\standalone\deployments\kolotv.war
```

Build compiles `kolotv-ejb` → JAR → embeds in WAR → exploded deployment with `.dodeploy` trigger.

## Creating a New Entity

### 1. Oracle Table + Sequence
```sql
CREATE TABLE matable (id VARCHAR2(10) PRIMARY KEY, nom VARCHAR2(100), ...);
CREATE SEQUENCE seq_matable START WITH 1;
CREATE OR REPLACE FUNCTION getSeqMatable RETURN NUMBER IS BEGIN RETURN seq_matable.NEXTVAL; END;
```

### 2. Bean Class (kolotv-ejb/src/java/monmodule/MaTable.java)
```java
public class MaTable extends ClassMAPTable {
    String id, nom; // Field names = column names (case-insensitive)
    
    public MaTable() { 
        this.setNomTable("matable"); // Use setter, nomTable is not public
    }
    
    @Override public String getTuppleID() { return id; }
    @Override public String getAttributIDName() { return "id"; }
    @Override public void construirePK(Connection c) throws Exception {
        this.preparePk("MAT", "getSeqMatable"); // Prefix + Oracle function
        this.setId(makePK(c));                   // → MAT0001
    }
    // ALL fields need getters/setters!
}
```

### 2b. Classe Lib pour les Vues (IMPORTANT)

**Quand créer une vue avec jointures** (ex: `MATABLE_CPL`), **TOUJOURS créer une classe `*Lib`** qui étend la classe de base :

```java
public class MaTableLib extends MaTable {
    private String libelleFK;  // Champs calculés/joints de la vue
    private String etatlib;
    
    public MaTableLib() {
        super();
        this.setNomTable("MATABLE_CPL"); // Vue avec _CPL
    }
    
    // Getters/setters pour les nouveaux champs
    public String getLibelleFK() { return libelleFK; }
    public void setLibelleFK(String libelleFK) { this.libelleFK = libelleFK; }
    
    public String getEtatlib() { return etatlib; }
    public void setEtatlib(String etatlib) { this.etatlib = etatlib; }
}
```

**Pattern obligatoire** :
- Table : `MaTable` → Vue : `MATABLE_CPL` → Classe : `MaTableLib extends MaTable`
- La classe Lib contient UNIQUEMENT les champs additionnels de la vue (pas ceux de la table de base)
- **Utiliser `MaTableLib` dans les pages de liste (PageRecherche)** au lieu de `MaTable`

### 3. JSP Pages (kolotv-war/web/pages/monmodule/)

Types de pages :
- `matable-saisie.jsp` → **PageInsert** pour création
- `matable-modif.jsp` → **PageUpdate** pour modification  
- `matable-liste.jsp` → **PageRecherche** pour recherche/liste paginée
- `matable-fiche.jsp` → Page de détail avec boutons d'action

## Framework JSP Classes

### PageRecherche - Pages de liste avec recherche

**Pattern complet observé** (client-liste.jsp, proforma-liste.jsp):

```jsp
<%@ page import="monmodule.MaTable" %>
<%@ page import="affichage.PageRecherche" %>
<% try {
    MaTable t = new MaTable();
    t.setNomTable("MATABLE"); // Nom de table ou vue
    
    String[] listeCrt = {"id", "nom", "telephone"}; // Champs de critères de recherche
    String[] listeInt = {"daty"}; // Champs de type intervalle (dates) - utiliser {} si aucun intervalle
    String[] libEntete = {"id", "nom", "telephone", "daty"}; // Colonnes à afficher
    
    PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Liste des Entités");
    pr.setUtilisateur((user.UserEJB) session.getValue("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("monmodule/matable-liste.jsp");
    
    // Configuration des labels de formulaire
    pr.getFormu().getChamp("id").setLibelle("ID");
    pr.getFormu().getChamp("nom").setLibelle("Nom");
    pr.getFormu().getChamp("daty1").setLibelle("Date Min");
    pr.getFormu().getChamp("daty2").setLibelle("Date Max");
    
    // Créer la page avec colonnes de somme optionnelles
    String[] colSomme = null; // ou {"montant", "quantite"} ou {} si aucune somme
    pr.creerObjetPage(libEntete, colSomme);
    
    // Configuration du tableau
    String[] lienTableau = {pr.getLien() + "?but=monmodule/matable-fiche.jsp"};
    String[] colonneLien = {"id"};
    pr.getTableau().setLien(lienTableau);
    pr.getTableau().setColonneLien(colonneLien);
    
    String[] libEnteteAffiche = {"ID", "Nom", "T&eacute;l&eacute;phone", "Date"};
    pr.getTableau().setLibelleAffiche(libEnteteAffiche);
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><%= pr.getTitre() %></h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=<%= pr.getApres() %>" method="post">
            <% out.println(pr.getFormu().getHtmlEnsemble()); %>
        </form>
        <% out.println(pr.getTableauRecap().getHtml()); %>
        <% out.println(pr.getTableau().getHtml()); %>
        <% out.println(pr.getBasPage()); %>
    </section>
</div>
<% } catch (Exception e) { e.printStackTrace(); } %>
```

**Méthodes PageRecherche importantes:**
- `setAWhere(String)` - Ajouter filtre WHERE SQL additionnel
- `setLienFille(String)` - Lien pour lignes expandables (mère/filles)
- `getTableau().setLienClicDroite(Map)` - Menu contextuel clic droit

**🔑 IMPORTANT - Champs d'intervalle (dates):**

Quand un champ est ajouté dans le paramètre `listeInt[]` du constructeur `PageRecherche`, le framework **crée automatiquement** deux champs supplémentaires :
- Si `listeInt[] = {"daty"}` → le framework génère `daty1` et `daty2`
- Si aucun intervalle : utiliser `String[] listeInt = {};` (tableau vide, **PAS null**)
- Ces champs sont créés dans le constructeur via `formu.makeChampFormu()`
- Ils sont **immédiatement accessibles** après `new PageRecherche(...)`

```jsp
// Avec intervalle de dates
String listeInt[] = {"daty"};  // Déclare "daty" comme champ d'intervalle
PageRecherche pr = new PageRecherche(bc, request, listeCrt, listeInt, 3, libEntete, libEntete.length);

// Sans intervalle
String listeInt[] = {};  // ✅ Tableau vide (PAS null)
PageRecherche pr = new PageRecherche(bc, request, listeCrt, listeInt, 3, libEntete, libEntete.length);

// Les champs daty1 et daty2 EXISTENT déjà ici (créés par le constructeur)
pr.getFormu().getChamp("daty1").setLibelle("Date Min");   // ✅ OK
pr.getFormu().getChamp("daty2").setLibelle("Date Max");   // ✅ OK
pr.getFormu().getChamp("daty1").setDefaut("2025-01-01"); // ✅ OK

pr.creerObjetPage(libEntete, colSomme);

// Toujours possible de modifier après creerObjetPage() aussi
pr.getFormu().getChamp("daty2").setDefaut(utilitaire.Utilitaire.dateDuJour()); // ✅ OK
```

**Mécanisme interne:**
- `PageRecherche` constructeur → appelle `formu.makeChampFormu(listeCrt, listeInt, nbRange)`
- `makeChampFormu()` parcourt `listeInt[]` et pour chaque champ :
  - Crée `Champ champ1 = new Champ(nomChamp + "1")`
  - Crée `Champ champ2 = new Champ(nomChamp + "2")`
  - Les ajoute automatiquement à la liste des champs du formulaire
- Pour les dates : définit automatiquement le type approprié

### PageInsert - Formulaire de création

**Pattern complet observé** (client-saisie.jsp, reservation-simple-saisie.jsp):

```jsp
<%@ page import="monmodule.MaTable" %>
<%@ page import="affichage.PageInsert" %>
<%@ page import="affichage.Liste" %>
<%@ page import="bean.TypeObjet" %>
<%@ page import="user.UserEJB" %>
<% try {
    UserEJB u = (user.UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    String mapping = "monmodule.MaTable";
    String nomtable = "MATABLE";
    String apres = "monmodule/matable-fiche.jsp";
    String titre = "Nouvelle Entité";
    
    MaTable t = new MaTable();
    PageInsert pi = new PageInsert(t, request, u);
    pi.setLien(lien);
    
    // Configuration des listes déroulantes
    affichage.Champ[] liste = new affichage.Champ[2];
    
    // Liste depuis TypeObjet (table de référence)
    TypeObjet op = new TypeObjet();
    op.setNomTable("as_unite");
    liste[0] = new Liste("idunite", op, "val", "id");
    
    // Liste depuis valeurs statiques
    Liste typeListe = new Liste("type");
    String[] valeurs = {"Commercial", "Institutionnel"};
    typeListe.makeListeString(valeurs, valeurs);
    liste[1] = typeListe;
    
    pi.getFormu().changerEnChamp(liste);
    
    // Configuration des champs
    pi.getFormu().getChamp("nom").setLibelle("Nom");
    pi.getFormu().getChamp("telephone").setLibelle("T&eacute;l&eacute;phone");
    pi.getFormu().getChamp("daty").setLibelle("Date");
    pi.getFormu().getChamp("remarque").setLibelle("Remarque");
    
    // PageAppel pour autocomplete avec popup
    pi.getFormu().getChamp("idclient").setPageAppelCompleteInsert(
        "client.Client", "id", "CLIENT", 
        "client/client-saisie.jsp", "id;nom"
    );
    
    // Ordre d'affichage des champs
    pi.getFormu().setOrdre(new String[]{"daty", "nom", "telephone"});
    
    // OBLIGATOIRE: Préparer le formulaire APRÈS toute configuration
    pi.preparerDataFormu();
%>
<div class="content-wrapper">
    <h1><%=titre%></h1>
    <form action="<%=pi.getLien()%>?but=apresTarif.jsp" method="post" name="<%=nomtable%>" id="<%=nomtable%>">
        <%
            pi.getFormu().makeHtmlInsertTabIndex();
            out.println(pi.getFormu().getHtmlInsert());
            out.println(pi.getHtmlAddOnPopup());
        %>
        <input name="acte" type="hidden" value="insert">
        <input name="bute" type="hidden" value="<%=apres%>">
        <input name="classe" type="hidden" value="<%=mapping%>">
        <input name="nomtable" type="hidden" value="<%=nomtable%>">
    </form>
</div>
<% } catch (Exception e) { 
    e.printStackTrace();
%>
<script language="JavaScript">
    alert('<%=e.getMessage()%>');
    history.back();
</script>
<% } %>
```

**Méthodes Champ importantes:**
- `setLibelle(String)` - Label du champ
- `setDefaut(String)` - Valeur par défaut
- `setVisible(boolean)` - Masquer/afficher
- ~~`setObligatoire(boolean)`~~ - ⚠️ **CETTE MÉTHODE N'EXISTE PAS** - Utiliser validation HTML5 ou JavaScript à la place
- `setType(String)` - Type HTML ("time", "editor", "date", etc.)
- `setAutre(String)` - Attributs HTML additionnels (ex: `"required"` pour champ obligatoire)
- `setPageAppelComplete(String classe, String col, String table)` - Autocomplete
- `setPageAppelCompleteInsert(String classe, String col, String table, String insertPage, String fields)` - Autocomplete avec bouton insertion

### PageInsertMultiple - Formulaire mère/filles

**Pattern complet observé** (proforma-saisie.jsp, bondecommande-saisie.jsp):

```jsp
<%@ page import="vente.InsertionVente" %>
<%@ page import="vente.InsertionVenteDetails" %>
<%@ page import="affichage.PageInsertMultiple" %>
<%@ page import="affichage.Liste" %>
<%@ page import="bean.TypeObjet" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    
    InsertionVente mere = new InsertionVente();
    InsertionVenteDetails fille = new InsertionVenteDetails();
    int nombreLigne = 10;
    
    // IMPORTANT: u en 5ème paramètre
    PageInsertMultiple pi = new PageInsertMultiple(mere, fille, request, nombreLigne, u);
    pi.setLien(lien);
    pi.setTitre("Saisie de Vente");
    
    // Configuration des champs MÈRE
    Liste[] listeMere = new Liste[1];
    Support typeMed = new Support();
    listeMere[0] = new Liste("idSupport", typeMed, "val", "id");
    pi.getFormu().changerEnChamp(listeMere);
    
    pi.getFormu().getChamp("daty").setLibelle("Date");
    pi.getFormu().getChamp("designation").setLibelle("D&eacute;signation");
    pi.getFormu().getChamp("etat").setVisible(false);
    pi.getFormu().getChamp("idclient").setPageAppelCompleteInsert(
        "client.Client", "id", "Client", 
        "client/client-saisie.jsp", "id;nom"
    );
    
    String[] ordre = {"daty", "designation", "idclient"};
    pi.getFormu().setOrdre(ordre);
    
    // Configuration des champs FILLES (lignes de détail)
    pi.getFormufle().getChampMulitple("id").setVisible(false);
    pi.getFormufle().getChampMulitple("idVente").setVisible(false);
    
    // Pour chaque ligne
    for (int i = 0; i < pi.getNombreLigne(); i++) {
        pi.getFormufle().getChamp("designation_" + i).setType("editor");
    }
    
    Liste[] listeFille = new Liste[1];
    TypeObjet typeRemise = new TypeObjet();
    typeRemise.setNomTable("MODEREMISE");
    listeFille[0] = new Liste("uniteRemise", typeRemise, "desce", "val");
    pi.getFormufle().changerEnChamp(listeFille);
    
    // Labels des champs filles (suffixe _0 pour la première ligne)
    pi.getFormufle().getChamp("idProduit_0").setLibelle("Produit");
    pi.getFormufle().getChamp("qte_0").setLibelle("Quantit&eacute;");
    pi.getFormufle().getChamp("pu_0").setLibelle("Prix unitaire");
    
    // PageAppel pour autocomplete dans les lignes
    affichage.Champ.setPageAppelComplete(
        pi.getFormufle().getChampFille("idProduit"),
        "produits.IngredientsLib", "id", "ST_INGREDIENTSAUTOVENTE",
        "pu;libelle", "pu;designation"
    );
    
    // Events JavaScript
    affichage.Champ.setAutre(pi.getFormufle().getChampFille("pu"), "onchange='calculerMontant()'");
    affichage.Champ.setAutre(pi.getFormufle().getChampFille("qte"), "onchange='calculerMontant()'");
    
    // Ordre des colonnes dans le tableau
    String[] orderCol = {"idProduit", "designation", "qte", "pu", "remise"};
    pi.getFormufle().setColOrdre(orderCol);
    
    // OBLIGATOIRE: Préparer APRÈS toute configuration
    pi.preparerDataFormu();
    
    // Préparer l'affichage HTML
    pi.getFormu().makeHtmlInsertTabIndex();
    pi.getFormufle().makeHtmlInsertTableauIndex();
    
    String classeMere = "vente.Vente";
    String classeFille = "vente.VenteDetails";
    String butApresPost = "vente/vente-fiche.jsp";
    String colonneMere = "idVente";
%>
<div class="content-wrapper">
    <h1><%= pi.getTitre() %></h1>
    <form action="<%=pi.getLien()%>?but=apresMultiple.jsp" method="post">
        <% out.println(pi.getFormu().getHtmlInsert()); %>
        <% out.println(pi.getFormufle().getHtmlTableauInsert()); %>
        <input name="acte" type="hidden" value="insert">
        <input name="classe" type="hidden" value="<%=classeMere%>">
        <input name="classefille" type="hidden" value="<%=classeFille%>">
        <input name="colonneMere" type="hidden" value="<%=colonneMere%>">
        <input name="nombreLigne" type="hidden" value="<%=nombreLigne%>">
        <input name="bute" type="hidden" value="<%=butApresPost%>">
    </form>
</div>
<% } catch (Exception e) { e.printStackTrace(); } %>
```

**Méthodes PageInsertMultiple importantes:**
- `getFormu()` - Formulaire de la mère
- `getFormufle()` - Formulaire des filles
- `getFormufle().getChampFille(String)` - Template de champ fille
- `getFormufle().getChamp(String_index)` - Champ fille d'une ligne spécifique
- `getFormufle().getChampMulitple(String)` - Configurer tous les champs filles
- `getNombreLigne()` - Nombre de lignes de détail

### PageUpdate - Formulaire de modification

**Pattern complet observé** (produitextra-modif.jsp, media-modif.jsp):

```jsp
<%@ page import="monmodule.MaTable" %>
<%@ page import="affichage.PageUpdate" %>
<%@ page import="affichage.Liste" %>
<%@ page import="bean.TypeObjet" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    String id = request.getParameter("id");
    String nomtable = "MATABLE";
    String classe = "monmodule.MaTable";
    
    MaTable critere = new MaTable();
    critere.setId(id);
    PageUpdate pu = new PageUpdate(critere, request, u);
    pu.setLien(lien);
    
    // Configuration des listes déroulantes
    affichage.Champ[] liste = new affichage.Champ[1];
    TypeObjet op = new TypeObjet();
    op.setNomTable("as_unite");
    liste[0] = new Liste("idunite", op, "VAL", "id");
    pu.getFormu().changerEnChamp(liste);
    
    // Configuration des champs
    pu.getFormu().getChamp("id").setAutre("readonly");
    pu.getFormu().getChamp("nom").setLibelle("Nom");
    pu.getFormu().getChamp("nom").setAutre("required");
    pu.getFormu().getChamp("telephone").setLibelle("T&eacute;l&eacute;phone");
    
    // OBLIGATOIRE: Préparer APRÈS configuration
    pu.preparerDataFormu();
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-edit"></i> Modifier</h1>
    </section>
    <section class="content">
        <div class="box">
            <div class="box-body">
                <form action="<%=lien%>?but=apresTarif.jsp&id=<%=id%>" method="post" data-parsley-validate>
                    <input type="hidden" name="acte" value="update" />
                    <input type="hidden" name="classe" value="<%=classe%>" />
                    <input type="hidden" name="nomtable" value="<%=nomtable%>" />
                    <input type="hidden" name="bute" value="monmodule/matable-fiche.jsp" />
                    <%-- IMPORTANT: Utiliser getHtmlInsert() pour formulaire, PAS getHtml() --%>
                    <%= pu.getFormu().getHtmlInsert() %>
                    <div class="form-group">
                        <button type="submit" class="btn btn-success">
                            <i class="fa fa-save"></i> Modifier
                        </button>
                        <a href="<%=lien%>?but=monmodule/matable-fiche.jsp&id=<%=id%>" class="btn btn-default">
                            <i class="fa fa-times"></i> Annuler
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </section>
</div>
<% } catch (Exception e) { e.printStackTrace(); } %>
```

**⚠️ IMPORTANT - getHtmlInsert() vs getHtml():**
- `pu.getFormu().getHtmlInsert()` - ✅ Génère un formulaire d'édition/insertion
- `pu.getFormu().getHtml()` - ❌ Génère une recherche avancée (ne pas utiliser pour PageUpdate/PageInsert)

### PageConsulte - Page de détail (fiche)

**Pattern complet observé** (media-fiche.jsp, produitextra-fiche.jsp):

```jsp
<%@ page import="monmodule.MaTableLib" %>
<%@ page import="affichage.*" %>
<%@ page import="user.UserEJB" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>

<%
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    
    MaTableLib objet = new MaTableLib();  // Utiliser Lib pour vue avec joints
    PageConsulte pc = new PageConsulte(objet, request, u);
    pc.setTitre("Fiche Ma Table");
    pc.getBase();
    String id = pc.getBase().getTuppleID();
    
    // Configuration des champs
    pc.getChampByName("id").setLibelle("ID");
    pc.getChampByName("nom").setLibelle("Nom");
    pc.getChampByName("telephone").setLibelle("T&eacute;l&eacute;phone");
    // Masquer FK et afficher libellé joint
    pc.getChampByName("idcategorie").setVisible(false);
    pc.getChampByName("libellecategorie").setLibelle("Cat&eacute;gorie");
    
    String pageModif = "monmodule/matable-modif.jsp";
    String classe = "monmodule.MaTable";
%>

<div class="content-wrapper">
    <div class="row">
        <div class="col-md-3"></div>
        <div class="col-md-6">
            <div class="box-fiche">
                <div class="box">
                    <div class="box-title with-border">
                        <h1 class="box-title">
                            <a href="<%= lien + "?but=monmodule/matable-liste.jsp"%>">
                                <i class="fa fa-arrow-circle-left"></i>
                            </a>
                            <%= pc.getTitre() %>
                        </h1>
                    </div>
                    <div class="box-body">
                        <%-- Le framework génère automatiquement l'affichage --%>
                        <%= pc.getHtml() %>
                        <br/>
                        <div class="box-footer">
                            <a class="btn btn-warning pull-right" href="<%= lien + "?but=" + pageModif + "&id=" + id %>" style="margin-right: 10px">
                                <i class="fa fa-edit"></i> Modifier
                            </a>
                            <a class="pull-right" href="<%= lien + "?but=apresTarif.jsp&id=" + id + "&acte=delete&bute=monmodule/matable-liste.jsp&classe=" + classe %>">
                                <button class="btn btn-danger">
                                    <i class="fa fa-trash"></i> Supprimer
                                </button>
                            </a>
                        </div>
                        <br/>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
```

**Méthodes PageConsulte importantes:**
- `setTitre(String)` - Titre de la page
- `getBase()` - Récupère l'objet depuis la base (via paramètre id)
- `getChampByName(String)` - Accéder à un champ pour configuration
- `getHtml()` - Génère l'affichage automatique des champs (pas de try/catch nécessaire)

## Règles critiques JSP

1. **Toujours entourer de try/catch** avec `e.printStackTrace()`
2. **Importer TOUTES les classes utilisées** - Ne JAMAIS utiliser une classe sans l'importer :
   ```jsp
   <%@ page import="venteextra.VenteExtraLib" %>
   <%@ page import="affichage.*" %>
   <%@ page import="user.UserEJB" %>
   <%@ page import="utilitaire.Utilitaire" %>  <%-- OBLIGATOIRE si on utilise Utilitaire.dateDuJour(), etc. --%>
   <%@ page import="java.sql.Date" %>
   ```
   **Erreur fréquente** : Oublier d'importer `utilitaire.Utilitaire` quand on utilise ses méthodes statiques.
3. **Appeler `preparerDataFormu()`** APRÈS toute configuration
4. **Pour PageInsertMultiple**: passer `u` en 5ème paramètre, NE PAS appeler `setUtilisateur()`
5. **Pour PageRecherche**: appeler `setUtilisateur()` et `setLien()` AVANT `creerObjetPage()`
6. **Utiliser `session.getValue("u")` et `session.getValue("lien")`** (pas getAttribute)
7. **getHtmlInsert() vs getHtml()** - CRITIQUE :
   - `PageInsert/PageUpdate` : **TOUJOURS** utiliser `getFormu().getHtmlInsert()` pour les formulaires
   - `PageRecherche` : utiliser `getFormu().getHtml()` pour la recherche avancée
   - `PageConsulte` : utiliser `getHtml()` pour l'affichage en lecture seule
   - ⚠️ Utiliser `getHtml()` sur PageInsert/PageUpdate génère une recherche avancée au lieu d'un formulaire !
8. **ChampAutocomplete est deprecated** - Utiliser `Liste` + `TypeObjet` ou `setPageAppelComplete()`
9. **Utiliser les classes Lib pour les vues** :
   - Pages **liste** et **fiche** : utiliser `MaTableLib` (pour accéder aux champs joints de la vue)
   - Pages **saisie** et **modif** : utiliser `MaTable` (pour les opérations insert/update)
   - Variable `classe` dans apresTarif.jsp doit toujours pointer vers la classe de base, pas Lib
10. **Erreurs JSP de compilation vs runtime**:
   - **Erreur de compilation** (méthode inexistante, syntaxe) : se produit AVANT l'exécution, le try/catch dans la JSP n'existe pas encore
   - **Exception runtime** (NullPointer, etc.) : se produit pendant l'exécution, capturé par try/catch normalement
   - Le try/catch de `module.jsp` peut capturer les deux types, mais `getMessage()` est souvent null pour les erreurs de compilation
   - Toujours vérifier les logs serveur WildFly pour les détails des erreurs de compilation JSP

**⚠️ Important:** Ne PAS créer de fichiers `*-ok.jsp` individuels pour le traitement des données. Utiliser les **fichiers centralisés `apres*.jsp`** avec les paramètres `acte` et `bute`.

## Traitement des Données avec apres*.jsp

Le framework utilise des **pages de traitement centralisées** au lieu de fichiers `-ok.jsp` par module :

### Fichiers de traitement principaux
| Fichier | Usage |
|---------|-------|
| `apresTarif.jsp` | **Principal** - CRUD standard, validation, annulation |
| `apresMultiple.jsp` | Opérations mère/filles (factures avec lignes) |
| `apresReservation.jsp` | Actions spécifiques aux réservations (diffuser, etc.) |
| `apresBL.jsp` | Génération de bons de livraison |
| `apresPlanPaiement.jsp` | Gestion des plans de paiement |

### Paramètres obligatoires
```
but=apresTarif.jsp          # Page de traitement
&acte=<action>              # Action à exécuter (voir liste ci-dessous)
&classe=package.ClassName   # Classe Java complète du bean
&bute=module/page.jsp       # Page de redirection après traitement
&id=XXX                     # ID de l'objet (si update/delete/valider)
&nomtable=TABLENAME         # (optionnel) Nom de table si différent du bean
```

### Actions disponibles (`acte=`)
| Acte | Description | Paramètres requis |
|------|-------------|-------------------|
| `insert` | Créer un nouvel enregistrement | `classe`, `bute` |
| `update` | Modifier un enregistrement | `classe`, `id`, `bute` |
| `delete` | Supprimer un enregistrement | `classe`, `id`, `bute` |
| `valider` | Viser/Valider (changer état à 11) | `classe`, `id`, `bute` |
| `annuler` | Annuler (changer état à 0) | `classe`, `id`, `bute` |
| `annulerVisa` | Annuler le visa (revenir à état 1) | `classe`, `id`, `bute` |
| `dupliquer` | Dupliquer un enregistrement | `classe`, `id`, `bute` |
| `insertWithAction` | Insérer avec action métier | `classe`, `action`, `bute` |
| `insertUser` | Créer un utilisateur | `classe`, `bute` |

### Exemples concrets

#### Formulaire d'insertion
```jsp
<form action="<%=pi.getLien()%>?but=apresTarif.jsp" method="post">
    <input type="hidden" name="acte" value="insert" />
    <input type="hidden" name="classe" value="media.Media" />
    <input type="hidden" name="bute" value="media/media-liste.jsp" />
    <%= formu.getHtml() %>
    <button type="submit">Enregistrer</button>
</form>
```

#### Formulaire de modification
```jsp
<form action="<%=lien%>?but=apresTarif.jsp&id=<%=id%>" method="post">
    <input type="hidden" name="acte" value="update" />
    <input type="hidden" name="classe" value="media.Media" />
    <input type="hidden" name="bute" value="media/media-fiche.jsp" />
    <%= formu.getHtml() %>
    <button type="submit">Modifier</button>
</form>
```

#### Boutons d'action dans fiche
```jsp
<!-- Bouton Valider/Viser -->
<a class="btn btn-success" href="<%=lien%>?but=apresTarif.jsp&acte=valider&id=<%=id%>&bute=media/media-fiche.jsp&classe=media.Media">
    Viser
</a>

<!-- Bouton Annuler -->
<a class="btn btn-danger" href="<%=lien%>?but=apresTarif.jsp&acte=annuler&id=<%=id%>&bute=media/media-fiche.jsp&classe=media.Media">
    Annuler
</a>

<!-- Bouton Supprimer -->
<a class="btn btn-danger" href="<%=lien%>?but=apresTarif.jsp&acte=delete&id=<%=id%>&bute=media/media-liste.jsp&classe=media.Media">
    Supprimer
</a>

<!-- Bouton Dupliquer -->
<a class="btn btn-info" href="<%=lien%>?but=apresTarif.jsp&acte=dupliquer&id=<%=id%>&bute=media/media-fiche.jsp&classe=media.Media">
    Dupliquer
</a>
```

#### Opérations mère/filles (apresMultiple.jsp)
```jsp
<form action="<%=lien%>?but=apresMultiple.jsp" method="post">
    <input type="hidden" name="acte" value="insert" />
    <input type="hidden" name="classe" value="vente.Vente" />
    <input type="hidden" name="classefille" value="vente.VenteDetails" />
    <input type="hidden" name="colonneMere" value="idvente" />
    <input type="hidden" name="nombreLigne" value="<%=nbLignes%>" />
    <input type="hidden" name="bute" value="vente/vente-fiche.jsp" />
    <!-- Champs mère + tableau de lignes filles -->
</form>
```

### 4. Menu Entry (bdd/YYYY/YYYY-MM-DD-description.sql)
```sql
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere) 
VALUES ('MENUMATABLE', 'Ma Table', 'fa fa-table', 'module.jsp?but=monmodule/matable-liste.jsp', 1, 3, 'MENUPARENT');
```

## Autocomplete Configuration

Use `ac_*` HTML attributes (AutoComplete prefix):

```jsp
<input type="text" id="nomClient" class="form-control autocomplete"
       ac_nomTable="client" 
       ac_classe="client.Client"
       ac_champValeur="id"           <!-- Hidden field value -->
       ac_champAffiche="nom"         <!-- Dropdown display -->
       ac_champRetour="nom;telephone" <!-- Extra return fields -->
       ac_useMotCle="true"           <!-- Multi-column search -->
       ac_Where="AND actif = 1"      <!-- Filter clause -->
/>
<input type="hidden" id="idClient" name="idClient" />
```

For **dependent autocompletes** (e.g., filter products by selected category):
```javascript
onchange="dynamicAutocompleteDependant('autocompleteIdProduit', 'idProduit', 'idcategorie', this.value, '')"
```

## Critical Conventions

1. **Connection Management** - ALWAYS use try-finally:
   ```java
   Connection c = null;
   try { c = new UtilDB().GetConn(); /* ... */ } 
   finally { if (c != null) c.close(); }
   ```

2. **Array Casting** - Cast elements individually:
   ```java
   Object[] results = CGenUtil.rechercher(critere, sql, c);
   MaTable[] list = new MaTable[results.length];
   for (int i = 0; i < results.length; i++) list[i] = (MaTable) results[i];
   ```

3. **Navigation Pattern** - All pages wrap in `module.jsp?but=<path>`:
   ```
   module.jsp?but=vente/vente-liste.jsp&currentMenu=MENUVENTE
   ```

4. **JS Utilities** - Global functions in `pages/elements/js.jsp`:
   - `fetchAutocomplete()` - AJAX autocomplete calls
   - `dynamicAutocompleteDependant()` - Dependent field filtering
   - `dynamicAutocompleteDependantForChampAutoComplete()` - Cascading autocompletes

## Database

- **Oracle** with French-named columns (no underscores): `DATECREATION`, `IDCLIENT`
- **Menu permissions**: `USERMENU` table filters menus by role/user
- **SQL scripts**: Run manually, organized by date in `bdd/YYYY/` folder

## Key Files Reference

| Purpose | Location |
|---------|----------|
| ORM base class | `apj-core-update/bean/ClassMAPTable.java` |
| CRUD utilities | `apj-core-update/bean/CGenUtil.java` |
| Form generation | `apj-core-update/affichage/PageInsert.java` |
| Autocomplete servlet | `apj-core2-update/web/servlet/AutoComplete.java` |
| JS utilities | `kolotv-war/web/pages/elements/js.jsp` |
| Main layout | `kolotv-war/web/pages/module.jsp` |
| Full documentation | `DOCUMENTATION_FRAMEWORK_APJ.md` |
