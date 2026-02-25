<%@ page import="user.UserEJB" %>
<%@ page import="java.sql.*, utilitaire.UtilDB" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String result = "{\"success\":false,\"message\":\"Action non reconnue\"}";
    Connection conn = null;
    
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        if (u == null) {
            result = "{\"success\":false,\"message\":\"Session expirée\"}";
            out.print(result);
            return;
        }
        
        int refuserInt = u.getUser().getRefuser();
        String acte = request.getParameter("acte");
        String id = request.getParameter("id");
        
        conn = new UtilDB().GetConn();
        
        if ("marquer_lu".equals(acte) && id != null) {
            // Marquer une notification comme lue
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE notifications SET vu = 1, lu_at = CURRENT_TIMESTAMP WHERE id = ? AND idutilisateur = ?"
            );
            ps.setString(1, id);
            ps.setInt(2, refuserInt);
            int updated = ps.executeUpdate();
            ps.close();
            
            if (updated > 0) {
                result = "{\"success\":true,\"message\":\"Notification marquée comme lue\"}";
            } else {
                result = "{\"success\":false,\"message\":\"Notification non trouvée\"}";
            }
        }
        else if ("marquer_non_lu".equals(acte) && id != null) {
            // Marquer une notification comme non lue
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE notifications SET vu = 0, lu_at = NULL WHERE id = ? AND idutilisateur = ?"
            );
            ps.setString(1, id);
            ps.setInt(2, refuserInt);
            int updated = ps.executeUpdate();
            ps.close();
            
            if (updated > 0) {
                result = "{\"success\":true,\"message\":\"Notification marquée comme non lue\"}";
            } else {
                result = "{\"success\":false,\"message\":\"Notification non trouvée\"}";
            }
        }
        else if ("supprimer".equals(acte) && id != null) {
            // Supprimer une notification
            PreparedStatement ps = conn.prepareStatement(
                "DELETE FROM notifications WHERE id = ? AND idutilisateur = ?"
            );
            ps.setString(1, id);
            ps.setInt(2, refuserInt);
            int deleted = ps.executeUpdate();
            ps.close();
            
            if (deleted > 0) {
                result = "{\"success\":true,\"message\":\"Notification supprimée\"}";
            } else {
                result = "{\"success\":false,\"message\":\"Notification non trouvée\"}";
            }
        }
        else if ("marquer_tout_lu".equals(acte)) {
            // Marquer toutes les notifications comme lues
            PreparedStatement ps = conn.prepareStatement(
                "UPDATE notifications SET vu = 1, lu_at = CURRENT_TIMESTAMP WHERE idutilisateur = ? AND vu = 0"
            );
            ps.setInt(1, refuserInt);
            int updated = ps.executeUpdate();
            ps.close();
            
            result = "{\"success\":true,\"message\":\"" + updated + " notification(s) marquée(s) comme lue(s)\"}";
        }
        else if ("count_non_lu".equals(acte)) {
            // Compter les notifications non lues (pour badge header)
            PreparedStatement ps = conn.prepareStatement(
                "SELECT COUNT(*) FROM notifications WHERE idutilisateur = ? AND vu = 0"
            );
            ps.setInt(1, refuserInt);
            ResultSet rs = ps.executeQuery();
            int count = 0;
            if (rs.next()) count = rs.getInt(1);
            rs.close();
            ps.close();
            
            result = "{\"success\":true,\"count\":" + count + "}";
        }
        else if ("get_recent".equals(acte)) {
            // Obtenir les X dernières notifications (pour dropdown header)
            int limit = 5;
            try {
                limit = Integer.parseInt(request.getParameter("limit"));
            } catch (Exception ignored) {}
            
            PreparedStatement ps = conn.prepareStatement(
                "SELECT n.id, n.contenu, n.lien, n.vu, n.created_at, " +
                "tn.libelle as type_libelle, tn.icon as type_icon, tn.couleur as type_couleur, " +
                "e.nomuser as emetteur_nom, e.prenom as emetteur_prenom " +
                "FROM notifications n " +
                "LEFT JOIN type_notification tn ON n.idtypenotification = tn.id " +
                "LEFT JOIN utilisateur e ON n.emetteur_id = e.refuser " +
                "WHERE n.idutilisateur = ? " +
                "ORDER BY n.created_at DESC LIMIT ?"
            );
            ps.setInt(1, refuserInt);
            ps.setInt(2, limit);
            ResultSet rs = ps.executeQuery();
            
            StringBuilder json = new StringBuilder("{\"success\":true,\"notifications\":[");
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                first = false;
                
                String contenu = rs.getString("contenu");
                if (contenu == null) contenu = rs.getString("type_libelle");
                contenu = contenu.replace("\"", "\\\"").replace("\n", " ");
                
                String lienNotif = rs.getString("lien");
                if (lienNotif == null) lienNotif = "";
                
                String emetteur = "";
                if (rs.getString("emetteur_prenom") != null) emetteur += rs.getString("emetteur_prenom") + " ";
                if (rs.getString("emetteur_nom") != null) emetteur += rs.getString("emetteur_nom");
                
                json.append("{");
                json.append("\"id\":\"").append(rs.getString("id")).append("\",");
                json.append("\"contenu\":\"").append(contenu).append("\",");
                json.append("\"lien\":\"").append(lienNotif).append("\",");
                json.append("\"vu\":").append(rs.getInt("vu")).append(",");
                json.append("\"icon\":\"").append(rs.getString("type_icon") != null ? rs.getString("type_icon") : "fa-bell").append("\",");
                json.append("\"couleur\":\"").append(rs.getString("type_couleur") != null ? rs.getString("type_couleur") : "#3498db").append("\",");
                json.append("\"emetteur\":\"").append(emetteur.trim()).append("\"");
                json.append("}");
            }
            json.append("]}");
            rs.close();
            ps.close();
            
            result = json.toString();
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        result = "{\"success\":false,\"message\":\"Erreur: " + e.getMessage().replace("\"", "'") + "\"}";
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (Exception ignored) {}
        }
    }
    
    out.print(result);
%>
