<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="affichage.PageInsert" %>
<%@ page import="affichage.Liste" %>
<%@ page import="bean.Post" %>
<%@ page import="bean.PostEmploi" %>
<%@ page import="bean.VisibilitePublication" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");

        // --------------------------------------------------------
        // Section 1 : Formulaire Post (contenu, visibilite)
        // --------------------------------------------------------
        Post post = new Post();
        PageInsert piPost = new PageInsert(post, request, u);
        piPost.setLien(lien);

        // Listes deroulantes
        Liste[] listesPost = new Liste[1];
        VisibilitePublication vis = new VisibilitePublication();
        listesPost[0] = new Liste("idvisibilite", vis, "libelle", "id");
        piPost.getFormu().changerEnChamp(listesPost);

        // Libelles
        piPost.getFormu().getChamp("contenu").setLibelle("Description de l'offre");
        piPost.getFormu().getChamp("contenu").setType("editor");
        piPost.getFormu().getChamp("idvisibilite").setLibelle("Visibilite");

        // Masquer les champs geres automatiquement
        piPost.getFormu().getChamp("id").setVisible(false);
        piPost.getFormu().getChamp("idutilisateur").setVisible(false);
        piPost.getFormu().getChamp("idtypepublication").setVisible(false);
        piPost.getFormu().getChamp("idstatutpublication").setVisible(false);
        piPost.getFormu().getChamp("idgroupe").setVisible(false);
        piPost.getFormu().getChamp("epingle").setVisible(false);
        piPost.getFormu().getChamp("supprime").setVisible(false);
        piPost.getFormu().getChamp("date_suppression").setVisible(false);
        piPost.getFormu().getChamp("nb_likes").setVisible(false);
        piPost.getFormu().getChamp("nb_commentaires").setVisible(false);
        piPost.getFormu().getChamp("nb_partages").setVisible(false);
        piPost.getFormu().getChamp("created_at").setVisible(false);
        piPost.getFormu().getChamp("edited_at").setVisible(false);
        piPost.getFormu().getChamp("edited_by").setVisible(false);

        piPost.getFormu().setOrdre(new String[]{"contenu", "idvisibilite"});
        piPost.preparerDataFormu();
        piPost.getFormu().makeHtmlInsertTabIndex();

        // --------------------------------------------------------
        // Section 2 : Formulaire PostEmploi (details specifiques)
        // --------------------------------------------------------
        PostEmploi emploi = new PostEmploi();
        PageInsert piEmploi = new PageInsert(emploi, request, u);
        piEmploi.setLien(lien);

        // Liste type_contrat via valeurs statiques
        Liste listeContrat = new Liste("type_contrat");
        listeContrat.makeListeString(
            new String[]{"CDI", "CDD", "Freelance", "Alternance", "Autre"},
            new String[]{"CDI", "CDD", "Freelance", "Alternance", "Autre"}
        );

        // Liste teletravail_possible
        Liste listeTeletravail = new Liste("teletravail_possible");
        listeTeletravail.makeListeString(
            new String[]{"Non", "Oui"},
            new String[]{"0",   "1"}
        );

        Liste[] listesEmploi = new Liste[]{listeContrat, listeTeletravail};
        piEmploi.getFormu().changerEnChamp(listesEmploi);

        // Libelles
        piEmploi.getFormu().getChamp("entreprise").setLibelle("Entreprise");
        piEmploi.getFormu().getChamp("entreprise").setAutre("required");
        piEmploi.getFormu().getChamp("poste").setLibelle("Intitule du poste");
        piEmploi.getFormu().getChamp("poste").setAutre("required");
        piEmploi.getFormu().getChamp("localisation").setLibelle("Localisation");
        piEmploi.getFormu().getChamp("type_contrat").setLibelle("Type de contrat");
        piEmploi.getFormu().getChamp("salaire_min").setLibelle("Salaire minimum (MGA)");
        piEmploi.getFormu().getChamp("salaire_max").setLibelle("Salaire maximum (MGA)");
        piEmploi.getFormu().getChamp("devise").setLibelle("Devise");
        piEmploi.getFormu().getChamp("devise").setDefaut("MGA");
        piEmploi.getFormu().getChamp("experience_requise").setLibelle("Experience requise");
        piEmploi.getFormu().getChamp("competences_requises").setLibelle("Competences requises");
        piEmploi.getFormu().getChamp("competences_requises").setType("editor");
        piEmploi.getFormu().getChamp("niveau_etude_requis").setLibelle("Niveau d'etude requis");
        piEmploi.getFormu().getChamp("teletravail_possible").setLibelle("Teletravail possible");
        piEmploi.getFormu().getChamp("date_limite").setLibelle("Date limite candidature");
        piEmploi.getFormu().getChamp("contact_email").setLibelle("Email de contact");
        piEmploi.getFormu().getChamp("contact_tel").setLibelle("Telephone de contact");
        piEmploi.getFormu().getChamp("lien_candidature").setLibelle("Lien de candidature");

        // Masquer post_id (auto-rempli par apresCarriere.jsp)
        piEmploi.getFormu().getChamp("post_id").setVisible(false);

        piEmploi.getFormu().setOrdre(new String[]{
            "entreprise", "poste", "localisation", "type_contrat",
            "salaire_min", "salaire_max", "devise",
            "experience_requise", "niveau_etude_requis",
            "competences_requises", "teletravail_possible",
            "date_limite", "contact_email", "contact_tel", "lien_candidature"
        });
        piEmploi.preparerDataFormu();
        piEmploi.getFormu().makeHtmlInsertTabIndex();
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-suitcase"></i> Publier une offre d'emploi</h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carriere</a></li>
            <li class="active">Publier emploi</li>
        </ol>
    </section>
    <section class="content">
        <form action="<%=lien%>?but=apresCarriere.jsp" method="post" data-parsley-validate>

            <!-- Section : Publication -->
            <div class="box box-primary">
                <div class="box-header with-border">
                    <h3 class="box-title"><i class="fa fa-pencil"></i> Description de l'offre</h3>
                </div>
                <div class="box-body">
                    <%= piPost.getFormu().getHtmlInsert() %>
                </div>
            </div>

            <!-- Section : Details emploi -->
            <div class="box box-success">
                <div class="box-header with-border">
                    <h3 class="box-title"><i class="fa fa-suitcase"></i> Details de l'offre d'emploi</h3>
                </div>
                <div class="box-body">
                    <%= piEmploi.getFormu().getHtmlInsert() %>
                </div>
            </div>

            <!-- Champs caches obligatoires -->
            <input type="hidden" name="acte"  value="insertEmploi" />
            <input type="hidden" name="bute"  value="carriere/emploi-fiche.jsp" />

            <!-- Boutons -->
            <div class="box">
                <div class="box-footer">
                    <button type="submit" class="btn btn-primary">
                        <i class="fa fa-check"></i> Publier l'offre d'emploi
                    </button>
                    <a href="<%=lien%>?but=carriere/emploi-liste.jsp" class="btn btn-default" style="margin-left:10px">
                        <i class="fa fa-times"></i> Annuler
                    </a>
                </div>
            </div>

        </form>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
        String msgErr = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
%>
<script language="JavaScript">
    alert('Erreur emploi-saisie : <%=msgErr.replace("'", "\\'")%>');
    history.back();
</script>
<%
    }
%>
