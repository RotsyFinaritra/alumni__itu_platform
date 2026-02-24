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
    } else {
        // Redirection si non connecté
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Pagination
    int limit = 10;
    int offset = 0;
    if (request.getParameter("offset") != null) {
        try {
            offset = Integer.parseInt(request.getParameter("offset"));
        } catch (Exception e) {}
    }
    
    // Récupérer les publications de l'utilisateur
    List<Object[]> posts = null;
    int totalPosts = 0;
    try {
        posts = PublicationService.getUserPosts(idutilisateur, limit, offset);
        totalPosts = PublicationService.countUserPosts(idutilisateur);
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    SimpleDateFormat sdf = new SimpleDateFormat("dd MMM yyyy à HH:mm");
%>

<style>
/* Publication Feed Styles */
.publication-feed { max-width: 800px; margin: 20px auto; padding: 0 15px; }
.feed-header { background: #fff; padding: 20px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); display: flex; justify-content: space-between; align-items: center; }
.feed-header-content h2 { margin: 0 0 10px 0; color: #333; font-size: 24px; }
.feed-header-content p { margin: 0; color: #666; font-size: 14px; }
.btn-create-post { background: #00a65a; color: #fff; padding: 10px 20px; border-radius: 6px; text-decoration: none; font-weight: 600; transition: background 0.3s; }
.btn-create-post:hover { background: #008d4c; color: #fff; }

.post-card { background: #fff; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; transition: box-shadow 0.3s ease; }
.post-card:hover { box-shadow: 0 3px 8px rgba(0,0,0,0.15); }

.post-header { padding: 15px 20px; display: flex; align-items: center; gap: 12px; border-bottom: 1px solid #f0f0f0; }
.post-avatar { width: 45px; height: 45px; border-radius: 50%; object-fit: cover; flex-shrink: 0; background: #e0e0e0; }
.post-user-info { flex: 1; }
.post-author { font-weight: 600; color: #333; font-size: 15px; margin: 0; }
.post-meta { font-size: 12px; color: #999; margin: 2px 0 0 0; }
.post-type-badge { display: inline-block; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; margin-left: 8px; }
.post-status-badge { display: inline-block; padding: 3px 8px; border-radius: 4px; font-size: 11px; font-weight: 600; margin-left: 4px; }

.post-content { padding: 20px; color: #333; font-size: 15px; line-height: 1.6; white-space: pre-wrap; word-wrap: break-word; }

.post-actions { padding: 10px 20px; border-top: 1px solid #f0f0f0; display: flex; gap: 15px; }
.post-action-btn { background: none; border: none; padding: 8px 12px; border-radius: 6px; cursor: pointer; display: flex; align-items: center; gap: 6px; font-size: 14px; color: #666; transition: all 0.2s; }
.post-action-btn:hover { background: #f5f5f5; color: #333; }
.post-action-btn i { font-size: 16px; }
.post-action-btn.active { color: #00a65a; font-weight: 600; }
.post-action-btn.like-btn.active { color: #e74c3c; }
.post-action-btn.like-btn.active i { animation: heartBeat 0.3s ease; }

.post-stats { padding: 0 20px 10px 20px; font-size: 13px; color: #999; display: flex; gap: 15px; }

.comments-section { border-top: 1px solid #f0f0f0; background: #fafafa; }
.comment-item { padding: 12px 20px; display: flex; gap: 10px; border-bottom: 1px solid #f0f0f0; }
.comment-item:last-child { border-bottom: none; }
.comment-avatar { width: 32px; height: 32px; border-radius: 50%; object-fit: cover; flex-shrink: 0; background: #e0e0e0; }
.comment-content { flex: 1; }
.comment-author { font-weight: 600; font-size: 13px; color: #333; margin: 0; }
.comment-text { font-size: 14px; color: #555; margin: 4px 0 0 0; }
.comment-time { font-size: 11px; color: #999; margin-top: 4px; }

.comment-form { padding: 15px 20px; background: #fff; border-top: 1px solid #f0f0f0; display: flex; gap: 10px; align-items: center; }
.comment-input { flex: 1; padding: 10px 15px; border: 1px solid #ddd; border-radius: 20px; font-size: 14px; outline: none; transition: border-color 0.3s; }
.comment-input:focus { border-color: #00a65a; }
.comment-submit { background: #00a65a; color: #fff; border: none; padding: 10px 20px; border-radius: 20px; cursor: pointer; font-size: 14px; font-weight: 600; transition: background 0.3s; }
.comment-submit:hover { background: #008d4c; }
.comment-submit:disabled { background: #ccc; cursor: not-allowed; }

.pagination-feed { text-align: center; padding: 20px; }
.pagination-feed .btn { margin: 0 5px; }

.empty-feed { text-align: center; padding: 60px 20px; color: #999; background: #fff; border-radius: 8px; }
.empty-feed i { font-size: 60px; margin-bottom: 20px; opacity: 0.3; }
.empty-feed h3 { font-size: 20px; margin: 0 0 10px 0; }
.empty-feed p { font-size: 14px; margin: 10px 0; }

@keyframes heartBeat {
    0%, 100% { transform: scale(1); }
    25% { transform: scale(1.3); }
    50% { transform: scale(1.1); }
}

@media (max-width: 768px) {
    .publication-feed { padding: 0; }
    .post-card { border-radius: 0; margin-bottom: 10px; }
    .feed-header { border-radius: 0; flex-direction: column; align-items: flex-start; gap: 15px; }
}
</style>

<div class="publication-feed">
    <div class="feed-header">
        <div class="feed-header-content">
            <h2><i class="fa fa-user-circle"></i> Mes Publications</h2>
            <p>Gérez toutes vos publications - Total : <%= totalPosts %> publication(s)</p>
        </div>
        <a href="module.jsp?but=publication/publication-saisie.jsp&currentMenu=MENDYN100-3" class="btn-create-post">
            <i class="fa fa-plus"></i> Créer une publication
        </a>
    </div>
    
    <% 
    String successMsg = (String) session.getAttribute("success");
    String errorMsg = (String) session.getAttribute("error");
    if (successMsg != null) {
        session.removeAttribute("success");
    %>
    <div class="alert alert-success" style="margin-bottom: 20px; padding: 15px 20px; background: #d4edda; border: 1px solid #c3e6cb; color: #155724; border-radius: 8px;">
        <i class="fa fa-check-circle"></i> <%= successMsg %>
    </div>
    <% } %>
    <% if (errorMsg != null) {
        session.removeAttribute("error");
    %>
    <div class="alert alert-error" style="margin-bottom: 20px; padding: 15px 20px; background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; border-radius: 8px;">
        <i class="fa fa-exclamation-triangle"></i> <%= errorMsg %>
    </div>
    <% } %>
    
    <%
    if (posts != null && !posts.isEmpty()) {
        for (Object[] row : posts) {
            Post post = (Post) row[0];
            String nomuser = (String) row[1];
            String prenom = (String) row[2];
            String photoAuteur = (String) row[3];
            String typeLibelle = (String) row[4];
            String typeIcon = (String) row[5];
            String typeCouleur = (String) row[6];
            String statutLibelle = (String) row[7];
            String statutCouleur = (String) row[8];
            String visibiliteLibelle = (String) row[9];
            int nbLikes = (Integer) row[10];
            int nbCommentaires = (Integer) row[11];
            int nbPartages = (Integer) row[12];
            boolean userALike = (Boolean) row[13];
            
            String auteurComplet = nomuser + " " + prenom;
            String defaultAvatar = "assets/img/default-avatar.png";
            String avatarUrl = (photoAuteur != null && !photoAuteur.isEmpty()) ? photoAuteur : defaultAvatar;
    %>
    
    <div class="post-card" data-post-id="<%= post.getId() %>">
        <!-- En-tête du post -->
        <div class="post-header">
            <img src="<%= avatarUrl %>" alt="<%= auteurComplet %>" class="post-avatar" onerror="this.src='<%= defaultAvatar %>'">
            <div class="post-user-info">
                <p class="post-author">
                    <%= auteurComplet %>
                    <% if (typeLibelle != null && typeIcon != null) { %>
                    <span class="post-type-badge" style="background-color: <%= typeCouleur %>; color: #fff;">
                        <i class="<%= typeIcon %>"></i> <%= typeLibelle %>
                    </span>
                    <% } %>
                    <span class="post-status-badge" style="background-color: <%= statutCouleur %>; color: #fff;">
                        <%= statutLibelle %>
                    </span>
                </p>
                <p class="post-meta">
                    <%= sdf.format(post.getCreated_at()) %> · 
                    <i class="fa fa-eye"></i> <%= visibiliteLibelle %>
                    <% if (post.getEpingle()) { %>
                    <i class="fa fa-thumb-tack" style="color: #f39c12; margin-left: 8px;" title="Épinglé"></i>
                    <% } %>
                </p>
            </div>
        </div>
        
        <!-- Contenu du post -->
        <div class="post-content"><%= post.getContenu() %></div>
        
        <!-- Statistiques -->
        <% if (nbLikes > 0 || nbCommentaires > 0 || nbPartages > 0) { %>
        <div class="post-stats">
            <% if (nbLikes > 0) { %>
            <span><i class="fa fa-heart" style="color: #e74c3c;"></i> <%= nbLikes %></span>
            <% } %>
            <% if (nbCommentaires > 0) { %>
            <span><i class="fa fa-comment"></i> <%= nbCommentaires %></span>
            <% } %>
            <% if (nbPartages > 0) { %>
            <span><i class="fa fa-share"></i> <%= nbPartages %></span>
            <% } %>
        </div>
        <% } %>
        
        <!-- Actions -->
        <div class="post-actions">
            <button class="post-action-btn like-btn <%= userALike ? "active" : "" %>" 
                    onclick="toggleLike('<%= post.getId() %>', this)">
                <i class="fa fa-heart"></i>
                <span class="like-count"><%= nbLikes %></span>
            </button>
            <button class="post-action-btn" onclick="toggleComments('<%= post.getId() %>')">
                <i class="fa fa-comment"></i>
                Commenter
            </button>
            <button class="post-action-btn">
                <i class="fa fa-share"></i>
                Partager
            </button>
        </div>
        
        <!-- Section commentaires -->
        <div class="comments-section" id="comments-<%= post.getId() %>" style="display: none;">
            <div class="comments-list" id="comments-list-<%= post.getId() %>">
                <%
                try {
                    List<Object[]> comments = PublicationService.getCommentaires(post.getId());
                    if (comments != null && !comments.isEmpty()) {
                        for (Object[] commentRow : comments) {
                            Commentaire comment = (Commentaire) commentRow[0];
                            String commentAuteurNom = (String) commentRow[1];
                            String commentAuteurPrenom = (String) commentRow[2];
                            String commentAuteurPhoto = (String) commentRow[3];
                            
                            String commentAuteurComplet = commentAuteurNom + " " + commentAuteurPrenom;
                            String commentAvatarUrl = (commentAuteurPhoto != null && !commentAuteurPhoto.isEmpty()) ? commentAuteurPhoto : defaultAvatar;
                %>
                <div class="comment-item">
                    <img src="<%= commentAvatarUrl %>" alt="<%= commentAuteurComplet %>" class="comment-avatar" onerror="this.src='<%= defaultAvatar %>'">
                    <div class="comment-content">
                        <p class="comment-author"><%= commentAuteurComplet %></p>
                        <p class="comment-text"><%= comment.getContenu() %></p>
                        <div class="comment-time"><%= sdf.format(comment.getCreated_at()) %></div>
                    </div>
                </div>
                <%
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                }
                %>
            </div>
            
            <!-- Formulaire d'ajout de commentaire -->
            <div class="comment-form">
                <input type="text" 
                       class="comment-input" 
                       id="comment-input-<%= post.getId() %>" 
                       placeholder="Ajouter un commentaire...">
                <button class="comment-submit" 
                        onclick="addComment('<%= post.getId() %>')">
                    <i class="fa fa-paper-plane"></i>
                </button>
            </div>
        </div>
    </div>
    
    <%
        }
    %>
    
    <!-- Pagination -->
    <% if (totalPosts > limit) { %>
    <div class="pagination-feed">
        <% if (offset > 0) { %>
        <a href="?offset=<%= Math.max(0, offset - limit) %>" class="btn btn-default">
            <i class="fa fa-chevron-left"></i> Précédent
        </a>
        <% } %>
        
        <span style="margin: 0 15px; color: #666;">
            Page <%= (offset / limit) + 1 %> sur <%= (int) Math.ceil((double) totalPosts / limit) %>
        </span>
        
        <% if (offset + limit < totalPosts) { %>
        <a href="?offset=<%= offset + limit %>" class="btn btn-default">
            Suivant <i class="fa fa-chevron-right"></i>
        </a>
        <% } %>
    </div>
    <% } %>
    
    <%
    } else {
    %>
    
    <div class="empty-feed">
        <i class="fa fa-inbox"></i>
        <h3>Aucune publication</h3>
        <p>Vous n'avez pas encore créé de publication.</p>
        <p>
            <a href="module.jsp?but=publication/publication-saisie.jsp&currentMenu=MENDYN100-3" class="btn btn-primary" style="margin-top: 15px;">
                <i class="fa fa-plus"></i> Créer ma première publication
            </a>
        </p>
    </div>
    
    <%
    }
    %>
</div>

<script>
// Fonction pour basculer le like
function toggleLike(postId, btn) {
    $.ajax({
        url: 'publication/toggle-like.jsp',
        method: 'POST',
        data: { post_id: postId },
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                if (response.liked) {
                    $(btn).addClass('active');
                } else {
                    $(btn).removeClass('active');
                }
                $(btn).find('.like-count').text(response.nbLikes);
            }
        },
        error: function() {
            alert('Erreur lors de l\'action');
        }
    });
}

// Fonction pour afficher/masquer les commentaires
function toggleComments(postId) {
    $('#comments-' + postId).slideToggle(300);
}

// Fonction pour ajouter un commentaire
function addComment(postId) {
    var input = $('#comment-input-' + postId);
    var contenu = input.val().trim();
    
    if (!contenu) {
        alert('Veuillez saisir un commentaire');
        return;
    }
    
    $.ajax({
        url: 'publication/add-comment.jsp',
        method: 'POST',
        data: { 
            post_id: postId,
            contenu: contenu
        },
        dataType: 'json',
        success: function(response) {
            if (response.success) {
                // Ajouter le nouveau commentaire à la liste
                var commentHtml = 
                    '<div class="comment-item">' +
                    '<img src="' + (response.photo || 'assets/img/default-avatar.png') + '" alt="' + response.auteur + '" class="comment-avatar">' +
                    '<div class="comment-content">' +
                    '<p class="comment-author">' + response.auteur + '</p>' +
                    '<p class="comment-text">' + response.contenu + '</p>' +
                    '<div class="comment-time">À l\'instant</div>' +
                    '</div>' +
                    '</div>';
                
                $('#comments-list-' + postId).append(commentHtml);
                input.val('');
                
                // Mettre à jour le compteur de commentaires
                var postCard = $('[data-post-id="' + postId + '"]');
                var commentBtn = postCard.find('.post-action-btn:contains("Commenter")');
                // Actualiser la page pour voir le nouveau compteur
                location.reload();
            } else {
                alert('Erreur : ' + (response.message || 'Impossible d\'ajouter le commentaire'));
            }
        },
        error: function() {
            alert('Erreur lors de l\'ajout du commentaire');
        }
    });
}

// Permettre l'envoi avec Entrée
$(document).on('keypress', '.comment-input', function(e) {
    if (e.which === 13) {
        var postId = $(this).attr('id').replace('comment-input-', '');
        addComment(postId);
    }
});
</script>
