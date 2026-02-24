<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="affichage.PageInsert" %>
<%@ page import="affichage.Champ" %>
<%@ page import="affichage.Liste" %>
<%@ page import="bean.Post" %>
<%@ page import="bean.PostStage" %>
<%@ page import="bean.VisibilitePublication" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");

        // --- Section 1 : formulaire Post parent ---
        Post postModele = new Post();
        postModele.setNomTable("posts");
        PageInsert piPost = new PageInsert(postModele, request, u);
        piPost.setTitre("Publier une offre de stage");

        Champ c;
        c = piPost.getChampByName("post_id");        if (c != null) c.setVisible(false);
        c = piPost.getChampByName("idutilisateur");  if (c != null) c.setVisible(false);
        c = piPost.getChampByName("type");           if (c != null) c.setVisible(false);
        c = piPost.getChampByName("idstatutpublication"); if (c != null) c.setVisible(false);
        c = piPost.getChampByName("idgroupe");       if (c != null) c.setVisible(false);
        c = piPost.getChampByName("epingle");        if (c != null) c.setVisible(false);
        c = piPost.getChampByName("supprime");       if (c != null) c.setVisible(false);
        c = piPost.getChampByName("edited_at");      if (c != null) c.setVisible(false);
        c = piPost.getChampByName("created_at");     if (c != null) c.setVisible(false);

        Champ champContenu = piPost.getChampByName("contenu");
        if (champContenu != null) {
            champContenu.setLibelle("Description du stage");
            champContenu.setType("editor");
            champContenu.setObligatoire(true);
        }

        Champ champVisi = piPost.getChampByName("idvisibilite");
        if (champVisi != null) {
            champVisi.setLibelle("Visibilite");
            champVisi.setObligatoire(true);
            Liste listeVisi = new Liste(new VisibilitePublication(), u,
                    "idvisibilite", "libelle");
            champVisi.setListe(listeVisi);
        }

        // --- Section 2 : formulaire PostStage ---
        PostStage stageModele = new PostStage();
        PageInsert piStage = new PageInsert(stageModele, request, u);

        c = piStage.getChampByName("post_id");       if (c != null) c.setVisible(false);

        piStage.getChampByName("entreprise").setLibelle("Entreprise / Organisme");
        piStage.getChampByName("entreprise").setObligatoire(true);
        piStage.getChampByName("localisation").setLibelle("Localisation");
        piStage.getChampByName("duree").setLibelle("Duree (ex: 3 mois)");
        piStage.getChampByName("date_debut").setLibelle("Date de debut");
        piStage.getChampByName("date_fin").setLibelle("Date de fin");
        piStage.getChampByName("indemnite").setLibelle("Indemnite mensuelle");
        piStage.getChampByName("places_disponibles").setLibelle("Nombre de places");
        piStage.getChampByName("contact_email").setLibelle("Email de contact");
        piStage.getChampByName("contact_tel").setLibelle("Telephone");
        piStage.getChampByName("lien_candidature").setLibelle("Lien de candidature");

        Champ champConvention = piStage.getChampByName("convention_requise");
        if (champConvention != null) {
            champConvention.setLibelle("Convention requise");
            Liste listeConv = new Liste();
            listeConv.ajouterLigne("0", "Non");
            listeConv.ajouterLigne("1", "Oui");
            champConvention.setListe(listeConv);
        }

        Champ champComp = piStage.getChampByName("competences_requises");
        if (champComp != null) {
            champComp.setLibelle("Competences requises");
            champComp.setType("editor");
        }

        Champ champNiveau = piStage.getChampByName("niveau_etude_requis");
        if (champNiveau != null) champNiveau.setLibelle("Niveau d etude requis");
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-graduation-cap"></i> <%= piPost.getTitre() %></h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carriere</a></li>
            <li><a href="<%=lien%>?but=carriere/stage-liste.jsp">Offres de stage</a></li>
            <li class="active">Publier</li>
        </ol>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-1"></div>
            <div class="col-md-10">
                <form method="post" action="<%=lien%>">
                    <input type="hidden" name="but" value="apresCarriere.jsp">
                    <input type="hidden" name="acte" value="insertStage">
                    <input type="hidden" name="bute" value="carriere/stage-fiche.jsp">

                    <!-- Section Post -->
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Publication</h3>
                        </div>
                        <div class="box-body">
                            <%= piPost.getHtml() %>
                        </div>
                    </div>

                    <!-- Section PostStage -->
                    <div class="box box-success">
                        <div class="box-header with-border">
                            <h3 class="box-title">Details du stage</h3>
                        </div>
                        <div class="box-body">
                            <%= piStage.getHtml() %>
                        </div>
                    </div>

                    <div class="box-footer">
                        <button type="submit" class="btn btn-success">
                            <i class="fa fa-paper-plane"></i> Publier
                        </button>
                        <a class="btn btn-default pull-right"
                           href="<%=lien%>?but=carriere/stage-liste.jsp">
                            <i class="fa fa-times"></i> Annuler
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
        String msgErr = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
%>
<script language="JavaScript">alert('Erreur stage-saisie : <%=msgErr.replace("'", "\\'")%>');</script>
<%
    }
%>
