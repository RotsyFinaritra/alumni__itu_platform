<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*, utilitaire.*, java.sql.*, user.UserEJB, affichage.PageInsert, utilisateurAcade.UtilisateurAcade, java.util.*" %>
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
    
    // Mapping type publication → topic auto-tag
    private String getAutoTagTopicId(String idtypepublication) {
        if (idtypepublication == null) return null;
        switch (idtypepublication) {
            case "TYP00001": return "TOP00010"; // Stage
            case "TYP00002": return "TOP00011"; // Emploi CDI
            case "TYP00003": return "TOP00022"; // Activité → Événements
            default: return null;
        }
    }
    
    // Insérer un PostTopic
    private void insertPostTopic(Connection conn, String postId, String topicId) throws Exception {
        PostTopic pt = new PostTopic();
        pt.construirePK(conn);
        pt.setPost_id(postId);
        pt.setTopic_id(topicId);
        pt.setCreated_at(new Timestamp(System.currentTimeMillis()));
        pt.insertToTable(conn);
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
        
        // Auto-tag + manual topics
        if (newId != null && !newId.isEmpty()) {
            Connection connTag = null;
            try {
                connTag = new UtilDB().GetConn();
                Set<String> insertedTopics = new HashSet<String>();
                
                // Auto-tag basé sur le type
                String autoTopicId = getAutoTagTopicId(idtypepublication);
                if (autoTopicId != null) {
                    insertPostTopic(connTag, newId, autoTopicId);
                    insertedTopics.add(autoTopicId);
                }
                
                // Topics manuels
                String[] manualTopics = request.getParameterValues("topics");
                if (manualTopics != null) {
                    for (String topicId : manualTopics) {
                        if (topicId != null && !topicId.trim().isEmpty() && !insertedTopics.contains(topicId.trim())) {
                            insertPostTopic(connTag, newId, topicId.trim());
                            insertedTopics.add(topicId.trim());
                        }
                    }
                }
            } catch (Exception tagEx) {
                tagEx.printStackTrace(); // Non-bloquant
            } finally {
                if (connTag != null) try { connTag.close(); } catch (Exception ignored) {}
            }
        }
        
%><script language="JavaScript"> document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=newId%>");</script><%
        return;
    }
    
    // ============== LIKE (toggle) ==============
    else if ("like".equals(acte)) {
        String postId = request.getParameter("id");
        String returnPage = request.getParameter("bute");
        String isAjax = request.getParameter("ajax");
        if (returnPage == null || returnPage.isEmpty()) returnPage = "publication/publication-fiche.jsp";
        
        if (postId == null || postId.isEmpty()) {
            if ("1".equals(isAjax)) {
                response.setContentType("application/json; charset=UTF-8");
                out.print("{\"success\": false, \"error\": \"ID manquant\"}");
                return;
            }
%><script language="JavaScript">alert('ID manquant');history.back();</script><%
            return;
        }
        
        int nbLikes = 0;
        try {
        // Vérifier si déjà liké via CGenUtil
        Like likeCheck = new Like();
        Object[] existingLikes = CGenUtil.rechercher(likeCheck, null, null, 
            " AND post_id = '" + postId + "' AND idutilisateur = " + refuserInt);
        
        if (existingLikes != null && existingLikes.length > 0) {
            // Déjà liké - supprimer (unlike)
            Like existingLike = (Like) existingLikes[0];
            u.deleteObject(existingLike);
        } else {
            // Créer nouveau like
            Like newLike = new Like();
            newLike.setPost_id(postId);
            newLike.setIdutilisateur(refuserInt);
            newLike.setCreated_at(new java.sql.Timestamp(System.currentTimeMillis()));
            u.createObject(newLike);
        }
        
        // Compter le nombre RÉEL de likes depuis la table likes
        Like likeCounting = new Like();
        Object[] allLikes = CGenUtil.rechercher(likeCounting, null, null, " AND post_id = '" + postId + "'");
        nbLikes = (allLikes != null) ? allLikes.length : 0;
        
        // Mettre à jour le compteur dans la table posts
        updatePostCounter(postId, "nb_likes", nbLikes);
        
        // Créer notification pour l'auteur du post si c'est un LIKE (pas un unlike)
        if (existingLikes == null || existingLikes.length == 0) {
            // C'était un like, créer notification
            Post postForNotif = new Post();
            postForNotif.setId(postId);
            Object[] postForNotifResult = CGenUtil.rechercher(postForNotif, null, null, "");
            if (postForNotifResult != null && postForNotifResult.length > 0) {
                Post p = (Post) postForNotifResult[0];
                if (p.getIdutilisateur() != refuserInt && currentUser != null) {
                    String nomComplet = ((currentUser.getPrenom() != null ? currentUser.getPrenom() + " " : "") + 
                                        (currentUser.getNomuser() != null ? currentUser.getNomuser() : "")).trim();
                    if (nomComplet.isEmpty()) nomComplet = "Utilisateur";
                    
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
            if ("1".equals(isAjax)) {
                response.setContentType("application/json; charset=UTF-8");
                out.print("{\"success\": false, \"error\": \"" + ex.getMessage() + "\"}");
                return;
            }
        }
        
        // Retourner JSON si AJAX, sinon rediriger
        if ("1".equals(isAjax)) {
            response.setContentType("application/json; charset=UTF-8");
            out.print("{\"success\": true, \"nbLikes\": " + nbLikes + "}");
        } else {
            // Rediriger vers la page d'origine
%><script language="JavaScript">document.location.replace("<%=lien%>?but=<%=returnPage%>&id=<%=postId%>");</script><%
        }
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
                    if (nomComplet.isEmpty()) nomComplet = "Utilisateur";
                    
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
    
    // ============== SIGNALER PUBLICATION ==============
    else if ("signaler".equals(acte)) {
        String sigPostId = request.getParameter("post_id");
        String idmotifsignalement = request.getParameter("idmotifsignalement");
        String sigDescription = request.getParameter("description");
        String returnPage = request.getParameter("bute");
        if (returnPage == null || returnPage.isEmpty()) returnPage = "publication/publication-fiche.jsp";
        
        if (sigPostId == null || sigPostId.isEmpty()) {
            throw new Exception("Aucune publication specifiee");
        }
        if (idmotifsignalement == null || idmotifsignalement.isEmpty()) {
            throw new Exception("Veuillez choisir un motif de signalement");
        }
        
        // Verifier que le post existe
        Post postCheck = new Post();
        postCheck.setId(sigPostId);
        Object[] postExists = CGenUtil.rechercher(postCheck, null, null, " AND id = '" + sigPostId + "'");
        if (postExists == null || postExists.length == 0) {
            throw new Exception("Publication introuvable");
        }
        
        // Verifier si l'utilisateur a deja signale ce post
        Signalement sigCheck = new Signalement();
        Object[] dejaSignale = CGenUtil.rechercher(sigCheck, null, null, 
            " AND post_id = '" + sigPostId + "' AND idutilisateur = " + refuserInt);
        if (dejaSignale != null && dejaSignale.length > 0) {
            throw new Exception("Vous avez deja signale cette publication");
        }
        
        // Creer le signalement avec connexion explicite
        Connection sigConn = null;
        try {
            sigConn = new UtilDB().GetConn();
            Signalement newSig = new Signalement();
            newSig.construirePK(sigConn);
            newSig.setIdutilisateur(refuserInt);
            newSig.setPost_id(sigPostId);
            newSig.setIdmotifsignalement(idmotifsignalement);
            newSig.setIdstatutsignalement("SSIG00001"); // En attente
            newSig.setCreated_at(new java.sql.Timestamp(System.currentTimeMillis()));
            if (sigDescription != null && !sigDescription.trim().isEmpty()) {
                newSig.setDescription(sigDescription.trim());
            }
            newSig.insertToTable(sigConn);
        } finally {
            if (sigConn != null) try { sigConn.close(); } catch (Exception ignored) {}
        }
        
%><script language="JavaScript"> alert('Votre signalement a bien ete enregistre. Il sera examine par les moderateurs.'); document.location.replace("<%=lien%>?but=<%=returnPage%>&id=<%=sigPostId%>");</script><%
        return;
    }
    
    // ============== SIGNALER COMMENTAIRE ==============
    else if ("signalerCommentaire".equals(acte)) {
        String sigCommentaireId = request.getParameter("commentaire_id");
        String idmotifsignalement = request.getParameter("idmotifsignalement");
        String sigDescription = request.getParameter("description");
        String returnPage = request.getParameter("bute");
        if (returnPage == null || returnPage.isEmpty()) returnPage = "publication/publication-fiche.jsp";
        
        if (sigCommentaireId == null || sigCommentaireId.isEmpty()) {
            throw new Exception("Aucun commentaire specifie");
        }
        if (idmotifsignalement == null || idmotifsignalement.isEmpty()) {
            throw new Exception("Veuillez choisir un motif de signalement");
        }
        
        // Verifier que le commentaire existe
        Commentaire commCheck = new Commentaire();
        commCheck.setId(sigCommentaireId);
        Object[] commExists = CGenUtil.rechercher(commCheck, null, null, "");
        if (commExists == null || commExists.length == 0) {
            throw new Exception("Commentaire introuvable");
        }
        
        // Verifier si l'utilisateur a deja signale ce commentaire
        Signalement sigCheck = new Signalement();
        Object[] dejaSignale = CGenUtil.rechercher(sigCheck, null, null, 
            " AND commentaire_id = '" + sigCommentaireId + "' AND idutilisateur = " + refuserInt);
        if (dejaSignale != null && dejaSignale.length > 0) {
            throw new Exception("Vous avez deja signale ce commentaire");
        }
        
        // Creer le signalement avec connexion explicite
        Connection sigConn = null;
        try {
            sigConn = new UtilDB().GetConn();
            Signalement newSig = new Signalement();
            newSig.construirePK(sigConn);
            newSig.setIdutilisateur(refuserInt);
            newSig.setCommentaire_id(sigCommentaireId);
            newSig.setIdmotifsignalement(idmotifsignalement);
            newSig.setIdstatutsignalement("SSIG00001"); // En attente
            newSig.setCreated_at(new java.sql.Timestamp(System.currentTimeMillis()));
            if (sigDescription != null && !sigDescription.trim().isEmpty()) {
                newSig.setDescription(sigDescription.trim());
            }
            newSig.insertToTable(sigConn);
        } finally {
            if (sigConn != null) try { sigConn.close(); } catch (Exception ignored) {}
        }
        
%><script language="JavaScript"> alert('Votre signalement a bien ete enregistre. Il sera examine par les moderateurs.'); document.location.replace("<%=lien%>?but=<%=returnPage%>");</script><%
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
