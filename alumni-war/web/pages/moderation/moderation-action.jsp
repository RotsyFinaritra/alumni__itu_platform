<%@page import="java.sql.Connection"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="utilitaire.UtilDB"%>
<%@page import="moderation.ModerationUtilisateur"%>
<%@page import="utilisateurAcade.UtilisateurPg"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% 
Connection con = null;
try {
    // Vérifier l'authentification et les droits (admin uniquement)
    user.UserEJB currentUser = (user.UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    
    if (currentUser == null || !"admin".equals(currentUser.getUser().getIdrole())) {
        out.println("<div class='alert alert-danger'>Accès réservé aux administrateurs.</div>");
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
    
    // Connexion avec gestion de transaction (pattern APJ)
    con = new UtilDB().GetConn();
    con.setAutoCommit(false);
    
    String message = "";
    String alertType = "success";
    
    switch (action) {
        case "ban":
            // Bannir l'utilisateur via le framework
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
            // Lever le bannissement via le framework
            ModerationUtilisateur.lever(con, refuser, idModerateur, "Débannissement par administrateur");
            message = "Utilisateur débanni avec succès.";
            break;
            
        case "promote":
            // Promouvoir en admin via le framework
            UtilisateurPg.promouvoir(refuser, con);
            message = "Utilisateur promu administrateur avec succès.";
            break;
            
        case "demote":
            // Rétrograder en utilisateur simple via le framework
            UtilisateurPg.retrograder(refuser, con);
            message = "Utilisateur rétrogradé avec succès.";
            break;
            
        default:
            message = "Action non reconnue.";
            alertType = "warning";
    }
    
    // Valider la transaction
    con.commit();
    
    // Stocker le message en session pour l'afficher après redirection
    session.setAttribute("moderationMessage", message);
    session.setAttribute("moderationAlertType", alertType);
    
    // Rediriger vers la liste via module.jsp
    response.sendRedirect(request.getContextPath() + "/pages/module.jsp?but=moderation/moderation-liste.jsp");
    
} catch(Exception e) {
    if (con != null) {
        try { con.rollback(); } catch(Exception ex) {}
    }
    out.println("<div class='alert alert-danger'>");
    out.println("<strong>Erreur:</strong> " + e.getMessage());
    out.println("</div>");
    e.printStackTrace();
} finally {
    if (con != null) {
        try { con.close(); } catch(Exception ex) {}
    }
}
%>
