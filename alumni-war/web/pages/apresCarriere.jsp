<%@ page import="affichage.PageInsert" %>
<%@ page import="bean.Post" %>
<%@ page import="bean.PostEmploi" %>
<%@ page import="bean.PostStage" %>
<%@ page import="bean.EmploiCompetence" %>
<%@ page import="bean.StageCompetence" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="user.UserEJB" %>
<%@ page import="bean.ClassMAPTable" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    String acte = request.getParameter("acte");
    String bute = request.getParameter("bute");
    String id   = request.getParameter("id"); // utilise pour update
    String postId = id;
    
    // Récupérer les compétences sélectionnées
    String[] competences = request.getParameterValues("competences[]");

    if (acte == null) acte = "";
    if (bute == null) bute = "carriere/carriere-accueil.jsp";

    try {

        // =====================================================================
        // INSERT EMPLOI : cree un Post (type emploi) + un PostEmploi + competences
        // =====================================================================
        if (acte.equalsIgnoreCase("insertEmploi")) {

            // 1. Creer le Post parent
            Post post = new Post();
            PageInsert piPost = new PageInsert(post, request);
            Post postAvecValeurs = (Post) piPost.getObjectAvecValeur();
            postAvecValeurs.setNomTable("posts");
            postAvecValeurs.setIdtypepublication("TYP00002");
            postAvecValeurs.setIdstatutpublication("STAT00002");
            postAvecValeurs.setIdvisibilite("VISI00001"); // Public par defaut
            postAvecValeurs.setIdutilisateur(Integer.parseInt(u.getUser().getTuppleID()));
            postAvecValeurs.setContenu(""); // Contenu vide par defaut pour emploi
            postAvecValeurs.setEpingle(0);
            postAvecValeurs.setSupprime(0);
            postAvecValeurs.setNb_likes(0);
            postAvecValeurs.setNb_commentaires(0);
            postAvecValeurs.setNb_partages(0);
            Post postInsere = (Post) u.createObject(postAvecValeurs);
            postId = postInsere.getTuppleID();

            // 2. Creer les details PostEmploi
            PostEmploi emploi = new PostEmploi();
            PageInsert piEmploi = new PageInsert(emploi, request);
            PostEmploi emploiAvecValeurs = (PostEmploi) piEmploi.getObjectAvecValeur();
            emploiAvecValeurs.setNomTable("post_emploi");
            emploiAvecValeurs.setPost_id(postId);
            u.createObject(emploiAvecValeurs);
            
            // 3. Inserer les competences associees
            if (competences != null) {
                for (String idComp : competences) {
                    if (idComp != null && !idComp.trim().isEmpty()) {
                        EmploiCompetence ec = new EmploiCompetence();
                        ec.setPost_id(postId);
                        ec.setIdcompetence(idComp);
                        CGenUtil.save(ec);
                    }
                }
            }

            bute = "carriere/emploi-fiche.jsp";
            id   = postId;
        }

        // =====================================================================
        // INSERT STAGE : cree un Post (type stage) + un PostStage + competences
        // =====================================================================
        else if (acte.equalsIgnoreCase("insertStage")) {

            // 1. Creer le Post parent
            Post post = new Post();
            PageInsert piPost = new PageInsert(post, request);
            Post postAvecValeurs = (Post) piPost.getObjectAvecValeur();
            postAvecValeurs.setNomTable("posts");
            postAvecValeurs.setIdtypepublication("TYP00001");
            postAvecValeurs.setIdstatutpublication("STAT00002");
            postAvecValeurs.setIdvisibilite("VISI00001"); // Public par defaut
            postAvecValeurs.setIdutilisateur(Integer.parseInt(u.getUser().getTuppleID()));
            postAvecValeurs.setContenu(""); // Contenu vide par defaut pour stage
            postAvecValeurs.setEpingle(0);
            postAvecValeurs.setSupprime(0);
            postAvecValeurs.setNb_likes(0);
            postAvecValeurs.setNb_commentaires(0);
            postAvecValeurs.setNb_partages(0);
            Post postInsere = (Post) u.createObject(postAvecValeurs);
            postId = postInsere.getTuppleID();

            // 2. Creer les details PostStage
            PostStage stage = new PostStage();
            PageInsert piStage = new PageInsert(stage, request);
            PostStage stageAvecValeurs = (PostStage) piStage.getObjectAvecValeur();
            stageAvecValeurs.setNomTable("post_stage");
            stageAvecValeurs.setPost_id(postId);
            u.createObject(stageAvecValeurs);
            
            // 3. Inserer les competences associees
            if (competences != null) {
                for (String idComp : competences) {
                    if (idComp != null && !idComp.trim().isEmpty()) {
                        StageCompetence sc = new StageCompetence();
                        sc.setPost_id(postId);
                        sc.setIdcompetence(idComp);
                        CGenUtil.save(sc);
                    }
                }
            }

            bute = "carriere/stage-fiche.jsp";
            id   = postId;
        }

        // =====================================================================
        // UPDATE EMPLOI : met a jour Post + PostEmploi + competences
        // =====================================================================
        else if (acte.equalsIgnoreCase("updateEmploi")) {

            // 1. Update Post
            Post postCritere = new Post();
            postCritere.setId(postId);
            PageInsert piPost = new PageInsert(postCritere, request);
            Post postAvecValeurs = (Post) piPost.getObjectAvecValeur();
            postAvecValeurs.setNomTable("posts");
            postAvecValeurs.setId(postId);
            u.updateObject(postAvecValeurs);

            // 2. Update PostEmploi
            PostEmploi emploiCritere = new PostEmploi();
            emploiCritere.setPost_id(postId);
            PageInsert piEmploi = new PageInsert(emploiCritere, request);
            PostEmploi emploiAvecValeurs = (PostEmploi) piEmploi.getObjectAvecValeur();
            emploiAvecValeurs.setNomTable("post_emploi");
            emploiAvecValeurs.setPost_id(postId);
            u.updateObject(emploiAvecValeurs);
            
            // 3. Supprimer les anciennes competences et inserer les nouvelles
            Connection connEc = null;
            PreparedStatement psEc = null;
            try {
                connEc = new UtilDB().GetConn();
                psEc = connEc.prepareStatement("DELETE FROM emploi_competence WHERE post_id = ?");
                psEc.setString(1, postId);
                psEc.executeUpdate();
            } finally {
                if (psEc != null) try { psEc.close(); } catch (Exception ignored) {}
                if (connEc != null) try { connEc.close(); } catch (Exception ignored) {}
            }
            
            if (competences != null) {
                for (String idComp : competences) {
                    if (idComp != null && !idComp.trim().isEmpty()) {
                        EmploiCompetence ec = new EmploiCompetence();
                        ec.setPost_id(postId);
                        ec.setIdcompetence(idComp);
                        CGenUtil.save(ec);
                    }
                }
            }

            bute = "carriere/emploi-fiche.jsp";
        }

        // =====================================================================
        // UPDATE STAGE : met a jour Post + PostStage + competences
        // =====================================================================
        else if (acte.equalsIgnoreCase("updateStage")) {

            // 1. Update Post
            Post postCritere = new Post();
            postCritere.setId(postId);
            PageInsert piPost = new PageInsert(postCritere, request);
            Post postAvecValeurs = (Post) piPost.getObjectAvecValeur();
            postAvecValeurs.setNomTable("posts");
            postAvecValeurs.setId(postId);
            u.updateObject(postAvecValeurs);

            // 2. Update PostStage
            PostStage stageCritere = new PostStage();
            stageCritere.setPost_id(postId);
            PageInsert piStage = new PageInsert(stageCritere, request);
            PostStage stageAvecValeurs = (PostStage) piStage.getObjectAvecValeur();
            stageAvecValeurs.setNomTable("post_stage");
            stageAvecValeurs.setPost_id(postId);
            u.updateObject(stageAvecValeurs);
            
            // 3. Supprimer les anciennes competences et inserer les nouvelles
            Connection connSc = null;
            PreparedStatement psSc = null;
            try {
                connSc = new UtilDB().GetConn();
                psSc = connSc.prepareStatement("DELETE FROM stage_competence WHERE post_id = ?");
                psSc.setString(1, postId);
                psSc.executeUpdate();
            } finally {
                if (psSc != null) try { psSc.close(); } catch (Exception ignored) {}
                if (connSc != null) try { connSc.close(); } catch (Exception ignored) {}
            }
            
            if (competences != null) {
                for (String idComp : competences) {
                    if (idComp != null && !idComp.trim().isEmpty()) {
                        StageCompetence sc = new StageCompetence();
                        sc.setPost_id(postId);
                        sc.setIdcompetence(idComp);
                        CGenUtil.save(sc);
                    }
                }
            }

            bute = "carriere/stage-fiche.jsp";
        }

%>
<script language="JavaScript">
    document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=id%>");
</script>
<%
    } catch (Exception e) {
        e.printStackTrace();
        String msgErr = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
%>
<script language="JavaScript">
    alert('Erreur apresCarriere : <%=msgErr.replace("'", "\\'")%>');
    history.back();
</script>
<%
    }
%>
