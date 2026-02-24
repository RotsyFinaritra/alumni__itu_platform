<%@page import="affichage.PageRecherche"%>
<%@page import="moderation.ModerationHistoriqueLibCPL"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% 
try {
    // Vérifier que l'utilisateur est modérateur/admin (rang <= 1)
    user.UserEJB currentUser = (user.UserEJB) session.getValue("u");
    if (currentUser == null || currentUser.getRole().getRang() > 1) {
        out.println("<div class='alert alert-danger'>Accès réservé aux modérateurs.</div>");
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
    
    // Récupérer les résultats
    Object[] resultats = pr.getListe();
    String lien = (String) session.getValue("lien");
%>
<style>
.historique-table {
    width: 100%;
    background: #fff;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 2px 12px rgba(0,0,0,0.08);
}
.historique-table th {
    background: #3c8dbc;
    color: #fff;
    padding: 12px 15px;
    text-align: left;
    font-weight: 500;
    font-size: 13px;
}
.historique-table td {
    padding: 12px 15px;
    border-bottom: 1px solid #eee;
    font-size: 13px;
}
.historique-table tr:hover {
    background: #f8f9fa;
}
.badge-action {
    padding: 4px 10px;
    border-radius: 15px;
    font-size: 11px;
    font-weight: 500;
}
.badge-banni {
    background: #f8d7da;
    color: #721c24;
}
.badge-suspendu {
    background: #fff3cd;
    color: #856404;
}
.badge-leve {
    background: #d4edda;
    color: #155724;
}
.search-section {
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    margin-bottom: 20px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.results-count {
    color: #666;
    margin-bottom: 15px;
    font-size: 14px;
}
</style>

<div class="container-fluid">
    <!-- Section de recherche -->
    <div class="search-section">
        <h4><i class="fa fa-search"></i> Rechercher dans l'historique</h4>
        <%=pr.getFormulaire()%>
    </div>
    
    <!-- Compteur de résultats -->
    <div class="results-count">
        <strong><%=(resultats != null ? resultats.length : 0)%></strong> action(s) trouvée(s)
    </div>
    
    <!-- Pagination -->
    <%=pr.getPagination()%>
    
    <!-- Tableau d'historique -->
    <table class="historique-table">
        <thead>
            <tr>
                <th>Date</th>
                <th>Utilisateur concerné</th>
                <th>Action</th>
                <th>Motif</th>
                <th>Modérateur</th>
                <th>Expiration</th>
            </tr>
        </thead>
        <tbody>
        <% 
        if (resultats != null && resultats.length > 0) {
            for (int i = 0; i < resultats.length; i++) {
                ModerationHistoriqueLibCPL h = (ModerationHistoriqueLibCPL) resultats[i];
                String badgeClass = "badge-leve";
                if ("banni".equalsIgnoreCase(h.getType_action())) badgeClass = "badge-banni";
                else if ("suspendu".equalsIgnoreCase(h.getType_action())) badgeClass = "badge-suspendu";
        %>
            <tr>
                <td><%=h.getDate_action() != null ? h.getDate_action() : "-"%></td>
                <td>
                    <a href="<%=lien%>pages/profil/profil-fiche.jsp?refuser=<%=h.getIdutilisateur()%>">
                        <%=h.getUtilisateur_nom()%> <%=h.getUtilisateur_prenom()%>
                    </a>
                </td>
                <td>
                    <span class="badge-action <%=badgeClass%>"><%=h.getType_action()%></span>
                </td>
                <td><%=h.getMotif() != null ? h.getMotif() : "-"%></td>
                <td><%=h.getModerateur_nom()%> <%=h.getModerateur_prenom()%></td>
                <td><%=h.getDate_expiration() != null && !h.getDate_expiration().isEmpty() ? h.getDate_expiration() : "Permanent"%></td>
            </tr>
        <% 
            }
        } else { 
        %>
            <tr>
                <td colspan="6" style="text-align: center; padding: 40px; color: #666;">
                    <i class="fa fa-history" style="font-size: 48px; color: #ddd;"></i>
                    <p style="margin-top: 15px;">Aucune action de modération enregistrée</p>
                </td>
            </tr>
        <% } %>
        </tbody>
    </table>
    
    <!-- Pagination bas -->
    <div style="margin-top: 20px;">
        <%=pr.getPagination()%>
    </div>
</div>

<% 
} catch(Exception e) {
    out.println("<div class='alert alert-danger'>");
    out.println("<strong>Erreur:</strong> " + e.getMessage());
    out.println("</div>");
    e.printStackTrace();
}
%>
