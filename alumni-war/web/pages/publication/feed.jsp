<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*" %>
<%@ page import="user.UserEJB" %>
<%@ page import="profil.PublicationService" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

<%
    UserEJB u = (UserEJB) session.getValue("u");
    int idutilisateur = 0;
    if (u != null && u.getUser() != null) {
        idutilisateur = Integer.parseInt(u.getUser().getTuppleID());
    }
    
    // Pagination
    int limit = 10;
    int offset = 0;
    if (request.getParameter("offset") != null) {
        try {
            offset = Integer.parseInt(request.getParameter("offset"));
        } catch (Exception e) {}
    }
    
    // Récupérer les publications
    List<Object[]> feed = null;
    int totalPosts = 0;
    try {
        feed = PublicationService.getFeed(idutilisateur, limit, offset);
        totalPosts = PublicationService.countPosts(idutilisateur);
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy à HH:mm");
%>

<style>
/* Publication Feed Styles - Instagram-like */
.publication-feed { max-width: 615px; margin: 0 auto; }
.feed-header { background: #fff; padding: 24px; border-radius: 3px; margin-bottom: 20px; border: 1px solid #dbdbdb; }
.feed-header h2 { margin: 0 0 10px 0; color: #262626; font-size: 24px; font-weight: 300; }
.feed-header p { margin: 0; color: #8e8e8e; font-size: 14px; }

.post-card { background: #fff; border-radius: 3px; margin-bottom: 24px; border: 1px solid #dbdbdb; overflow: hidden; }
.post-card:hover { border-color: #a8a8a8; }

.post-header { padding: 14px 16px; display: flex; align-items: center; gap: 12px; }
.post-avatar { width: 32px; height: 32px; border-radius: 50%; object-fit: cover; flex-shrink: 0; background: #fafafa; }
.post-user-info { flex: 1; }
.post-author { font-weight: 600; color: #262626; font-size: 14px; margin: 0; }
.post-meta { font-size: 12px; color: #8e8e8e; margin: 2px 0 0 0; }
.post-type-badge { display: inline-block; padding: 2px 6px; border-radius: 2px; font-size: 11px; font-weight: 600; margin-left: 8px; }

.post-content { padding: 16px; color: #262626; font-size: 14px; line-height: 1.5; white-space: pre-wrap; word-wrap: break-word; }

.post-actions { padding: 4px 16px; border-top: 1px solid #efefef; display: flex; gap: 16px; }
.post-action-btn { background: none; border: none; padding: 8px 0; cursor: pointer; display: flex; align-items: center; gap: 6px; font-size: 14px; color: #262626; transition: opacity 0.2s; }
.post-action-btn:hover { opacity: 0.5; }
.post-action-btn i { font-size: 24px; }
.post-action-btn.active { color: #262626; }
.post-action-btn.like-btn.active { color: #ed4956; }
.post-action-btn.like-btn.active i { animation: heartBeat 0.3s ease; }

.post-stats { padding: 0 16px 8px 16px; font-size: 14px; color: #262626; font-weight: 600; }

.comments-section { border-top: 1px solid #efefef; }
.comment-item { padding: 12px 16px; display: flex; gap: 12px; }
.comment-avatar { width: 32px; height: 32px; border-radius: 50%; object-fit: cover; flex-shrink: 0; background: #fafafa; }
.comment-content { flex: 1; }
.comment-author { font-weight: 600; font-size: 14px; color: #262626; margin: 0; display: inline; }
.comment-text { font-size: 14px; color: #262626; margin: 0; display: inline; margin-left: 6px; }
.comment-time { font-size: 12px; color: #8e8e8e; margin-top: 4px; }

.comment-form { padding: 6px 16px 6px 16px; border-top: 1px solid #efefef; display: flex; gap: 8px; align-items: center; }
.comment-input { flex: 1; padding: 8px 0; border: none; font-size: 14px; outline: none; }
.comment-input::placeholder { color: #8e8e8e; }
.comment-submit { background: none; color: #0095f6; border: none; padding: 0; cursor: pointer; font-size: 14px; font-weight: 600; }
.comment-submit:hover { color: #00376b; }
.comment-submit:disabled { color: #b3dbff; cursor: default; }

.pagination-feed { text-align: center; padding: 20px; }
.pagination-feed .btn { margin: 0 5px; background: #fff; border: 1px solid #dbdbdb; color: #262626; padding: 6px 12px; border-radius: 3px; }
.pagination-feed .btn:hover { background: #fafafa; }

.empty-feed { text-align: center; padding: 60px 20px; color: #8e8e8e; background: #fff; border-radius: 3px; border: 1px solid #dbdbdb; }
.empty-feed i { font-size: 60px; margin-bottom: 20px; opacity: 0.3; }
.empty-feed h3 { font-size: 20px; margin: 0 0 10px 0; font-weight: 300; color: #262626; }
.empty-feed p { font-size: 14px; }

@keyframes heartBeat {
    0%, 100% { transform: scale(1); }
    25% { transform: scale(1.3); }
    50% { transform: scale(1.1); }
}

@media (max-width: 768px) {
    .publication-feed { max-width: 100%; }
    .post-card { border-radius: 0; margin-bottom: 0; border-left: none; border-right: none; }
    .feed-header { border-radius: 0; border-left: none; border-right: none; }
}
</style>

<div class="content-wrapper">
    <section class="content">
        <div class="container-fluid">
            <div class="publication-feed">
        <div class="feed-header">
            <h2><i class="fa fa-newspaper-o"></i> Fil d'actualités</h2>
            <p>Découvrez les dernières publications de la communauté alumni</p>
        </div>

        <% if (feed == null || feed.isEmpty()) { %>
        <div class="empty-feed">
            <i class="fa fa-newspaper-o"></i>
            <h3>Aucune publication disponible</h3>
            <p>Soyez le premier à partager quelque chose avec la communauté !</p>
        </div>
        <% } else { 
            for (Object[] row : feed) {
                Post post = (Post) row[0];
                String nomuser = (String) row[1];
                String prenom = (String) row[2];
                String photo = (String) row[3];
                String typeLibelle = (String) row[4];
                String typeIcon = (String) row[5];
                String typeCouleur = (String) row[6];
                int nbLikes = (Integer) row[9];
                int nbCommentaires = (Integer) row[10];
                int nbPartages = (Integer) row[11];
                boolean userALike = (Boolean) row[12];
                
                String avatarUrl = (photo != null && !photo.isEmpty()) 
                    ? request.getContextPath() + "/uploads/" + photo 
                    : request.getContextPath() + "/assets/img/default-avatar.png";
        %>
        
        <div class="post-card" data-post-id="<%= post.getId() %>">
            <div class="post-header">
                <img src="<%= avatarUrl %>" alt="Avatar" class="post-avatar" 
                     onerror="this.src='${pageContext.request.contextPath}/assets/img/default-avatar.png'">
                <div class="post-user-info">
                    <p class="post-author"><%= nomuser %> <%= prenom %>
                        <% if (typeLibelle != null) { %>
                        <span class="post-type-badge" style="background-color: <%= typeCouleur %>20; color: <%= typeCouleur %>;">
                            <% if (typeIcon != null) { %><i class="fa <%= typeIcon %>"></i><% } %>
                            <%= typeLibelle %>
                        </span>
                        <% } %>
                    </p>
                    <p class="post-meta">
                        <%= sdf.format(post.getCreated_at()) %>
                        <% if (post.getEdited_at() != null) { %> · Modifié<% } %>
                        <% if (post.getEpingle()) { %> · <i class="fa fa-thumb-tack"></i> Épinglé<% } %>
                    </p>
                </div>
            </div>

            <div class="post-content"><%= post.getContenu() %></div>

            <% if (nbLikes > 0 || nbCommentaires > 0 || nbPartages > 0) { %>
            <div class="post-stats">
                <% if (nbLikes > 0) { %>
                <span><i class="fa fa-heart" style="color: #e74c3c;"></i> <%= nbLikes %> J'aime</span>
                <% } %>
                <% if (nbCommentaires > 0) { %>
                <span><i class="fa fa-comment"></i> <%= nbCommentaires %> Commentaires</span>
                <% } %>
                <% if (nbPartages > 0) { %>
                <span><i class="fa fa-share"></i> <%= nbPartages %> Partages</span>
                <% } %>
            </div>
            <% } %>

            <div class="post-actions">
                <button class="post-action-btn like-btn <%= userALike ? "active" : "" %>" 
                        onclick="toggleLike('<%= post.getId() %>', this)">
                    <i class="fa <%= userALike ? "fa-heart" : "fa-heart-o" %>"></i>
                    <span class="like-text"><%= userALike ? "J'aime" : "J'aime" %></span>
                </button>
                <button class="post-action-btn comment-btn" onclick="toggleComments('<%= post.getId() %>')">
                    <i class="fa fa-comment-o"></i>
                    <span>Commenter</span>
                </button>
                <button class="post-action-btn share-btn" onclick="sharePost('<%= post.getId() %>')">
                    <i class="fa fa-share"></i>
                    <span>Partager</span>
                </button>
            </div>

            <div class="comments-section" id="comments-<%= post.getId() %>" style="display: none;">
                <!-- Les commentaires seront chargés ici via AJAX -->
                <div class="comments-list" id="comments-list-<%= post.getId() %>">
                    <!-- Chargement des commentaires existants -->
                    <%
                        try {
                            List<Object[]> commentaires = PublicationService.getCommentaires(post.getId());
                            for (Object[] commRow : commentaires) {
                                Commentaire comm = (Commentaire) commRow[0];
                                String commNom = (String) commRow[1];
                                String commPrenom = (String) commRow[2];
                                String commPhoto = (String) commRow[3];
                                String commAvatar = (commPhoto != null && !commPhoto.isEmpty()) 
                                    ? request.getContextPath() + "/uploads/" + commPhoto 
                                    : request.getContextPath() + "/assets/img/default-avatar.png";
                    %>
                    <div class="comment-item">
                        <img src="<%= commAvatar %>" alt="Avatar" class="comment-avatar"
                             onerror="this.src='${pageContext.request.contextPath}/assets/img/default-avatar.png'">
                        <div class="comment-content">
                            <p class="comment-author"><%= commNom %> <%= commPrenom %></p>
                            <p class="comment-text"><%= comm.getContenu() %></p>
                            <div class="comment-time"><%= sdf.format(comm.getCreated_at()) %></div>
                        </div>
                    </div>
                    <%
                            }
                        } catch (Exception e) {
                            e.printStackTrace();
                        }
                    %>
                </div>
                <div class="comment-form">
                    <input type="text" class="comment-input" 
                           placeholder="Écrivez un commentaire..." 
                           id="comment-input-<%= post.getId() %>"
                           onkeypress="if(event.keyCode==13) addComment('<%= post.getId() %>')">
                    <button class="comment-submit" onclick="addComment('<%= post.getId() %>')">
                        <i class="fa fa-paper-plane"></i>
                    </button>
                </div>
            </div>
        </div>
        
        <% } // end for %>
        
        <!-- Pagination -->
        <% if (totalPosts > limit) { %>
        <div class="pagination-feed">
            <% if (offset > 0) { %>
            <a href="?but=publication/feed.jsp&offset=<%= Math.max(0, offset - limit) %>" 
               class="btn btn-default">
                <i class="fa fa-chevron-left"></i> Précédent
            </a>
            <% } %>
            
            <% if (offset + limit < totalPosts) { %>
            <a href="?but=publication/feed.jsp&offset=<%= offset + limit %>" 
               class="btn btn-default">
                Suivant <i class="fa fa-chevron-right"></i>
            </a>
            <% } %>
            
            <p style="margin-top: 10px; color: #999; font-size: 13px;">
                Publications <%= offset + 1 %> - <%= Math.min(offset + limit, totalPosts) %> sur <%= totalPosts %>
            </p>
        </div>
        <% } %>
        
        <% } // end if feed not empty %>
    </div>
</div>

<script>
// Toggle Like
function toggleLike(postId, btn) {
    $.ajax({
        url: '${pageContext.request.contextPath}/pages/publication/toggle-like.jsp',
        type: 'POST',
        data: { postId: postId },
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                // Mettre à jour l'UI
                var $btn = $(btn);
                var $icon = $btn.find('i');
                var $stats = $btn.closest('.post-card').find('.post-stats');
                
                if (response.liked) {
                    $btn.addClass('active');
                    $icon.removeClass('fa-heart-o').addClass('fa-heart');
                } else {
                    $btn.removeClass('active');
                    $icon.removeClass('fa-heart').addClass('fa-heart-o');
                }
                
                // Mettre à jour le compteur
                var likesText = response.nbLikes > 0 
                    ? '<span><i class="fa fa-heart" style="color: #e74c3c;"></i> ' + response.nbLikes + ' J\'aime</span>'
                    : '';
                
                // Reconstruire les stats
                var statsHtml = likesText;
                var commentsCount = $stats.find('.fa-comment').parent().text().trim();
                if (commentsCount) statsHtml += $stats.find('.fa-comment').parent()[0].outerHTML;
                var sharesCount = $stats.find('.fa-share').parent().text().trim();
                if (sharesCount) statsHtml += $stats.find('.fa-share').parent()[0].outerHTML;
                
                $stats.html(statsHtml);
            } else {
                alert('Erreur: ' + response.message);
            }
        },
        error: function() {
            alert('Erreur lors de l\'ajout du like');
        }
    });
}

// Toggle Comments Section
function toggleComments(postId) {
    $('#comments-' + postId).slideToggle(300);
}

// Add Comment
function addComment(postId) {
    var $input = $('#comment-input-' + postId);
    var contenu = $input.val().trim();
    
    if (!contenu) {
        alert('Veuillez saisir un commentaire');
        return;
    }
    
    $.ajax({
        url: '${pageContext.request.contextPath}/pages/publication/add-comment.jsp',
        type: 'POST',
        data: { 
            postId: postId,
            contenu: contenu
        },
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                // Ajouter le commentaire à la liste
                var commentHtml = 
                    '<div class="comment-item">' +
                    '  <img src="' + response.avatar + '" alt="Avatar" class="comment-avatar">' +
                    '  <div class="comment-content">' +
                    '    <p class="comment-author">' + response.auteur + '</p>' +
                    '    <p class="comment-text">' + response.contenu + '</p>' +
                    '    <div class="comment-time">À l\'instant</div>' +
                    '  </div>' +
                    '</div>';
                
                $('#comments-list-' + postId).append(commentHtml);
                $input.val('');
                
                // Mettre à jour le compteur
                var $stats = $('[data-post-id="' + postId + '"]').find('.post-stats');
                var $commentStat = $stats.find('.fa-comment').parent();
                if ($commentStat.length) {
                    $commentStat.html('<i class="fa fa-comment"></i> ' + response.nbCommentaires + ' Commentaires');
                } else {
                    $stats.append('<span><i class="fa fa-comment"></i> ' + response.nbCommentaires + ' Commentaires</span>');
                }
            } else {
                alert('Erreur: ' + response.message);
            }
        },
        error: function() {
            alert('Erreur lors de l\'ajout du commentaire');
        }
    });
}

// Share Post (placeholder)
function sharePost(postId) {
    alert('Fonctionnalité de partage à implémenter');
}
</script>
