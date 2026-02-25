<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*, utilitaire.*, java.sql.*, user.UserEJB, affichage.PageInsert, utilisateurAcade.UtilisateurAcade" %>
<%!
    // Helper pour update les compteurs sans toucher à edited_by
    public void updatePostCounter(String postId, String colonne, int valeur) throws Exception {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = new UtilDB().GetConn();
            String sql = "UPDATE posts SET " + colonne + " = ? WHERE id = ?";
            ps = conn.prepareStatement(sql);
            ps.setInt(1, valeur);
            ps.setString(2, postId);
            ps.executeUpdate();
        } finally {
            if (ps != null) try { ps.close(); } catch (Exception ignored) {}
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }
    }
%>
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
    
    int refuserInt = u.getUser().getRefuser();
    String refuserStr = String.valueOf(refuserInt);
    
    // Récupérer info utilisateur courant pour les notifications
    UtilisateurAcade currentUser = null;
    Object[] currentUserResult = CGenUtil.rechercher(new UtilisateurAcade(), null, null, " AND refuser = " + refuserInt);
    if (currentUserResult != null && currentUserResult.length > 0) {
        currentUser = (UtilisateurAcade) currentUserResult[0];
    }
    
    // ============== INSERT PUBLICATION ==============
    if ("insert".equals(acte)) {
        String contenu = request.getParameter("contenu");
        String idtypepublication = request.getParameter("idtypepublication");
        String idvisibilite = request.getParameter("idvisibilite");
        
        if (contenu == null || contenu.trim().isEmpty()) {
            throw new Exception("Le contenu ne peut pas être vide");
        }
        
        Post post = new Post();
        post.setContenu(contenu.trim());
        post.setIdutilisateur(refuserInt);
        post.setIdtypepublication(idtypepublication != null ? idtypepublication : "TYP00005");
        post.setIdvisibilite(idvisibilite != null ? idvisibilite : "VISI00001");
        post.setIdstatutpublication("STAT00002");
        post.setSupprime(0);
        post.setNb_likes(0);
        post.setNb_commentaires(0);
        post.setNb_partages(0);
        
        Post created = (Post) u.createObject(post);
        String newId = created != null ? created.getTuppleID() : "";
        
%><script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=newId%>");</script><%
        return;
    }
    
    // ============== LIKE (toggle) ==============
    else if ("like".equals(acte)) {
        String postId = request.getParameter("id");
        String returnPage = request.getParameter("bute");
        if (returnPage == null || returnPage.isEmpty()) returnPage = "publication/publication-fiche.jsp";
        
        if (postId == null || postId.isEmpty()) {
%><script language="JavaScript">alert('ID manquant');history.back();</script><%
            return;
        }
        
        try {
        // Vérifier si déjà liké via CGenUtil
        Like likeCheck = new Like();
        Object[] existingLikes = CGenUtil.rechercher(likeCheck, null, null, 
            " AND post_id = '" + postId + "' AND idutilisateur = " + refuserInt);
        
        if (existingLikes != null && existingLikes.length > 0) {
            // Déjà liké - supprimer (unlike)
            Like existingLike = (Like) existingLikes[0];
            u.deleteObject(existingLike);
            
            // Mettre à jour compteur
            Post postToUpdate = new Post();
            postToUpdate.setId(postId);
            Object[] posts = CGenUtil.rechercher(postToUpdate, null, null, "");
            if (posts != null && posts.length > 0) {
                Post p = (Post) posts[0];
                int newCount = Math.max(0, p.getNb_likes() - 1);
                updatePostCounter(postId, "nb_likes", newCount);
            }
        } else {
            // Créer nouveau like
            Like newLike = new Like();
            newLike.setPost_id(postId);
            newLike.setIdutilisateur(refuserInt);
            u.createObject(newLike);
            
            // Mettre à jour compteur et créer notification
            Post postToUpdate = new Post();
            postToUpdate.setId(postId);
            Object[] posts = CGenUtil.rechercher(postToUpdate, null, null, "");
            if (posts != null && posts.length > 0) {
                Post p = (Post) posts[0];
                int newCount = p.getNb_likes() + 1;
                updatePostCounter(postId, "nb_likes", newCount);
                
                // Créer notification pour l'auteur du post
                if (p.getIdutilisateur() != refuserInt && currentUser != null) {
                    String nomComplet = ((currentUser.getPrenom() != null ? currentUser.getPrenom() + " " : "") + 
                                        (currentUser.getNomuser() != null ? currentUser.getNomuser() : "")).trim();
                    
                    Notification notif = new Notification();
                    notif.setIdutilisateur(p.getIdutilisateur());
                    notif.setEmetteur_id(refuserInt);
                    notif.setIdtypenotification("TNOT00001");
                    notif.setPost_id(postId);
                    notif.setContenu(nomComplet.trim() + " a aimé votre publication");
                    notif.setLien("publication/publication-fiche.jsp&id=" + postId);
                    notif.setVu(0);
                    notif.setCreated_at(new java.sql.Timestamp(System.currentTimeMillis()));
                    try { u.createObject(notif); } catch (Exception ne) { ne.printStackTrace(); }
                }
            }
        }
        } catch (Exception ex) {
            ex.printStackTrace();
        }
        
        // Rediriger vers la page d'origine
%><script language="JavaScript">document.location.replace("<%=lien%>?but=<%=returnPage%>&id=<%=postId%>");</script><%
        return;
    }
    
    // ============== SUPPRIMER ==============
    else if ("supprimer".equals(acte)) {
        String postId = request.getParameter("id");
        String returnPage = request.getParameter("bute");
        if (returnPage == null || returnPage.isEmpty()) returnPage = "publication/publication-liste.jsp";
        
        if (postId == null || postId.isEmpty()) {
%><script language="JavaScript">alert('ID manquant');history.back();</script><%
            return;
        }
        
        // Vérifier propriétaire
        Post postCheck = new Post();
        postCheck.setId(postId);
        Object[] posts = CGenUtil.rechercher(postCheck, null, null, "");
        
        if (posts != null && posts.length > 0) {
            Post p = (Post) posts[0];
            if (p.getIdutilisateur() == refuserInt) {
                // Suppression logique via SQL direct
                Connection conn = null;
                PreparedStatement ps = null;
                try {
                    conn = new UtilDB().GetConn();
                    ps = conn.prepareStatement("UPDATE posts SET supprime = 1, date_suppression = CURRENT_TIMESTAMP WHERE id = ?");
                    ps.setString(1, postId);
                    ps.executeUpdate();
                } finally {
                    if (ps != null) try { ps.close(); } catch (Exception ignored) {}
                    if (conn != null) try { conn.close(); } catch (Exception ignored) {}
                }
            }
        }
        
%><script language="JavaScript">document.location.replace("<%=lien%>?but=<%=returnPage%>");</script><%
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
        Post postCheck2 = new Post();
        postCheck2.setId(postId);
        Object[] posts2 = CGenUtil.rechercher(postCheck2, null, null, "");
        
        if (posts2 != null && posts2.length > 0) {
            Post p = (Post) posts2[0];
            if (p.getIdutilisateur() == refuserInt) {
                // Mise à jour via SQL direct pour éviter FK error sur edited_by
                Connection conn = null;
                PreparedStatement ps = null;
                try {
                    conn = new UtilDB().GetConn();
                    StringBuilder sql = new StringBuilder("UPDATE posts SET contenu = ?, edited_at = CURRENT_TIMESTAMP, edited_by = ?");
                    if (idtypepublication != null) sql.append(", idtypepublication = ?");
                    if (idvisibilite != null) sql.append(", idvisibilite = ?");
                    sql.append(" WHERE id = ?");
                    
                    ps = conn.prepareStatement(sql.toString());
                    int idx = 1;
                    ps.setString(idx++, contenu);
                    ps.setInt(idx++, refuserInt);
                    if (idtypepublication != null) ps.setString(idx++, idtypepublication);
                    if (idvisibilite != null) ps.setString(idx++, idvisibilite);
                    ps.setString(idx++, postId);
                    ps.executeUpdate();
                } finally {
                    if (ps != null) try { ps.close(); } catch (Exception ignored) {}
                    if (conn != null) try { conn.close(); } catch (Exception ignored) {}
                }
                
%><script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=postId%>");</script><%
                return;
            } else {
                throw new Exception("Non autorisé");
            }
        } else {
            throw new Exception("Publication non trouvée");
        }
    }
    
    // ============== GET COMMENTS ==============
    else if ("getComments".equals(acte)) {
        response.setContentType("application/json; charset=UTF-8");
        String postId = request.getParameter("id");
        
        if (postId == null || postId.isEmpty()) {
            out.print("{\"success\": false, \"error\": \"ID manquant\"}");
            return;
        }
        
        // Récupérer commentaires via CGenUtil
        Commentaire commCritere = new Commentaire();
        Object[] comments = CGenUtil.rechercher(commCritere, null, null, 
            " AND post_id = '" + postId + "' AND supprime = 0 ORDER BY created_at ASC");
        
        StringBuilder json = new StringBuilder("{\"success\": true, \"comments\": [");
        
        if (comments != null && comments.length > 0) {
            for (int i = 0; i < comments.length; i++) {
                Commentaire c = (Commentaire) comments[i];
                
                // Récupérer info utilisateur
                String nom = "Utilisateur";
                String photoUrl = request.getContextPath() + "/assets/img/default-avatar.png";
                
                UtilisateurAcade userCritere = new UtilisateurAcade();
                Object[] users = CGenUtil.rechercher(userCritere, null, null, " AND refuser = " + c.getIdutilisateur());
                if (users != null && users.length > 0) {
                    UtilisateurAcade user = (UtilisateurAcade) users[0];
                    nom = ((user.getPrenom() != null ? user.getPrenom() : "") + " " + 
                           (user.getNomuser() != null ? user.getNomuser() : "")).trim();
                    if (nom.isEmpty()) nom = "Utilisateur";
                    
                    if (user.getPhoto() != null && !user.getPhoto().isEmpty()) {
                        String photo = user.getPhoto();
                        if (photo.contains("/")) photo = photo.substring(photo.lastIndexOf("/") + 1);
                        photoUrl = request.getContextPath() + "/profile-photo?file=" + photo;
                    }
                }
                
                String contenu = c.getContenu();
                contenu = contenu != null ? contenu.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "") : "";
                nom = nom.replace("\\", "\\\\").replace("\"", "\\\"");
                
                String dateStr = c.getCreated_at() != null ? new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm").format(c.getCreated_at()) : "";
                
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"id\": \"").append(c.getId()).append("\",");
                json.append("\"contenu\": \"").append(contenu).append("\",");
                json.append("\"idutilisateur\": ").append(c.getIdutilisateur()).append(",");
                json.append("\"nom\": \"").append(nom).append("\",");
                json.append("\"photo\": \"").append(photoUrl).append("\",");
                json.append("\"date\": \"").append(dateStr).append("\",");
                json.append("\"canDelete\": ").append(c.getIdutilisateur() == refuserInt);
                json.append("}");
            }
        }
        
        json.append("], \"currentUser\": ").append(refuserInt).append("}");
        out.print(json.toString());
        return;
    }
    
    // ============== ADD COMMENT ==============
    else if ("addComment".equals(acte)) {
        String postId = request.getParameter("id");
        String contenu = request.getParameter("contenu");
        
        if (postId != null && !postId.isEmpty() && contenu != null && !contenu.trim().isEmpty()) {
            // Créer commentaire
            Commentaire newComm = new Commentaire();
            newComm.setPost_id(postId);
            newComm.setIdutilisateur(refuserInt);
            newComm.setContenu(contenu.trim());
            newComm.setSupprime(0);
            newComm.setCreated_at(new java.sql.Timestamp(System.currentTimeMillis()));
            
            Commentaire created = (Commentaire) u.createObject(newComm);
            String commId = created != null ? created.getTuppleID() : "";
            
            // Mettre à jour compteur du post
            Post postCheck = new Post();
            postCheck.setId(postId);
            Object[] posts = CGenUtil.rechercher(postCheck, null, null, "");
            if (posts != null && posts.length > 0) {
                Post p = (Post) posts[0];
                
                // Compter commentaires actifs
                Commentaire countCritere = new Commentaire();
                Object[] allComms = CGenUtil.rechercher(countCritere, null, null, 
                    " AND post_id = '" + postId + "' AND supprime = 0");
                int newCount = allComms != null ? allComms.length : 0;
                updatePostCounter(postId, "nb_commentaires", newCount);
                
                // Créer notification pour l'auteur
                if (p.getIdutilisateur() != refuserInt && currentUser != null) {
                    String nomComplet = ((currentUser.getPrenom() != null ? currentUser.getPrenom() + " " : "") + 
                                        (currentUser.getNomuser() != null ? currentUser.getNomuser() : "")).trim();
                    
                    Notification notif = new Notification();
                    notif.setIdutilisateur(p.getIdutilisateur());
                    notif.setEmetteur_id(refuserInt);
                    notif.setIdtypenotification("TNOT00002");
                    notif.setPost_id(postId);
                    notif.setCommentaire_id(commId);
                    notif.setContenu(nomComplet.trim() + " a commenté votre publication");
                    notif.setLien("publication/publication-fiche.jsp&id=" + postId);
                    notif.setVu(0);
                    notif.setCreated_at(new java.sql.Timestamp(System.currentTimeMillis()));
                    try { u.createObject(notif); } catch (Exception ne) { ne.printStackTrace(); }
                }
            }
        }
        
%><script language="JavaScript"> document.location.replace("<%=lien%>?but=publication/publication-fiche.jsp&id=<%=postId%>");</script><%
        return;
    }
    
    // ============== DELETE COMMENT ==============
    else if ("deleteComment".equals(acte)) {
        String commentId = request.getParameter("id");
        String redirectPostId = request.getParameter("postId");
        
        if (commentId != null && !commentId.isEmpty()) {
            // Vérifier propriétaire du commentaire
            Commentaire commCheck = new Commentaire();
            commCheck.setId(commentId);
            Object[] comms = CGenUtil.rechercher(commCheck, null, null, "");
            
            if (comms != null && comms.length > 0) {
                Commentaire c = (Commentaire) comms[0];
                if (redirectPostId == null || redirectPostId.isEmpty()) redirectPostId = c.getPost_id();
                if (c.getIdutilisateur() == refuserInt) {
                    String postId = c.getPost_id();
                    
                    // Suppression logique
                    c.setSupprime(1);
                    u.updateObject(c);
                    
                    // Mettre à jour compteur du post
                    Post postCheck3 = new Post();
                    postCheck3.setId(postId);
                    Object[] posts3 = CGenUtil.rechercher(postCheck3, null, null, "");
                    if (posts3 != null && posts3.length > 0) {
                        Commentaire countCritere = new Commentaire();
                        Object[] allComms = CGenUtil.rechercher(countCritere, null, null, 
                            " AND post_id = '" + postId + "' AND supprime = 0");
                        int newCount = allComms != null ? allComms.length : 0;
                        updatePostCounter(postId, "nb_commentaires", newCount);
                    }
                }
            }
        }
        
%><script language="JavaScript"> document.location.replace("<%=lien%>?but=publication/publication-fiche.jsp&id=<%=redirectPostId%>");</script><%
        return;
    }
    
%><script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>");</script><%
    
} catch (Exception e) {
    e.printStackTrace();
%>
<script>
    alert('Erreur: <%= e.getMessage() != null ? e.getMessage().replace("'", "\\'") : "Une erreur est survenue" %>');
    history.back();
</script>
<% } %>
