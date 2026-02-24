<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="bean.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="affichage.*" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Traitement Carrière</title>
</head>
<body>
<%
    String acte = null;
    String lien = null;
    String bute = null;
    UserEJB u = null;
    Connection conn = null;
    
    try {
        lien = (String) session.getValue("lien");
        u = (UserEJB) session.getAttribute("u");
        acte = request.getParameter("acte");
        bute = request.getParameter("bute");
        
        if (lien == null) lien = "module.jsp";
        if (bute == null) bute = "carriere/carriere-accueil.jsp";
        
        conn = CGenUtil.getConnection();
        conn.setAutoCommit(false);
        
        String postId = null;
        String message = "";
        
        // ========================
        // INSERT EMPLOI
        // ========================
        if ("insertEmploi".equalsIgnoreCase(acte)) {
            // 1. Créer le Post de base
            Post post = new Post();
            post.construirePK(conn);
            postId = post.getId();
            
            post.setIdtypepublication("TYP00002"); // Offre d'emploi
            post.setIdutilisateur(u.getRefUser());
            post.setIdstatutpublication("STAT0001"); // Brouillon par défaut
            post.setIdvisibilite(request.getParameter("idvisibilite"));
            post.setContenu(request.getParameter("contenu"));
            post.setNb_likes(0);
            post.setNb_commentaires(0);
            post.setNb_partages(0);
            post.setEpingle(0);
            post.setSupprime(0);
            post.insertToTable(conn);
            
            // 2. Créer PostEmploi
            PostEmploi emploi = new PostEmploi();
            emploi.setPost_id(postId);
            emploi.setIdentreprise(request.getParameter("identreprise"));
            emploi.setLocalisation(request.getParameter("localisation"));
            emploi.setPoste(request.getParameter("poste"));
            emploi.setType_contrat(request.getParameter("type_contrat"));
            
            String salaireMin = request.getParameter("salaire_min");
            if (salaireMin != null && !salaireMin.isEmpty()) {
                emploi.setSalaire_min(Double.parseDouble(salaireMin));
            }
            String salaireMax = request.getParameter("salaire_max");
            if (salaireMax != null && !salaireMax.isEmpty()) {
                emploi.setSalaire_max(Double.parseDouble(salaireMax));
            }
            
            emploi.setDevise(request.getParameter("devise"));
            emploi.setExperience_requise(request.getParameter("experience_requise"));
            emploi.setNiveau_etude_requis(request.getParameter("niveau_etude_requis"));
            
            String teletravail = request.getParameter("teletravail_possible");
            emploi.setTeletravail_possible(teletravail != null && ("1".equals(teletravail) || "on".equalsIgnoreCase(teletravail)) ? 1 : 0);
            
            String dateLimite = request.getParameter("date_limite");
            if (dateLimite != null && !dateLimite.isEmpty()) {
                emploi.setDate_limite(java.sql.Date.valueOf(dateLimite));
            }
            
            emploi.setContact_email(request.getParameter("contact_email"));
            emploi.setContact_tel(request.getParameter("contact_tel"));
            emploi.setLien_candidature(request.getParameter("lien_candidature"));
            emploi.insertToTable(conn);
            
            // 3. Insérer les compétences
            String[] competences = request.getParameterValues("competences[]");
            if (competences != null) {
                for (String compId : competences) {
                    if (compId != null && !compId.isEmpty()) {
                        EmploiCompetence ec = new EmploiCompetence();
                        ec.setPost_id(postId);
                        ec.setIdcompetence(compId);
                        ec.insertToTable(conn);
                    }
                }
            }
            
            conn.commit();
            message = "Offre d'emploi créée avec succès";
        }
        
        // ========================
        // INSERT STAGE
        // ========================
        else if ("insertStage".equalsIgnoreCase(acte)) {
            // 1. Créer le Post de base
            Post post = new Post();
            post.construirePK(conn);
            postId = post.getId();
            
            post.setIdtypepublication("TYP00003"); // Offre de stage
            post.setIdutilisateur(u.getRefUser());
            post.setIdstatutpublication("STAT0001");
            post.setIdvisibilite(request.getParameter("idvisibilite"));
            post.setContenu(request.getParameter("contenu"));
            post.setNb_likes(0);
            post.setNb_commentaires(0);
            post.setNb_partages(0);
            post.setEpingle(0);
            post.setSupprime(0);
            post.insertToTable(conn);
            
            // 2. Créer PostStage
            PostStage stage = new PostStage();
            stage.setPost_id(postId);
            stage.setIdentreprise(request.getParameter("identreprise"));
            stage.setDuree(request.getParameter("duree"));
            
            String dateDebut = request.getParameter("date_debut");
            if (dateDebut != null && !dateDebut.isEmpty()) {
                stage.setDate_debut(java.sql.Date.valueOf(dateDebut));
            }
            String dateFin = request.getParameter("date_fin");
            if (dateFin != null && !dateFin.isEmpty()) {
                stage.setDate_fin(java.sql.Date.valueOf(dateFin));
            }
            
            String indemnite = request.getParameter("indemnite");
            if (indemnite != null && !indemnite.isEmpty()) {
                stage.setIndemnite(Double.parseDouble(indemnite));
            }
            
            stage.setNiveau_etude_requis(request.getParameter("niveau_etude_requis"));
            
            String convention = request.getParameter("convention_requise");
            stage.setConvention_requise(convention != null && ("1".equals(convention) || "on".equalsIgnoreCase(convention)) ? 1 : 0);
            
            String places = request.getParameter("places_disponibles");
            if (places != null && !places.isEmpty()) {
                stage.setPlaces_disponibles(Integer.parseInt(places));
            }
            
            stage.setContact_email(request.getParameter("contact_email"));
            stage.setContact_tel(request.getParameter("contact_tel"));
            stage.setLien_candidature(request.getParameter("lien_candidature"));
            stage.insertToTable(conn);
            
            // 3. Insérer les compétences
            String[] competences = request.getParameterValues("competences[]");
            if (competences != null) {
                for (String compId : competences) {
                    if (compId != null && !compId.isEmpty()) {
                        StageCompetence sc = new StageCompetence();
                        sc.setPost_id(postId);
                        sc.setIdcompetence(compId);
                        sc.insertToTable(conn);
                    }
                }
            }
            
            conn.commit();
            message = "Offre de stage créée avec succès";
        }
        
        // ========================
        // UPDATE EMPLOI
        // ========================
        else if ("updateEmploi".equalsIgnoreCase(acte)) {
            postId = request.getParameter("post_id");
            
            // 1. Mettre à jour Post
            String sqlPost = "UPDATE posts SET contenu = ?, edited_at = CURRENT_TIMESTAMP WHERE id = ?";
            PreparedStatement psPost = conn.prepareStatement(sqlPost);
            psPost.setString(1, request.getParameter("contenu"));
            psPost.setString(2, postId);
            psPost.executeUpdate();
            psPost.close();
            
            // 2. Mettre à jour PostEmploi
            PostEmploi emploi = new PostEmploi();
            emploi.setPost_id(postId);
            emploi.setIdentreprise(request.getParameter("identreprise"));
            emploi.setLocalisation(request.getParameter("localisation"));
            emploi.setPoste(request.getParameter("poste"));
            emploi.setType_contrat(request.getParameter("type_contrat"));
            
            String salaireMin = request.getParameter("salaire_min");
            if (salaireMin != null && !salaireMin.isEmpty()) {
                emploi.setSalaire_min(Double.parseDouble(salaireMin));
            }
            String salaireMax = request.getParameter("salaire_max");
            if (salaireMax != null && !salaireMax.isEmpty()) {
                emploi.setSalaire_max(Double.parseDouble(salaireMax));
            }
            
            emploi.setDevise(request.getParameter("devise"));
            emploi.setExperience_requise(request.getParameter("experience_requise"));
            emploi.setNiveau_etude_requis(request.getParameter("niveau_etude_requis"));
            
            String teletravail = request.getParameter("teletravail_possible");
            emploi.setTeletravail_possible(teletravail != null && ("1".equals(teletravail) || "on".equalsIgnoreCase(teletravail)) ? 1 : 0);
            
            String dateLimite = request.getParameter("date_limite");
            if (dateLimite != null && !dateLimite.isEmpty()) {
                emploi.setDate_limite(java.sql.Date.valueOf(dateLimite));
            }
            
            emploi.setContact_email(request.getParameter("contact_email"));
            emploi.setContact_tel(request.getParameter("contact_tel"));
            emploi.setLien_candidature(request.getParameter("lien_candidature"));
            emploi.updateToTable(conn);
            
            // 3. Supprimer anciennes compétences et insérer les nouvelles
            String sqlDelComp = "DELETE FROM emploi_competence WHERE post_id = ?";
            PreparedStatement psDel = conn.prepareStatement(sqlDelComp);
            psDel.setString(1, postId);
            psDel.executeUpdate();
            psDel.close();
            
            String[] competences = request.getParameterValues("competences[]");
            if (competences != null) {
                for (String compId : competences) {
                    if (compId != null && !compId.isEmpty()) {
                        EmploiCompetence ec = new EmploiCompetence();
                        ec.setPost_id(postId);
                        ec.setIdcompetence(compId);
                        ec.insertToTable(conn);
                    }
                }
            }
            
            conn.commit();
            message = "Offre d'emploi mise à jour avec succès";
        }
        
        // ========================
        // UPDATE STAGE
        // ========================
        else if ("updateStage".equalsIgnoreCase(acte)) {
            postId = request.getParameter("post_id");
            
            // 1. Mettre à jour Post
            String sqlPost = "UPDATE posts SET contenu = ?, edited_at = CURRENT_TIMESTAMP WHERE id = ?";
            PreparedStatement psPost = conn.prepareStatement(sqlPost);
            psPost.setString(1, request.getParameter("contenu"));
            psPost.setString(2, postId);
            psPost.executeUpdate();
            psPost.close();
            
            // 2. Mettre à jour PostStage
            PostStage stage = new PostStage();
            stage.setPost_id(postId);
            stage.setIdentreprise(request.getParameter("identreprise"));
            stage.setDuree(request.getParameter("duree"));
            
            String dateDebut = request.getParameter("date_debut");
            if (dateDebut != null && !dateDebut.isEmpty()) {
                stage.setDate_debut(java.sql.Date.valueOf(dateDebut));
            }
            String dateFin = request.getParameter("date_fin");
            if (dateFin != null && !dateFin.isEmpty()) {
                stage.setDate_fin(java.sql.Date.valueOf(dateFin));
            }
            
            String indemnite = request.getParameter("indemnite");
            if (indemnite != null && !indemnite.isEmpty()) {
                stage.setIndemnite(Double.parseDouble(indemnite));
            }
            
            stage.setNiveau_etude_requis(request.getParameter("niveau_etude_requis"));
            
            String convention = request.getParameter("convention_requise");
            stage.setConvention_requise(convention != null && ("1".equals(convention) || "on".equalsIgnoreCase(convention)) ? 1 : 0);
            
            String places = request.getParameter("places_disponibles");
            if (places != null && !places.isEmpty()) {
                stage.setPlaces_disponibles(Integer.parseInt(places));
            }
            
            stage.setContact_email(request.getParameter("contact_email"));
            stage.setContact_tel(request.getParameter("contact_tel"));
            stage.setLien_candidature(request.getParameter("lien_candidature"));
            stage.updateToTable(conn);
            
            // 3. Supprimer anciennes compétences et insérer les nouvelles
            String sqlDelComp = "DELETE FROM stage_competence WHERE post_id = ?";
            PreparedStatement psDel = conn.prepareStatement(sqlDelComp);
            psDel.setString(1, postId);
            psDel.executeUpdate();
            psDel.close();
            
            String[] competences = request.getParameterValues("competences[]");
            if (competences != null) {
                for (String compId : competences) {
                    if (compId != null && !compId.isEmpty()) {
                        StageCompetence sc = new StageCompetence();
                        sc.setPost_id(postId);
                        sc.setIdcompetence(compId);
                        sc.insertToTable(conn);
                    }
                }
            }
            
            conn.commit();
            message = "Offre de stage mise à jour avec succès";
        }
        
        // Stocker le message en session pour affichage
        session.setAttribute("message_success", message);
%>
<script language="JavaScript">
    document.location.replace("<%=lien%>?but=<%=bute%>");
</script>
<%
    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (Exception ex) {}
        }
        e.printStackTrace();
        session.setAttribute("message_error", "Erreur: " + e.getMessage());
%>
<script language="JavaScript">
    document.location.replace("<%=lien%>?but=<%=bute%>");
</script>
<%
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (Exception ex) {}
        }
    }
%>
</body>
</html>
