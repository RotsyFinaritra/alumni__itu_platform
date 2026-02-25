<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="affichage.PageConsulte" %>
<%@ page import="affichage.Champ" %>
<%@ page import="bean.PostEmploiLib" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String refUserConnecte = u.getUser().getTuppleID();

        PostEmploiLib objet = new PostEmploiLib();
        PageConsulte pc = new PageConsulte(objet, request, u);
        pc.setTitre("Offre d'emploi");
        PostEmploiLib detail = (PostEmploiLib) pc.getBase();
        String postId = detail.getTuppleID();

        // Configurer les libelles
        Champ c;

        c = pc.getChampByName("post_id");
        if (c != null) c.setVisible(false);

        pc.getChampByName("entreprise").setLibelle("Entreprise");
        pc.getChampByName("poste").setLibelle("Poste");
        pc.getChampByName("localisation").setLibelle("Localisation");
        pc.getChampByName("type_contrat").setLibelle("Type de contrat");
        pc.getChampByName("salaire_min").setLibelle("Salaire minimum");
        pc.getChampByName("salaire_max").setLibelle("Salaire maximum");
        pc.getChampByName("devise").setLibelle("Devise");
        pc.getChampByName("experience_requise").setLibelle("Experience requise");
        pc.getChampByName("competences_requises").setLibelle("Competences requises");
        pc.getChampByName("niveau_etude_requis").setLibelle("Niveau d'etude requis");
        pc.getChampByName("teletravail_possible").setLibelle("Teletravail possible");
        pc.getChampByName("date_limite").setLibelle("Date limite");
        pc.getChampByName("contact_email").setLibelle("Email de contact");
        pc.getChampByName("contact_tel").setLibelle("Telephone de contact");
        pc.getChampByName("lien_candidature").setLibelle("Lien de candidature");
        pc.getChampByName("contenu").setLibelle("Description");
        pc.getChampByName("auteur_nom").setLibelle("Publie par");
        pc.getChampByName("statut_libelle").setLibelle("Statut");
        pc.getChampByName("visibilite_libelle").setLibelle("Visibilite");
        pc.getChampByName("nb_likes").setLibelle("Likes");
        pc.getChampByName("nb_commentaires").setLibelle("Commentaires");
        pc.getChampByName("nb_partages").setLibelle("Partages");
        pc.getChampByName("created_at").setLibelle("Date de publication");

        // Masquer les champs techniques internes
        c = pc.getChampByName("idutilisateur");      if (c != null) c.setVisible(false);
        c = pc.getChampByName("idgroupe");            if (c != null) c.setVisible(false);
        c = pc.getChampByName("idvisibilite");        if (c != null) c.setVisible(false);
        c = pc.getChampByName("idstatutpublication"); if (c != null) c.setVisible(false);
        c = pc.getChampByName("epingle");             if (c != null) c.setVisible(false);
        c = pc.getChampByName("supprime");            if (c != null) c.setVisible(false);
        c = pc.getChampByName("edited_at");           if (c != null) c.setVisible(false);

        // Determiner si l'utilisateur connecte est l'auteur
        boolean isAuteur = (detail.getIdutilisateur() != null)
                && String.valueOf(detail.getIdutilisateur()).equals(refUserConnecte);
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-suitcase"></i> <%= pc.getTitre() %></h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carriere</a></li>
            <li><a href="<%=lien%>?but=carriere/emploi-liste.jsp">Offres d'emploi</a></li>
            <li class="active">Fiche</li>
        </ol>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-2"></div>
            <div class="col-md-8">
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title">
                            <a href="<%=lien%>?but=carriere/emploi-liste.jsp">
                                <i class="fa fa-arrow-circle-left"></i>
                            </a>
                            &nbsp;<%= pc.getTitre() %>
                        </h3>
                    </div>
                    <div class="box-body">
                        <%= pc.getHtml() %>
                    </div>
                    <div class="box-footer">
                        <% if (isAuteur) { %>
                        <a class="btn btn-warning"
                           href="<%=lien%>?but=carriere/emploi-modif.jsp&id=<%=postId%>">
                            <i class="fa fa-edit"></i> Modifier
                        </a>
                        <a class="btn btn-info"
                           href="<%=lien%>?but=carriere/post-fichiers.jsp&postId=<%=postId%>&type=emploi">
                            <i class="fa fa-file"></i> Fichiers
                        </a>
                        <a class="btn btn-danger"
                           href="<%=lien%>?but=apresTarif.jsp&acte=delete&classe=bean.Post&nomtable=posts&bute=carriere/emploi-liste.jsp&id=<%=postId%>"
                           onclick="return confirm('Supprimer cette offre ?')">
                            <i class="fa fa-trash"></i> Supprimer
                        </a>
                        <% } %>
                        <a class="btn btn-default pull-right"
                           href="<%=lien%>?but=carriere/emploi-liste.jsp">
                            <i class="fa fa-list"></i> Retour a la liste
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
        String msgErr = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
%>
<script language="JavaScript">alert('Erreur emploi-fiche : <%=msgErr.replace("'", "\\'")%>');</script>
<%
    }
%>
