<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="affichage.PageRecherche" %>
<%@ page import="bean.PostEmploiLib" %>
<%@ page import="user.UserEJB" %>
<%@ page import="utilitaire.Utilitaire" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");

        PostEmploiLib t = new PostEmploiLib();

        String[] listeCrt = {"entreprise", "poste", "localisation", "type_contrat", "auteur_nom"};
        String[] listeInt = {"created_at"};
        String[] libEntete = {"created_at", "entreprise", "poste", "localisation", "type_contrat", "auteur_nom", "nb_likes", "nb_commentaires"};

        PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
        pr.setTitre("Offres d'emploi");
        pr.setUtilisateur(u);
        pr.setLien(lien);
        pr.setApres("carriere/emploi-liste.jsp");

        // Libelles des criteres
        pr.getFormu().getChamp("entreprise").setLibelle("Entreprise");
        pr.getFormu().getChamp("poste").setLibelle("Poste");
        pr.getFormu().getChamp("localisation").setLibelle("Localisation");
        pr.getFormu().getChamp("type_contrat").setLibelle("Type de contrat");
        pr.getFormu().getChamp("auteur_nom").setLibelle("Publie par");
        pr.getFormu().getChamp("created_at1").setLibelle("Date min");
        pr.getFormu().getChamp("created_at2").setLibelle("Date max");
        pr.getFormu().getChamp("created_at2").setDefaut(Utilitaire.dateDuJour());

        // Filtre : offres actives uniquement (non supprimees, publiees)
        pr.setAWhere(" AND supprime = 0");

        pr.setNpp(20);

        String[] colSomme = null;
        pr.creerObjetPage(libEntete, colSomme);

        // Lien cliquable sur post_id (colonne principale d'identifiant)
        String[] lienTableau  = {lien + "?but=carriere/emploi-fiche.jsp"};
        String[] colonneLien  = {"post_id"};
        pr.getTableau().setLien(lienTableau);
        pr.getTableau().setColonneLien(colonneLien);

        // En-tetes affiches
        String[] libEnteteAffiche = {"Date", "Entreprise", "Poste", "Localisation", "Contrat", "Publie par", "Likes", "Commentaires"};
        pr.getTableau().setLibelleAffiche(libEnteteAffiche);
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-suitcase"></i> Offres d'emploi</h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carriere</a></li>
            <li class="active">Offres d'emploi</li>
        </ol>
    </section>
    <section class="content">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title"><i class="fa fa-search"></i> Rechercher</h3>
                <div class="box-tools pull-right">
                    <a href="<%=lien%>?but=carriere/emploi-saisie.jsp" class="btn btn-success btn-sm">
                        <i class="fa fa-plus"></i> Publier une offre
                    </a>
                </div>
            </div>
            <div class="box-body">
                <form action="<%=lien%>?but=carriere/emploi-liste.jsp" method="post">
                    <%= pr.getFormu().getHtmlEnsemble() %>
                </form>
            </div>
        </div>

        <%= pr.getTableauRecap().getHtml() %>

        <div class="box">
            <div class="box-body no-padding">
                <%= pr.getTableau().getHtml() %>
            </div>
        </div>

        <%= pr.getBasPage() %>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
        String msgErr = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
%>
<script language="JavaScript">alert('Erreur emploi-liste : <%=msgErr.replace("'", "\\'")%>');</script>
<%
    }
%>
