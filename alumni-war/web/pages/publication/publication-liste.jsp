<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*, utilitaire.Utilitaire, java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="user.UserEJB, utilisateurAcade.UtilisateurAcade, utilisateurAcade.UtilisateurPg" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    if (u == null || lien == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int refuserInt = Integer.parseInt(u.getUser().getTuppleID());
    
    // Parametres de filtrage
    String typePublicationFilter = request.getParameter("type");
    String visibiliteFilter = request.getParameter("visibilite");
    String searchQuery = request.getParameter("q");
    int currentPage = 1;
    try { 
        currentPage = Integer.parseInt(request.getParameter("page")); 
    } catch (Exception ignored) {}
    int postsPerPage = 10;
    
    // Construire le WHERE dynamique
    StringBuilder apresWhere = new StringBuilder(" AND idstatutpublication = 'STPU00001'");
    
    if (typePublicationFilter != null && !typePublicationFilter.isEmpty()) {
        apresWhere.append(" AND idtypepublication = '").append(typePublicationFilter).append("'");
    }
    if (visibiliteFilter != null && !visibiliteFilter.isEmpty()) {
        apresWhere.append(" AND idvisibilite = '").append(visibiliteFilter).append("'");
    }
    if (searchQuery != null && !searchQuery.trim().isEmpty()) {
        apresWhere.append(" AND LOWER(contenu) LIKE '%").append(searchQuery.toLowerCase()).append("%'");
    }
    
    apresWhere.append(" ORDER BY created_at DESC LIMIT ").append(postsPerPage)
               .append(" OFFSET ").append((currentPage - 1) * postsPerPage);
    
    // Charger les posts via la vue v_posts_complets
    Post postFilter = new Post();
    postFilter.setNomTable("v_posts_complets");
    Object[] posts = CGenUtil.rechercher(postFilter, null, null, apresWhere.toString());
    
    // Compter le total pour pagination
    String countWhere = apresWhere.toString().replaceAll(" ORDER BY.*", "");
    postFilter = new Post();
    Object[] allPosts = CGenUtil.rechercher(postFilter, null, null, countWhere);
    int totalPosts = (allPosts != null) ? allPosts.length : 0;
    int totalPages = (int) Math.ceil((double) totalPosts / postsPerPage);
    
    // Charger les donnees de reference
    TypePublication[] typesPublication = (TypePublication[]) CGenUtil.rechercher(new TypePublication(), null, null, " AND actif = 1 ORDER BY ordre");
    VisibilitePublication[] visibilites = (VisibilitePublication[]) CGenUtil.rechercher(new VisibilitePublication(), null, null, " AND actif = 1 ORDER BY ordre");
    
    // Charger les fichiers pour tous les posts
    // (on chargera par post dans la boucle)
%>

<%!
    public String formatTempsRelatif(java.sql.Timestamp date) {
        if (date == null) return "";
        long diff = System.currentTimeMillis() - date.getTime();
        long seconds = diff / 1000;
        long minutes = seconds / 60;
        long hours = minutes / 60;
        long days = hours / 24;
        if (days > 7) return new java.text.SimpleDateFormat("dd/MM/yyyy").format(date);
        else if (days > 0) return "Il y a " + days + " jour" + (days > 1 ? "s" : "");
        else if (hours > 0) return "Il y a " + hours + " heure" + (hours > 1 ? "s" : "");
        else if (minutes > 0) return "Il y a " + minutes + " minute" + (minutes > 1 ? "s" : "");
        else return "&Agrave; l'instant";
    }
%>

<div class="content-wrapper">
    <section class="content">
        <div class="feed-container">

    <!-- ========== FIL PRINCIPAL ========== -->
    <div class="feed-main">

        <!-- En-tete + filtres -->
        <div class="post-card" style="padding: 16px;">
            <form method="get" action="<%= lien %>" style="margin: 0;">
                <input type="hidden" name="but" value="publication/publication-liste.jsp">
                <div style="display: flex; align-items: center; gap: 10px; flex-wrap: wrap;">
                    <select name="type" class="form-control" style="width: auto; min-width: 150px;" onchange="this.form.submit()">
                        <option value="">Tous les types</option>
                        <% if (typesPublication != null) {
                            for (TypePublication tp : typesPublication) { %>
                        <option value="<%= tp.getId() %>" <%= (tp.getId().equals(typePublicationFilter)) ? "selected" : "" %>>
                            <%= tp.getLibelle() %>
                        </option>
                        <% }
                        } %>
                    </select>
                    <select name="visibilite" class="form-control" style="width: auto; min-width: 150px;" onchange="this.form.submit()">
                        <option value="">Toutes visibilit&eacute;s</option>
                        <% if (visibilites != null) {
                            for (VisibilitePublication vp : visibilites) { %>
                        <option value="<%= vp.getId() %>" <%= (vp.getId().equals(visibiliteFilter)) ? "selected" : "" %>>
                            <%= vp.getLibelle() %>
                        </option>
                        <% }
                        } %>
                    </select>
                    <div style="flex: 1; min-width: 180px; position: relative;">
                        <input type="text" name="q" class="form-control" placeholder="Rechercher..." 
                               value="<%= (searchQuery != null) ? searchQuery : "" %>">
                    </div>
                    <button type="submit" class="btn btn-primary btn-sm"><i class="fa fa-search"></i></button>
                    <% if (typePublicationFilter != null || visibiliteFilter != null || searchQuery != null) { %>
                    <a href="<%= lien %>?but=publication/publication-liste.jsp" class="btn btn-default btn-sm" title="R&eacute;initialiser">
                        <i class="fa fa-times"></i>
                    </a>
                    <% } %>
                </div>
            </form>
        </div>
        
        <!-- Feed -->
        <% if (posts == null || posts.length == 0) { %>
        <div class="post-card empty-state">
            <i class="fa fa-camera-retro"></i>
            <h3>Aucune publication trouv&eacute;e</h3>
            <p>Soyez le premier &agrave; publier quelque chose !</p>
            <a href="<%= lien %>?but=publication/publication-saisie.jsp" class="accueil-btn-apply">
                <i class="fa fa-plus"></i> Cr&eacute;er une publication
            </a>
        </div>
        <% } else {
            for (Object o : posts) {
                Post post = (Post) o;
                String postId = post.getId();
                
                // Charger l'auteur
                String nomAuteur = "Utilisateur inconnu";
                String photoAuteur = request.getContextPath() + "/assets/img/user-placeholder.svg";
                UtilisateurPg auteurPg = new UtilisateurPg();
                Object[] auteurResult = CGenUtil.rechercher(auteurPg, null, null, " AND refuser = " + post.getIdutilisateur());
                if (auteurResult != null && auteurResult.length > 0) {
                    UtilisateurPg auteurInfo = (UtilisateurPg) auteurResult[0];
                    nomAuteur = ((auteurInfo.getPrenom() != null ? auteurInfo.getPrenom() + " " : "") + 
                                (auteurInfo.getNomuser() != null ? auteurInfo.getNomuser() : "")).trim();
                    if (nomAuteur.isEmpty()) nomAuteur = "Utilisateur inconnu";
                    if (auteurInfo.getPhoto() != null && !auteurInfo.getPhoto().isEmpty()) {
                        String pFile = auteurInfo.getPhoto();
                        if (pFile.contains("/")) pFile = pFile.substring(pFile.lastIndexOf("/") + 1);
                        if (!"user-placeholder.svg".equals(pFile)) {
                            photoAuteur = request.getContextPath() + "/profile-photo?file=" + pFile;
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
                
                // Charger les details selon le type
                PostStage postStage = null;
                PostEmploi postEmploi = null;
                PostActivite postActivite = null;
                String entrepriseNom = "";
                
                if ("TYP00001".equals(post.getIdtypepublication())) {
                    PostStage sf = new PostStage(); sf.setPost_id(postId);
                    Object[] sr = CGenUtil.rechercher(sf, null, null, "");
                    if (sr != null && sr.length > 0) {
                        postStage = (PostStage) sr[0];
                        if (postStage.getEntreprise() != null) entrepriseNom = postStage.getEntreprise();
                    }
                } else if ("TYP00002".equals(post.getIdtypepublication())) {
                    PostEmploi ef = new PostEmploi(); ef.setPost_id(postId);
                    Object[] er = CGenUtil.rechercher(ef, null, null, "");
                    if (er != null && er.length > 0) {
                        postEmploi = (PostEmploi) er[0];
                        if (postEmploi.getEntreprise() != null) entrepriseNom = postEmploi.getEntreprise();
                    }
                } else if ("TYP00003".equals(post.getIdtypepublication())) {
                    PostActivite af = new PostActivite(); af.setPost_id(postId);
                    Object[] ar = CGenUtil.rechercher(af, null, null, "");
                    if (ar != null && ar.length > 0) {
                        postActivite = (PostActivite) ar[0];
                    }
                }
                
                // Charger les fichiers attaches
                PostFichier fichierFilter = new PostFichier();
                fichierFilter.setPost_id(postId);
                Object[] fichiersResult = CGenUtil.rechercher(fichierFilter, null, null, " ORDER BY ordre");
                
                // Verifier si l'utilisateur a deja like
                Like likeChk = new Like();
                Object[] likeChkRes = CGenUtil.rechercher(likeChk, null, null, " AND post_id = '" + postId + "' AND idutilisateur = " + refuserInt);
                boolean hasLiked = (likeChkRes != null && likeChkRes.length > 0);
                
                int nbLikes = post.getNb_likes();
                int nbComments = post.getNb_commentaires();
        %>
        
        <!-- Publication -->
        <div class="post-card">
            <div class="post-header">
                <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= post.getIdutilisateur() %>" class="post-author">
                    <img class="avatar" src="<%= photoAuteur %>" alt="Photo">
                    <div class="author-info">
                        <span class="author-name"><%= nomAuteur %></span>
                        <span class="post-meta">
                            <span class="post-type" style="background-color: <%= typeCouleur %>;">
                                <i class="fa <%= typeIcon %>"></i> <%= typeLibelle %>
                            </span>
                            <span class="post-time"><%= formatTempsRelatif(post.getCreated_at()) %></span>
                        </span>
                    </div>
                </a>
                <div class="post-menu">
                    <button class="menu-btn" onclick="toggleMenu('<%= postId %>')">
                        <i class="fa fa-ellipsis-h"></i>
                    </button>
                    <div class="menu-dropdown" id="menu-<%= postId %>">
                        <a href="<%= lien %>?but=publication/publication-fiche.jsp&id=<%= postId %>">
                            <i class="fa fa-eye"></i> Voir d&eacute;tails
                        </a>
                        <% if (post.getIdutilisateur() == refuserInt) { %>
                        <a href="<%= lien %>?but=publication/publication-modif.jsp&id=<%= postId %>">
                            <i class="fa fa-edit"></i> Modifier
                        </a>
                        <% } else { %>
                        <a href="<%= lien %>?but=publication/signalement-saisie.jsp&post_id=<%= postId %>">
                            <i class="fa fa-flag" style="color:#e74c3c"></i> Signaler
                        </a>
                        <% } %>
                    </div>
                </div>
            </div>

            <div class="post-content">
                <p><%= post.getContenu() != null ? post.getContenu() : "" %></p>
            </div>
            
            <!-- Details Stage -->
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
            
            <!-- Details Emploi -->
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
                        <%= (postEmploi.getSalaire_max() > 0 ? String.format("%,.0f", postEmploi.getSalaire_max()) : "") %> Ar
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
            
            <!-- Details Activite -->
            <% if (postActivite != null) { %>
            <div class="accueil-detail accueil-detail-activite">
                <div class="accueil-detail-head">
                    <span class="accueil-detail-icon activite-bg"><i class="fa fa-calendar"></i></span>
                    <div>
                        <strong><%= postActivite.getTitre() != null && !postActivite.getTitre().isEmpty() ? postActivite.getTitre() : "&Eacute;v&eacute;nement" %></strong>
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
            
            <!-- Fichiers attaches -->
            <% if (fichiersResult != null && fichiersResult.length > 0) {
                java.util.List<PostFichier> images = new java.util.ArrayList<PostFichier>();
                java.util.List<PostFichier> docs = new java.util.ArrayList<PostFichier>();
                for (Object fObj : fichiersResult) {
                    PostFichier pf = (PostFichier) fObj;
                    String mime = pf.getMime_type() != null ? pf.getMime_type() : "";
                    if (mime.startsWith("image/")) images.add(pf);
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
                <button class="action-btn" onclick="sharePost('<%= postId %>')">
                    <i class="fa fa-paper-plane-o"></i>
                    <span><%= post.getNb_partages() %></span>
                </button>
                <button class="action-btn bookmark-btn">
                    <i class="fa fa-bookmark-o"></i>
                </button>
            </div>
            <% if (nbLikes > 0) { %>
            <div class="post-likes-summary">
                <strong><%= nbLikes %> J'aime<%= nbLikes > 1 ? "s" : "" %></strong>
            </div>
            <% } %>
        </div>
        
        <% }
        } %>
        
        <!-- Pagination -->
        <% if (totalPages > 1) { %>
        <div class="pagination-wrapper">
            <% if (currentPage > 1) { %>
            <a href="<%= lien %>?but=publication/publication-liste.jsp&page=<%= currentPage - 1 %><%= (typePublicationFilter != null ? "&type=" + typePublicationFilter : "") %><%= (visibiliteFilter != null ? "&visibilite=" + visibiliteFilter : "") %><%= (searchQuery != null ? "&q=" + searchQuery : "") %>" class="page-btn">
                <i class="fa fa-chevron-left"></i>
            </a>
            <% } %>
            <% for (int i = Math.max(1, currentPage - 2); i <= Math.min(totalPages, currentPage + 2); i++) { %>
            <a href="<%= lien %>?but=publication/publication-liste.jsp&page=<%= i %><%= (typePublicationFilter != null ? "&type=" + typePublicationFilter : "") %><%= (visibiliteFilter != null ? "&visibilite=" + visibiliteFilter : "") %><%= (searchQuery != null ? "&q=" + searchQuery : "") %>" class="page-btn <%= (i == currentPage) ? "active" : "" %>">
                <%= i %>
            </a>
            <% } %>
            <% if (currentPage < totalPages) { %>
            <a href="<%= lien %>?but=publication/publication-liste.jsp&page=<%= currentPage + 1 %><%= (typePublicationFilter != null ? "&type=" + typePublicationFilter : "") %><%= (visibiliteFilter != null ? "&visibilite=" + visibiliteFilter : "") %><%= (searchQuery != null ? "&q=" + searchQuery : "") %>" class="page-btn">
                <i class="fa fa-chevron-right"></i>
            </a>
            <% } %>
        </div>
        <% } %>
        
    </div>
    
    <!-- ========== SIDEBAR DROITE ========== -->
    <div class="feed-sidebar">
        <div class="sidebar-inner">
            <!-- Bouton creer publication -->
            <a href="<%= lien %>?but=publication/publication-saisie.jsp" class="accueil-btn-apply" style="display: block; text-align: center; margin-bottom: 16px; padding: 12px 18px; border-radius: 10px; font-size: 14px;">
                <i class="fa fa-plus"></i> Nouvelle publication
            </a>
            
            <!-- Raccourcis -->
            <div class="sidebar-section">
                <div class="section-header">
                    <span>Raccourcis</span>
                </div>
                <nav class="sidebar-nav">
                    <a href="<%= lien %>?but=accueil.jsp">
                        <i class="fa fa-home"></i> Accueil
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
                </nav>
            </div>
            
            <!-- Filtres actifs -->
            <% if (typePublicationFilter != null || visibiliteFilter != null || searchQuery != null) { %>
            <div class="sidebar-section">
                <div class="section-header">
                    <span>Filtres actifs</span>
                </div>
                <div style="padding: 10px 0; font-size: 13px; color: #555;">
                    <% if (typePublicationFilter != null && !typePublicationFilter.isEmpty()) { %>
                    <div style="margin-bottom: 6px;"><i class="fa fa-tag"></i> Type: <strong><%= typePublicationFilter %></strong></div>
                    <% } %>
                    <% if (visibiliteFilter != null && !visibiliteFilter.isEmpty()) { %>
                    <div style="margin-bottom: 6px;"><i class="fa fa-eye"></i> Visibilit&eacute;: <strong><%= visibiliteFilter %></strong></div>
                    <% } %>
                    <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
                    <div style="margin-bottom: 6px;"><i class="fa fa-search"></i> &laquo; <%= searchQuery %> &raquo;</div>
                    <% } %>
                    <a href="<%= lien %>?but=publication/publication-liste.jsp" style="color: #e74c3c; font-size: 12px;">
                        <i class="fa fa-times"></i> R&eacute;initialiser les filtres
                    </a>
                </div>
            </div>
            <% } %>
            
            <!-- Statistiques -->
            <div class="sidebar-section">
                <div class="section-header">
                    <span>R&eacute;sultats</span>
                </div>
                <div style="padding: 10px 0; font-size: 13px; color: #555;">
                    <strong><%= totalPosts %></strong> publication<%= totalPosts > 1 ? "s" : "" %> trouv&eacute;e<%= totalPosts > 1 ? "s" : "" %>
                    <% if (totalPages > 1) { %>
                    <br>Page <strong><%= currentPage %></strong> / <strong><%= totalPages %></strong>
                    <% } %>
                </div>
            </div>
        </div>
    </div>

        </div>
    </section>
</div>

<link href="${pageContext.request.contextPath}/assets/css/accueil.css" rel="stylesheet" type="text/css" />

<script>
function toggleMenu(postId) {
    var menu = document.getElementById('menu-' + postId);
    // Fermer tous les autres menus
    var allMenus = document.querySelectorAll('.menu-dropdown');
    for (var i = 0; i < allMenus.length; i++) {
        if (allMenus[i].id !== 'menu-' + postId) {
            allMenus[i].classList.remove('show');
        }
    }
    menu.classList.toggle('show');
}

// Fermer les menus en cliquant ailleurs
document.addEventListener('click', function(e) {
    if (!e.target.closest('.post-menu')) {
        var allMenus = document.querySelectorAll('.menu-dropdown');
        for (var i = 0; i < allMenus.length; i++) {
            allMenus[i].classList.remove('show');
        }
    }
});

function likePost(postId) {
    var btn = document.getElementById('like-btn-' + postId);
    var icon = btn.querySelector('i');
    var countSpan = document.getElementById('likes-' + postId);
    var isLiked = btn.classList.contains('liked');
    
    // Mise a jour visuelle immédiate
    if (isLiked) {
        btn.classList.remove('liked');
        icon.className = 'fa fa-heart-o';
        countSpan.textContent = Math.max(0, parseInt(countSpan.textContent) - 1);
    } else {
        btn.classList.add('liked');
        icon.className = 'fa fa-heart';
        icon.classList.add('heart-animating');
        countSpan.textContent = parseInt(countSpan.textContent) + 1;
        setTimeout(function() { icon.classList.remove('heart-animating'); }, 500);
    }
    
    // Appel serveur
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '<%= lien %>?but=publication/apresPublication.jsp&acte=like&id=' + postId + '&bute=publication/publication-liste.jsp&ajax=1', true);
    xhr.send();
}

function sharePost(postId) {
    if (confirm('Partager cette publication ?')) {
        window.location.href = '<%= lien %>?but=publication/apresPublication.jsp&acte=share&id=' + postId + '&bute=publication/publication-liste.jsp';
    }
}
</script>

<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='callout callout-danger'><h4><i class='fa fa-ban'></i> Erreur</h4><p>" + e.getMessage() + "</p></div>");
} %>
