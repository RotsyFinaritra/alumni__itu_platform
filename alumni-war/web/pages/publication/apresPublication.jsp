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
    
    String acte = request.getParameter("acte");
    String bute = request.getParameter("bute");
    if (bute == null || bute.isEmpty()) bute = "accueil.jsp";
    
    Connection conn = new UtilDB().GetConn();
    int refuserInt = u.getUser().getRefuser();
    
    // ============== INSERT PUBLICATION ==============
    if ("insert".equals(acte)) {
        String contenu = request.getParameter("contenu");
        String idtypepublication = request.getParameter("idtypepublication");
        String idvisibilite = request.getParameter("idvisibilite");
        
        if (contenu == null || contenu.trim().isEmpty()) {
            throw new Exception("Le contenu ne peut pas être vide");
        }
        
        // Générer ID
        String newId = "";
        PreparedStatement psSeq = conn.prepareStatement("SELECT 'POST' || LPAD(COALESCE(MAX(CAST(SUBSTRING(id, 5) AS INTEGER)), 0) + 1, 5, '0') FROM posts");
        ResultSet rsSeq = psSeq.executeQuery();
        if (rsSeq.next()) {
            newId = rsSeq.getString(1);
        }
        rsSeq.close();
        psSeq.close();
        
        // Insérer
        String sql = "INSERT INTO posts (id, contenu, idutilisateur, idtypepublication, idvisibilite, idstatutpublication, supprime, created_at, updated_at) " +
                     "VALUES (?, ?, ?, ?, ?, 'STAT00002', 0, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, newId);
        ps.setString(2, contenu);
        ps.setInt(3, refuserInt);
        ps.setString(4, idtypepublication != null ? idtypepublication : "TYP00005"); // Par défaut: Discussion
        ps.setString(5, idvisibilite != null ? idvisibilite : "VISI00001"); // Par défaut: Public
        ps.executeUpdate();
        ps.close();
        
        conn.close();
        response.sendRedirect(lien + "?but=" + bute);
        return;
    }
    
    // ============== LIKE ==============
    else if ("like".equals(acte)) {
        response.setContentType("application/json");
        String postId = request.getParameter("id");
        
        if (postId == null || postId.isEmpty()) {
            out.print("{\"success\": false, \"error\": \"ID manquant\"}");
            return;
        }
        
        // Vérifier si déjà liké
        PreparedStatement psCheck = conn.prepareStatement("SELECT id FROM likes WHERE post_id = ? AND user_id = ?");
        psCheck.setString(1, postId);
        psCheck.setInt(2, refuserInt);
        ResultSet rsCheck = psCheck.executeQuery();
        
        if (rsCheck.next()) {
            // Déjà liké - supprimer (unlike)
            String likeId = rsCheck.getString("id");
            rsCheck.close();
            psCheck.close();
            
            PreparedStatement psDelete = conn.prepareStatement("DELETE FROM likes WHERE id = ?");
            psDelete.setString(1, likeId);
            psDelete.executeUpdate();
            psDelete.close();
            
            conn.close();
            out.print("{\"success\": true, \"action\": \"unlike\"}");
        } else {
            rsCheck.close();
            psCheck.close();
            
            // Générer ID like
            String likeId = "";
            PreparedStatement psSeq = conn.prepareStatement("SELECT 'LIKE' || LPAD(COALESCE(MAX(CAST(SUBSTRING(id, 5) AS INTEGER)), 0) + 1, 5, '0') FROM likes");
            ResultSet rsSeq = psSeq.executeQuery();
            if (rsSeq.next()) {
                likeId = rsSeq.getString(1);
            }
            rsSeq.close();
            psSeq.close();
            
            // Insérer like
            PreparedStatement psInsert = conn.prepareStatement("INSERT INTO likes (id, post_id, user_id, created_at) VALUES (?, ?, ?, CURRENT_TIMESTAMP)");
            psInsert.setString(1, likeId);
            psInsert.setString(2, postId);
            psInsert.setInt(3, refuserInt);
            psInsert.executeUpdate();
            psInsert.close();
            
            // Créer notification pour l'auteur du post
            PreparedStatement psPost = conn.prepareStatement("SELECT idutilisateur FROM posts WHERE id = ?");
            psPost.setString(1, postId);
            ResultSet rsPost = psPost.executeQuery();
            if (rsPost.next()) {
                int auteurId = rsPost.getInt("idutilisateur");
                if (auteurId != refuserInt) { // Ne pas notifier soi-même
                    String notifId = "";
                    PreparedStatement psSeqNotif = conn.prepareStatement("SELECT 'NOTIF' || LPAD(COALESCE(MAX(CAST(SUBSTRING(id, 6) AS INTEGER)), 0) + 1, 5, '0') FROM notifications");
                    ResultSet rsSeqNotif = psSeqNotif.executeQuery();
                    if (rsSeqNotif.next()) notifId = rsSeqNotif.getString(1);
                    rsSeqNotif.close();
                    psSeqNotif.close();
                    
                    String nomComplet = (u.getUser().getPrenom() != null ? u.getUser().getPrenom() + " " : "") + 
                                        (u.getUser().getNomuser() != null ? u.getUser().getNomuser() : "");
                    String contenuNotif = nomComplet.trim() + " a aimé votre publication";
                    
                    PreparedStatement psNotif = conn.prepareStatement(
                        "INSERT INTO notifications (id, idutilisateur, idtypenotification, contenu, lien, vu, created_at) " +
                        "VALUES (?, ?, 'TNOT00001', ?, ?, 0, CURRENT_TIMESTAMP)"
                    );
                    psNotif.setString(1, notifId);
                    psNotif.setInt(2, auteurId);
                    psNotif.setString(3, contenuNotif);
                    psNotif.setString(4, "publication/publication-fiche.jsp&id=" + postId);
                    psNotif.executeUpdate();
                    psNotif.close();
                }
            }
            rsPost.close();
            psPost.close();
            
            conn.close();
            out.print("{\"success\": true, \"action\": \"like\"}");
        }
        return;
    }
    
    // ============== SUPPRIMER ==============
    else if ("supprimer".equals(acte)) {
        response.setContentType("application/json");
        String postId = request.getParameter("id");
        
        if (postId == null || postId.isEmpty()) {
            out.print("{\"success\": false, \"error\": \"ID manquant\"}");
            return;
        }
        
        // Vérifier que c'est le propriétaire
        PreparedStatement psCheck = conn.prepareStatement("SELECT idutilisateur FROM posts WHERE id = ?");
        psCheck.setString(1, postId);
        ResultSet rsCheck = psCheck.executeQuery();
        
        if (rsCheck.next() && rsCheck.getInt("idutilisateur") == refuserInt) {
            rsCheck.close();
            psCheck.close();
            
            // Suppression logique
            PreparedStatement psDelete = conn.prepareStatement("UPDATE posts SET supprime = 1, updated_at = CURRENT_TIMESTAMP WHERE id = ?");
            psDelete.setString(1, postId);
            psDelete.executeUpdate();
            psDelete.close();
            
            conn.close();
            out.print("{\"success\": true}");
        } else {
            rsCheck.close();
            psCheck.close();
            conn.close();
            out.print("{\"success\": false, \"error\": \"Non autorisé\"}");
        }
        return;
    }
    
    // ============== UPDATE ==============
    else if ("update".equals(acte)) {
        String postId = request.getParameter("id");
        String contenu = request.getParameter("contenu");
        String idtypepublication = request.getParameter("idtypepublication");
        String idvisibilite = request.getParameter("idvisibilite");
        
        if (postId == null || postId.isEmpty()) {
            throw new Exception("ID manquant");
        }
        
        // Vérifier propriétaire
        PreparedStatement psCheck = conn.prepareStatement("SELECT idutilisateur FROM posts WHERE id = ?");
        psCheck.setString(1, postId);
        ResultSet rsCheck = psCheck.executeQuery();
        
        if (rsCheck.next() && rsCheck.getInt("idutilisateur") == refuserInt) {
            rsCheck.close();
            psCheck.close();
            
            PreparedStatement psUpdate = conn.prepareStatement(
                "UPDATE posts SET contenu = ?, idtypepublication = ?, idvisibilite = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?"
            );
            psUpdate.setString(1, contenu);
            psUpdate.setString(2, idtypepublication);
            psUpdate.setString(3, idvisibilite);
            psUpdate.setString(4, postId);
            psUpdate.executeUpdate();
            psUpdate.close();
            
            conn.close();
            response.sendRedirect(lien + "?but=" + bute + "&id=" + postId);
            return;
        } else {
            throw new Exception("Non autorisé");
        }
    }
    
    conn.close();
    response.sendRedirect(lien + "?but=" + bute);
    
} catch (Exception e) {
    e.printStackTrace();
%>
<script>
    alert('Erreur: <%= e.getMessage() != null ? e.getMessage().replace("'", "\\'") : "Une erreur est survenue" %>');
    history.back();
</script>
<% } %>
