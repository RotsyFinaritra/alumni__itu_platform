<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*, utilitaire.Utilitaire, utilitaire.UtilDB, java.util.*, java.text.SimpleDateFormat, java.sql.*" %>
<%@ page import="user.UserEJB, utilisateurAcade.UtilisateurAcade, utilisateurAcade.UtilisateurPg" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    if (u == null || lien == null) {
        response.sendRedirect("security-login.jsp");
        return;
    }
    
    int refuserInt = u.getUser().getRefuser();
    String nomUser = u.getUser().getNomuser() != null ? u.getUser().getNomuser() : "";
    String loginUser = u.getUser().getLoginuser() != null ? u.getUser().getLoginuser() : "";
    
    // === RÉCUPÉRER L'UTILISATEUR CONNECTÉ (prenom, photo via UtilisateurAcade) ===
    String prenomUser = "";
    String nomCompletUser = "";
    String defaultAvatar = request.getContextPath() + "/assets/img/user-placeholder.svg";
    String photoUser = defaultAvatar;
    String roleSubtitle = "Membre Alumni ITU"; // Par défaut
    UtilisateurAcade userCritere = new UtilisateurAcade();
    // Ne pas utiliser setters car CGenUtil applique UPPER() qui échoue sur integers
    Object[] userResult = CGenUtil.rechercher(userCritere, null, null, " AND refuser = " + refuserInt);
    boolean isEtudiant = false;
    if (userResult != null && userResult.length > 0) {
        UtilisateurAcade userInfo = (UtilisateurAcade) userResult[0];
        prenomUser = userInfo.getPrenom() != null ? userInfo.getPrenom() : "";
        nomUser = userInfo.getNomuser() != null ? userInfo.getNomuser() : "";
        nomCompletUser = ((prenomUser + " " + nomUser).trim());
        if (userInfo.getPhoto() != null && !userInfo.getPhoto().isEmpty()) {
            String photoFileName = userInfo.getPhoto();
            if (photoFileName.contains("/")) {
                photoFileName = photoFileName.substring(photoFileName.lastIndexOf("/") + 1);
            }
            // Si c'est la photo par défaut, utiliser le chemin statique
            if ("user-placeholder.svg".equals(photoFileName)) {
                photoUser = defaultAvatar;
            } else {
                photoUser = request.getContextPath() + "/profile-photo?file=" + photoFileName;
            }
        }
        // Déterminer le sous-titre selon le type d'utilisateur
        String typeUtilisateur = userInfo.getIdtypeutilisateur();
        if ("TU0000001".equals(typeUtilisateur)) {
            roleSubtitle = "Ancien Étudiant (Alumni)";
        } else if ("TU0000002".equals(typeUtilisateur)) {
            roleSubtitle = "Étudiant";
            isEtudiant = true;
        } else if ("TU0000003".equals(typeUtilisateur)) {
            roleSubtitle = "Enseignant";
        } else {
            roleSubtitle = "Administrateur";
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
        <% if (!isEtudiant) { %>
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
                    <textarea name="contenu" class="create-input" placeholder="Quoi de neuf, <%= nomCompletUser %> ?" required rows="1" oninput="autoResize(this)"></textarea>
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
        <% } %>
        
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
                
                // Charger l'auteur via UtilisateurPg (pour loginuser)
                String nomComplet = "Utilisateur";
                String photoAuteur = request.getContextPath() + "/assets/img/user-placeholder.svg";
                UtilisateurPg auteurPg = new UtilisateurPg();
                auteurPg.setRefuser(postAuteurId);
                Object[] auteurResult = CGenUtil.rechercher(auteurPg, null, null, " AND refuser = " + postAuteurId);
                if (auteurResult != null && auteurResult.length > 0) {
                    UtilisateurPg auteur = (UtilisateurPg) auteurResult[0];
                    nomComplet = ((auteur.getPrenom() != null ? auteur.getPrenom() + " " : "") + 
                                (auteur.getNomuser() != null ? auteur.getNomuser() : "")).trim();
                    if (nomComplet.isEmpty()) nomComplet = "Utilisateur";
                    if (auteur.getPhoto() != null && !auteur.getPhoto().isEmpty()) {
                        String auteurPhotoFile = auteur.getPhoto();
                        if (auteurPhotoFile.contains("/")) {
                            auteurPhotoFile = auteurPhotoFile.substring(auteurPhotoFile.lastIndexOf("/") + 1);
                        }
                        if ("user-placeholder.svg".equals(auteurPhotoFile)) {
                            photoAuteur = request.getContextPath() + "/assets/img/user-placeholder.svg";
                        } else {
                            photoAuteur = request.getContextPath() + "/profile-photo?file=" + auteurPhotoFile;
                        }
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
                        <span class="profile-name"><%= nomCompletUser %></span>
                        <span class="profile-subtitle"><%= roleSubtitle %></span>
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
            <h2><i class="fa fa-heart"></i> Bienvenue, <%= nomCompletUser %> !</h2>
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

<link href="${pageContext.request.contextPath}/assets/css/accueil.css" rel="stylesheet" type="text/css" />

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
    // Animation du cœur avant redirection
    var btn = document.getElementById('like-btn-' + postId);
    if (btn) {
        var icon = btn.querySelector('i');
        if (icon) {
            icon.classList.add('heart-animating');
        }
    }
    // Redirection avec petit délai pour voir l'animation
    setTimeout(function() {
        window.location.href = '<%= lien %>?but=publication/apresPublication.jsp&acte=like&id=' + postId + '&bute=accueil.jsp';
    }, 150);
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
