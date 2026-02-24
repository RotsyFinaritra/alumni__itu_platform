<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="affichage.PageRecherche" %>
<%@ page import="affichage.Champ" %>
<%@ page import="bean.PostStageLib" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");

        PostStageLib objet = new PostStageLib();
        PageRecherche pr = new PageRecherche(objet, request, u);
        pr.setTitre("Offres de stage");
        pr.setNpp(20);
        pr.setListeCrt(new String[]{"entreprise", "localisation", "duree", "auteur_nom"});
        pr.setListeInt(new String[]{"date_debut", "created_at"});
        pr.setApresWhere(" AND supprime = 0");

        // Colonnes a afficher dans la liste
        pr.setListeCol(new String[]{
            "created_at", "entreprise", "localisation",
            "duree", "date_debut", "date_fin",
            "indemnite", "auteur_nom"
        });
        pr.setListeLibCol(new String[]{
            "Date", "Entreprise / Organisme", "Localisation",
            "Duree", "Debut", "Fin",
            "Indemnite", "Publie par"
        });

        // Lien vers la fiche sur la colonne entreprise
        pr.setLienColonne("entreprise",
                lien + "?but=carriere/stage-fiche.jsp&id=", "post_id");
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-graduation-cap"></i> <%= pr.getTitre() %></h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carriere</a></li>
            <li class="active">Offres de stage</li>
        </ol>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-12">
                <div class="box box-success">
                    <div class="box-header with-border">
                        <h3 class="box-title"><%= pr.getTitre() %></h3>
                        <div class="box-tools pull-right">
                            <a class="btn btn-success btn-sm"
                               href="<%=lien%>?but=carriere/stage-saisie.jsp">
                                <i class="fa fa-plus"></i> Publier un stage
                            </a>
                        </div>
                    </div>
                    <div class="box-body">
                        <%= pr.getHtml() %>
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
<script language="JavaScript">alert('Erreur stage-liste : <%=msgErr.replace("'", "\\'")%>');</script>
<%
    }
%>
