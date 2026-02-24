<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="affichage.PageUpdate" %>
<%@ page import="affichage.Champ" %>
<%@ page import="affichage.Liste" %>
<%@ page import="bean.Post" %>
<%@ page import="bean.PostEmploi" %>
<%@ page import="bean.VisibilitePublication" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String postId = request.getParameter("id");

        // --- Section 1 : mise a jour du Post parent ---
        Post postModele = new Post();
        postModele.setNomTable("posts");
        PageUpdate puPost = new PageUpdate(postModele, request, u);
        puPost.setTitre("Modifier l'offre d'emploi");

        Champ c;
        c = puPost.getChampByName("post_id");        if (c != null) c.setVisible(false);
        c = puPost.getChampByName("idutilisateur");  if (c != null) c.setVisible(false);
        c = puPost.getChampByName("type");           if (c != null) c.setVisible(false);
        c = puPost.getChampByName("idstatutpublication"); if (c != null) c.setVisible(false);
        c = puPost.getChampByName("idgroupe");       if (c != null) c.setVisible(false);
        c = puPost.getChampByName("epingle");        if (c != null) c.setVisible(false);
        c = puPost.getChampByName("supprime");       if (c != null) c.setVisible(false);
        c = puPost.getChampByName("edited_at");      if (c != null) c.setVisible(false);
        c = puPost.getChampByName("created_at");     if (c != null) c.setVisible(false);

        Champ champContenu = puPost.getChampByName("contenu");
        if (champContenu != null) {
            champContenu.setLibelle("Description");
            champContenu.setType("editor");
            champContenu.setObligatoire(true);
        }

        Champ champVisi = puPost.getChampByName("idvisibilite");
        if (champVisi != null) {
            champVisi.setLibelle("Visibilite");
            champVisi.setObligatoire(true);
            Liste listeVisi = new Liste(new VisibilitePublication(), u,
                    "idvisibilite", "libelle");
            champVisi.setListe(listeVisi);
        }

        // --- Section 2 : mise a jour du PostEmploi ---
        PostEmploi emploiModele = new PostEmploi();
        PageUpdate puEmploi = new PageUpdate(emploiModele, request, u);

        c = puEmploi.getChampByName("post_id");      if (c != null) c.setVisible(false);

        puEmploi.getChampByName("entreprise").setLibelle("Entreprise");
        puEmploi.getChampByName("entreprise").setObligatoire(true);
        puEmploi.getChampByName("poste").setLibelle("Poste");
        puEmploi.getChampByName("poste").setObligatoire(true);
        puEmploi.getChampByName("localisation").setLibelle("Localisation");
        puEmploi.getChampByName("salaire_min").setLibelle("Salaire minimum");
        puEmploi.getChampByName("salaire_max").setLibelle("Salaire maximum");
        puEmploi.getChampByName("devise").setLibelle("Devise");
        puEmploi.getChampByName("experience_requise").setLibelle("Experience requise");
        puEmploi.getChampByName("niveau_etude_requis").setLibelle("Niveau d etude requis");
        puEmploi.getChampByName("date_limite").setLibelle("Date limite");
        puEmploi.getChampByName("contact_email").setLibelle("Email de contact");
        puEmploi.getChampByName("contact_tel").setLibelle("Telephone");
        puEmploi.getChampByName("lien_candidature").setLibelle("Lien de candidature");

        Champ champContrat = puEmploi.getChampByName("type_contrat");
        if (champContrat != null) {
            champContrat.setLibelle("Type de contrat");
            Liste listeContrat = new Liste();
            listeContrat.ajouterLigne("CDI", "CDI");
            listeContrat.ajouterLigne("CDD", "CDD");
            listeContrat.ajouterLigne("Freelance", "Freelance");
            listeContrat.ajouterLigne("Alternance", "Alternance");
            listeContrat.ajouterLigne("Autre", "Autre");
            champContrat.setListe(listeContrat);
        }

        Champ champTeletravail = puEmploi.getChampByName("teletravail_possible");
        if (champTeletravail != null) {
            champTeletravail.setLibelle("Teletravail possible");
            Liste listeTT = new Liste();
            listeTT.ajouterLigne("0", "Non");
            listeTT.ajouterLigne("1", "Oui");
            champTeletravail.setListe(listeTT);
        }

        Champ champComp = puEmploi.getChampByName("competences_requises");
        if (champComp != null) {
            champComp.setLibelle("Competences requises");
            champComp.setType("editor");
        }
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-edit"></i> <%= puPost.getTitre() %></h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carriere</a></li>
            <li><a href="<%=lien%>?but=carriere/emploi-liste.jsp">Offres d'emploi</a></li>
            <li class="active">Modifier</li>
        </ol>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-1"></div>
            <div class="col-md-10">
                <form method="post" action="<%=lien%>">
                    <input type="hidden" name="but" value="apresCarriere.jsp">
                    <input type="hidden" name="acte" value="updateEmploi">
                    <input type="hidden" name="bute" value="carriere/emploi-fiche.jsp">
                    <input type="hidden" name="id" value="<%=postId%>">

                    <!-- Section Post -->
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Publication</h3>
                        </div>
                        <div class="box-body">
                            <%= puPost.getHtml() %>
                        </div>
                    </div>

                    <!-- Section PostEmploi -->
                    <div class="box box-warning">
                        <div class="box-header with-border">
                            <h3 class="box-title">Details de l offre d emploi</h3>
                        </div>
                        <div class="box-body">
                            <%= puEmploi.getHtml() %>
                        </div>
                    </div>

                    <div class="box-footer">
                        <button type="submit" class="btn btn-warning">
                            <i class="fa fa-save"></i> Enregistrer les modifications
                        </button>
                        <a class="btn btn-default pull-right"
                           href="<%=lien%>?but=carriere/emploi-fiche.jsp&id=<%=postId%>">
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
<script language="JavaScript">alert('Erreur emploi-modif : <%=msgErr.replace("'", "\\'")%>');</script>
<%
    }
%>
