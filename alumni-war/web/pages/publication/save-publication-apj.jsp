<%@ page import="bean.*, user.UserEJB, utilitaire.UtilDB, java.sql.*" %>
<%
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        
        if (u == null || lien == null) {
            response.sendRedirect("login.jsp");
            return;
        }
        
        int refuserInt = Integer.parseInt(u.getUser().getTuppleID());
        String acte = request.getParameter("acte");
        String redirectUrl = lien + "?but=publication/publication-liste.jsp";
        
        // ==================== INSERT ====================
        if ("insert".equalsIgnoreCase(acte)) {
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);
            
            try {
                String typePublication = request.getParameter("idtypepublication");
                String contenu = request.getParameter("contenu");
                String idvisibilite = request.getParameter("idvisibilite");
                String idstatutpublication = request.getParameter("idstatutpublication");
                
                // Creer le post principal
                Post post = new Post();
                post.setIdutilisateur(refuserInt);
                post.setIdtypepublication(typePublication);
                post.setIdstatutpublication(idstatutpublication);
                post.setIdvisibilite(idvisibilite);
                post.setContenu(contenu);
                post.setNb_likes(0);
                post.setNb_commentaires(0);
                post.setNb_partages(0);
                
                CGenUtil.save(post, conn);
                String postId = post.getId();
                
                // Creer les details selon le type
                if ("TYPU00001".equals(typePublication)) {
                    // Stage
                    PostStage stage = new PostStage();
                    stage.setPost_id(postId);
                    stage.setEntreprise(request.getParameter("stage_entreprise"));
                    stage.setLocalisation(request.getParameter("stage_localisation"));
                    stage.setDuree(request.getParameter("stage_duree"));
                    stage.setIndemnite(request.getParameter("stage_indemnite"));
                    stage.setCompetences_requises(request.getParameter("stage_competences"));
                    stage.setLien_candidature(request.getParameter("stage_lien"));
                    CGenUtil.save(stage, conn);
                    
                } else if ("TYPU00002".equals(typePublication)) {
                    // Emploi
                    PostEmploi emploi = new PostEmploi();
                    emploi.setPost_id(postId);
                    emploi.setEntreprise(request.getParameter("emploi_entreprise"));
                    emploi.setPoste(request.getParameter("emploi_poste"));
                    emploi.setLocalisation(request.getParameter("emploi_localisation"));
                    emploi.setType_contrat(request.getParameter("emploi_type_contrat"));
                    
                    String salMin = request.getParameter("emploi_salaire_min");
                    String salMax = request.getParameter("emploi_salaire_max");
                    if (salMin != null && !salMin.isEmpty()) {
                        emploi.setSalaire_min(Integer.parseInt(salMin));
                    }
                    if (salMax != null && !salMax.isEmpty()) {
                        emploi.setSalaire_max(Integer.parseInt(salMax));
                    }
                    
                    emploi.setQualifications_requises(request.getParameter("emploi_qualifications"));
                    emploi.setLien_candidature(request.getParameter("emploi_lien"));
                    CGenUtil.save(emploi, conn);
                    
                } else if ("TYPU00003".equals(typePublication)) {
                    // Activite
                    PostActivite activite = new PostActivite();
                    activite.setPost_id(postId);
                    activite.setTitre_evenement(request.getParameter("activite_titre"));
                    activite.setLieu(request.getParameter("activite_lieu"));
                    activite.setDate_debut(request.getParameter("activite_date_debut"));
                    activite.setDate_fin(request.getParameter("activite_date_fin"));
                    activite.setPrix(request.getParameter("activite_prix"));
                    activite.setLien_inscription(request.getParameter("activite_lien"));
                    CGenUtil.save(activite, conn);
                }
                
                // TODO: Gerer les fichiers uploads (necessiterait la mise en place d'un servlet)
                
                conn.commit();
                redirectUrl = lien + "?but=publication/publication-fiche.jsp&id=" + postId;
                
            } catch (Exception e) {
                if (conn != null) conn.rollback();
                throw e;
            }
        }
        
        // ==================== UPDATE ====================
        else if ("update".equalsIgnoreCase(acte)) {
            String postId = request.getParameter("id");
            
            // Verifier les permissions
            Post existingPost = new Post();
            existingPost.setId(postId);
            Object[] result = CGenUtil.rechercher(existingPost, null, null, "");
            if (result == null || result.length == 0) {
                throw new Exception("Publication introuvable");
            }
            existingPost = (Post) result[0];
            if (existingPost.getIdutilisateur() != refuserInt) {
                throw new Exception("Vous n'avez pas la permission de modifier cette publication");
            }
            
            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);
            
            try {
                String contenu = request.getParameter("contenu");
                String idvisibilite = request.getParameter("idvisibilite");
                String idstatutpublication = request.getParameter("idstatutpublication");
                
                // Mettre a jour le post
                ps = conn.prepareStatement(
                    "UPDATE posts SET contenu = ?, idvisibilite = ?, idstatutpublication = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?"
                );
                ps.setString(1, contenu);
                ps.setString(2, idvisibilite);
                ps.setString(3, idstatutpublication);
                ps.setString(4, postId);
                ps.executeUpdate();
                ps.close();
                
                // Mettre a jour les details selon le type
                String typePublication = existingPost.getIdtypepublication();
                
                if ("TYPU00001".equals(typePublication)) {
                    // Stage
                    ps = conn.prepareStatement(
                        "UPDATE post_stage SET entreprise = ?, localisation = ?, duree = ?, indemnite = ?, " +
                        "competences_requises = ?, lien_candidature = ? WHERE post_id = ?"
                    );
                    ps.setString(1, request.getParameter("stage_entreprise"));
                    ps.setString(2, request.getParameter("stage_localisation"));
                    ps.setString(3, request.getParameter("stage_duree"));
                    ps.setString(4, request.getParameter("stage_indemnite"));
                    ps.setString(5, request.getParameter("stage_competences"));
                    ps.setString(6, request.getParameter("stage_lien"));
                    ps.setString(7, postId);
                    ps.executeUpdate();
                    
                } else if ("TYPU00002".equals(typePublication)) {
                    // Emploi
                    ps = conn.prepareStatement(
                        "UPDATE post_emploi SET entreprise = ?, poste = ?, localisation = ?, type_contrat = ?, " +
                        "salaire_min = ?, salaire_max = ?, qualifications_requises = ?, lien_candidature = ? WHERE post_id = ?"
                    );
                    ps.setString(1, request.getParameter("emploi_entreprise"));
                    ps.setString(2, request.getParameter("emploi_poste"));
                    ps.setString(3, request.getParameter("emploi_localisation"));
                    ps.setString(4, request.getParameter("emploi_type_contrat"));
                    
                    String salMin = request.getParameter("emploi_salaire_min");
                    String salMax = request.getParameter("emploi_salaire_max");
                    if (salMin != null && !salMin.isEmpty()) {
                        ps.setInt(5, Integer.parseInt(salMin));
                    } else {
                        ps.setNull(5, Types.INTEGER);
                    }
                    if (salMax != null && !salMax.isEmpty()) {
                        ps.setInt(6, Integer.parseInt(salMax));
                    } else {
                        ps.setNull(6, Types.INTEGER);
                    }
                    
                    ps.setString(7, request.getParameter("emploi_qualifications"));
                    ps.setString(8, request.getParameter("emploi_lien"));
                    ps.setString(9, postId);
                    ps.executeUpdate();
                    
                } else if ("TYPU00003".equals(typePublication)) {
                    // Activite
                    ps = conn.prepareStatement(
                        "UPDATE post_activite SET titre_evenement = ?, lieu = ?, date_debut = ?, date_fin = ?, " +
                        "prix = ?, lien_inscription = ? WHERE post_id = ?"
                    );
                    ps.setString(1, request.getParameter("activite_titre"));
                    ps.setString(2, request.getParameter("activite_lieu"));
                    ps.setString(3, request.getParameter("activite_date_debut"));
                    ps.setString(4, request.getParameter("activite_date_fin"));
                    ps.setString(5, request.getParameter("activite_prix"));
                    ps.setString(6, request.getParameter("activite_lien"));
                    ps.setString(7, postId);
                    ps.executeUpdate();
                }
                
                conn.commit();
                redirectUrl = lien + "?but=publication/publication-fiche.jsp&id=" + postId;
                
            } catch (Exception e) {
                if (conn != null) conn.rollback();
                throw e;
            }
        }
        
        // ==================== DELETE ====================
        else if ("delete".equalsIgnoreCase(acte)) {
            String postId = request.getParameter("id");
            
            // Verifier les permissions
            Post post = new Post();
            post.setId(postId);
            Object[] result = CGenUtil.rechercher(post, null, null, "");
            if (result != null && result.length > 0) {
                post = (Post) result[0];
                if (post.getIdutilisateur() == refuserInt) {
                    conn = new UtilDB().GetConn();
                    // Les triggers et CASCADE feront le reste
                    ps = conn.prepareStatement("DELETE FROM posts WHERE id = ?");
                    ps.setString(1, postId);
                    ps.executeUpdate();
                }
            }
        }
        
        // ==================== LIKE ====================
        else if ("like".equalsIgnoreCase(acte)) {
            String postId = request.getParameter("postId");
            
            // Verifier si deja like
            Like likeFilter = new Like();
            likeFilter.setIdutilisateur(refuserInt);
            likeFilter.setPost_id(postId);
            Object[] existing = CGenUtil.rechercher(likeFilter, null, null, "");
            
            if (existing == null || existing.length == 0) {
                Like like = new Like();
                like.setIdutilisateur(refuserInt);
                like.setPost_id(postId);
                CGenUtil.save(like);
                
                // Le trigger increment_likes s'occupera du compteur
            }
            
            redirectUrl = lien + "?but=publication/publication-fiche.jsp&id=" + postId;
        }
        
        // ==================== UNLIKE ====================
        else if ("unlike".equalsIgnoreCase(acte)) {
            String postId = request.getParameter("postId");
            
            conn = new UtilDB().GetConn();
            ps = conn.prepareStatement("DELETE FROM likes WHERE idutilisateur = ? AND post_id = ?");
            ps.setInt(1, refuserInt);
            ps.setString(2, postId);
            ps.executeUpdate();
            
            // Le trigger decrement_likes s'occupera du compteur
            
            redirectUrl = lien + "?but=publication/publication-fiche.jsp&id=" + postId;
        }
        
        // ==================== SHARE ====================
        else if ("share".equalsIgnoreCase(acte)) {
            String postId = request.getParameter("postId");
            
            Partage partage = new Partage();
            partage.setIdutilisateur(refuserInt);
            partage.setPost_id(postId);
            CGenUtil.save(partage);
            
            // Le trigger increment_partages s'occupera du compteur
            
            redirectUrl = lien + "?but=publication/publication-fiche.jsp&id=" + postId;
        }
        
        // ==================== COMMENT ====================
        else if ("comment".equalsIgnoreCase(acte)) {
            String postId = request.getParameter("postId");
            String contenu = request.getParameter("contenu");
            String parentId = request.getParameter("parentId"); // Pour les reponses
            
            Commentaire comment = new Commentaire();
            comment.setIdutilisateur(refuserInt);
            comment.setPost_id(postId);
            comment.setContenu(contenu);
            if (parentId != null && !parentId.isEmpty()) {
                comment.setParent_id(parentId);
            }
            
            CGenUtil.save(comment);
            
            // Le trigger increment_commentaires s'occupera du compteur
            
            // Creer une notification pour l'auteur du post
            Post post = new Post();
            post.setId(postId);
            Object[] postResult = CGenUtil.rechercher(post, null, null, "");
            if (postResult != null && postResult.length > 0) {
                post = (Post) postResult[0];
                if (post.getIdutilisateur() != refuserInt) {
                    Notification notif = new Notification();
                    notif.setIdutilisateur(post.getIdutilisateur());
                    notif.setEmetteur_id(refuserInt);
                    notif.setIdtypenotification("TYNO00002"); // Commentaire
                    notif.setPost_id(postId);
                    notif.setVu(false);
                    CGenUtil.save(notif);
                }
            }
            
            redirectUrl = lien + "?but=publication/publication-fiche.jsp&id=" + postId;
        }
        
        // ==================== DELETE COMMENT ====================
        else if ("deleteComment".equalsIgnoreCase(acte)) {
            String commentId = request.getParameter("id");
            String postId = request.getParameter("postId");
            
            // Verifier les permissions
            Commentaire comment = new Commentaire();
            comment.setId(commentId);
            Object[] result = CGenUtil.rechercher(comment, null, null, "");
            if (result != null && result.length > 0) {
                comment = (Commentaire) result[0];
                if (comment.getIdutilisateur() == refuserInt) {
                    conn = new UtilDB().GetConn();
                    // Supprimer aussi les reponses (CASCADE)
                    ps = conn.prepareStatement("DELETE FROM commentaires WHERE id = ?");
                    ps.setString(1, commentId);
                    ps.executeUpdate();
                    
                    // Le trigger decrement_commentaires s'occupera du compteur
                }
            }
            
            redirectUrl = lien + "?but=publication/publication-fiche.jsp&id=" + postId;
        }
        
        // Redirect
%>
<script>window.location.href='<%= redirectUrl %>';</script>
<%
    } catch (Exception e) {
        e.printStackTrace();
        String lien = (String) session.getValue("lien");
        String errorMsg = (e.getMessage() != null) ? e.getMessage().replace("'", "\\'") : "Erreur inconnue";
%>
<script>
    alert('Erreur: <%= errorMsg %>');
    window.location.href='<%= lien %>?but=publication/publication-liste.jsp';
</script>
<%
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignored) {}
        if (ps != null) try { ps.close(); } catch (Exception ignored) {}
        if (conn != null) try { 
            if (!conn.getAutoCommit()) conn.setAutoCommit(true);
            conn.close(); 
        } catch (Exception ignored) {}
    }
%>
