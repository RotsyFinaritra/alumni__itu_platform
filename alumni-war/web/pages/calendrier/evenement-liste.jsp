<%@ page pageEncoding="UTF-8" %>
<%@ page import="bean.CalendrierScolaire" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="user.UserEJB" %>
<%@ page import="affichage.PageRecherche" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String idrole = u.getUser().getIdrole() != null ? u.getUser().getIdrole() : "";
        if (!"admin".equalsIgnoreCase(idrole)) {
%>
<script>document.location.replace('<%= lien %>?but=calendrier/calendrier-scolaire.jsp');</script>
<%
            return;
        }

        CalendrierScolaire liste = new CalendrierScolaire();
        String[] libEntete = {"id", "titre", "date_debut", "date_fin", "couleur", "idpromotion"};
        String[] listeCrt = {"titre", "idpromotion"};
        String[] listeInt = {"date_debut"};

        PageRecherche pr = new PageRecherche(liste, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
        pr.setTitre("Gestion des &eacute;v&eacute;nements");
        pr.setUtilisateur(u);
        pr.setLien(lien);
        pr.setApres("calendrier/evenement-liste.jsp");

        // Labels des critères
        pr.getFormu().getChamp("titre").setLibelle("Titre");
        pr.getFormu().getChamp("idpromotion").setLibelle("Promotion");
        pr.getFormu().getChamp("date_debut1").setLibelle("Date d&eacute;but min");
        pr.getFormu().getChamp("date_debut2").setLibelle("Date d&eacute;but max");

        String[] colSomme = null;
        pr.creerObjetPage(libEntete, colSomme);

        // Liens tableau
        String[] lienTableau = {pr.getLien() + "?but=calendrier/evenement-modif.jsp"};
        String[] colonneLien = {"id"};
        pr.getTableau().setLien(lienTableau);
        pr.getTableau().setColonneLien(colonneLien);

        String[] libEnteteAffiche = {"ID", "Titre", "Date d&eacute;but", "Date fin", "Couleur", "Promotion"};
        pr.getTableau().setLibelleAffiche(libEnteteAffiche);
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-list"></i> <%= pr.getTitre() %></h1>
        <ol class="breadcrumb">
            <li><a href="<%= lien %>?but=calendrier/calendrier-scolaire.jsp"><i class="fa fa-calendar"></i> Calendrier</a></li>
            <li class="active">G&eacute;rer les &eacute;v&eacute;nements</li>
        </ol>
    </section>
    <section class="content">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title">Recherche</h3>
                <div class="box-tools pull-right">
                    <a href="<%= lien %>?but=calendrier/evenement-saisie.jsp" class="btn btn-primary btn-sm">
                        <i class="fa fa-plus"></i> Nouvel &eacute;v&eacute;nement
                    </a>
                </div>
            </div>
            <div class="box-body">
                <form action="<%= pr.getLien() %>?but=calendrier/evenement-liste.jsp" method="post">
                    <% out.println(pr.getFormu().getHtmlEnsemble()); %>
                </form>
            </div>
        </div>

        <% out.println(pr.getTableauRecap().getHtml()); %>
        <% out.println(pr.getTableau().getHtml()); %>
        <% out.println(pr.getBasPage()); %>
    </section>
</div>
<% } catch (Exception e) { e.printStackTrace(); %>
<div class="content-wrapper">
    <section class="content">
        <div class="alert alert-danger"><i class="fa fa-exclamation-triangle"></i> Erreur: <%= e.getMessage() %></div>
    </section>
</div>
<% } %>
