<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*, utilitaire.Utilitaire, java.util.*, java.text.SimpleDateFormat" %>
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
    String idrole = u.getUser().getIdrole() != null ? u.getUser().getIdrole() : "";
    boolean isAdmin = "admin".equalsIgnoreCase(idrole) || "enseignant".equalsIgnoreCase(idrole);
    
    // === RÉCUPÉRER L'UTILISATEUR CONNECTÉ ===
    String prenomUser = "";
    String photoUser = request.getContextPath() + "/assets/img/default-avatar.png";
    String userPromoId = "";
    UtilisateurAcade userCritere = new UtilisateurAcade();
    Object[] userResult = CGenUtil.rechercher(userCritere, null, null, " AND refuser = " + refuserInt);
    if (userResult != null && userResult.length > 0) {
        UtilisateurAcade userInfo = (UtilisateurAcade) userResult[0];
        prenomUser = userInfo.getPrenom() != null ? userInfo.getPrenom() : "";
        userPromoId = userInfo.getIdpromotion() != null ? userInfo.getIdpromotion() : "";
        if (userInfo.getPhoto() != null && !userInfo.getPhoto().isEmpty()) {
            String photoFileName = userInfo.getPhoto();
            if (photoFileName.contains("/")) {
                photoFileName = photoFileName.substring(photoFileName.lastIndexOf("/") + 1);
            }
            photoUser = request.getContextPath() + "/profile-photo?file=" + photoFileName;
        }
    }
    
    // === SÉLECTION DE LA PROMOTION ===
    // Admin/enseignant peut choisir une promotion, sinon on utilise celle de l'utilisateur
    String selectedPromoId = request.getParameter("promo");
    if (selectedPromoId == null || selectedPromoId.isEmpty()) {
        selectedPromoId = userPromoId;
    }
    // Si pas admin/enseignant, forcer la promo de l'utilisateur
    if (!isAdmin) {
        selectedPromoId = userPromoId;
    }
    
    // Charger toutes les promotions (pour le sélecteur admin)
    Promotion[] allPromos = null;
    if (isAdmin) {
        Object[] promosResult = CGenUtil.rechercher(new Promotion(), null, null, " ORDER BY annee DESC, libelle");
        if (promosResult != null) {
            allPromos = new Promotion[promosResult.length];
            for (int i = 0; i < promosResult.length; i++) allPromos[i] = (Promotion) promosResult[i];
        }
    }
    
    // === TROUVER LE GROUPE DE LA PROMOTION ===
    String groupeId = null;
    String promoNom = "";
    int promoAnnee = 0;
    
    if (selectedPromoId != null && !selectedPromoId.isEmpty()) {
        // Charger la promotion
        Object[] promoResult = CGenUtil.rechercher(new Promotion(), null, null, " AND id = '" + selectedPromoId + "'");
        if (promoResult != null && promoResult.length > 0) {
            Promotion promo = (Promotion) promoResult[0];
            promoNom = promo.getLibelle() != null ? promo.getLibelle() : "";
            promoAnnee = promo.getAnnee();
        }
        
        // Chercher le groupe lié à cette promotion
        Object[] groupeResult = CGenUtil.rechercher(new Groupe(), null, null, " AND idpromotion = '" + selectedPromoId + "' AND actif = 1");
        if (groupeResult != null && groupeResult.length > 0) {
            Groupe grp = (Groupe) groupeResult[0];
            groupeId = grp.getId();
        }
    }
    
    // === VÉRIFIER L'ACCÈS AU GROUPE ===
    boolean isMember = false;
    if (groupeId != null) {
        Object[] membreCheck = CGenUtil.rechercher(new GroupeMembre(), null, null, 
            " AND idutilisateur = " + refuserInt + " AND idgroupe = '" + groupeId + "' AND statut = 'actif'");
        isMember = (membreCheck != null && membreCheck.length > 0);
    }
    // Admin/enseignant a toujours accès
    if (isAdmin) isMember = true;
    
    // Compter les membres du groupe
    int nbMembres = 0;
    if (groupeId != null) {
        Object[] membresResult = CGenUtil.rechercher(new GroupeMembre(), null, null, " AND idgroupe = '" + groupeId + "' AND statut = 'actif'");
        nbMembres = (membresResult != null) ? membresResult.length : 0;
    }
    
    // === CHARGER LES PUBLICATIONS DU GROUPE ===
    int currentPage = 1;
    try { currentPage = Integer.parseInt(request.getParameter("page")); } catch (Exception ignored) {}
    int postsPerPage = 10;
    
    Object[] postsResult = null;
    int totalPosts = 0;
    int totalPages = 0;
    
    if (groupeId != null && isMember) {
        String apresWherePost = " AND idgroupe = '" + groupeId + "' AND supprime = 0 ORDER BY epingle DESC, created_at DESC LIMIT " 
            + postsPerPage + " OFFSET " + ((currentPage - 1) * postsPerPage);
        postsResult = CGenUtil.rechercher(new Post(), null, null, apresWherePost);
        
        Object[] allPostsResult = CGenUtil.rechercher(new Post(), null, null, " AND idgroupe = '" + groupeId + "' AND supprime = 0");
        totalPosts = (allPostsResult != null) ? allPostsResult.length : 0;
        totalPages = (int) Math.ceil((double) totalPosts / postsPerPage);
    }
    
    // Compter mes posts dans ce groupe
    int nbMesPosts = 0;
    if (groupeId != null) {
        Object[] mesPostsR = CGenUtil.rechercher(new Post(), null, null, 
            " AND idgroupe = '" + groupeId + "' AND idutilisateur = " + refuserInt + " AND supprime = 0");
        nbMesPosts = (mesPostsR != null) ? mesPostsR.length : 0;
    }
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
        else return "A l'instant";
    }
%>

<div class="content-wrapper">
    <section class="content">
        <div class="feed-container">
    
    <!-- ========== FIL DE PROMOTION (CENTRE) ========== -->
    <div class="feed-main">
        
        <!-- En-tête de la promotion -->
        <div class="promo-header-card">
            <div class="promo-header-top">
                <div class="promo-icon">
                    <i class="fa fa-graduation-cap"></i>
                </div>
                <div class="promo-header-info">
                    <h2 class="promo-title">
                        <% if (promoNom.isEmpty()) { %>
                            Espace Promotion
                        <% } else { %>
                            Promotion <%= promoNom %>
                        <% } %>
                    </h2>
                    <% if (promoAnnee > 0) { %>
                    <span class="promo-year"><i class="fa fa-calendar"></i> Ann&eacute;e <%= promoAnnee %></span>
                    <% } %>
                </div>
                <% if (groupeId != null) { %>
                <div class="promo-stats-inline">
                    <span><i class="fa fa-users"></i> <%= nbMembres %> membre<%= nbMembres > 1 ? "s" : "" %></span>
                    <span><i class="fa fa-file-text-o"></i> <%= totalPosts %> publication<%= totalPosts > 1 ? "s" : "" %></span>
                </div>
                <% } %>
            </div>
            
            <% if (isAdmin && allPromos != null && allPromos.length > 0) { %>
            <div class="promo-selector">
                <form method="get" action="<%= lien %>">
                    <input type="hidden" name="but" value="promotion/espace-promotion.jsp">
                    <label><i class="fa fa-filter"></i> Promotion :</label>
                    <select name="promo" onchange="this.form.submit()" class="promo-select">
                        <option value="">-- Choisir --</option>
                        <% for (Promotion p : allPromos) { %>
                        <option value="<%= p.getId() %>" <%= p.getId().equals(selectedPromoId) ? "selected" : "" %>>
                            <%= p.getLibelle() %> (<%= p.getAnnee() %>)
                        </option>
                        <% } %>
                    </select>
                </form>
            </div>
            <% } %>
        </div>
        
        <% if (selectedPromoId == null || selectedPromoId.isEmpty()) { %>
        <!-- Pas de promotion assignée -->
        <div class="post-card empty-state">
            <i class="fa fa-graduation-cap"></i>
            <h3>Aucune promotion assign&eacute;e</h3>
            <% if (isAdmin) { %>
            <p>S&eacute;lectionnez une promotion dans le menu ci-dessus pour voir ses publications.</p>
            <% } else { %>
            <p>Votre compte n'est pas encore rattach&eacute; &agrave; une promotion. Contactez l'administration.</p>
            <% } %>
        </div>
        
        <% } else if (groupeId == null) { %>
        <!-- Pas de groupe créé pour cette promotion -->
        <div class="post-card empty-state">
            <i class="fa fa-exclamation-circle"></i>
            <h3>Espace non initialis&eacute;</h3>
            <p>Le groupe de cette promotion n'a pas encore &eacute;t&eacute; cr&eacute;&eacute;. Contactez l'administration.</p>
        </div>
        
        <% } else if (!isMember) { %>
        <!-- Pas membre du groupe -->
        <div class="post-card empty-state">
            <i class="fa fa-lock"></i>
            <h3>Acc&egrave;s restreint</h3>
            <p>Vous n'&ecirc;tes pas membre de cette promotion. Seuls les membres peuvent voir les publications.</p>
        </div>
        
        <% } else { %>
        
        <!-- Formulaire de publication -->
        <div class="create-post-compact">
            <form action="<%= lien %>?but=publication/apresPublicationFichier.jsp" method="post" id="formPromoPost" enctype="multipart/form-data">
                <input type="hidden" name="idgroupe" value="<%= groupeId %>">
                <input type="hidden" name="idtypepublication" value="TYP00004">
                <input type="hidden" name="idvisibilite" value="VISI00004">
                <input type="hidden" name="acte" value="insert">
                <input type="hidden" name="bute" value="promotion/espace-promotion.jsp<%= isAdmin && selectedPromoId != null ? "?promo=" + selectedPromoId : "" %>">
                <input type="file" id="promoFileInput" name="fichier" style="display:none;" onchange="previewPromoFile(this)" accept="image/*,.pdf,.doc,.docx,.xls,.xlsx,.ppt,.pptx">

                <!-- Zone fichier en premier -->
                <div class="file-drop-zone" onclick="document.getElementById('promoFileInput').click()">
                    <div id="promo-drop-placeholder" class="file-drop-placeholder">
                        <i class="fa fa-cloud-upload"></i>
                        <span>Ajouter une photo ou un fichier</span>
                    </div>
                    <div id="promo-file-preview" class="file-preview-container" style="display:none;">
                        <div class="file-preview-item">
                            <i class="fa fa-file file-icon"></i>
                            <span id="promo-file-name" class="file-preview-name"></span>
                            <button type="button" class="file-remove-btn" onclick="event.stopPropagation(); removePromoFile()"><i class="fa fa-times"></i></button>
                        </div>
                        <img id="promo-file-img" class="file-preview-img" style="display:none;" />
                    </div>
                </div>

                <!-- Zone texte + actions -->
                <div class="create-bottom">
                    <img class="avatar-sm" src="<%= photoUser %>" alt="Photo">
                    <textarea name="contenu" class="create-input" placeholder="Partager avec votre promotion, <%= prenomUser %> ..." required rows="1" oninput="autoResizePromo(this)"></textarea>
                    <button type="submit" class="btn-post" title="Publier"><i class="fa fa-paper-plane"></i></button>
                </div>
            </form>
        </div>
        
        <!-- Publications de la promotion -->
        <% if (postsResult == null || postsResult.length == 0) { %>
        <div class="post-card empty-state">
            <i class="fa fa-comments-o"></i>
            <h3>Aucune publication</h3>
            <p>Soyez le premier &agrave; partager quelque chose avec votre promotion !</p>
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
                boolean isEpingle = post.getEpingle() == 1;
                
                // Charger l'auteur
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
                
                // Charger les fichiers attachés
                PostFichier fichierFilter = new PostFichier();
                fichierFilter.setPost_id(postId);
                Object[] fichiersResult = CGenUtil.rechercher(fichierFilter, null, null, " ORDER BY ordre");
                
                // Vérifier si l'utilisateur a liké
                Like likeCheck = new Like();
                Object[] likeCheckResult = CGenUtil.rechercher(likeCheck, null, null, " AND post_id = '" + postId + "' AND idutilisateur = " + refuserInt);
                boolean hasLiked = (likeCheckResult != null && likeCheckResult.length > 0);
        %>
        
        <div class="post-card <%= isEpingle ? "post-pinned" : "" %>">
            <% if (isEpingle) { %>
            <div class="pinned-badge"><i class="fa fa-thumb-tack"></i> &Eacute;pingl&eacute;</div>
            <% } %>
            <div class="post-header">
                <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= postAuteurId %>" class="post-author">
                    <img class="avatar" src="<%= photoAuteur %>" alt="Photo">
                    <div class="author-info">
                        <span class="author-name"><%= nomComplet %></span>
                        <span class="post-meta">
                            <span class="post-type" style="background-color: #f39c12;">
                                <i class="fa fa-graduation-cap"></i> Promotion
                            </span>
                            <span class="post-time"><%= formatTempsRelatif(createdAt) %></span>
                        </span>
                    </div>
                </a>
                <div class="post-menu">
                    <button class="menu-btn" onclick="togglePromoMenu('<%= postId %>')">
                        <i class="fa fa-ellipsis-h"></i>
                    </button>
                    <div class="menu-dropdown" id="promo-menu-<%= postId %>">
                        <% if (postAuteurId == refuserInt || isAdmin) { %>
                        <a href="#" onclick="supprimerPromoPost('<%= postId %>')"><i class="fa fa-trash"></i> Supprimer</a>
                        <% } %>
                        <% if (isAdmin) { %>
                        <a href="#" onclick="epinglerPost('<%= postId %>', '<%= isEpingle ? "0" : "1" %>')">
                            <i class="fa fa-thumb-tack"></i> <%= isEpingle ? "D&eacute;s&eacute;pingler" : "&Eacute;pingler" %>
                        </a>
                        <% } %>
                        <% if (postAuteurId != refuserInt) { %>
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
            
            <!-- Fichiers attachés -->
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
                <button class="action-btn like-btn <%= hasLiked ? "liked" : "" %>" onclick="likePromoPost('<%= postId %>')" id="like-btn-<%= postId %>">
                    <i class="fa <%= hasLiked ? "fa-heart" : "fa-heart-o" %>"></i>
                    <span id="likes-<%= postId %>"><%= nbLikes %></span>
                </button>
                <a href="<%= lien %>?but=publication/publication-fiche.jsp&id=<%= postId %>" class="action-btn" style="text-decoration:none;">
                    <i class="fa fa-comment-o"></i>
                    <span><%= nbComments %></span>
                </a>
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
            <a href="<%= lien %>?but=promotion/espace-promotion.jsp&page=<%= currentPage - 1 %><%= isAdmin ? "&promo=" + selectedPromoId : "" %>" class="page-btn"><i class="fa fa-chevron-left"></i></a>
            <% } %>
            <% 
            int startPage = Math.max(1, currentPage - 2);
            int endPage = Math.min(totalPages, currentPage + 2);
            for (int i = startPage; i <= endPage; i++) { 
            %>
            <a href="<%= lien %>?but=promotion/espace-promotion.jsp&page=<%= i %><%= isAdmin ? "&promo=" + selectedPromoId : "" %>" class="page-btn <%= i == currentPage ? "active" : "" %>"><%= i %></a>
            <% } %>
            <% if (currentPage < totalPages) { %>
            <a href="<%= lien %>?but=promotion/espace-promotion.jsp&page=<%= currentPage + 1 %><%= isAdmin ? "&promo=" + selectedPromoId : "" %>" class="page-btn"><i class="fa fa-chevron-right"></i></a>
            <% } %>
        </div>
        <% } %>
        
        <% } /* fin du else isMember */ %>
        
    </div>
    
    <!-- ========== SIDEBAR DROITE ========== -->
    <div class="feed-sidebar">
        <div class="sidebar-inner">
            
            <!-- Profil utilisateur -->
            <div class="sidebar-profile">
                <a href="<%= lien %>?but=profil/mon-profil.jsp" class="profile-link">
                    <img class="profile-avatar" src="<%= photoUser %>" alt="Photo">
                    <div class="profile-info">
                        <span class="profile-name"><%= prenomUser %> <%= nomUser %></span>
                        <% if (!promoNom.isEmpty()) { %>
                        <span class="profile-subtitle"><i class="fa fa-graduation-cap"></i> Promotion <%= promoNom %></span>
                        <% } else { %>
                        <span class="profile-subtitle">Membre Alumni ITU</span>
                        <% } %>
                    </div>
                </a>
            </div>
            
            <% if (groupeId != null && isMember) { %>
            <!-- Stats du groupe -->
            <div class="sidebar-section">
                <div class="section-header">
                    <span>Statistiques</span>
                </div>
                <div class="stats-grid">
                    <div class="stat-item">
                        <span class="stat-value"><%= nbMembres %></span>
                        <span class="stat-label">Membres</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value"><%= totalPosts %></span>
                        <span class="stat-label">Publications</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value"><%= nbMesPosts %></span>
                        <span class="stat-label">Mes posts</span>
                    </div>
                </div>
            </div>
            
            <!-- Membres récents -->
            <div class="sidebar-section">
                <div class="section-header">
                    <span>Membres</span>
                </div>
                <div class="promo-members-list">
                    <%
                    if (groupeId != null) {
                        Object[] membresListe = CGenUtil.rechercher(new GroupeMembre(), null, null, 
                            " AND idgroupe = '" + groupeId + "' AND statut = 'actif' ORDER BY joined_at DESC LIMIT 8");
                        if (membresListe != null) {
                            for (Object mObj : membresListe) {
                                GroupeMembre gm = (GroupeMembre) mObj;
                                UtilisateurAcade membreInfo = new UtilisateurAcade();
                                Object[] memResult = CGenUtil.rechercher(membreInfo, null, null, " AND refuser = " + gm.getIdutilisateur());
                                if (memResult != null && memResult.length > 0) {
                                    UtilisateurAcade membre = (UtilisateurAcade) memResult[0];
                                    String memNom = ((membre.getPrenom() != null ? membre.getPrenom() : "") + " " + 
                                                    (membre.getNomuser() != null ? membre.getNomuser() : "")).trim();
                                    if (memNom.isEmpty()) memNom = "Membre";
                                    String memPhoto = request.getContextPath() + "/assets/img/default-avatar.png";
                                    if (membre.getPhoto() != null && !membre.getPhoto().isEmpty()) {
                                        String mpf = membre.getPhoto();
                                        if (mpf.contains("/")) mpf = mpf.substring(mpf.lastIndexOf("/") + 1);
                                        memPhoto = request.getContextPath() + "/profile-photo?file=" + mpf;
                                    }
                    %>
                    <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= gm.getIdutilisateur() %>" class="promo-member-item">
                        <img src="<%= memPhoto %>" alt="" class="member-avatar">
                        <span class="member-name"><%= memNom %></span>
                    </a>
                    <%
                                }
                            }
                        }
                    }
                    %>
                </div>
            </div>
            <% } %>
            
            <!-- Raccourcis -->
            <div class="sidebar-section">
                <div class="section-header">
                    <span>Raccourcis</span>
                </div>
                <nav class="sidebar-nav">
                    <a href="<%= lien %>?but=accueil.jsp">
                        <i class="fa fa-home"></i> Accueil
                    </a>
                    <a href="<%= lien %>?but=annuaire/annuaire-liste.jsp">
                        <i class="fa fa-users"></i> Annuaire
                    </a>
                    <a href="<%= lien %>?but=chatbot/alumni-chat.jsp" class="chat-link">
                        <i class="fa fa-comments"></i> Assistant Alumni
                        <span class="badge-new">IA</span>
                    </a>
                </nav>
            </div>
            
            <div class="sidebar-footer">
                <p>Alumni ITU Platform &copy; 2026</p>
            </div>
            
        </div>
    </div>
</div>
    </section>
</div>

<style>
/* ========== LAYOUT FEED ========== */
.feed-container { display: flex; max-width: 100%; margin: 0; padding: 20px; gap: 30px; min-height: calc(100vh - 100px); background: #fafafa; }
.feed-main { flex: 1; max-width: calc(100% - 320px); }
.feed-sidebar { width: 290px; flex-shrink: 0; }
.sidebar-inner { position: sticky; top: 70px; width: 290px; max-height: calc(100vh - 80px); overflow-y: auto; }

/* ========== PROMO HEADER ========== */
.promo-header-card {
    background: linear-gradient(135deg, #f39c12 0%, #e67e22 100%);
    border-radius: 12px;
    padding: 20px 24px;
    margin-bottom: 20px;
    color: #fff;
}
.promo-header-top {
    display: flex;
    align-items: center;
    gap: 16px;
}
.promo-icon {
    width: 52px; height: 52px;
    background: rgba(255,255,255,0.25);
    border-radius: 12px;
    display: flex; align-items: center; justify-content: center;
    font-size: 24px;
    flex-shrink: 0;
}
.promo-header-info { flex: 1; }
.promo-title { margin: 0; font-size: 20px; font-weight: 700; }
.promo-year { font-size: 13px; opacity: 0.85; }
.promo-year i { margin-right: 4px; }
.promo-stats-inline {
    display: flex; gap: 16px; font-size: 13px; opacity: 0.9;
}
.promo-stats-inline span { display: flex; align-items: center; gap: 5px; white-space: nowrap; }

.promo-selector {
    margin-top: 14px;
    padding-top: 14px;
    border-top: 1px solid rgba(255,255,255,0.3);
    display: flex;
    align-items: center;
    gap: 10px;
}
.promo-selector label {
    font-size: 13px;
    font-weight: 600;
    display: flex; align-items: center; gap: 5px;
}
.promo-select {
    flex: 1;
    padding: 8px 12px;
    border-radius: 8px;
    border: 1px solid rgba(255,255,255,0.4);
    background: rgba(255,255,255,0.2);
    color: #fff;
    font-size: 13px;
    outline: none;
}
.promo-select option { color: #333; background: #fff; }

/* ========== CREATE POST COMPACT ========== */
.create-post-compact { background: #fff; border: 1px solid #e0e0e0; border-radius: 12px; margin-bottom: 20px; overflow: hidden; }
.avatar-sm { width: 34px; height: 34px; border-radius: 50%; object-fit: cover; flex-shrink: 0; }

.file-drop-zone { border-bottom: 1px solid #f0f0f0; cursor: pointer; transition: background 0.2s; }
.file-drop-zone:hover { background: #fafbfc; }
.file-drop-placeholder { display: flex; align-items: center; justify-content: center; gap: 8px; padding: 18px 16px; color: #8e8e8e; font-size: 13px; }
.file-drop-placeholder i { font-size: 18px; color: #d4a04a; }
.file-drop-zone:hover .file-drop-placeholder i { color: #f39c12; }
.file-drop-zone:hover .file-drop-placeholder { color: #555; }

.file-preview-container { padding: 10px 16px; }
.file-preview-item { display: flex; align-items: center; gap: 10px; margin-bottom: 6px; }
.file-icon { color: #f39c12; font-size: 16px; }
.file-preview-name { flex: 1; font-size: 13px; color: #333; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.file-preview-img { max-height: 160px; max-width: 100%; border-radius: 8px; object-fit: cover; }
.file-remove-btn { background: transparent; border: none; color: #999; cursor: pointer; font-size: 13px; padding: 4px 6px; border-radius: 4px; transition: all 0.15s; }
.file-remove-btn:hover { background: #fee; color: #dc3545; }

.create-bottom { display: flex; align-items: center; gap: 10px; padding: 10px 14px; }
.create-input { flex: 1; border: none; padding: 8px 0; font-size: 14px; background: transparent; outline: none; resize: none; min-height: 34px; max-height: 100px; overflow-y: auto; font-family: inherit; line-height: 1.4; color: #262626; }
.create-input::placeholder { color: #b0b0b0; }
.btn-post { background: #f39c12; color: #fff; border: none; border-radius: 50%; width: 34px; height: 34px; cursor: pointer; display: flex; align-items: center; justify-content: center; transition: background 0.15s; flex-shrink: 0; font-size: 13px; }
.btn-post:hover { background: #e67e22; }

/* ========== POST CARDS ========== */
.post-card { background: #fff; border: 1px solid #dbdbdb; border-radius: 8px; margin-bottom: 24px; }
.post-pinned { border-color: #f39c12; border-width: 2px; }
.pinned-badge { background: #fff8e1; color: #f39c12; font-size: 12px; font-weight: 600; padding: 6px 16px; border-bottom: 1px solid #ffe082; border-radius: 8px 8px 0 0; }
.pinned-badge i { margin-right: 5px; }
.post-header { display: flex; align-items: center; padding: 14px 16px; border-bottom: 1px solid #efefef; }
.avatar { width: 42px; height: 42px; border-radius: 50%; object-fit: cover; margin-right: 12px; }
.post-author { display: flex; align-items: center; text-decoration: none; flex: 1; }
.author-info { display: flex; flex-direction: column; }
.author-name { font-weight: 600; font-size: 14px; color: #262626; }
.post-meta { display: flex; align-items: center; gap: 8px; margin-top: 2px; }
.post-type { font-size: 10px; padding: 2px 6px; border-radius: 3px; color: #fff; }
.post-time { font-size: 12px; color: #8e8e8e; }
.post-menu { position: relative; }
.menu-btn { background: none; border: none; padding: 8px; cursor: pointer; color: #262626; }
.menu-dropdown { display: none; position: absolute; right: 0; top: 100%; background: #fff; border: 1px solid #dbdbdb; border-radius: 8px; box-shadow: 0 4px 12px rgba(0,0,0,0.15); min-width: 150px; z-index: 100; }
.menu-dropdown.show { display: block; }
.menu-dropdown a { display: block; padding: 12px 16px; color: #262626; text-decoration: none; font-size: 14px; }
.menu-dropdown a:hover { background: #fafafa; }
.menu-dropdown a i { margin-right: 8px; width: 16px; }

.post-content { padding: 12px 16px; }
.post-content p { margin: 0; font-size: 14px; line-height: 1.6; white-space: pre-wrap; color: #262626; }

.post-actions { display: flex; padding: 8px 16px; border-top: 1px solid #efefef; }
.action-btn { background: none; border: none; padding: 8px; cursor: pointer; display: flex; align-items: center; gap: 6px; font-size: 14px; color: #262626; }
.action-btn:hover { color: #8e8e8e; }
.action-btn i {
    font-size: 24px;
    transition: all 0.2s ease;
}

/* Animation du cœur Instagram-style */
@keyframes likeHeartAnimation {
    0% { transform: scale(1); }
    15% { transform: scale(1.3); }
    30% { transform: scale(0.95); }
    45% { transform: scale(1.15); }
    60% { transform: scale(1); }
    100% { transform: scale(1); }
}

.action-btn.liked i {
    color: #ed4956;
}

.action-btn i.heart-animating {
    animation: likeHeartAnimation 0.5s cubic-bezier(0.4, 0, 0.2, 1);
}

.action-btn:active i {
    transform: scale(0.9);
}

.post-likes-summary { padding: 0 16px 12px; font-size: 14px; }

/* ========== MEDIA ========== */
.accueil-media { overflow: hidden; }
.accueil-images { display: grid; gap: 2px; }
.accueil-images.single { grid-template-columns: 1fr; }
.accueil-images.double { grid-template-columns: 1fr 1fr; }
.accueil-images.multi { grid-template-columns: 1fr 1fr; }
.accueil-images img { width: 100%; max-height: 400px; object-fit: cover; display: block; }
.accueil-images.single img { max-height: 500px; }
.accueil-docs { padding: 10px 16px; display: flex; flex-direction: column; gap: 6px; }
.accueil-doc-link { display: inline-flex; align-items: center; gap: 8px; padding: 8px 14px; background: #f5f5f5; border-radius: 6px; font-size: 13px; color: #333; text-decoration: none; border: 1px solid #e0e0e0; }
.accueil-doc-link:hover { background: #eee; color: #000; }

/* ========== SIDEBAR ========== */
.sidebar-profile { padding: 16px 0; border-bottom: 1px solid #efefef; margin-bottom: 12px; }
.profile-link { display: flex; align-items: center; text-decoration: none; }
.profile-avatar { width: 56px; height: 56px; border-radius: 50%; object-fit: cover; margin-right: 12px; }
.profile-info { display: flex; flex-direction: column; }
.profile-name { font-weight: 600; font-size: 14px; color: #262626; }
.profile-subtitle { font-size: 12px; color: #8e8e8e; }
.profile-subtitle i { margin-right: 4px; color: #f39c12; }

.sidebar-section { margin-bottom: 20px; }
.section-header { display: flex; justify-content: space-between; padding: 4px 0 12px; }
.section-header span { font-weight: 600; font-size: 14px; color: #8e8e8e; }

.stats-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 12px; }
.stat-item { display: flex; flex-direction: column; align-items: center; padding: 16px 8px; background: #fafafa; border-radius: 8px; text-decoration: none; }
.stat-value { font-size: 20px; font-weight: 700; color: #262626; }
.stat-label { font-size: 11px; color: #8e8e8e; margin-top: 4px; text-align: center; }

.sidebar-nav a { display: flex; align-items: center; padding: 12px; text-decoration: none; color: #262626; font-size: 14px; border-radius: 8px; margin-bottom: 4px; }
.sidebar-nav a:hover { background: #fafafa; }
.sidebar-nav a i { width: 24px; font-size: 18px; margin-right: 12px; color: #262626; }
.badge-new { margin-left: auto; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; font-size: 10px; padding: 2px 8px; border-radius: 10px; font-weight: 600; }
.chat-link { background: linear-gradient(135deg, #f5f7fa 0%, #e8edf5 100%) !important; border-left: 3px solid #667eea !important; }
.chat-link:hover { background: linear-gradient(135deg, #e8edf5 0%, #dce3f0 100%) !important; }
.chat-link i { color: #667eea !important; }

.sidebar-footer { padding-top: 20px; border-top: 1px solid #efefef; }
.sidebar-footer p { font-size: 11px; color: #c7c7c7; margin: 0; }

/* ========== MEMBERS LIST ========== */
.promo-members-list {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}
.promo-member-item {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 6px 10px;
    background: #fafafa;
    border-radius: 8px;
    text-decoration: none;
    width: 100%;
    transition: background 0.2s;
}
.promo-member-item:hover { background: #f0f0f0; }
.member-avatar {
    width: 32px; height: 32px; border-radius: 50%; object-fit: cover;
}
.member-name {
    font-size: 13px; color: #262626; font-weight: 500;
}

/* ========== EMPTY STATE ========== */
.empty-state { text-align: center; padding: 60px 20px; }
.empty-state i { font-size: 64px; color: #dbdbdb; }
.empty-state h3 { margin: 20px 0 8px; color: #262626; }
.empty-state p { color: #8e8e8e; }

/* ========== PAGINATION ========== */
.pagination-wrapper { display: flex; justify-content: center; gap: 8px; padding: 20px 0; }
.page-btn { display: flex; align-items: center; justify-content: center; width: 36px; height: 36px; border: 1px solid #dbdbdb; border-radius: 8px; color: #262626; text-decoration: none; font-size: 14px; }
.page-btn:hover, .page-btn.active { background: #f39c12; border-color: #f39c12; color: #fff; }

/* ========== RESPONSIVE ========== */
@media (max-width: 992px) {
    .feed-sidebar { display: none; }
    .feed-main { max-width: 100%; }
    .feed-container { padding: 15px; }
    .promo-header-top { flex-wrap: wrap; }
    .promo-stats-inline { width: 100%; margin-top: 8px; }
}
</style>

<script>
// Auto-resize textarea
function autoResizePromo(el) {
    el.style.height = 'auto';
    el.style.height = el.scrollHeight + 'px';
}

// File preview
function previewPromoFile(input) {
    var container = document.getElementById('promo-file-preview');
    var nameSpan = document.getElementById('promo-file-name');
    var iconElem = container.querySelector('.file-icon');
    var placeholder = document.getElementById('promo-drop-placeholder');
    var previewImg = document.getElementById('promo-file-img');
    
    if (input.files && input.files[0]) {
        var file = input.files[0];
        nameSpan.textContent = file.name;
        
        var ext = file.name.split('.').pop().toLowerCase();
        var iconClass = 'fa-file';
        if (['jpg', 'jpeg', 'png', 'gif', 'webp'].includes(ext)) iconClass = 'fa-image';
        else if (ext === 'pdf') iconClass = 'fa-file-pdf-o';
        else if (['doc', 'docx'].includes(ext)) iconClass = 'fa-file-word-o';
        else if (['xls', 'xlsx'].includes(ext)) iconClass = 'fa-file-excel-o';
        iconElem.className = 'fa ' + iconClass + ' file-icon';
        
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
function removePromoFile() {
    document.getElementById('promoFileInput').value = '';
    document.getElementById('promo-file-preview').style.display = 'none';
    document.getElementById('promo-file-img').style.display = 'none';
    document.getElementById('promo-drop-placeholder').style.display = 'flex';
}

// Toggle menu
function togglePromoMenu(postId) {
    var menu = document.getElementById('promo-menu-' + postId);
    // Fermer tous les autres menus
    var allMenus = document.querySelectorAll('.menu-dropdown');
    for (var i = 0; i < allMenus.length; i++) {
        if (allMenus[i] !== menu) allMenus[i].classList.remove('show');
    }
    menu.classList.toggle('show');
}

// Fermer menus au clic extérieur
document.addEventListener('click', function(e) {
    if (!e.target.closest('.post-menu')) {
        var allMenus = document.querySelectorAll('.menu-dropdown');
        for (var i = 0; i < allMenus.length; i++) {
            allMenus[i].classList.remove('show');
        }
    }
});

// Like
function likePromoPost(postId) {
    // Animation du cœur avant le rechargement
    var btn = document.getElementById('like-btn-' + postId);
    if (btn) {
        var icon = btn.querySelector('i');
        if (icon) {
            icon.classList.add('heart-animating');
        }
    }
    
    // Envoyer la requête avec petit délai pour voir l'animation
    setTimeout(function() {
        var xhr = new XMLHttpRequest();
        xhr.open('POST', '<%= lien %>?but=publication/apresPublication.jsp', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                // Rafraîchir la page pour voir le résultat
                location.reload();
            }
        };
        xhr.send('acte=like&post_id=' + postId);
    }, 150);
}

// Supprimer
function supprimerPromoPost(postId) {
    if (confirm('Supprimer cette publication ?')) {
        var promoParam = '<%= isAdmin && selectedPromoId != null ? "&promo=" + selectedPromoId : "" %>';
        document.location.href = '<%= lien %>?but=publication/apresPublication.jsp&acte=supprimer&post_id=' + postId 
            + '&bute=promotion/espace-promotion.jsp' + promoParam;
    }
}

// Épingler
function epinglerPost(postId, valeur) {
    var promoParam = '<%= isAdmin && selectedPromoId != null ? "&promo=" + selectedPromoId : "" %>';
    document.location.href = '<%= lien %>?but=promotion/apresPromotionPost.jsp&acte=epingler&post_id=' + postId 
        + '&epingle=' + valeur + '&bute=promotion/espace-promotion.jsp' + promoParam;
}
</script>

<% } catch (Exception e) { 
    e.printStackTrace();
%>
<div class="content-wrapper">
    <section class="content">
        <div class="post-card empty-state" style="background:#fff; border:1px solid #dbdbdb; border-radius:8px; text-align:center; padding:60px 20px;">
            <i class="fa fa-exclamation-triangle" style="font-size:64px; color:#e74c3c;"></i>
            <h3>Erreur</h3>
            <p><%= e.getMessage() %></p>
        </div>
    </section>
</div>
<% } %>
