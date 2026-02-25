<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="affichage.PageConsulte" %>
<%@ page import="affichage.Champ" %>
<%@ page import="bean.PostActiviteLib" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String refUserConnecte = u.getUser().getTuppleID();

        PostActiviteLib objet = new PostActiviteLib();
        PageConsulte pc = new PageConsulte(objet, request, u);
        pc.setTitre("Activit&eacute; / &Eacute;v&eacute;nement");
        PostActiviteLib detail = (PostActiviteLib) pc.getBase();
        String postId = detail.getTuppleID();

        // Configurer les libellés
        Champ c;

        c = pc.getChampByName("post_id");
        if (c != null) c.setVisible(false);

        pc.getChampByName("titre").setLibelle("Titre");
        c = pc.getChampByName("idcategorie"); if (c != null) c.setVisible(false);
        pc.getChampByName("categorie_libelle").setLibelle("Cat&eacute;gorie");
        pc.getChampByName("lieu").setLibelle("Lieu");
        pc.getChampByName("adresse").setLibelle("Adresse");
        pc.getChampByName("date_debut").setLibelle("Date de d&eacute;but");
        pc.getChampByName("date_fin").setLibelle("Date de fin");
        pc.getChampByName("prix").setLibelle("Prix");
        pc.getChampByName("nombre_places").setLibelle("Nombre de places");
        pc.getChampByName("places_restantes").setLibelle("Places restantes");
        pc.getChampByName("contact_email").setLibelle("Email de contact");
        pc.getChampByName("contact_tel").setLibelle("T&eacute;l&eacute;phone de contact");
        pc.getChampByName("lien_inscription").setLibelle("Lien d'inscription");
        pc.getChampByName("lien_externe").setLibelle("Lien externe");
        pc.getChampByName("contenu").setLibelle("Description");
        pc.getChampByName("auteur_nom").setLibelle("Publi&eacute; par");
        pc.getChampByName("statut_libelle").setLibelle("Statut");
        pc.getChampByName("visibilite_libelle").setLibelle("Visibilit&eacute;");
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

        // Déterminer si l'utilisateur connecté est l'auteur
        boolean isAuteur = (detail.getIdutilisateur() != 0)
                && String.valueOf(detail.getIdutilisateur()).equals(refUserConnecte);
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-calendar"></i> <%= pc.getTitre() %></h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carri&egrave;re</a></li>
            <li><a href="<%=lien%>?but=carriere/activite-liste.jsp">Activit&eacute;s</a></li>
            <li class="active">Fiche</li>
        </ol>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-2"></div>
            <div class="col-md-8">
                <div class="box box-danger">
                    <div class="box-header with-border">
                        <h3 class="box-title">
                            <a href="<%=lien%>?but=carriere/activite-liste.jsp">
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
                        <a class="btn btn-danger"
                           href="<%=lien%>?but=apresTarif.jsp&acte=delete&classe=bean.Post&nomtable=posts&bute=carriere/activite-liste.jsp&id=<%=postId%>"
                           onclick="return confirm('Supprimer cette activit&eacute; ?')">
                            <i class="fa fa-trash"></i> Supprimer
                        </a>
                        <a class="btn btn-info"
                           href="<%=lien%>?but=carriere/post-fichiers.jsp&postId=<%=postId%>&type=activite">
                            <i class="fa fa-file"></i> Fichiers
                        </a>
                        <% } %>
                        <a class="btn btn-default pull-right"
                           href="<%=lien%>?but=carriere/activite-liste.jsp">
                            <i class="fa fa-list"></i> Retour &agrave; la liste
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
<script language="JavaScript">alert('Erreur activite-fiche : <%=msgErr.replace("'", "\\'")%>');</script>
<%
    }
%>
