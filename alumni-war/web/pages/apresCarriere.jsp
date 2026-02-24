<%@ page import="affichage.PageInsert" %>
<%@ page import="bean.Post" %>
<%@ page import="bean.PostEmploi" %>
<%@ page import="bean.PostStage" %>
<%@ page import="user.UserEJB" %>
<%@ page import="bean.ClassMAPTable" %>
<%
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    String acte = request.getParameter("acte");
    String bute = request.getParameter("bute");
    String id   = request.getParameter("id"); // utilise pour update
    String postId = id;

    if (acte == null) acte = "";
    if (bute == null) bute = "carriere/carriere-accueil.jsp";

    try {

        // =====================================================================
        // INSERT EMPLOI : cree un Post (type emploi) + un PostEmploi
        // =====================================================================
        if (acte.equalsIgnoreCase("insertEmploi")) {

            // 1. Creer le Post parent
            Post post = new Post();
            PageInsert piPost = new PageInsert(post, request);
            Post postAvecValeurs = (Post) piPost.getObjectAvecValeur();
            postAvecValeurs.setNomTable("posts");
            postAvecValeurs.setIdtypepublication("TYP00002");
            postAvecValeurs.setIdstatutpublication("STAT00002");
            postAvecValeurs.setIdutilisateur(Integer.parseInt(u.getUser().getTuppleID()));
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

            bute = "carriere/emploi-fiche.jsp";
            id   = postId;
        }

        // =====================================================================
        // INSERT STAGE : cree un Post (type stage) + un PostStage
        // =====================================================================
        else if (acte.equalsIgnoreCase("insertStage")) {

            // 1. Creer le Post parent
            Post post = new Post();
            PageInsert piPost = new PageInsert(post, request);
            Post postAvecValeurs = (Post) piPost.getObjectAvecValeur();
            postAvecValeurs.setNomTable("posts");
            postAvecValeurs.setIdtypepublication("TYP00001");
            postAvecValeurs.setIdstatutpublication("STAT00002");
            postAvecValeurs.setIdutilisateur(Integer.parseInt(u.getUser().getTuppleID()));
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

            bute = "carriere/stage-fiche.jsp";
            id   = postId;
        }

        // =====================================================================
        // UPDATE EMPLOI : met a jour Post + PostEmploi
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

            bute = "carriere/emploi-fiche.jsp";
        }

        // =====================================================================
        // UPDATE STAGE : met a jour Post + PostStage
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
