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
    
    // Charger les publications via CGenUtil
    Post postFilter = new Post();
    String apresWherePost = " AND supprime = 0 ORDER BY created_at DESC LIMIT " + postsPerPage + " OFFSET " + ((currentPage - 1) * postsPerPage);
    Object[] postsResult = CGenUtil.rechercher(postFilter, null, null, apresWherePost);
    
    // Compter le total pour pagination
    Post totalFilter = new Post();
    Object[] allPostsResult = CGenUtil.rechercher(totalFilter, null, null, " AND supprime = 0");
    int totalPosts = (allPostsResult != null) ? allPostsResult.length : 0;
    int totalPages = (int) Math.ceil((double) totalPosts / postsPerPage);
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
        
        <!-- Formulaire de création de publication (compact) -->
        <div class="create-post-compact">
            <div class="create-header">
                <img class="avatar-sm" src="<%= photoUser %>" alt="Photo">
                <form action="<%= lien %>?but=publication/apresPublication.jsp" method="post" id="formPublication" class="create-form">
                    <input type="text" name="contenu" class="create-input" placeholder="Quoi de neuf, <%= prenomUser %> ?" required>
                    <input type="hidden" name="idtypepublication" value="TYP00004">
                    <input type="hidden" name="idvisibilite" value="VISI00001">
                    <input type="hidden" name="acte" value="insert">
                    <input type="hidden" name="bute" value="accueil.jsp">
                    <button type="submit" class="btn-post"><i class="fa fa-paper-plane"></i></button>
                </form>
            </div>
            <div class="create-actions">
                <a href="<%= lien %>?but=carriere/emploi-saisie.jsp" class="action-link">
                    <i class="fa fa-briefcase"></i> Offre d'emploi
                </a>
                <a href="<%= lien %>?but=carriere/stage-saisie.jsp" class="action-link">
                    <i class="fa fa-graduation-cap"></i> Stage
                </a>
            </div>
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
        %>
        
        <!-- Publication -->
        <div class="post-card">
            <div class="post-header">
                <a href="<%= lien %>?but=profil/profil-fiche.jsp&refuser=<%= postAuteurId %>" class="post-author">
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
                <% if (postAuteurId == refuserInt) { %>
                <div class="post-menu">
                    <button class="menu-btn" onclick="toggleMenu('<%= postId %>')">
                        <i class="fa fa-ellipsis-h"></i>
                    </button>
                    <div class="menu-dropdown" id="menu-<%= postId %>">
                        <a href="<%= lien %>?but=publication/publication-modif.jsp&id=<%= postId %>"><i class="fa fa-edit"></i> Modifier</a>
                        <a href="#" onclick="supprimerPost('<%= postId %>')"><i class="fa fa-trash"></i> Supprimer</a>
                    </div>
                </div>
                <% } %>
            </div>
            <div class="post-content">
                <p><%= contenu != null ? contenu : "" %></p>
            </div>
            <div class="post-actions">
                <button class="action-btn like-btn" onclick="likePost('<%= postId %>')" id="like-btn-<%= postId %>">
                    <i class="fa fa-heart-o"></i>
                    <span id="likes-<%= postId %>"><%= nbLikes %></span>
                </button>
                <button class="action-btn" onclick="toggleComments('<%= postId %>')">
                    <i class="fa fa-comment-o"></i>
                    <span><%= nbComments %></span>
                </button>
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
            
            <!-- Footer -->
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
    top: 20px;
    width: 290px;
}

/* ========== CREATE POST COMPACT ========== */
.create-post-compact {
    background: #fff;
    border: 1px solid #dbdbdb;
    border-radius: 8px;
    margin-bottom: 20px;
    padding: 12px 16px;
}

.create-header {
    display: flex;
    align-items: center;
    gap: 12px;
}

.avatar-sm {
    width: 38px;
    height: 38px;
    border-radius: 50%;
    object-fit: cover;
}

.create-form {
    flex: 1;
    display: flex;
    align-items: center;
    gap: 10px;
}

.create-input {
    flex: 1;
    border: 1px solid #e0e0e0;
    border-radius: 20px;
    padding: 10px 16px;
    font-size: 14px;
    background: #f5f5f5;
    outline: none;
    transition: all 0.2s;
}

.create-input:focus {
    background: #fff;
    border-color: #0095f6;
}

.btn-post {
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
    transition: background 0.2s;
}

.btn-post:hover {
    background: #0081d6;
}

.create-actions {
    display: flex;
    gap: 8px;
    margin-top: 10px;
    padding-top: 10px;
    border-top: 1px solid #efefef;
}

.action-link {
    display: flex;
    align-items: center;
    gap: 6px;
    padding: 6px 12px;
    border-radius: 6px;
    font-size: 13px;
    color: #65676b;
    text-decoration: none;
    transition: background 0.2s;
}

.action-link:hover {
    background: #f0f2f5;
    color: #050505;
}

.action-link i {
    font-size: 16px;
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

.sidebar-footer {
    padding-top: 20px;
    border-top: 1px solid #efefef;
}

.sidebar-footer p {
    font-size: 11px;
    color: #c7c7c7;
    margin: 0;
}

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
</style>

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
    var btn = document.getElementById('like-btn-' + postId);
    var icon = btn.querySelector('i');
    var likesSpan = document.getElementById('likes-' + postId);
    var currentLikes = parseInt(likesSpan.textContent) || 0;
    
    // Toggle visuel immédiat
    if (icon.classList.contains('fa-heart-o')) {
        icon.classList.remove('fa-heart-o');
        icon.classList.add('fa-heart');
        btn.classList.add('liked');
        likesSpan.textContent = currentLikes + 1;
    } else {
        icon.classList.remove('fa-heart');
        icon.classList.add('fa-heart-o');
        btn.classList.remove('liked');
        likesSpan.textContent = Math.max(0, currentLikes - 1);
    }
    
    $.ajax({
        url: lien + '?but=publication/apresPublication.jsp',
        type: 'POST',
        data: { acte: 'like', id: postId }
    });
}

function supprimerPost(postId) {
    if (!confirm('Supprimer cette publication ?')) return;
    
    $.ajax({
        url: lien + '?but=publication/apresPublication.jsp',
        type: 'POST',
        data: { acte: 'supprimer', id: postId },
        success: function(response) {
            location.reload();
        }
    });
}

function toggleComments(postId) {
    alert('Fonctionnalité commentaires à venir');
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
