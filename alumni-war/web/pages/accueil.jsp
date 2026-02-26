<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*, utilitaire.Utilitaire, utilitaire.UtilDB, java.util.*, java.text.SimpleDateFormat, java.sql.*" %>
<%@ page import="user.UserEJB, utilisateurAcade.UtilisateurAcade" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    if (u == null || lien == null) {
        response.sendRedirect("security-login.jsp");
        return;
    }
    
    int refuserInt = u.getUser().getRefuser();
    String nomUser = u.getUser().getNomuser() != null ? u.getUser().getNomuser() : "";
    
    // === RÉCUPÉRER L'UTILISATEUR CONNECTÉ (prenom, photo via UtilisateurAcade) ===
    String prenomUser = "";
    String photoUser = request.getContextPath() + "/assets/img/default-avatar.png";
    UtilisateurAcade userCritere = new UtilisateurAcade();
    // Ne pas utiliser setters car CGenUtil applique UPPER() qui échoue sur integers
    Object[] userResult = CGenUtil.rechercher(userCritere, null, null, " AND refuser = " + refuserInt);
    if (userResult != null && userResult.length > 0) {
        UtilisateurAcade userInfo = (UtilisateurAcade) userResult[0];
        prenomUser = userInfo.getPrenom() != null ? userInfo.getPrenom() : "";
        if (userInfo.getPhoto() != null && !userInfo.getPhoto().isEmpty()) {
            String photoFileName = userInfo.getPhoto();
            if (photoFileName.contains("/")) {
                photoFileName = photoFileName.substring(photoFileName.lastIndexOf("/") + 1);
            }
            photoUser = request.getContextPath() + "/profile-photo?file=" + photoFileName;
        }
    }
    
    // === STATISTIQUES ===
    // Nombre de notifications non lues
    Notification notifCritere = new Notification();
    Object[] notifResult = CGenUtil.rechercher(notifCritere, null, null, " AND idutilisateur = " + refuserInt + " AND vu = 0");
    int nbNotifs = (notifResult != null) ? notifResult.length : 0;
    
    // Nombre de mes publications
    Post mesPostsCritere = new Post();
    Object[] mesPostsResult = CGenUtil.rechercher(mesPostsCritere, null, null, " AND idutilisateur = " + refuserInt + " AND supprime = 0");
    int nbMesPosts = (mesPostsResult != null) ? mesPostsResult.length : 0;
    
    // Nombre d'offres emploi/stage actives
    Post offresFilter = new Post();
    Object[] offresResult = CGenUtil.rechercher(offresFilter, null, null, 
        " AND idtypepublication IN ('TYP00001', 'TYP00002') AND idstatutpublication = 'STAT00002' AND supprime = 0");
    int nbOffres = (offresResult != null) ? offresResult.length : 0;
    
    // === CHARGER LES PUBLICATIONS (FIL D'ACTUALITÉ) ===
    int currentPage = 1;
    try { currentPage = Integer.parseInt(request.getParameter("page")); } catch (Exception ignored) {}
    int postsPerPage = 10;
    
    // Charger les types de publication pour le formulaire
    TypePublication[] typesPublication = (TypePublication[]) CGenUtil.rechercher(new TypePublication(), null, null, " AND actif = 1 ORDER BY ordre");
    VisibilitePublication[] visibilites = (VisibilitePublication[]) CGenUtil.rechercher(new VisibilitePublication(), null, null, " AND actif = 1 ORDER BY ordre");
    
    // Charger les topics pour le tag manuel
    Object[] allTopicsResult = CGenUtil.rechercher(new Topic(), null, null, " AND actif = 1 ORDER BY nom");
    
    // Vérifier si l'utilisateur a déjà choisi ses intérêts
    Object[] userInteretsResult = CGenUtil.rechercher(new UtilisateurInteret(), null, null, " AND idutilisateur = " + refuserInt);
    boolean hasChosenInterets = (userInteretsResult != null && userInteretsResult.length > 0);
    
    // Charger les publications via CGenUtil (exclure les posts de promotion/groupe)
    // === FILTRAGE MIXTE 70/30 BASÉ SUR LES INTÉRÊTS ===
    Object[] postsResult = null;
    int totalPosts = 0;
    int totalPages = 0;
    
    if (hasChosenInterets) {
        // Construire la liste des topic_ids de l'utilisateur
        StringBuilder topicIdsList = new StringBuilder();
        for (int i = 0; i < userInteretsResult.length; i++) {
            UtilisateurInteret ui = (UtilisateurInteret) userInteretsResult[i];
            if (i > 0) topicIdsList.append(",");
            topicIdsList.append("'").append(ui.getTopic_id()).append("'");
        }
        String topicsIn = topicIdsList.toString();
        
        // Calculer les limites 70/30
        int matchingLimit = (int) Math.ceil(postsPerPage * 0.7);
        int otherLimit = postsPerPage - matchingLimit;
        int offset = (currentPage - 1) * postsPerPage;
        int matchingOffset = (int) Math.ceil(offset * 0.7);
        int otherOffset = offset - matchingOffset;
        
        Connection connFeed = null;
        try {
            connFeed = new utilitaire.UtilDB().GetConn();
            
            // 1. Posts qui matchent les intérêts de l'utilisateur
            String sqlMatching = "SELECT DISTINCT p.id FROM posts p " +
                "INNER JOIN post_topics pt ON pt.post_id = p.id " +
                "WHERE p.supprime = 0 AND (p.idvisibilite IS NULL OR p.idvisibilite != 'VISI00004') " +
                "AND (p.idgroupe IS NULL OR p.idgroupe = '') " +
                "AND pt.topic_id IN (" + topicsIn + ") " +
                "ORDER BY p.id DESC LIMIT " + matchingLimit + " OFFSET " + matchingOffset;
            
            java.sql.Statement stmtMatch = connFeed.createStatement();
            java.sql.ResultSet rsMatch = stmtMatch.executeQuery(sqlMatching);
            List<String> matchingIds = new ArrayList<String>();
            while (rsMatch.next()) {
                matchingIds.add(rsMatch.getString("id"));
            }
            rsMatch.close();
            stmtMatch.close();
            
            // 2. Posts récents qui NE matchent PAS (30%)
            String excludeClause = "";
            if (!matchingIds.isEmpty()) {
                StringBuilder excludeBuilder = new StringBuilder();
                for (int i = 0; i < matchingIds.size(); i++) {
                    if (i > 0) excludeBuilder.append(",");
                    excludeBuilder.append("'").append(matchingIds.get(i)).append("'");
                }
                excludeClause = " AND p.id NOT IN (" + excludeBuilder.toString() + ")";
            }
            
            String sqlOther = "SELECT p.id FROM posts p " +
                "WHERE p.supprime = 0 AND (p.idvisibilite IS NULL OR p.idvisibilite != 'VISI00004') " +
                "AND (p.idgroupe IS NULL OR p.idgroupe = '')" + excludeClause +
                " ORDER BY p.created_at DESC LIMIT " + otherLimit + " OFFSET " + otherOffset;
            
            java.sql.Statement stmtOther = connFeed.createStatement();
            java.sql.ResultSet rsOther = stmtOther.executeQuery(sqlOther);
            List<String> otherIds = new ArrayList<String>();
            while (rsOther.next()) {
                otherIds.add(rsOther.getString("id"));
            }
            rsOther.close();
            stmtOther.close();
            
            // 3. Combiner : matching d'abord, puis autres
            List<String> allIds = new ArrayList<String>();
            allIds.addAll(matchingIds);
            allIds.addAll(otherIds);
            
            // 4. Charger les posts via CGenUtil
            if (!allIds.isEmpty()) {
                StringBuilder inClause = new StringBuilder();
                for (int i = 0; i < allIds.size(); i++) {
                    if (i > 0) inClause.append(",");
                    inClause.append("'").append(allIds.get(i)).append("'");
                }
                Post postFilter = new Post();
                postsResult = CGenUtil.rechercher(postFilter, null, null, 
                    " AND id IN (" + inClause.toString() + ") ORDER BY created_at DESC");
            }
            
            // 5. Compter le total
            String sqlTotal = "SELECT COUNT(DISTINCT p.id) as cnt FROM posts p " +
                "WHERE p.supprime = 0 AND (p.idvisibilite IS NULL OR p.idvisibilite != 'VISI00004') " +
                "AND (p.idgroupe IS NULL OR p.idgroupe = '')";
            java.sql.Statement stmtTotal = connFeed.createStatement();
            java.sql.ResultSet rsTotal = stmtTotal.executeQuery(sqlTotal);
            if (rsTotal.next()) totalPosts = rsTotal.getInt("cnt");
            rsTotal.close();
            stmtTotal.close();
            totalPages = (int) Math.ceil((double) totalPosts / postsPerPage);
            
        } catch (Exception feedEx) {
            feedEx.printStackTrace();
        } finally {
            if (connFeed != null) try { connFeed.close(); } catch (Exception ignored) {}
        }
        
    } else {
        // Pas d'intérêts → affichage chronologique classique
        Post postFilter = new Post();
        String apresWherePost = " AND supprime = 0 AND (idvisibilite IS NULL OR idvisibilite != 'VISI00004') AND (idgroupe IS NULL OR idgroupe = '') ORDER BY created_at DESC LIMIT " + postsPerPage + " OFFSET " + ((currentPage - 1) * postsPerPage);
        postsResult = CGenUtil.rechercher(postFilter, null, null, apresWherePost);
        
        Post totalFilter = new Post();
        Object[] allPostsResult = CGenUtil.rechercher(totalFilter, null, null, " AND supprime = 0 AND (idvisibilite IS NULL OR idvisibilite != 'VISI00004') AND (idgroupe IS NULL OR idgroupe = '')");
        totalPosts = (allPostsResult != null) ? allPostsResult.length : 0;
        totalPages = (int) Math.ceil((double) totalPosts / postsPerPage);
    }
%>

<%!
    // Formater le temps relatif
    public String formatTempsRelatif(java.sql.Timestamp date) {
        if (date == null) return "";
        long diff = System.currentTimeMillis() - date.getTime();
        long seconds = diff / 1000;
        long minutes = seconds / 60;
        long hours = minutes / 60;
        long days = hours / 24;
        
        if (days > 7) {
            return new java.text.SimpleDateFormat("dd/MM/yyyy").format(date);
        } else if (days > 0) {
            return "Il y a " + days + " jour" + (days > 1 ? "s" : "");
        } else if (hours > 0) {
            return "Il y a " + hours + " heure" + (hours > 1 ? "s" : "");
        } else if (minutes > 0) {
            return "Il y a " + minutes + " minute" + (minutes > 1 ? "s" : "");
        } else {
            return "A l'instant";
        }
    }
%>

<div class="content-wrapper">
    <section class="content">
        <div class="feed-container">
    <!-- ========== FIL D'ACTUALITÉ (CENTRE) ========== -->
    <div class="feed-main">
        
        <!-- Formulaire de création de publication -->
        <div class="create-post-compact">
            <form action="<%= lien %>?but=publication/apresPublicationFichier.jsp" method="post" id="formPublication" enctype="multipart/form-data">
                <input type="hidden" name="idtypepublication" value="TYP00004">
                <input type="hidden" name="idvisibilite" value="VISI00001">
                <input type="hidden" name="acte" value="insert">
                <input type="hidden" name="bute" value="accueil.jsp">
                <input type="file" id="fileInput" name="fichier" style="display:none;" onchange="previewFile(this)" accept="image/*,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx">

                <!-- Zone fichier en premier -->
                <div id="file-drop-zone" class="file-drop-zone" onclick="document.getElementById('fileInput').click()">
                    <div id="file-drop-placeholder" class="file-drop-placeholder">
                        <i class="fa fa-cloud-upload"></i>
                        <span>Ajouter une photo ou un fichier</span>
                    </div>
                    <div id="file-preview-container" class="file-preview-container" style="display:none;">
                        <div class="file-preview-item">
                            <i class="fa fa-file file-icon"></i>
                            <span id="file-preview-name" class="file-preview-name"></span>
                            <button type="button" class="file-remove-btn" onclick="event.stopPropagation(); removeFile()"><i class="fa fa-times"></i></button>
                        </div>
                        <img id="file-preview-img" class="file-preview-img" style="display:none;" />
                    </div>
                </div>

                <!-- Zone texte + actions -->
                <div class="create-bottom">
                    <img class="avatar-sm" src="<%= photoUser %>" alt="Photo">
                    <textarea name="contenu" class="create-input" placeholder="Quoi de neuf, <%= prenomUser %> ?" required rows="1" oninput="autoResize(this)"></textarea>
                    <button type="submit" class="btn-post" title="Publier"><i class="fa fa-paper-plane"></i></button>
                </div>

                <!-- Sélection de topics -->
                <div class="topic-selector">
                    <div class="topic-toggle" onclick="toggleTopicChips()">
                        <i class="fa fa-tags"></i> <span>Ajouter des tags</span>
                        <i class="fa fa-chevron-down topic-arrow"></i>
                    </div>
                    <div class="topic-chips-container" id="topicChipsContainer" style="display:none;">
                        <% if (allTopicsResult != null) {
                            for (Object topicObj : allTopicsResult) {
                                Topic topic = (Topic) topicObj;
                        %>
                        <label class="topic-chip" data-topic-id="<%= topic.getId() %>" style="--chip-color: <%= topic.getCouleur() != null ? topic.getCouleur() : "#6c757d" %>">
                            <input type="checkbox" name="topics" value="<%= topic.getId() %>" style="display:none;" onchange="toggleChipStyle(this)">
                            <i class="fa <%= topic.getIcon() != null ? topic.getIcon() : "fa-tag" %>"></i>
                            <span><%= topic.getNom() %></span>
                        </label>
                        <% }} %>
                    </div>
                </div>

                <div class="create-actions">
                    <a href="<%= lien %>?but=carriere/emploi-saisie.jsp" class="action-link">
                        <i class="fa fa-briefcase"></i> Emploi
                    </a>
                    <a href="<%= lien %>?but=carriere/stage-saisie.jsp" class="action-link">
                        <i class="fa fa-graduation-cap"></i> Stage
                    </a>
                </div>
            </form>
        </div>
        
        <!-- Fil d'actualité -->
        <% if (postsResult == null || postsResult.length == 0) { %>
        <div class="post-card empty-state">
            <i class="fa fa-camera-retro"></i>
            <h3>Aucune publication</h3>
            <p>Soyez le premier à partager quelque chose avec la communauté !</p>
        </div>
        <% } else { 
            for (Object postObj : postsResult) {
                Post post = (Post) postObj;
                String postId = post.getId();
                String contenu = post.getContenu();
                java.sql.Timestamp createdAt = post.getCreated_at();
                int postAuteurId = post.getIdutilisateur();
                int nbLikes = post.getNb_likes();
                int nbComments = post.getNb_commentaires();
                
                // Charger l'auteur via UtilisateurAcade
                String nomComplet = "Utilisateur";
                String photoAuteur = request.getContextPath() + "/assets/img/default-avatar.png";
                UtilisateurAcade auteurCritere = new UtilisateurAcade();
                Object[] auteurResult = CGenUtil.rechercher(auteurCritere, null, null, " AND refuser = " + postAuteurId);
                if (auteurResult != null && auteurResult.length > 0) {
                    UtilisateurAcade auteur = (UtilisateurAcade) auteurResult[0];
                    String prenom = auteur.getPrenom() != null ? auteur.getPrenom() : "";
                    String nom = auteur.getNomuser() != null ? auteur.getNomuser() : "";
                    nomComplet = (prenom + " " + nom).trim();
                    if (nomComplet.isEmpty()) nomComplet = "Utilisateur";
                    if (auteur.getPhoto() != null && !auteur.getPhoto().isEmpty()) {
                        String auteurPhotoFile = auteur.getPhoto();
                        if (auteurPhotoFile.contains("/")) {
                            auteurPhotoFile = auteurPhotoFile.substring(auteurPhotoFile.lastIndexOf("/") + 1);
                        }
                        photoAuteur = request.getContextPath() + "/profile-photo?file=" + auteurPhotoFile;
                    }
                }
                
                // Charger le type de publication
                String typeLibelle = "";
                String typeIcon = "fa-file-text-o";
                String typeCouleur = "#3498db";
                if (post.getIdtypepublication() != null) {
                    TypePublication typeCritere = new TypePublication();
                    typeCritere.setId(post.getIdtypepublication());
                    Object[] typeResult = CGenUtil.rechercher(typeCritere, null, null, " AND id = '" + post.getIdtypepublication() + "'");
                    if (typeResult != null && typeResult.length > 0) {
                        TypePublication typePost = (TypePublication) typeResult[0];
                        typeLibelle = typePost.getLibelle() != null ? typePost.getLibelle() : "";
                        typeIcon = typePost.getIcon() != null ? typePost.getIcon() : "fa-file-text-o";
                        typeCouleur = typePost.getCouleur() != null ? typePost.getCouleur() : "#3498db";
                    }
                }
                
                // Charger les détails selon le type
                PostStage postStage = null;
                PostEmploi postEmploi = null;
                PostActivite postActivite = null;
                String entrepriseNom = "";
                String categorieNom = "";
                
                if ("TYP00001".equals(post.getIdtypepublication())) {
                    PostStage sf = new PostStage(); sf.setPost_id(postId);
                    Object[] sr = CGenUtil.rechercher(sf, null, null, "");
                    if (sr != null && sr.length > 0) {
                        postStage = (PostStage) sr[0];
                        if (postStage.getIdentreprise() != null && !postStage.getIdentreprise().isEmpty()) {
                            Entreprise ent = new Entreprise(); ent.setId(postStage.getIdentreprise());
                            Object[] er = CGenUtil.rechercher(ent, null, null, "");
                            if (er != null && er.length > 0) entrepriseNom = ((Entreprise)er[0]).getLibelle();
                        }
                        if (entrepriseNom.isEmpty() && postStage.getEntreprise() != null) entrepriseNom = postStage.getEntreprise();
                    }
                } else if ("TYP00002".equals(post.getIdtypepublication())) {
                    PostEmploi ef = new PostEmploi(); ef.setPost_id(postId);
                    Object[] er = CGenUtil.rechercher(ef, null, null, "");
                    if (er != null && er.length > 0) {
                        postEmploi = (PostEmploi) er[0];
                        if (postEmploi.getIdentreprise() != null && !postEmploi.getIdentreprise().isEmpty()) {
                            Entreprise ent = new Entreprise(); ent.setId(postEmploi.getIdentreprise());
                            Object[] entr = CGenUtil.rechercher(ent, null, null, "");
                            if (entr != null && entr.length > 0) entrepriseNom = ((Entreprise)entr[0]).getLibelle();
                        }
                        if (entrepriseNom.isEmpty() && postEmploi.getEntreprise() != null) entrepriseNom = postEmploi.getEntreprise();
                    }
                } else if ("TYP00003".equals(post.getIdtypepublication())) {
                    PostActivite af = new PostActivite(); af.setPost_id(postId);
                    Object[] ar = CGenUtil.rechercher(af, null, null, "");
                    if (ar != null && ar.length > 0) {
                        postActivite = (PostActivite) ar[0];
                        if (postActivite.getIdcategorie() != null && !postActivite.getIdcategorie().isEmpty()) {
                            CategorieActivite cat = new CategorieActivite(); cat.setId(postActivite.getIdcategorie());
                            Object[] cr = CGenUtil.rechercher(cat, null, null, "");
                            if (cr != null && cr.length > 0) categorieNom = ((CategorieActivite)cr[0]).getLibelle();
                        }
                    }
                }
                
                // Charger les fichiers attachés
                PostFichier fichierFilter = new PostFichier();
                fichierFilter.setPost_id(postId);
                Object[] fichiersResult = CGenUtil.rechercher(fichierFilter, null, null, " ORDER BY ordre");
                
                // Charger les topics du post
                Object[] postTopicsResult = CGenUtil.rechercher(new PostTopic(), null, null, " AND post_id = '" + postId + "'");
                
                // Vérifier si l'utilisateur a liké
                Like likeCheck = new Like();
                Object[] likeCheckResult = CGenUtil.rechercher(likeCheck, null, null, " AND post_id = '" + postId + "' AND idutilisateur = " + refuserInt);
                boolean hasLiked = (likeCheckResult != null && likeCheckResult.length > 0);
        %>
        
        <!-- Publication -->
        <div class="post-card">
            <div class="post-header">
                <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= postAuteurId %>" class="post-author">
                    <img class="avatar" src="<%= photoAuteur %>" alt="Photo">
                    <div class="author-info">
                        <span class="author-name"><%= nomComplet %></span>
                        <span class="post-meta">
                            <span class="post-type" style="background-color: <%= typeCouleur %>;">
                                <i class="fa <%= typeIcon %>"></i> <%= typeLibelle %>
                            </span>
                            <span class="post-time"><%= formatTempsRelatif(createdAt) %></span>
                        </span>
                    </div>
                </a>
                <div class="post-menu">
                    <button class="menu-btn" onclick="toggleMenu('<%= postId %>')">
                        <i class="fa fa-ellipsis-h"></i>
                    </button>
                    <div class="menu-dropdown" id="menu-<%= postId %>">
                        <% if (postAuteurId == refuserInt) { %>
                        <a href="<%= lien %>?but=publication/publication-modif.jsp&id=<%= postId %>"><i class="fa fa-edit"></i> Modifier</a>
                        <a href="#" onclick="supprimerPost('<%= postId %>')"><i class="fa fa-trash"></i> Supprimer</a>
                        <% } else { %>
                        <a href="<%= lien %>?but=publication/signalement-saisie.jsp&post_id=<%= postId %>">
                            <i class="fa fa-flag" style="color:#e74c3c"></i> Signaler
                        </a>
                        <% } %>
                    </div>
                </div>
            </div>
            <div class="post-content">
                <p><%= contenu != null ? contenu : "" %></p>
            </div>
            
            <!-- Tags du post -->
            <% if (postTopicsResult != null && postTopicsResult.length > 0) { %>
            <div class="post-tags">
                <% for (Object ptObj : postTopicsResult) {
                    PostTopic pt = (PostTopic) ptObj;
                    // Trouver le topic
                    if (allTopicsResult != null) {
                        for (Object tObj : allTopicsResult) {
                            Topic t = (Topic) tObj;
                            if (t.getId().equals(pt.getTopic_id())) {
                %>
                <span class="post-tag" style="--tag-color: <%= t.getCouleur() != null ? t.getCouleur() : "#6c757d" %>">
                    <i class="fa <%= t.getIcon() != null ? t.getIcon() : "fa-tag" %>"></i> <%= t.getNom() %>
                </span>
                <%              break;
                            }
                        }
                    }
                } %>
            </div>
            <% } %>
            
            <!-- Détails Stage -->
            <% if (postStage != null) { %>
            <div class="accueil-detail accueil-detail-stage">
                <div class="accueil-detail-head">
                    <span class="accueil-detail-icon stage-bg"><i class="fa fa-briefcase"></i></span>
                    <div>
                        <strong>Offre de Stage</strong>
                        <% if (!entrepriseNom.isEmpty()) { %><br><span class="accueil-detail-sub"><i class="fa fa-building-o"></i> <%= entrepriseNom %></span><% } %>
                    </div>
                </div>
                <div class="accueil-detail-chips">
                    <% if (postStage.getLocalisation() != null && !postStage.getLocalisation().isEmpty()) { %>
                    <span class="achip"><i class="fa fa-map-marker"></i> <%= postStage.getLocalisation() %></span>
                    <% } %>
                    <% if (postStage.getDuree() != null && !postStage.getDuree().isEmpty()) { %>
                    <span class="achip"><i class="fa fa-clock-o"></i> <%= postStage.getDuree() %></span>
                    <% } %>
                    <% if (postStage.getIndemnite() > 0) { %>
                    <span class="achip achip-hl"><i class="fa fa-money"></i> <%= String.format("%,.0f", postStage.getIndemnite()) %> Ar</span>
                    <% } %>
                    <% if (postStage.getNiveau_etude_requis() != null && !postStage.getNiveau_etude_requis().isEmpty()) { %>
                    <span class="achip"><i class="fa fa-graduation-cap"></i> <%= postStage.getNiveau_etude_requis() %></span>
                    <% } %>
                </div>
                <% if (postStage.getLien_candidature() != null && !postStage.getLien_candidature().isEmpty()) { %>
                <a href="<%= postStage.getLien_candidature() %>" target="_blank" class="accueil-btn-apply"><i class="fa fa-paper-plane"></i> Postuler</a>
                <% } %>
            </div>
            <% } %>
            
            <!-- Détails Emploi -->
            <% if (postEmploi != null) { %>
            <div class="accueil-detail accueil-detail-emploi">
                <div class="accueil-detail-head">
                    <span class="accueil-detail-icon emploi-bg"><i class="fa fa-suitcase"></i></span>
                    <div>
                        <strong><%= postEmploi.getPoste() != null && !postEmploi.getPoste().isEmpty() ? postEmploi.getPoste() : "Offre d'emploi" %></strong>
                        <% if (!entrepriseNom.isEmpty()) { %><br><span class="accueil-detail-sub"><i class="fa fa-building-o"></i> <%= entrepriseNom %></span><% } %>
                    </div>
                </div>
                <div class="accueil-detail-chips">
                    <% if (postEmploi.getLocalisation() != null && !postEmploi.getLocalisation().isEmpty()) { %>
                    <span class="achip"><i class="fa fa-map-marker"></i> <%= postEmploi.getLocalisation() %></span>
                    <% } %>
                    <% if (postEmploi.getType_contrat() != null && !postEmploi.getType_contrat().isEmpty()) { %>
                    <span class="achip"><i class="fa fa-file-text-o"></i> <%= postEmploi.getType_contrat() %></span>
                    <% } %>
                    <% if (postEmploi.getSalaire_min() > 0 || postEmploi.getSalaire_max() > 0) { %>
                    <span class="achip achip-hl"><i class="fa fa-money"></i>
                        <%= (postEmploi.getSalaire_min() > 0 ? String.format("%,.0f", postEmploi.getSalaire_min()) : "") %>
                        <%= (postEmploi.getSalaire_min() > 0 && postEmploi.getSalaire_max() > 0 ? " - " : "") %>
                        <%= (postEmploi.getSalaire_max() > 0 ? String.format("%,.0f", postEmploi.getSalaire_max()) : "") %>
                        <%= postEmploi.getDevise() != null && !postEmploi.getDevise().isEmpty() ? postEmploi.getDevise() : "Ar" %>
                    </span>
                    <% } %>
                    <% if (postEmploi.getExperience_requise() != null && !postEmploi.getExperience_requise().isEmpty()) { %>
                    <span class="achip"><i class="fa fa-star"></i> <%= postEmploi.getExperience_requise() %></span>
                    <% } %>
                    <% if (postEmploi.getTeletravail_possible() == 1) { %>
                    <span class="achip achip-ok"><i class="fa fa-home"></i> T&eacute;l&eacute;travail</span>
                    <% } %>
                </div>
                <% if (postEmploi.getDate_limite() != null) { %>
                <div class="accueil-detail-date"><i class="fa fa-hourglass-end"></i> Date limite : <strong><%= new SimpleDateFormat("dd/MM/yyyy").format(postEmploi.getDate_limite()) %></strong></div>
                <% } %>
                <% if (postEmploi.getLien_candidature() != null && !postEmploi.getLien_candidature().isEmpty()) { %>
                <a href="<%= postEmploi.getLien_candidature() %>" target="_blank" class="accueil-btn-apply"><i class="fa fa-paper-plane"></i> Postuler</a>
                <% } %>
            </div>
            <% } %>
            
            <!-- Détails Activité -->
            <% if (postActivite != null) { %>
            <div class="accueil-detail accueil-detail-activite">
                <div class="accueil-detail-head">
                    <span class="accueil-detail-icon activite-bg"><i class="fa fa-calendar"></i></span>
                    <div>
                        <strong><%= postActivite.getTitre() != null && !postActivite.getTitre().isEmpty() ? postActivite.getTitre() : "&Eacute;v&eacute;nement" %></strong>
                        <% if (!categorieNom.isEmpty()) { %><br><span class="accueil-detail-sub"><i class="fa fa-tag"></i> <%= categorieNom %></span><% } %>
                    </div>
                </div>
                <div class="accueil-detail-chips">
                    <% if (postActivite.getLieu() != null && !postActivite.getLieu().isEmpty()) { %>
                    <span class="achip"><i class="fa fa-map-marker"></i> <%= postActivite.getLieu() %></span>
                    <% } %>
                    <% if (postActivite.getPrix() > 0) { %>
                    <span class="achip achip-hl"><i class="fa fa-ticket"></i> <%= String.format("%,.0f", postActivite.getPrix()) %> Ar</span>
                    <% } else { %>
                    <span class="achip achip-ok"><i class="fa fa-gift"></i> Gratuit</span>
                    <% } %>
                    <% if (postActivite.getNombre_places() > 0) { %>
                    <span class="achip"><i class="fa fa-users"></i> <%= postActivite.getPlaces_restantes() %>/<%= postActivite.getNombre_places() %> places</span>
                    <% } %>
                </div>
                <% if (postActivite.getDate_debut() != null || postActivite.getDate_fin() != null) { %>
                <div class="accueil-detail-date"><i class="fa fa-calendar"></i>
                    <% if (postActivite.getDate_debut() != null) { %>Du <strong><%= new SimpleDateFormat("dd/MM/yyyy HH:mm").format(postActivite.getDate_debut()) %></strong><% } %>
                    <% if (postActivite.getDate_fin() != null) { %> au <strong><%= new SimpleDateFormat("dd/MM/yyyy HH:mm").format(postActivite.getDate_fin()) %></strong><% } %>
                </div>
                <% } %>
                <% if (postActivite.getLien_inscription() != null && !postActivite.getLien_inscription().isEmpty()) { %>
                <a href="<%= postActivite.getLien_inscription() %>" target="_blank" class="accueil-btn-apply accueil-btn-inscrire"><i class="fa fa-check-circle"></i> S'inscrire</a>
                <% } %>
            </div>
            <% } %>
            
            <!-- Fichiers attachés -->
            <% if (fichiersResult != null && fichiersResult.length > 0) { 
                // Séparer images, vidéos, documents
                java.util.List<PostFichier> images = new java.util.ArrayList<PostFichier>();
                java.util.List<PostFichier> videos = new java.util.ArrayList<PostFichier>();
                java.util.List<PostFichier> docs = new java.util.ArrayList<PostFichier>();
                for (Object fObj : fichiersResult) {
                    PostFichier pf = (PostFichier) fObj;
                    String mime = pf.getMime_type() != null ? pf.getMime_type() : "";
                    if (mime.startsWith("image/")) images.add(pf);
                    else if (mime.startsWith("video/")) videos.add(pf);
                    else docs.add(pf);
                }
            %>
            <div class="accueil-media">
                <% if (!images.isEmpty()) { %>
                <div class="accueil-images <%= images.size() == 1 ? "single" : (images.size() == 2 ? "double" : "multi") %>">
                    <% for (PostFichier img : images) { %>
                    <a href="<%= lien %>?but=publication/publication-fiche.jsp&id=<%= postId %>">
                        <img src="<%= request.getContextPath() %>/PostFichierServlet?action=view&id=<%= img.getId() %>" alt="<%= img.getNom_original() %>">
                    </a>
                    <% } %>
                </div>
                <% } %>
                <% if (!videos.isEmpty()) { 
                    for (PostFichier vid : videos) { %>
                <video controls preload="metadata" style="width:100%; max-height:400px; border-radius:0;">
                    <source src="<%= request.getContextPath() %>/PostFichierServlet?action=view&id=<%= vid.getId() %>" type="<%= vid.getMime_type() %>">
                </video>
                <% } } %>
                <% if (!docs.isEmpty()) { %>
                <div class="accueil-docs">
                    <% for (PostFichier doc : docs) { %>
                    <a href="<%= request.getContextPath() %>/PostFichierServlet?action=download&id=<%= doc.getId() %>" class="accueil-doc-link">
                        <i class="fa fa-file-o"></i> <%= doc.getNom_original() %>
                    </a>
                    <% } %>
                </div>
                <% } %>
            </div>
            <% } %>
            
            <div class="post-actions">
                <button class="action-btn like-btn <%= hasLiked ? "liked" : "" %>" onclick="likePost('<%= postId %>')" id="like-btn-<%= postId %>">
                    <i class="fa <%= hasLiked ? "fa-heart" : "fa-heart-o" %>"></i>
                    <span id="likes-<%= postId %>"><%= nbLikes %></span>
                </button>
                <a href="<%= lien %>?but=publication/publication-fiche.jsp&id=<%= postId %>" class="action-btn" style="text-decoration:none;">
                    <i class="fa fa-comment-o"></i>
                    <span><%= nbComments %></span>
                </a>
                <button class="action-btn">
                    <i class="fa fa-paper-plane-o"></i>
                </button>
                <button class="action-btn bookmark-btn">
                    <i class="fa fa-bookmark-o"></i>
                </button>
            </div>
            <div class="post-likes-summary">
                <% if (nbLikes > 0) { %>
                <strong><%= nbLikes %> J'aime<%= nbLikes > 1 ? "s" : "" %></strong>
                <% } %>
            </div>
        </div>
        
        <% }
        } %>
        
        <!-- Pagination -->
        <% if (totalPages > 1) { %>
        <div class="pagination-wrapper">
            <% if (currentPage > 1) { %>
            <a href="<%= lien %>?but=accueil.jsp&page=<%= currentPage - 1 %>" class="page-btn"><i class="fa fa-chevron-left"></i></a>
            <% } %>
            <% 
            int startPage = Math.max(1, currentPage - 2);
            int endPage = Math.min(totalPages, currentPage + 2);
            for (int i = startPage; i <= endPage; i++) { 
            %>
            <a href="<%= lien %>?but=accueil.jsp&page=<%= i %>" class="page-btn <%= i == currentPage ? "active" : "" %>"><%= i %></a>
            <% } %>
            <% if (currentPage < totalPages) { %>
            <a href="<%= lien %>?but=accueil.jsp&page=<%= currentPage + 1 %>" class="page-btn"><i class="fa fa-chevron-right"></i></a>
            <% } %>
        </div>
        <% } %>
        
    </div>
    
    <!-- ========== SIDEBAR DROITE (FIXED) ========== -->
    <div class="feed-sidebar">
        <div class="sidebar-inner">
            
            <!-- Profil utilisateur -->
            <div class="sidebar-profile">
                <a href="<%= lien %>?but=profil/mon-profil.jsp" class="profile-link">
                    <img class="profile-avatar" src="<%= photoUser %>" alt="Photo">
                    <div class="profile-info">
                        <span class="profile-name"><%= prenomUser %> <%= nomUser %></span>
                        <span class="profile-subtitle">Membre Alumni ITU</span>
                    </div>
                </a>
            </div>
            
            <!-- Statistiques -->
            <div class="sidebar-section">
                <div class="section-header">
                    <span>Vos statistiques</span>
                </div>
                <div class="stats-grid">
                    <a href="<%= lien %>?but=notification/notification-liste.jsp" class="stat-item">
                        <span class="stat-value <%= nbNotifs > 0 ? "has-notif" : "" %>"><%= nbNotifs %></span>
                        <span class="stat-label">Notifications</span>
                    </a>
                    <div class="stat-item">
                        <span class="stat-value"><%= nbMesPosts %></span>
                        <span class="stat-label">Publications</span>
                    </div>
                    <a href="<%= lien %>?but=carriere/emploi-liste.jsp" class="stat-item">
                        <span class="stat-value"><%= nbOffres %></span>
                        <span class="stat-label">Offres</span>
                    </a>
                </div>
            </div>
            
            <!-- Raccourcis -->
            <div class="sidebar-section">
                <div class="section-header">
                    <span>Raccourcis</span>
                </div>
                <nav class="sidebar-nav">
                    <a href="<%= lien %>?but=chatbot/alumni-chat.jsp" class="chat-link">
                        <i class="fa fa-comments"></i> Assistant Alumni
                        <span class="badge-new">IA</span>
                    </a>
                    <a href="<%= lien %>?but=carriere/emploi-liste.jsp">
                        <i class="fa fa-briefcase"></i> Offres d'emploi
                    </a>
                    <a href="<%= lien %>?but=carriere/stage-liste.jsp">
                        <i class="fa fa-graduation-cap"></i> Stages
                    </a>
                    <a href="<%= lien %>?but=annuaire/annuaire-liste.jsp">
                        <i class="fa fa-users"></i> Annuaire
                    </a>
                    <a href="<%= lien %>?but=notification/notification-liste.jsp">
                        <i class="fa fa-bell"></i> Notifications
                        <% if (nbNotifs > 0) { %><span class="nav-badge"><%= nbNotifs %></span><% } %>
                    </a>
                </nav>
            </div>
            
            <!-- Mes intérêts -->
            <div class="sidebar-section">
                <div class="section-header">
                    <span>Mes int&eacute;r&ecirc;ts</span>
                    <a href="<%= lien %>?but=profil/mes-interets.jsp" class="section-edit-link" title="G&eacute;rer"><i class="fa fa-pencil"></i></a>
                </div>
                <div class="sidebar-topics">
                    <% if (hasChosenInterets) {
                        for (Object uiObj : userInteretsResult) {
                            UtilisateurInteret ui = (UtilisateurInteret) uiObj;
                            // Trouver le topic correspondant
                            if (allTopicsResult != null) {
                                for (Object tObj : allTopicsResult) {
                                    Topic t = (Topic) tObj;
                                    if (t.getId().equals(ui.getTopic_id())) {
                    %>
                    <span class="sidebar-topic-chip" style="--chip-color: <%= t.getCouleur() != null ? t.getCouleur() : "#6c757d" %>">
                        <i class="fa <%= t.getIcon() != null ? t.getIcon() : "fa-tag" %>"></i> <%= t.getNom() %>
                    </span>
                    <%              break;
                                    }
                                }
                            }
                        }
                    } else { %>
                    <a href="<%= lien %>?but=profil/mes-interets.jsp" class="sidebar-choose-interests">
                        <i class="fa fa-plus-circle"></i> Choisir mes int&eacute;r&ecirc;ts
                    </a>
                    <% } %>
                </div>
            </div>
            
            <!-- Footer -->
            <div class="sidebar-footer">
                <p>Alumni ITU Platform &copy; 2026</p>
            </div>
            
        </div>
    </div>
</div>
    </section>
</div>

<!-- ========== POPUP CHOIX INTÉRÊTS (premier login) ========== -->
<% if (!hasChosenInterets) { %>
<div class="interests-overlay" id="interestsOverlay">
    <div class="interests-modal">
        <div class="interests-header">
            <h2><i class="fa fa-heart"></i> Bienvenue, <%= prenomUser %> !</h2>
            <p>Choisissez vos centres d'int&eacute;r&ecirc;t pour personnaliser votre fil d'actualit&eacute;.</p>
        </div>
        <div class="interests-body">
            <div class="interests-grid" id="interestsGrid">
                <% if (allTopicsResult != null) {
                    for (Object topicObj : allTopicsResult) {
                        Topic topic = (Topic) topicObj;
                %>
                <div class="interest-card" data-topic-id="<%= topic.getId() %>" onclick="toggleInterest(this)" style="--card-color: <%= topic.getCouleur() != null ? topic.getCouleur() : "#6c757d" %>">
                    <div class="interest-icon">
                        <i class="fa <%= topic.getIcon() != null ? topic.getIcon() : "fa-tag" %>"></i>
                    </div>
                    <span class="interest-name"><%= topic.getNom() %></span>
                    <div class="interest-check"><i class="fa fa-check"></i></div>
                </div>
                <% }} %>
            </div>
        </div>
        <div class="interests-footer">
            <span class="interests-counter"><span id="selectedCount">0</span> s&eacute;lectionn&eacute;(s)</span>
            <button class="btn-save-interests" onclick="saveInterests()" id="btnSaveInterests" disabled>
                <i class="fa fa-check"></i> Confirmer mes int&eacute;r&ecirc;ts
            </button>
            <button class="btn-skip-interests" onclick="skipInterests()">
                Passer pour l'instant
            </button>
        </div>
    </div>
</div>
<% } %>

<style>
/* ========== LAYOUT FEED ========== */
.feed-container {
    display: flex;
    max-width: 100%;
    margin: 0;
    padding: 20px;
    gap: 30px;
    min-height: calc(100vh - 100px);
    background: #fafafa;
}

.feed-main {
    flex: 1;
    max-width: calc(100% - 320px);
}

.feed-sidebar {
    width: 290px;
    flex-shrink: 0;
}

.sidebar-inner {
    position: sticky;
    top: 70px;
    width: 290px;
    max-height: calc(100vh - 80px);
    overflow-y: auto;
}

/* ========== CREATE POST COMPACT ========== */
.create-post-compact {
    background: #fff;
    border: 1px solid #e0e0e0;
    border-radius: 12px;
    margin-bottom: 20px;
    overflow: hidden;
}

.avatar-sm {
    width: 34px;
    height: 34px;
    border-radius: 50%;
    object-fit: cover;
    flex-shrink: 0;
}

/* --- File drop zone (premier) --- */
.file-drop-zone {
    border-bottom: 1px solid #f0f0f0;
    cursor: pointer;
    transition: background 0.2s;
}
.file-drop-zone:hover {
    background: #fafbfc;
}
.file-drop-placeholder {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    padding: 18px 16px;
    color: #8e8e8e;
    font-size: 13px;
}
.file-drop-placeholder i {
    font-size: 18px;
    color: #b0b0b0;
}
.file-drop-zone:hover .file-drop-placeholder i {
    color: #0095f6;
}
.file-drop-zone:hover .file-drop-placeholder {
    color: #555;
}

.file-preview-container {
    padding: 10px 16px;
}
.file-preview-item {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 6px;
}
.file-icon {
    color: #0095f6;
    font-size: 16px;
}
.file-preview-name {
    flex: 1;
    font-size: 13px;
    color: #333;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.file-preview-img {
    max-height: 160px;
    max-width: 100%;
    border-radius: 8px;
    object-fit: cover;
}
.file-remove-btn {
    background: transparent;
    border: none;
    color: #999;
    cursor: pointer;
    font-size: 13px;
    padding: 4px 6px;
    border-radius: 4px;
    transition: all 0.15s;
}
.file-remove-btn:hover {
    background: #fee;
    color: #dc3545;
}

/* --- Bottom: avatar + textarea + submit --- */
.create-bottom {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 14px;
}

.create-input {
    flex: 1;
    border: none;
    padding: 8px 0;
    font-size: 14px;
    background: transparent;
    outline: none;
    resize: none;
    min-height: 34px;
    max-height: 100px;
    overflow-y: auto;
    font-family: inherit;
    line-height: 1.4;
    color: #262626;
}
.create-input::placeholder {
    color: #b0b0b0;
}

.btn-post {
    background: #0095f6;
    color: #fff;
    border: none;
    border-radius: 50%;
    width: 34px;
    height: 34px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: background 0.15s;
    flex-shrink: 0;
    font-size: 13px;
}
.btn-post:hover {
    background: #0081d6;
}

/* --- Topic Selector --- */
.topic-selector {
    border-top: 1px solid #f0f0f0;
}
.topic-toggle {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 8px 14px;
    font-size: 12px;
    color: #65676b;
    cursor: pointer;
    transition: background 0.15s;
    user-select: none;
}
.topic-toggle:hover {
    background: #f7f8fa;
    color: #333;
}
.topic-toggle .topic-arrow {
    margin-left: auto;
    font-size: 10px;
    transition: transform 0.2s;
}
.topic-toggle.open .topic-arrow {
    transform: rotate(180deg);
}
.topic-chips-container {
    display: flex;
    flex-wrap: wrap;
    gap: 6px;
    padding: 6px 14px 12px;
}
.topic-chip {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    padding: 4px 10px;
    border-radius: 20px;
    border: 1.5px solid #e0e0e0;
    font-size: 11px;
    font-weight: 500;
    color: #555;
    background: #fff;
    cursor: pointer;
    transition: all 0.2s;
    user-select: none;
}
.topic-chip:hover {
    border-color: var(--chip-color, #6c757d);
    color: var(--chip-color, #6c757d);
    background: color-mix(in srgb, var(--chip-color, #6c757d) 6%, white);
}
.topic-chip.selected {
    border-color: var(--chip-color, #6c757d);
    background: var(--chip-color, #6c757d);
    color: #fff;
}
.topic-chip i {
    font-size: 11px;
}

/* --- Actions row --- */
.create-actions {
    display: flex;
    gap: 0;
    border-top: 1px solid #f0f0f0;
}

.action-link {
    flex: 1;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 6px;
    padding: 9px 12px;
    font-size: 12px;
    font-weight: 500;
    color: #65676b;
    text-decoration: none;
    transition: background 0.15s;
}
.action-link:hover {
    background: #f7f8fa;
    color: #333;
    text-decoration: none;
}
.action-link + .action-link {
    border-left: 1px solid #f0f0f0;
}
.action-link i {
    font-size: 14px;
}
.action-link:nth-child(1) i { color: #0a66c2; }
.action-link:nth-child(2) i { color: #7c3aed; }

/* ========== POST CARDS ========== */
.post-card {
    background: #fff;
    border: 1px solid #dbdbdb;
    border-radius: 8px;
    margin-bottom: 24px;
}

.post-header {
    display: flex;
    align-items: center;
    padding: 14px 16px;
    border-bottom: 1px solid #efefef;
}

.avatar {
    width: 42px;
    height: 42px;
    border-radius: 50%;
    object-fit: cover;
    margin-right: 12px;
}

.post-author {
    display: flex;
    align-items: center;
    text-decoration: none;
    flex: 1;
}

.author-info {
    display: flex;
    flex-direction: column;
}

.author-name {
    font-weight: 600;
    font-size: 14px;
    color: #262626;
}

.post-meta {
    display: flex;
    align-items: center;
    gap: 8px;
    margin-top: 2px;
}

.post-type {
    font-size: 10px;
    padding: 2px 6px;
    border-radius: 3px;
    color: #fff;
}

.post-time {
    font-size: 12px;
    color: #8e8e8e;
}

.post-menu {
    position: relative;
}

.menu-btn {
    background: none;
    border: none;
    padding: 8px;
    cursor: pointer;
    color: #262626;
}

.menu-dropdown {
    display: none;
    position: absolute;
    right: 0;
    top: 100%;
    background: #fff;
    border: 1px solid #dbdbdb;
    border-radius: 8px;
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    min-width: 150px;
    z-index: 100;
}

.menu-dropdown.show {
    display: block;
}

.menu-dropdown a {
    display: block;
    padding: 12px 16px;
    color: #262626;
    text-decoration: none;
    font-size: 14px;
}

.menu-dropdown a:hover {
    background: #fafafa;
}

.menu-dropdown a i {
    margin-right: 8px;
    width: 16px;
}

/* ========== POST CONTENT ========== */
.post-content {
    padding: 0 16px 12px;
}

.post-content p {
    margin: 0;
    font-size: 14px;
    line-height: 1.6;
    white-space: pre-wrap;
    color: #262626;
}

/* Post tags */
.post-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 5px;
    padding: 0 16px 12px;
}
.post-tag {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 2px 8px;
    border-radius: 10px;
    font-size: 10.5px;
    font-weight: 500;
    color: var(--tag-color, #6c757d);
    background: color-mix(in srgb, var(--tag-color, #6c757d) 8%, white);
}
.post-tag i { font-size: 9px; }

/* ========== POST ACTIONS (LIKE INSTAGRAM) ========== */
.post-actions {
    display: flex;
    padding: 8px 16px;
    border-top: 1px solid #efefef;
}

.action-btn {
    background: none;
    border: none;
    padding: 8px;
    cursor: pointer;
    display: flex;
    align-items: center;
    gap: 6px;
    font-size: 14px;
    color: #262626;
}

.action-btn:hover {
    color: #8e8e8e;
}

.action-btn i {
    font-size: 24px;
}

.action-btn.liked i {
    color: #ed4956;
}

.bookmark-btn {
    margin-left: auto;
}

.post-likes-summary {
    padding: 0 16px 12px;
    font-size: 14px;
}

/* ========== DETAIL CARDS ACCUEIL ========== */
.accueil-detail {
    margin: 0 16px 12px;
    border-radius: 10px;
    padding: 14px 16px;
    border: 1px solid #e8e8e8;
}
.accueil-detail-stage { background: #eaf4fd; border-left: 4px solid #3498db; }
.accueil-detail-emploi { background: #e8f5e9; border-left: 4px solid #2ecc71; }
.accueil-detail-activite { background: #fce4ec; border-left: 4px solid #e74c3c; }

.accueil-detail-head {
    display: flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 10px;
}
.accueil-detail-head strong { font-size: 14px; color: #1a1a2e; }
.accueil-detail-icon {
    width: 36px; height: 36px; border-radius: 8px;
    display: flex; align-items: center; justify-content: center;
    color: #fff; font-size: 16px; flex-shrink: 0;
}
.stage-bg { background: linear-gradient(135deg, #3498db, #2980b9); }
.emploi-bg { background: linear-gradient(135deg, #2ecc71, #27ae60); }
.activite-bg { background: linear-gradient(135deg, #e74c3c, #c0392b); }
.accueil-detail-sub { font-size: 12px; color: #666; }
.accueil-detail-sub i { margin-right: 3px; }

.accueil-detail-chips {
    display: flex; flex-wrap: wrap; gap: 6px; margin-bottom: 6px;
}
.achip {
    display: inline-flex; align-items: center; gap: 5px;
    padding: 4px 10px; background: rgba(255,255,255,0.8);
    border-radius: 16px; font-size: 12px; color: #444;
    border: 1px solid rgba(0,0,0,0.08);
}
.achip i { font-size: 12px; color: #888; }
.achip-hl { color: #e65100; font-weight: 600; background: #fff8e1; border-color: #ffe082; }
.achip-hl i { color: #e65100; }
.achip-ok { color: #2e7d32; background: #e8f5e9; border-color: #a5d6a7; }
.achip-ok i { color: #2e7d32; }

.accueil-detail-date {
    margin-top: 8px; padding: 6px 10px;
    background: rgba(255,255,255,0.7); border-radius: 6px;
    font-size: 12px; color: #555; border-left: 3px solid #0095f6;
}
.accueil-detail-date i { margin-right: 5px; color: #0095f6; }

.accueil-btn-apply {
    display: inline-flex; align-items: center; gap: 6px;
    margin-top: 10px; padding: 7px 18px;
    background: linear-gradient(135deg, #0095f6, #0077cc);
    color: #fff; text-decoration: none; border-radius: 6px;
    font-size: 13px; font-weight: 600;
    transition: all 0.2s;
}
.accueil-btn-apply:hover { background: linear-gradient(135deg, #0077cc, #005fa3); color: #fff; transform: translateY(-1px); }
.accueil-btn-inscrire { background: linear-gradient(135deg, #e74c3c, #c0392b); }
.accueil-btn-inscrire:hover { background: linear-gradient(135deg, #c0392b, #a93226); }

/* ========== MEDIA ACCUEIL ========== */
.accueil-media { overflow: hidden; }
.accueil-images { display: grid; gap: 2px; }
.accueil-images.single { grid-template-columns: 1fr; }
.accueil-images.double { grid-template-columns: 1fr 1fr; }
.accueil-images.multi { grid-template-columns: 1fr 1fr; }
.accueil-images img { width: 100%; max-height: 400px; object-fit: cover; display: block; }
.accueil-images.single img { max-height: 500px; }
.accueil-docs {
    padding: 10px 16px; display: flex; flex-direction: column; gap: 6px;
}
.accueil-doc-link {
    display: inline-flex; align-items: center; gap: 8px;
    padding: 8px 14px; background: #f5f5f5; border-radius: 6px;
    font-size: 13px; color: #333; text-decoration: none;
    border: 1px solid #e0e0e0; transition: background 0.2s;
}
.accueil-doc-link:hover { background: #eee; color: #000; }
.accueil-doc-link i { color: #666; }

/* ========== EMPTY STATE ========== */
.empty-state {
    text-align: center;
    padding: 60px 20px;
}

.empty-state i {
    font-size: 64px;
    color: #dbdbdb;
}

.empty-state h3 {
    margin: 20px 0 8px;
    color: #262626;
}

.empty-state p {
    color: #8e8e8e;
}

/* ========== PAGINATION ========== */
.pagination-wrapper {
    display: flex;
    justify-content: center;
    gap: 8px;
    padding: 20px 0;
}

.page-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 36px;
    height: 36px;
    border: 1px solid #dbdbdb;
    border-radius: 8px;
    color: #262626;
    text-decoration: none;
    font-size: 14px;
}

.page-btn:hover, .page-btn.active {
    background: #0095f6;
    border-color: #0095f6;
    color: #fff;
}

/* ========== SIDEBAR (FIXED) ========== */
.sidebar-profile {
    padding: 16px 0;
    border-bottom: 1px solid #efefef;
    margin-bottom: 12px;
}

.profile-link {
    display: flex;
    align-items: center;
    text-decoration: none;
}

.profile-avatar {
    width: 56px;
    height: 56px;
    border-radius: 50%;
    object-fit: cover;
    margin-right: 12px;
}

.profile-info {
    display: flex;
    flex-direction: column;
}

.profile-name {
    font-weight: 600;
    font-size: 14px;
    color: #262626;
}

.profile-subtitle {
    font-size: 12px;
    color: #8e8e8e;
}

.sidebar-section {
    margin-bottom: 20px;
}

.section-header {
    display: flex;
    justify-content: space-between;
    padding: 4px 0 12px;
}

.section-header span {
    font-weight: 600;
    font-size: 14px;
    color: #8e8e8e;
}

/* ========== STATS GRID ========== */
.stats-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 12px;
}

.stat-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 16px 8px;
    background: #fafafa;
    border-radius: 8px;
    text-decoration: none;
}

.stat-value {
    font-size: 20px;
    font-weight: 700;
    color: #262626;
}

.stat-value.has-notif {
    color: #ed4956;
}

.stat-label {
    font-size: 11px;
    color: #8e8e8e;
    margin-top: 4px;
    text-align: center;
}

/* ========== SIDEBAR NAV ========== */
.sidebar-nav a {
    display: flex;
    align-items: center;
    padding: 12px;
    text-decoration: none;
    color: #262626;
    font-size: 14px;
    border-radius: 8px;
    margin-bottom: 4px;
}

.sidebar-nav a:hover {
    background: #fafafa;
}

.sidebar-nav a i {
    width: 24px;
    font-size: 18px;
    margin-right: 12px;
    color: #262626;
}

.nav-badge {
    margin-left: auto;
    background: #ed4956;
    color: #fff;
    font-size: 11px;
    padding: 2px 8px;
    border-radius: 10px;
}

.badge-new {
    margin-left: auto;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #fff;
    font-size: 10px;
    padding: 2px 8px;
    border-radius: 10px;
    font-weight: 600;
}

.chat-link {
    background: linear-gradient(135deg, #f5f7fa 0%, #e8edf5 100%) !important;
    border-left: 3px solid #667eea !important;
}

.chat-link:hover {
    background: linear-gradient(135deg, #e8edf5 0%, #dce3f0 100%) !important;
}

.chat-link i {
    color: #667eea !important;
}

.sidebar-footer {
    padding-top: 20px;
    border-top: 1px solid #efefef;
}

.sidebar-footer p {
    font-size: 11px;
    color: #c7c7c7;
    margin: 0;
}

/* Sidebar topics */
.section-edit-link {
    color: #999;
    font-size: 12px;
    text-decoration: none;
    transition: color 0.15s;
}
.section-edit-link:hover { color: #0095f6; text-decoration: none; }
.section-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
}
.sidebar-topics {
    display: flex;
    flex-wrap: wrap;
    gap: 5px;
    margin-top: 8px;
}
.sidebar-topic-chip {
    display: inline-flex;
    align-items: center;
    gap: 4px;
    padding: 3px 8px;
    border-radius: 12px;
    font-size: 10.5px;
    font-weight: 500;
    color: var(--chip-color, #6c757d);
    background: color-mix(in srgb, var(--chip-color, #6c757d) 10%, white);
    border: 1px solid color-mix(in srgb, var(--chip-color, #6c757d) 20%, white);
}
.sidebar-topic-chip i { font-size: 10px; }
.sidebar-choose-interests {
    font-size: 12px;
    color: #0095f6;
    text-decoration: none;
    display: flex;
    align-items: center;
    gap: 4px;
}
.sidebar-choose-interests:hover { text-decoration: underline; }

/* ========== RESPONSIVE ========== */
@media (max-width: 992px) {
    .feed-sidebar {
        display: none;
    }
    .feed-main {
        max-width: 100%;
    }
    .feed-container {
        padding: 15px;
    }
}

/* ========== MODAL COMMENTAIRES ========== */
.comments-modal-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0, 0, 0, 0.6);
    z-index: 9999;
    justify-content: center;
    align-items: center;
}

.comments-modal-overlay.show {
    display: flex;
}

.comments-modal {
    background: #fff;
    border-radius: 12px;
    width: 90%;
    max-width: 500px;
    max-height: 80vh;
    display: flex;
    flex-direction: column;
    overflow: hidden;
    animation: modalSlideIn 0.2s ease;
}

@keyframes modalSlideIn {
    from { transform: translateY(-20px); opacity: 0; }
    to { transform: translateY(0); opacity: 1; }
}

.comments-modal-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 20px;
    border-bottom: 1px solid #efefef;
}

.comments-modal-header h3 {
    margin: 0;
    font-size: 16px;
    font-weight: 600;
}

.btn-close-modal {
    background: none;
    border: none;
    font-size: 20px;
    cursor: pointer;
    color: #262626;
    padding: 0;
    line-height: 1;
}

.comments-modal-body {
    flex: 1;
    overflow-y: auto;
    padding: 0;
    min-height: 200px;
    max-height: 400px;
}

.comments-list {
    padding: 8px 0;
}

.comment-item {
    display: flex;
    padding: 12px 20px;
    gap: 12px;
}

.comment-item:hover {
    background: #fafafa;
}

.comment-avatar {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    object-fit: cover;
    flex-shrink: 0;
}

.comment-content {
    flex: 1;
    min-width: 0;
}

.comment-author {
    font-weight: 600;
    font-size: 14px;
    color: #262626;
    margin-right: 8px;
}

.comment-text {
    font-size: 14px;
    color: #262626;
    line-height: 1.4;
    word-wrap: break-word;
}

.comment-meta {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-top: 4px;
}

.comment-date {
    font-size: 12px;
    color: #8e8e8e;
}

.btn-delete-comment {
    background: none;
    border: none;
    color: #ed4956;
    font-size: 12px;
    cursor: pointer;
    padding: 0;
}

.btn-delete-comment:hover {
    text-decoration: underline;
}

.comments-empty {
    text-align: center;
    padding: 40px 20px;
    color: #8e8e8e;
}

.comments-empty i {
    font-size: 48px;
    margin-bottom: 12px;
    display: block;
    opacity: 0.5;
}

.comments-loading {
    text-align: center;
    padding: 40px 20px;
    color: #8e8e8e;
}

.comments-modal-footer {
    padding: 12px 20px;
    border-top: 1px solid #efefef;
    display: flex;
    gap: 10px;
    align-items: center;
}

.comment-input {
    flex: 1;
    border: 1px solid #dbdbdb;
    border-radius: 22px;
    padding: 10px 16px;
    font-size: 14px;
    outline: none;
    resize: none;
    max-height: 80px;
    line-height: 1.4;
}

.comment-input:focus {
    border-color: #0095f6;
}

.btn-send-comment {
    background: #0095f6;
    color: #fff;
    border: none;
    border-radius: 50%;
    width: 36px;
    height: 36px;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}

.btn-send-comment:hover {
    background: #0081d6;
}

.btn-send-comment:disabled {
    background: #b2dffc;
    cursor: not-allowed;
}

/* ========== POPUP INTERESTS ========== */
.interests-overlay {
    position: fixed;
    inset: 0;
    background: rgba(0,0,0,0.55);
    z-index: 9999;
    display: flex;
    align-items: center;
    justify-content: center;
    animation: fadeIn 0.3s;
}
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
@keyframes slideUp { from { transform: translateY(30px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }

.interests-modal {
    background: #fff;
    border-radius: 16px;
    width: 580px;
    max-width: 92vw;
    max-height: 85vh;
    display: flex;
    flex-direction: column;
    box-shadow: 0 20px 60px rgba(0,0,0,0.2);
    animation: slideUp 0.4s;
    overflow: hidden;
}
.interests-header {
    padding: 28px 28px 16px;
    text-align: center;
    border-bottom: 1px solid #f0f0f0;
}
.interests-header h2 {
    font-size: 20px;
    color: #1a1a2e;
    margin: 0 0 6px;
    font-weight: 700;
}
.interests-header h2 i {
    color: #e74c3c;
    margin-right: 6px;
}
.interests-header p {
    color: #888;
    font-size: 13px;
    margin: 0;
}
.interests-body {
    padding: 20px 28px;
    overflow-y: auto;
    flex: 1;
}
.interests-grid {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 10px;
}
.interest-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 6px;
    padding: 14px 8px;
    border-radius: 12px;
    border: 2px solid #e8e8e8;
    cursor: pointer;
    transition: all 0.2s;
    position: relative;
    background: #fafafa;
}
.interest-card:hover {
    border-color: var(--card-color, #6c757d);
    background: color-mix(in srgb, var(--card-color, #6c757d) 5%, white);
    transform: translateY(-2px);
}
.interest-card.selected {
    border-color: var(--card-color, #6c757d);
    background: color-mix(in srgb, var(--card-color, #6c757d) 10%, white);
}
.interest-icon {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 15px;
    color: var(--card-color, #6c757d);
    background: color-mix(in srgb, var(--card-color, #6c757d) 12%, white);
    transition: all 0.2s;
}
.interest-card.selected .interest-icon {
    background: var(--card-color, #6c757d);
    color: #fff;
}
.interest-name {
    font-size: 11.5px;
    font-weight: 600;
    color: #555;
    text-align: center;
}
.interest-card.selected .interest-name {
    color: #333;
}
.interest-check {
    position: absolute;
    top: 6px;
    right: 6px;
    width: 20px;
    height: 20px;
    border-radius: 50%;
    background: var(--card-color, #6c757d);
    color: #fff;
    display: none;
    align-items: center;
    justify-content: center;
    font-size: 10px;
}
.interest-card.selected .interest-check {
    display: flex;
}
.interests-footer {
    padding: 16px 28px;
    border-top: 1px solid #f0f0f0;
    display: flex;
    align-items: center;
    gap: 12px;
    background: #fafafa;
}
.interests-counter {
    font-size: 12px;
    color: #888;
    font-weight: 500;
}
.btn-save-interests {
    flex: 1;
    padding: 10px 20px;
    border: none;
    border-radius: 8px;
    background: #0095f6;
    color: #fff;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
}
.btn-save-interests:hover:not(:disabled) {
    background: #0081d6;
}
.btn-save-interests:disabled {
    background: #b2dffc;
    cursor: not-allowed;
}
.btn-skip-interests {
    padding: 10px 16px;
    border: 1px solid #ddd;
    border-radius: 8px;
    background: #fff;
    color: #888;
    font-size: 12px;
    cursor: pointer;
    transition: all 0.2s;
}
.btn-skip-interests:hover {
    background: #f5f5f5;
    color: #333;
}
</style>

<!-- Modal Commentaires -->
<div id="commentsModal" class="comments-modal-overlay">
    <div class="comments-modal">
        <div class="comments-modal-header">
            <h3><i class="fa fa-comments"></i> Commentaires</h3>
            <button type="button" class="btn-close-modal" onclick="closeCommentsModal()">&times;</button>
        </div>
        <div class="comments-modal-body">
            <div id="commentsList" class="comments-list">
                <div class="comments-loading">
                    <i class="fa fa-spinner fa-spin"></i> Chargement...
                </div>
            </div>
        </div>
        <div class="comments-modal-footer">
            <textarea id="commentInput" class="comment-input" placeholder="Écrire un commentaire..." rows="1"></textarea>
            <button type="button" class="btn-send-comment" onclick="addComment()">
                <i class="fa fa-paper-plane"></i>
            </button>
        </div>
    </div>
</div>

<script>
var lien = '<%= lien %>';

function toggleMenu(postId) {
    var menu = document.getElementById('menu-' + postId);
    document.querySelectorAll('.menu-dropdown').forEach(function(m) {
        if (m !== menu) m.classList.remove('show');
    });
    menu.classList.toggle('show');
}

document.addEventListener('click', function(e) {
    if (!e.target.closest('.post-menu')) {
        document.querySelectorAll('.menu-dropdown').forEach(function(m) {
            m.classList.remove('show');
        });
    }
});

function likePost(postId) {
    window.location.href = '<%= lien %>?but=publication/apresPublication.jsp&acte=like&id=' + postId + '&bute=accueil.jsp';
}

function supprimerPost(postId) {
    if (!confirm('Supprimer cette publication ?')) return;
    window.location.href = '<%= lien %>?but=publication/apresPublication.jsp&acte=supprimer&id=' + postId + '&bute=accueil.jsp';
}

// ========== COMMENTAIRES ==========
var currentPostId = null;

function toggleComments(postId) {
    currentPostId = postId;
    document.getElementById('commentsModal').classList.add('show');
    document.getElementById('commentInput').value = '';
    loadComments(postId);
}

function closeCommentsModal() {
    document.getElementById('commentsModal').classList.remove('show');
    currentPostId = null;
}

// Fermer modal en cliquant à l'extérieur
document.getElementById('commentsModal').addEventListener('click', function(e) {
    if (e.target === this) {
        closeCommentsModal();
    }
});

// Fermer avec Echap
document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape' && document.getElementById('commentsModal').classList.contains('show')) {
        closeCommentsModal();
    }
});

function loadComments(postId) {
    var container = document.getElementById('commentsList');
    container.innerHTML = '<div class="comments-loading"><i class="fa fa-spinner fa-spin"></i> Chargement...</div>';
    
    $.ajax({
        url: lien + '?but=publication/apresPublication.jsp',
        type: 'POST',
        dataType: 'json',
        data: { acte: 'getComments', id: postId },
        success: function(response) {
            if (response.success && response.comments) {
                if (response.comments.length === 0) {
                    container.innerHTML = '<div class="comments-empty"><i class="fa fa-comment-o"></i>Aucun commentaire<br><small>Soyez le premier à commenter</small></div>';
                } else {
                    var html = '';
                    response.comments.forEach(function(c) {
                        html += '<div class="comment-item" id="comment-' + c.id + '">';
                        html += '<img src="' + c.photo + '" class="comment-avatar" onerror="this.src=\'<%= request.getContextPath() %>/assets/img/default-avatar.png\'">';
                        html += '<div class="comment-content">';
                        html += '<span class="comment-author">' + escapeHtml(c.nom) + '</span>';
                        html += '<span class="comment-text">' + escapeHtml(c.contenu) + '</span>';
                        html += '<div class="comment-meta">';
                        html += '<span class="comment-date">' + c.date + '</span>';
                        if (c.canDelete) {
                            html += '<button class="btn-delete-comment" onclick="deleteComment(\'' + c.id + '\')"><i class="fa fa-trash"></i> Supprimer</button>';
                        }
                        html += '</div></div></div>';
                    });
                    container.innerHTML = html;
                    // Scroll en bas
                    container.scrollTop = container.scrollHeight;
                }
            } else {
                container.innerHTML = '<div class="comments-empty"><i class="fa fa-exclamation-circle"></i>Erreur de chargement</div>';
            }
        },
        error: function() {
            container.innerHTML = '<div class="comments-empty"><i class="fa fa-exclamation-circle"></i>Erreur de connexion</div>';
        }
    });
}

function addComment() {
    var input = document.getElementById('commentInput');
    var contenu = input.value.trim();
    
    if (!contenu || !currentPostId) return;
    
    var btn = document.querySelector('.btn-send-comment');
    btn.disabled = true;
    
    $.ajax({
        url: lien + '?but=publication/apresPublication.jsp',
        type: 'POST',
        dataType: 'json',
        data: { acte: 'addComment', id: currentPostId, contenu: contenu },
        success: function(response) {
            btn.disabled = false;
            if (response.success) {
                input.value = '';
                loadComments(currentPostId);
                // Mettre à jour le compteur sur la page
                var countSpan = document.getElementById('comments-count-' + currentPostId);
                if (countSpan) {
                    countSpan.textContent = parseInt(countSpan.textContent || 0) + 1;
                }
            } else {
                alert(response.error || 'Erreur lors de l\'ajout');
            }
        },
        error: function() {
            btn.disabled = false;
            alert('Erreur de connexion');
        }
    });
}

function deleteComment(commentId) {
    if (!confirm('Supprimer ce commentaire ?')) return;
    
    $.ajax({
        url: lien + '?but=publication/apresPublication.jsp',
        type: 'POST',
        dataType: 'json',
        data: { acte: 'deleteComment', id: commentId, postId: currentPostId },
        success: function(response) {
            if (response.success) {
                var elem = document.getElementById('comment-' + commentId);
                if (elem) elem.remove();
                // Mettre à jour le compteur
                var countSpan = document.getElementById('comments-count-' + currentPostId);
                if (countSpan) {
                    countSpan.textContent = Math.max(0, parseInt(countSpan.textContent || 0) - 1);
                }
                // Vérifier s'il reste des commentaires
                var container = document.getElementById('commentsList');
                if (!container.querySelector('.comment-item')) {
                    container.innerHTML = '<div class="comments-empty"><i class="fa fa-comment-o"></i>Aucun commentaire<br><small>Soyez le premier à commenter</small></div>';
                }
            } else {
                alert(response.error || 'Erreur lors de la suppression');
            }
        },
        error: function() {
            alert('Erreur de connexion');
        }
    });
}

function escapeHtml(text) {
    var div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Enter pour envoyer commentaire
document.getElementById('commentInput').addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        addComment();
    }
});

// ========== FONCTIONS POUR LE FORMULAIRE DE PUBLICATION ==========

// --- Topic selector ---
function toggleTopicChips() {
    var container = document.getElementById('topicChipsContainer');
    var toggle = document.querySelector('.topic-toggle');
    if (container.style.display === 'none') {
        container.style.display = 'flex';
        toggle.classList.add('open');
    } else {
        container.style.display = 'none';
        toggle.classList.remove('open');
    }
}

function toggleChipStyle(checkbox) {
    var chip = checkbox.closest('.topic-chip');
    if (checkbox.checked) {
        chip.classList.add('selected');
    } else {
        chip.classList.remove('selected');
    }
}

function autoResize(textarea) {
    textarea.style.height = 'auto';
    textarea.style.height = Math.min(textarea.scrollHeight, 120) + 'px';
}

function previewFile(input) {
    var container = document.getElementById('file-preview-container');
    var nameSpan = document.getElementById('file-preview-name');
    var iconElem = container.querySelector('.file-icon');
    var placeholder = document.getElementById('file-drop-placeholder');
    var previewImg = document.getElementById('file-preview-img');
    
    if (input.files && input.files[0]) {
        var file = input.files[0];
        nameSpan.textContent = file.name;
        
        var ext = file.name.split('.').pop().toLowerCase();
        var iconClass = 'fa-file';
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].includes(ext)) {
            iconClass = 'fa-image';
        } else if (ext === 'pdf') {
            iconClass = 'fa-file-pdf-o';
        } else if (['doc', 'docx'].includes(ext)) {
            iconClass = 'fa-file-word-o';
        } else if (['xls', 'xlsx'].includes(ext)) {
            iconClass = 'fa-file-excel-o';
        } else if (['ppt', 'pptx'].includes(ext)) {
            iconClass = 'fa-file-powerpoint-o';
        }
        iconElem.className = 'fa ' + iconClass + ' file-icon';
        
        // Image preview
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].includes(ext)) {
            var reader = new FileReader();
            reader.onload = function(e) {
                previewImg.src = e.target.result;
                previewImg.style.display = 'block';
            };
            reader.readAsDataURL(file);
        } else {
            previewImg.style.display = 'none';
        }
        
        placeholder.style.display = 'none';
        container.style.display = 'block';
    } else {
        placeholder.style.display = 'flex';
        container.style.display = 'none';
        previewImg.style.display = 'none';
    }
}

function removeFile() {
    var input = document.getElementById('fileInput');
    input.value = '';
    document.getElementById('file-preview-container').style.display = 'none';
    document.getElementById('file-preview-img').style.display = 'none';
    document.getElementById('file-drop-placeholder').style.display = 'flex';
}

// ========== POPUP INTERESTS ==========
function toggleInterest(card) {
    card.classList.toggle('selected');
    var count = document.querySelectorAll('.interest-card.selected').length;
    document.getElementById('selectedCount').textContent = count;
    document.getElementById('btnSaveInterests').disabled = (count === 0);
}

function saveInterests() {
    var selectedCards = document.querySelectorAll('.interest-card.selected');
    if (selectedCards.length === 0) return;
    
    var topicIds = [];
    selectedCards.forEach(function(card) {
        topicIds.push(card.getAttribute('data-topic-id'));
    });
    
    // Envoyer via AJAX
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '<%= lien %>?but=publication/apresInterets.jsp&acte=saveInterets&topics=' + topicIds.join(','), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4) {
            document.getElementById('interestsOverlay').style.display = 'none';
            if (xhr.status === 200) {
                // Recharger pour appliquer le filtrage
                document.location.replace('<%= lien %>?but=accueil.jsp');
            }
        }
    };
    xhr.send();
}

function skipInterests() {
    document.getElementById('interestsOverlay').style.display = 'none';
}
</script>

<%
} catch (Exception e) {
    e.printStackTrace();
%>
<div class="alert alert-danger">
    <i class="fa fa-exclamation-triangle"></i> Erreur: <%= e.getMessage() %>
</div>
<% } %>
