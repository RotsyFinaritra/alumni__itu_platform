<%@page contentType="text/html;charset=UTF-8" %>
<%@page import="bean.Post" %>
<%@page import="bean.CGenUtil" %>
<%@page import="user.UserEJB" %>
<%@page import="utilitaire.UtilDB" %>
<%@page import="java.sql.Connection" %>
<%@page import="java.sql.Timestamp" %>
<% 
try {
    UserEJB u = (UserEJB) session.getValue("u");
    String redirectBase = "../module.jsp"; // Chemin relatif depuis pages/moderation/
    
    if (u == null || !"admin".equals(u.getUser().getIdrole())) {
        response.sendRedirect(redirectBase + "?but=moderation/publication-admin-liste.jsp");
        return;
    }
    
    String id = request.getParameter("id");
    String action = request.getParameter("action"); // "supprimer" ou "restaurer"
    String bute = request.getParameter("bute");
    
    if (id == null || action == null) {
        response.sendRedirect(redirectBase + "?but=moderation/publication-admin-liste.jsp");
        return;
    }
    
    // Charger le post existant
    Post critere = new Post();
    critere.setId(id);
    Connection c = new UtilDB().GetConn();
    try {
        Object[] results = CGenUtil.rechercher(critere, null, null, "");
        if (results != null && results.length > 0) {
            Post post = (Post) results[0];
            
            if ("supprimer".equals(action)) {
                // Suppression: changer statut + flag + date
                post.setIdstatutpublication("STAT00005"); // Statut "Supprimé"
                post.setSupprime(1);
                post.setDate_suppression(new Timestamp(System.currentTimeMillis()));
            } else if ("restaurer".equals(action)) {
                // Restauration: remettre statut publié + flag + effacer date
                post.setIdstatutpublication("STAT00002"); // Statut "Publié"
                post.setSupprime(0);
                post.setDate_suppression(null);
            }
            
            // Sauvegarder
            post.updateToTable(c);
        }
    } finally {
        if (c != null) c.close();
    }
    
    // Rediriger
    if (bute != null && !bute.isEmpty()) {
        response.sendRedirect(redirectBase + "?but=" + bute);
    } else {
        response.sendRedirect(redirectBase + "?but=moderation/publication-admin-liste.jsp");
    }
    
} catch (Exception e) {
    e.printStackTrace();
%>
<div class="alert alert-danger" style="margin:20px;">
    <i class="fa fa-exclamation-circle"></i> Erreur: <%=e.getMessage()%>
</div>
<% } %>
