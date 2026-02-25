<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="affichage.PageConsulte" %>
<%@ page import="affichage.Champ" %>
<%@ page import="bean.PostStageLib" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String refUserConnecte = u.getUser().getTuppleID();

        PostStageLib objet = new PostStageLib();
        PageConsulte pc = new PageConsulte(objet, request, u);
        pc.setTitre("Offre de stage");
        PostStageLib detail = (PostStageLib) pc.getBase();
        String postId = detail.getTuppleID();

        Champ c;

        c = pc.getChampByName("post_id");             if (c != null) c.setVisible(false);
        c = pc.getChampByName("identreprise");        if (c != null) c.setVisible(false);
        c = pc.getChampByName("entreprise");           if (c != null) c.setLibelle("Entreprise / Organisme");
        c = pc.getChampByName("localisation");         if (c != null) c.setLibelle("Localisation");
        c = pc.getChampByName("duree");                if (c != null) c.setLibelle("Duree");
        c = pc.getChampByName("date_debut");           if (c != null) c.setLibelle("Date de debut");
        c = pc.getChampByName("date_fin");             if (c != null) c.setLibelle("Date de fin");
        c = pc.getChampByName("indemnite");            if (c != null) c.setLibelle("Indemnite mensuelle");
        c = pc.getChampByName("convention_requise");   if (c != null) c.setLibelle("Convention requise");
        c = pc.getChampByName("places_disponibles");   if (c != null) c.setLibelle("Nombre de places");
        c = pc.getChampByName("niveau_etude_requis");  if (c != null) c.setLibelle("Niveau d'etude requis");
        c = pc.getChampByName("competences_requises"); if (c != null) c.setLibelle("Competences requises");
        c = pc.getChampByName("contact_email");        if (c != null) c.setLibelle("Email de contact");
        c = pc.getChampByName("contact_tel");          if (c != null) c.setLibelle("Telephone");
        c = pc.getChampByName("lien_candidature");     if (c != null) c.setLibelle("Lien de candidature");
        c = pc.getChampByName("contenu");              if (c != null) c.setLibelle("Description");
        c = pc.getChampByName("auteur_nom");           if (c != null) c.setLibelle("Publie par");
        c = pc.getChampByName("statut_libelle");       if (c != null) c.setLibelle("Statut");
        c = pc.getChampByName("visibilite_libelle");   if (c != null) c.setLibelle("Visibilite");
        c = pc.getChampByName("nb_likes");             if (c != null) c.setLibelle("Likes");
        c = pc.getChampByName("nb_commentaires");      if (c != null) c.setLibelle("Commentaires");
        c = pc.getChampByName("nb_partages");          if (c != null) c.setLibelle("Partages");
        c = pc.getChampByName("created_at");           if (c != null) c.setLibelle("Date de publication");

        // Masquer les champs techniques
        c = pc.getChampByName("idutilisateur");        if (c != null) c.setVisible(false);
        c = pc.getChampByName("idgroupe");             if (c != null) c.setVisible(false);
        c = pc.getChampByName("idvisibilite");         if (c != null) c.setVisible(false);
        c = pc.getChampByName("idstatutpublication");  if (c != null) c.setVisible(false);
        c = pc.getChampByName("epingle");              if (c != null) c.setVisible(false);
        c = pc.getChampByName("supprime");             if (c != null) c.setVisible(false);
        c = pc.getChampByName("edited_at");            if (c != null) c.setVisible(false);
        c = pc.getChampByName("edited_by");            if (c != null) c.setVisible(false);
        c = pc.getChampByName("date_suppression");     if (c != null) c.setVisible(false);

        boolean isAuteur = (detail.getIdutilisateur() != 0)
                && String.valueOf(detail.getIdutilisateur()).equals(refUserConnecte);
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-graduation-cap"></i> <%= pc.getTitre() %></h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carriere</a></li>
            <li><a href="<%=lien%>?but=carriere/stage-liste.jsp">Offres de stage</a></li>
            <li class="active">Fiche</li>
        </ol>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-2"></div>
            <div class="col-md-8">
                <div class="box box-success">
                    <div class="box-header with-border">
                        <h3 class="box-title">
                            <a href="<%=lien%>?but=carriere/stage-liste.jsp">
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
                           href="<%=lien%>?but=carriere/stage-modif.jsp&id=<%=postId%>">
                            <i class="fa fa-edit"></i> Modifier
                        </a>
                        <a class="btn btn-info"
                           href="<%=lien%>?but=carriere/post-fichiers.jsp&postId=<%=postId%>&type=stage">
                            <i class="fa fa-file"></i> Fichiers
                        </a>
                        <a class="btn btn-danger"
                           href="<%=lien%>?but=apresTarif.jsp&acte=delete&classe=bean.Post&nomtable=posts&bute=carriere/stage-liste.jsp&id=<%=postId%>"
                           onclick="return confirm('Supprimer cette offre de stage ?')">
                            <i class="fa fa-trash"></i> Supprimer
                        </a>
                        <% } %>
                        <a class="btn btn-default pull-right"
                           href="<%=lien%>?but=carriere/stage-liste.jsp">
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
<script language="JavaScript">alert('Erreur stage-fiche : <%=msgErr.replace("'", "\\'")%>');</script>
<%
    }
%>
