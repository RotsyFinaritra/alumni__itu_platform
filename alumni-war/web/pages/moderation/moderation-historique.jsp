<%@page import="affichage.PageRecherche"%>
<%@page import="moderation.ModerationHistoriqueLibCPL"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% 
try {
    // Vérifier que l'utilisateur est admin (idrole='admin')
    user.UserEJB currentUser = (user.UserEJB) session.getValue("u");
    if (currentUser == null || !"admin".equals(currentUser.getUser().getIdrole())) {
        out.println("<div class='alert alert-danger'>Accès réservé aux administrateurs.</div>");
        return;
    }
    
    ModerationHistoriqueLibCPL filtre = new ModerationHistoriqueLibCPL();
    
    // Champs de critères
    String listeCrt[] = {"utilisateur_nom", "moderateur_nom", "type_action", "date_action"};
    String listeInt[] = {};
    // Colonnes affichées
    String libEntete[] = {"date_action", "utilisateur_nom", "utilisateur_prenom", "type_action", "motif", "moderateur_nom", "date_expiration"};
    
    PageRecherche pr = new PageRecherche(filtre, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Historique de modération");
    pr.setUtilisateur(currentUser);
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("moderation/moderation-historique.jsp");
    pr.setNpp(30);
    
    // Labels des champs de recherche
    pr.getFormu().getChamp("utilisateur_nom").setLibelle("Utilisateur");
    pr.getFormu().getChamp("moderateur_nom").setLibelle("Modérateur");
    pr.getFormu().getChamp("type_action").setLibelle("Action");
    pr.getFormu().getChamp("date_action").setLibelle("Date");
    
    String[] colSomme = null;
    pr.creerObjetPage(libEntete, colSomme);
    
    // Configuration du tableau APJ
    String[] lienTableau = {pr.getLien() + "?but=profil/mon-profil.jsp"};
    String[] colonneLien = {"utilisateur_nom"};
    pr.getTableau().setLien(lienTableau);
    pr.getTableau().setColonneLien(colonneLien);
    
    String[] libEnteteAffiche = {"Date", "Utilisateur", "Pr&eacute;nom", "Action", "Motif", "Mod&eacute;rateur", "Expiration"};
    pr.getTableau().setLibelleAffiche(libEnteteAffiche);
    
    String lien = (String) session.getValue("lien");
%>
<style>
.search-section {
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    margin-bottom: 20px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
</style>

<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-history"></i> Historique de mod&eacute;ration</h1>
    </section>
    <section class="content">
        <!-- Section de recherche -->
        <div class="search-section">
            <h4><i class="fa fa-search"></i> Rechercher dans l'historique</h4>
            <form action="<%=pr.getLien()%>?but=moderation/moderation-historique.jsp" method="post">
                <%=pr.getFormu().getHtmlEnsemble()%>
            </form>
        </div>
    
        <!-- Tableau récapitulatif -->
        <%= pr.getTableauRecap().getHtml() %>
        <br>
        <!-- Tableau APJ standard -->
        <%
            out.println(pr.getTableau().getHtml());
            out.println(pr.getBasPage());
        %>
    </section>
</div>

<% 
} catch(Exception e) {
    out.println("<div class='alert alert-danger'>");
    out.println("<strong>Erreur:</strong> " + e.getMessage());
    out.println("</div>");
    e.printStackTrace();
}
%>
