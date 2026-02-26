<%@page contentType="text/html;charset=UTF-8" %>
<%@page import="affichage.PageRecherche" %>
<%@page import="bean.PostAdmin" %>
<%@page import="user.UserEJB" %>
<% try {
    // Vérifier que l'utilisateur est admin
    UserEJB currentUser = (UserEJB) session.getValue("u");
    if (currentUser == null || !"admin".equals(currentUser.getUser().getIdrole())) {
        out.println("<div class='alert alert-danger' style='margin:20px;'><i class='fa fa-exclamation-circle'></i> Acc&egrave;s r&eacute;serv&eacute; aux administrateurs.</div>");
        return;
    }
    
    String lien = (String) session.getValue("lien");

    PostAdmin t = new PostAdmin();

    // Critères et colonnes
    String[] listeCrt = {"id", "nom_complet", "type_libelle", "statut_libelle"};
    String[] listeInt = {};
    String[] libEntete = {"id", "created_at", "nom_complet", "type_libelle", "statut_libelle"};

    PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Mod&eacute;ration des Publications");
    pr.setUtilisateur(currentUser);
    pr.setLien(lien);
    pr.setApres("moderation/publication-admin-liste.jsp");

    pr.getFormu().getChamp("id").setLibelle("ID");
    pr.getFormu().getChamp("nom_complet").setLibelle("Auteur");
    pr.getFormu().getChamp("type_libelle").setLibelle("Type");
    pr.getFormu().getChamp("statut_libelle").setLibelle("Statut");

    pr.setNpp(30);
    String[] colSomme = null;
    pr.creerObjetPage(libEntete, colSomme);

    // Lien vers fiche
    String[] lienTableau = {pr.getLien() + "?but=moderation/publication-admin-fiche.jsp"};
    String[] colonneLien = {"id"};
    pr.getTableau().setLien(lienTableau);
    pr.getTableau().setColonneLien(colonneLien);

    String[] libEnteteAffiche = {"ID", "Date", "Auteur", "Type", "Statut"};
    pr.getTableau().setLibelleAffiche(libEnteteAffiche);
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-newspaper-o"></i> <%= pr.getTitre() %></h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=<%= pr.getApres() %>" method="post">
            <% out.println(pr.getFormu().getHtmlEnsemble()); %>
        </form>
        <br>
        <% out.println(pr.getTableau().getHtml()); %>
        <% out.println(pr.getBasPage()); %>
    </section>
</div>
<% } catch (Exception e) {
    e.printStackTrace();
%>
<div class="alert alert-danger" style="margin:20px;">
    <i class="fa fa-exclamation-circle"></i> Erreur: <%=e.getMessage()%>
</div>
<% } %>
