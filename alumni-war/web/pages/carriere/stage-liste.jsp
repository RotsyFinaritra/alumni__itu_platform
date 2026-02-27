<%@page contentType="text/html;charset=UTF-8" %>
<%@page import="affichage.PageRecherche" %>
<%@page import="bean.PostStageLib" %>
<%@page import="utilitaire.Utilitaire" %>
<%@page import="utils.PublicationPermission" %>
<%@page import="user.UserEJB" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    boolean peutAjouter = PublicationPermission.afficherBoutonAjouter(u);
    int pubRestantes = PublicationPermission.publicationsRestantes(u);
    PostStageLib t = new PostStageLib();

    String[] listeCrt = {"identreprise", "localisation", "duree", "auteur_nom", "created_at"};
    String[] listeInt = {"created_at"};
    String[] libEntete = {"post_id", "created_at", "entreprise", "localisation", "duree", "auteur_nom", "nb_likes", "nb_commentaires"};

    PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Liste des offres de stage");
    pr.setUtilisateur((user.UserEJB) session.getValue("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("carriere/stage-liste.jsp");

    // Labels des criteres de recherche
    pr.getFormu().getChamp("identreprise").setLibelle("Entreprise / Organisme");
    pr.getFormu().getChamp("identreprise").setPageAppelComplete("bean.Entreprise", "id", "entreprise");
    pr.getFormu().getChamp("localisation").setLibelle("Localisation");
    pr.getFormu().getChamp("duree").setLibelle("Dur&eacute;e");
    pr.getFormu().getChamp("auteur_nom").setLibelle("Auteur");
    pr.getFormu().getChamp("created_at1").setLibelle("Date Min");
    pr.getFormu().getChamp("created_at2").setLibelle("Date Max");
    pr.getFormu().getChamp("created_at1").setDefaut(Utilitaire.getDebutAnnee(Utilitaire.getAnnee(Utilitaire.dateDuJour())));
    pr.getFormu().getChamp("created_at2").setDefaut(Utilitaire.dateDuJour());

    pr.setNpp(50);
    String[] colSomme = null;
    pr.creerObjetPage(libEntete, colSomme);

    // Configuration du tableau
    String[] lienTableau = {pr.getLien() + "?but=carriere/stage-fiche.jsp"};
    String[] colonneLien = {"post_id"};
    pr.getTableau().setLien(lienTableau);
    pr.getTableau().setColonneLien(colonneLien);

    String[] libEnteteAffiche = {"ID", "Date", "Entreprise", "Localisation", "Dur&eacute;e", "Publi&eacute; par", "Likes", "Commentaires"};
    pr.getTableau().setLibelleAffiche(libEnteteAffiche);
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-graduation-cap"></i> <%= pr.getTitre() %></h1>
        <ol class="breadcrumb">
            <li><a href="<%=pr.getLien()%>?but=accueil.jsp"><i class="fa fa-home"></i> Accueil</a></li>
            <li><a href="<%=pr.getLien()%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-briefcase"></i> Espace Carri&egrave;re</a></li>
            <li class="active">Offres de stage</li>
        </ol>
    </section>
    <section class="content">
        <div style="margin-bottom:10px; text-align:right;">
            <% if (peutAjouter) { %>
                <% if (pubRestantes > 0 && pubRestantes < 100) { %>
                    <span class="badge badge-info" style="margin-right:10px;">
                        <i class="fa fa-info-circle"></i> <%= pubRestantes %> publication(s) restante(s) aujourd'hui
                    </span>
                <% } %>
                <a href="<%=pr.getLien()%>?but=carriere/stage-saisie.jsp" class="btn btn-primary btn-sm">
                    <i class="fa fa-plus"></i> Nouvelle offre
                </a>
            <% } else { %>
                <span class="text-muted"><i class="fa fa-lock"></i> Publication r&eacute;serv&eacute;e aux alumni et enseignants</span>
            <% } %>
        </div>
        <form action="<%=pr.getLien()%>?but=<%= pr.getApres() %>" method="post">
            <% out.println(pr.getFormu().getHtmlEnsemble()); %>
        </form>
        <% if (pr.getTableauRecap() != null) out.println(pr.getTableauRecap().getHtml()); %>
        <br>
        <% out.println(pr.getTableau().getHtml()); %>
        <% out.println(pr.getBasPage()); %>
    </section>
</div>
<% } catch (Exception e) {
    e.printStackTrace();
%>
<div class="alert alert-danger" style="margin:20px;"><i class="fa fa-exclamation-circle"></i> Erreur: <%=e.getMessage()%></div>
<% } %>
