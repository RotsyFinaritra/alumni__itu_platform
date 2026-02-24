<%@page import="java.sql.Connection"%>
<%@page import="java.sql.PreparedStatement"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="web.SingletonConn"%>
<%@page import="moderation.ModerationUtilisateur"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% 
try {
    // Vérifier l'authentification et les droits (rang = 1)
    user.UserEJB currentUser = (user.UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    
    if (currentUser == null || currentUser.getRole().getRang() > 1) {
        out.println("<div class='alert alert-danger'>Accès refusé.</div>");
        return;
    }
    
    // Récupérer les paramètres
    String action = request.getParameter("action");
    String refuserStr = request.getParameter("refuser");
    String motif = request.getParameter("motif");
    String type = request.getParameter("type"); // permanent ou temporaire
    String dateExpirationStr = request.getParameter("dateExpiration");
    
    if (action == null || refuserStr == null) {
        out.println("<div class='alert alert-warning'>Paramètres manquants.</div>");
        return;
    }
    
    int refuser = Integer.parseInt(refuserStr);
    int idModerateur = Integer.parseInt(currentUser.getUser().getTuppleID());
    
    Connection con = SingletonConn.getInstance().getConnection();
    String message = "";
    String alertType = "success";
    
    switch (action) {
        case "ban":
            // Bannir l'utilisateur
            Date dateExpiration = null;
            if ("temporaire".equals(type) && dateExpirationStr != null && !dateExpirationStr.isEmpty()) {
                SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
                dateExpiration = sdf.parse(dateExpirationStr);
            }
            if (motif == null || motif.trim().isEmpty()) {
                motif = "Aucun motif spécifié";
            }
            ModerationUtilisateur.bannir(con, refuser, idModerateur, motif, dateExpiration);
            message = "Utilisateur banni avec succès.";
            break;
            
        case "unban":
            // Lever le bannissement
            ModerationUtilisateur.lever(con, refuser, idModerateur, "Débannissement par modérateur");
            message = "Utilisateur débanni avec succès.";
            break;
            
        case "promote":
            // Promouvoir en modérateur
            String sqlPromote = "UPDATE utilisateur SET idrole = 'moderateur', rang = 1 WHERE refuser = ?";
            PreparedStatement psPromote = con.prepareStatement(sqlPromote);
            psPromote.setInt(1, refuser);
            psPromote.executeUpdate();
            psPromote.close();
            message = "Utilisateur promu modérateur avec succès.";
            break;
            
        case "demote":
            // Rétrograder en utilisateur simple (seulement si admin)
            if (currentUser.getRole().getRang() != 0) {
                message = "Seuls les administrateurs peuvent rétrograder un modérateur.";
                alertType = "danger";
            } else {
                String sqlDemote = "UPDATE utilisateur SET idrole = 'utilisateur', rang = 2 WHERE refuser = ?";
                PreparedStatement psDemote = con.prepareStatement(sqlDemote);
                psDemote.setInt(1, refuser);
                psDemote.executeUpdate();
                psDemote.close();
                message = "Utilisateur rétrogradé avec succès.";
            }
            break;
            
        default:
            message = "Action non reconnue.";
            alertType = "warning";
    }
    
    // Stocker le message en session pour l'afficher après redirection
    session.setAttribute("moderationMessage", message);
    session.setAttribute("moderationAlertType", alertType);
    
    // Rediriger vers la liste
    response.sendRedirect(lien + "pages/moderation/moderation-liste.jsp");
    
} catch(Exception e) {
    out.println("<div class='alert alert-danger'>");
    out.println("<strong>Erreur:</strong> " + e.getMessage());
    out.println("</div>");
    e.printStackTrace();
}
%>
