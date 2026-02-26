<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*, utilitaire.*, java.sql.*, user.UserEJB" %>
<%
try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    if (u == null || lien == null) {
        response.sendRedirect("security-login.jsp");
        return;
    }
    
    int refuserInt = u.getUser().getRefuser();
    String acte = request.getParameter("acte");
    String bute = request.getParameter("bute");
    if (bute == null) bute = "accueil.jsp";
    
    // ============== SAVE INTERETS ==============
    if ("saveInterets".equals(acte)) {
        String topicsParam = request.getParameter("topics");
        
        if (topicsParam != null && !topicsParam.trim().isEmpty()) {
            String[] topicIds = topicsParam.split(",");
            
            Connection conn = null;
            try {
                conn = new UtilDB().GetConn();
                conn.setAutoCommit(false);
                
                // Supprimer les anciens intérêts
                PreparedStatement psDelete = conn.prepareStatement(
                    "DELETE FROM utilisateur_interets WHERE idutilisateur = ?");
                psDelete.setInt(1, refuserInt);
                psDelete.executeUpdate();
                psDelete.close();
                
                // Insérer les nouveaux
                for (String topicId : topicIds) {
                    if (topicId != null && !topicId.trim().isEmpty()) {
                        UtilisateurInteret ui = new UtilisateurInteret();
                        ui.construirePK(conn);
                        ui.setIdutilisateur(refuserInt);
                        ui.setTopic_id(topicId.trim());
                        ui.setCreated_at(new Timestamp(System.currentTimeMillis()));
                        ui.insertToTable(conn);
                    }
                }
                
                conn.commit();
            } catch (Exception e) {
                if (conn != null) try { conn.rollback(); } catch (Exception ignored) {}
                throw e;
            } finally {
                if (conn != null) try { conn.close(); } catch (Exception ignored) {}
            }
        }
        
        // Si appel AJAX, répondre simplement
        String xRequestedWith = request.getHeader("X-Requested-With");
        if ("XMLHttpRequest".equals(xRequestedWith) || request.getParameter("ajax") != null) {
            response.setContentType("application/json; charset=UTF-8");
            out.print("{\"success\": true}");
            return;
        }
        
%><script language="JavaScript">document.location.replace("<%=lien%>?but=<%=bute%>");</script><%
        return;
    }
    
    // ============== GET INTERETS (pour page profil) ==============
    else if ("getInterets".equals(acte)) {
        response.setContentType("application/json; charset=UTF-8");
        
        Object[] interets = CGenUtil.rechercher(new UtilisateurInteret(), null, null, 
            " AND idutilisateur = " + refuserInt);
        
        StringBuilder json = new StringBuilder("{\"success\": true, \"interets\": [");
        if (interets != null) {
            for (int i = 0; i < interets.length; i++) {
                UtilisateurInteret ui = (UtilisateurInteret) interets[i];
                if (i > 0) json.append(",");
                json.append("\"").append(ui.getTopic_id()).append("\"");
            }
        }
        json.append("]}");
        out.print(json.toString());
        return;
    }
    
%><script language="JavaScript">document.location.replace("<%=lien%>?but=<%=bute%>");</script><%
    
} catch (Exception e) {
    e.printStackTrace();
    response.setContentType("application/json; charset=UTF-8");
    out.print("{\"success\": false, \"error\": \"" + (e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Erreur") + "\"}");
}
%>
