<%@page contentType="text/html;charset=UTF-8" %>
<%@page import="affichage.PageRecherche" %>
<%@page import="bean.PostActiviteLib" %>
<%@page import="utilitaire.Utilitaire" %>
<% try {
    PostActiviteLib t = new PostActiviteLib();

    String[] listeCrt = {"titre", "categorie", "lieu", "auteur_nom", "created_at"};
    String[] listeInt = {"created_at"};
    String[] libEntete = {"post_id", "created_at", "titre", "categorie", "lieu", "date_debut", "date_fin", "auteur_nom", "nb_likes", "nb_commentaires"};

    PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Liste des activit&eacute;s / &eacute;v&eacute;nements");
    pr.setUtilisateur((user.UserEJB) session.getValue("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("carriere/activite-liste.jsp");

    // Labels des critères de recherche
    pr.getFormu().getChamp("titre").setLibelle("Titre");
    pr.getFormu().getChamp("categorie").setLibelle("Cat&eacute;gorie");
    pr.getFormu().getChamp("lieu").setLibelle("Lieu");
    pr.getFormu().getChamp("auteur_nom").setLibelle("Auteur");
    pr.getFormu().getChamp("created_at1").setLibelle("Date Min");
    pr.getFormu().getChamp("created_at2").setLibelle("Date Max");
    pr.getFormu().getChamp("created_at1").setDefaut(Utilitaire.getDebutAnnee(Utilitaire.getAnnee(Utilitaire.dateDuJour())));
    pr.getFormu().getChamp("created_at2").setDefaut(Utilitaire.dateDuJour());

    pr.setNpp(50);
    String[] colSomme = null;
    pr.creerObjetPage(libEntete, colSomme);

    // Configuration du tableau
    String[] lienTableau = {pr.getLien() + "?but=carriere/activite-fiche.jsp"};
    String[] colonneLien = {"post_id"};
    pr.getTableau().setLien(lienTableau);
    pr.getTableau().setColonneLien(colonneLien);

    String[] libEnteteAffiche = {"ID", "Date", "Titre", "Cat&eacute;gorie", "Lieu", "D&eacute;but", "Fin", "Publi&eacute; par", "Likes", "Commentaires"};
    pr.getTableau().setLibelleAffiche(libEnteteAffiche);
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-calendar"></i> <%= pr.getTitre() %></h1>
        <ol class="breadcrumb">
            <li><a href="<%=pr.getLien()%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-briefcase"></i> Espace Carri&egrave;re</a></li>
            <li class="active">Activit&eacute;s</li>
        </ol>
    </section>
    <section class="content">
        <div style="margin-bottom:10px; text-align:right;">
            <a href="<%=pr.getLien()%>?but=carriere/activite-saisie.jsp" class="btn btn-danger btn-sm">
                <i class="fa fa-plus"></i> Nouvelle activit&eacute;
            </a>
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
