<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*, affichage.*, utilitaire.Utilitaire, java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="user.UserEJB, utilisateurAcade.UtilisateurPg" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    if (u == null || lien == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int refuserInt = Integer.parseInt(u.getUser().getTuppleID());
    String postId = request.getParameter("id");
    
    if (postId == null || postId.isEmpty()) {
        throw new Exception("ID de publication manquant");
    }
    
    // Photo utilisateur connecté
    String photoUserConnecte = request.getContextPath() + "/assets/img/default-avatar.png";
    UtilisateurPg userConnecte = new UtilisateurPg();
    Object[] userConnecteResult = CGenUtil.rechercher(userConnecte, null, null, " AND refuser = " + refuserInt);
    if (userConnecteResult != null && userConnecteResult.length > 0) {
        userConnecte = (UtilisateurPg) userConnecteResult[0];
        if (userConnecte.getPhoto() != null && !userConnecte.getPhoto().isEmpty()) {
            String photoFile = userConnecte.getPhoto();
            if (photoFile.contains("/")) photoFile = photoFile.substring(photoFile.lastIndexOf("/") + 1);
            photoUserConnecte = request.getContextPath() + "/profile-photo?file=" + photoFile;
        }
    }
    
    // Charger le post
    Post post = new Post();
    post.setId(postId);
    Object[] postResult = CGenUtil.rechercher(post, null, null, "");
    if (postResult == null || postResult.length == 0) {
        throw new Exception("Publication introuvable");
    }
    post = (Post) postResult[0];
    
    // Charger l'auteur
    UtilisateurPg auteur = new UtilisateurPg();
    Object[] auteurResult = CGenUtil.rechercher(auteur, null, null, " AND refuser = " + post.getIdutilisateur());
    String nomAuteur = "Utilisateur inconnu";
    String photoAuteur = request.getContextPath() + "/assets/img/default-avatar.png";
    String emailAuteur = "";
    if (auteurResult != null && auteurResult.length > 0) {
        auteur = (UtilisateurPg) auteurResult[0];
        nomAuteur = (auteur.getNomuser() != null ? auteur.getNomuser() : "") + " " + (auteur.getPrenom() != null ? auteur.getPrenom() : "");
        emailAuteur = auteur.getMail() != null ? auteur.getMail() : "";
        if (auteur.getPhoto() != null && !auteur.getPhoto().isEmpty()) {
            String auteurPhotoFile = auteur.getPhoto();
            if (auteurPhotoFile.contains("/")) auteurPhotoFile = auteurPhotoFile.substring(auteurPhotoFile.lastIndexOf("/") + 1);
            photoAuteur = request.getContextPath() + "/profile-photo?file=" + auteurPhotoFile;
        }
    }
    
    // Charger le type de publication
    TypePublication typePost = new TypePublication();
    typePost.setId(post.getIdtypepublication());
    Object[] typeResult = CGenUtil.rechercher(typePost, null, null, "");
    String typeLibelle = "";
    String typeIcon = "fa-file-text-o";
    String typeCouleur = "#3498db";
    if (typeResult != null && typeResult.length > 0) {
        typePost = (TypePublication) typeResult[0];
        typeLibelle = typePost.getLibelle() != null ? typePost.getLibelle() : "";
        typeIcon = typePost.getIcon() != null ? typePost.getIcon() : "fa-file-text-o";
        typeCouleur = typePost.getCouleur() != null ? typePost.getCouleur() : "#3498db";
    }
    
    // Charger la visibilité
    VisibilitePublication visibilite = new VisibilitePublication();
    visibilite.setId(post.getIdvisibilite());
    Object[] visibiliteResult = CGenUtil.rechercher(visibilite, null, null, "");
    String visibiliteLibelle = "";
    if (visibiliteResult != null && visibiliteResult.length > 0) {
        visibilite = (VisibilitePublication) visibiliteResult[0];
        visibiliteLibelle = visibilite.getLibelle();
    }
    
    // Charger les détails selon le type
    PostStage stage = null;
    PostEmploi emploi = null;
    PostActivite activite = null;
    
    if ("TYPU00001".equals(post.getIdtypepublication())) {
        PostStage stageFilter = new PostStage();
        stageFilter.setPost_id(postId);
        Object[] stageResult = CGenUtil.rechercher(stageFilter, null, null, "");
        if (stageResult != null && stageResult.length > 0) {
            stage = (PostStage) stageResult[0];
        }
    } else if ("TYPU00002".equals(post.getIdtypepublication())) {
        PostEmploi emploiFilter = new PostEmploi();
        emploiFilter.setPost_id(postId);
        Object[] emploiResult = CGenUtil.rechercher(emploiFilter, null, null, "");
        if (emploiResult != null && emploiResult.length > 0) {
            emploi = (PostEmploi) emploiResult[0];
        }
    } else if ("TYPU00003".equals(post.getIdtypepublication())) {
        PostActivite activiteFilter = new PostActivite();
        activiteFilter.setPost_id(postId);
        Object[] activiteResult = CGenUtil.rechercher(activiteFilter, null, null, "");
        if (activiteResult != null && activiteResult.length > 0) {
            activite = (PostActivite) activiteResult[0];
        }
    }
    
    // Charger les fichiers joints
    PostFichier fichierFilter = new PostFichier();
    fichierFilter.setPost_id(postId);
    Object[] fichiers = CGenUtil.rechercher(fichierFilter, null, null, " ORDER BY created_at");
    
    // Charger les commentaires (sans parent = top-level, non supprimés)
    Commentaire commentaireFilter = new Commentaire();
    commentaireFilter.setPost_id(postId);
    Object[] commentaires = CGenUtil.rechercher(commentaireFilter, null, null, " AND parent_id IS NULL AND supprime = 0 ORDER BY created_at DESC");
    
    // Vérifier si l'utilisateur a liké
    Like likeFilter = new Like();
    likeFilter.setIdutilisateur(refuserInt);
    likeFilter.setPost_id(postId);
    Object[] likeResult = CGenUtil.rechercher(likeFilter, null, null, "");
    boolean hasLiked = (likeResult != null && likeResult.length > 0);
    
    boolean isOwner = (post.getIdutilisateur() == refuserInt);
    SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
    String dateAffichage = sdf.format(post.getCreated_at());
%>

<%!
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
        <div class="fiche-container">

    <!-- ========== CONTENU PRINCIPAL ========== -->
    <div class="fiche-main">

        <!-- Lien retour -->
        <a href="<%= lien %>?but=publication/publication-liste.jsp" class="back-link">
            <i class="fa fa-arrow-left"></i> Retour aux publications
        </a>

        <!-- ===== CARTE PUBLICATION ===== -->
        <div class="post-card">
            <!-- En-tête -->
            <div class="post-header">
                <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= post.getIdutilisateur() %>" class="post-author">
                    <img class="avatar" src="<%= photoAuteur %>" alt="<%= nomAuteur %>">
                    <div class="author-info">
                        <span class="author-name"><%= nomAuteur %></span>
                        <span class="post-meta">
                            <span class="post-type" style="background-color: <%= typeCouleur %>;">
                                <i class="fa <%= typeIcon %>"></i> <%= typeLibelle %>
                            </span>
                            <span class="post-time"><%= formatTempsRelatif(post.getCreated_at()) %></span>
                            <% if (post.getEdited_at() != null && !post.getEdited_at().equals(post.getCreated_at())) { %>
                            <span class="post-edited">(modifi&eacute;)</span>
                            <% } %>
                        </span>
                    </div>
                </a>
                <% if (isOwner) { %>
                <div class="post-menu">
                    <button class="menu-btn" onclick="toggleMenu('<%= postId %>')">
                        <i class="fa fa-ellipsis-h"></i>
                    </button>
                    <div class="menu-dropdown" id="menu-<%= postId %>">
                        <a href="<%= lien %>?but=publication/publication-saisie.jsp&id=<%= postId %>"><i class="fa fa-edit"></i> Modifier</a>
                        <a href="<%= lien %>?but=publication/save-publication-apj.jsp&acte=delete&id=<%= postId %>"
                           onclick="return confirm('Voulez-vous vraiment supprimer cette publication ?');">
                            <i class="fa fa-trash"></i> Supprimer
                        </a>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- Contenu -->
            <div class="post-content">
                <p><%= post.getContenu() != null ? post.getContenu() : "" %></p>
            </div>

            <!-- Détails Stage -->
            <% if (stage != null) { %>
            <div class="detail-section">
                <div class="detail-header"><i class="fa fa-briefcase"></i> Informations sur le stage</div>
                <div class="detail-body">
                    <div class="detail-row">
                        <span class="detail-label">Entreprise</span>
                        <span class="detail-value"><strong><%= stage.getEntreprise() %></strong></span>
                    </div>
                    <% if (stage.getLocalisation() != null && !stage.getLocalisation().isEmpty()) { %>
                    <div class="detail-row">
                        <span class="detail-label">Localisation</span>
                        <span class="detail-value"><i class="fa fa-map-marker"></i> <%= stage.getLocalisation() %></span>
                    </div>
                    <% } %>
                    <% if (stage.getDuree() != null && !stage.getDuree().isEmpty()) { %>
                    <div class="detail-row">
                        <span class="detail-label">Dur&eacute;e</span>
                        <span class="detail-value"><i class="fa fa-clock-o"></i> <%= stage.getDuree() %></span>
                    </div>
                    <% } %>
                    <% if (stage.getIndemnite() > 0) { %>
                    <div class="detail-row">
                        <span class="detail-label">Indemnit&eacute;</span>
                        <span class="detail-value"><i class="fa fa-money"></i> <%= stage.getIndemnite() %> Ar</span>
                    </div>
                    <% } %>
                    <% if (stage.getNiveau_etude_requis() != null && !stage.getNiveau_etude_requis().isEmpty()) { %>
                    <div class="detail-row">
                        <span class="detail-label">Comp&eacute;tences</span>
                        <span class="detail-value"><%= stage.getNiveau_etude_requis() %></span>
                    </div>
                    <% } %>
                    <% if (stage.getLien_candidature() != null && !stage.getLien_candidature().isEmpty()) { %>
                    <div class="detail-row">
                        <span class="detail-label">Candidature</span>
                        <span class="detail-value">
                            <a href="<%= stage.getLien_candidature() %>" target="_blank" class="btn-apply">
                                <i class="fa fa-external-link"></i> Postuler
                            </a>
                        </span>
                    </div>
                    <% } %>
                </div>
            </div>
            <% } else if (emploi != null) { %>
            <!-- Détails Emploi -->
            <div class="detail-section">
                <div class="detail-header"><i class="fa fa-graduation-cap"></i> Informations sur l'emploi</div>
                <div class="detail-body">
                    <div class="detail-row">
                        <span class="detail-label">Entreprise</span>
                        <span class="detail-value"><strong><%= emploi.getEntreprise() %></strong></span>
                    </div>
                    <div class="detail-row">
                        <span class="detail-label">Poste</span>
                        <span class="detail-value"><strong><%= emploi.getPoste() %></strong></span>
                    </div>
                    <% if (emploi.getLocalisation() != null && !emploi.getLocalisation().isEmpty()) { %>
                    <div class="detail-row">
                        <span class="detail-label">Localisation</span>
                        <span class="detail-value"><i class="fa fa-map-marker"></i> <%= emploi.getLocalisation() %></span>
                    </div>
                    <% } %>
                    <% if (emploi.getType_contrat() != null && !emploi.getType_contrat().isEmpty()) { %>
                    <div class="detail-row">
                        <span class="detail-label">Type de contrat</span>
                        <span class="detail-value"><%= emploi.getType_contrat() %></span>
                    </div>
                    <% } %>
                    <% if (emploi.getSalaire_min() > 0 || emploi.getSalaire_max() > 0) { %>
                    <div class="detail-row">
                        <span class="detail-label">Salaire</span>
                        <span class="detail-value"><i class="fa fa-money"></i>
                            <%= (emploi.getSalaire_min() > 0 ? emploi.getSalaire_min() + " Ar" : "") %>
                            <%= (emploi.getSalaire_min() > 0 && emploi.getSalaire_max() > 0 ? " - " : "") %>
                            <%= (emploi.getSalaire_max() > 0 ? emploi.getSalaire_max() + " Ar" : "") %>
                        </span>
                    </div>
                    <% } %>
                    <% if (emploi.getExperience_requise() != null && !emploi.getExperience_requise().isEmpty()) { %>
                    <div class="detail-row">
                        <span class="detail-label">Qualifications</span>
                        <span class="detail-value"><%= emploi.getExperience_requise() %></span>
                    </div>
                    <% } %>
                    <% if (emploi.getLien_candidature() != null && !emploi.getLien_candidature().isEmpty()) { %>
                    <div class="detail-row">
                        <span class="detail-label">Candidature</span>
                        <span class="detail-value">
                            <a href="<%= emploi.getLien_candidature() %>" target="_blank" class="btn-apply">
                                <i class="fa fa-external-link"></i> Postuler
                            </a>
                        </span>
                    </div>
                    <% } %>
                </div>
            </div>
            <% } else if (activite != null) { %>
            <!-- Détails Activité -->
            <div class="detail-section">
                <div class="detail-header"><i class="fa fa-calendar"></i> Informations sur l'activit&eacute;</div>
                <div class="detail-body">
                    <div class="detail-row">
                        <span class="detail-label">&Eacute;v&eacute;nement</span>
                        <span class="detail-value"><strong><%= activite.getTitre() %></strong></span>
                    </div>
                    <% if (activite.getLieu() != null && !activite.getLieu().isEmpty()) { %>
                    <div class="detail-row">
                        <span class="detail-label">Lieu</span>
                        <span class="detail-value"><i class="fa fa-map-marker"></i> <%= activite.getLieu() %></span>
                    </div>
                    <% } %>
                    <% if (activite.getDate_debut() != null) { %>
                    <div class="detail-row">
                        <span class="detail-label">D&eacute;but</span>
                        <span class="detail-value"><i class="fa fa-calendar"></i> <%= sdf.format(activite.getDate_debut()) %></span>
                    </div>
                    <% } %>
                    <% if (activite.getDate_fin() != null) { %>
                    <div class="detail-row">
                        <span class="detail-label">Fin</span>
                        <span class="detail-value"><i class="fa fa-calendar"></i> <%= sdf.format(activite.getDate_fin()) %></span>
                    </div>
                    <% } %>
                    <% if (activite.getPrix() > 0) { %>
                    <div class="detail-row">
                        <span class="detail-label">Prix</span>
                        <span class="detail-value"><i class="fa fa-ticket"></i> <%= activite.getPrix() %> Ar</span>
                    </div>
                    <% } %>
                    <% if (activite.getLien_inscription() != null && !activite.getLien_inscription().isEmpty()) { %>
                    <div class="detail-row">
                        <span class="detail-label">Inscription</span>
                        <span class="detail-value">
                            <a href="<%= activite.getLien_inscription() %>" target="_blank" class="btn-apply">
                                <i class="fa fa-external-link"></i> S'inscrire
                            </a>
                        </span>
                    </div>
                    <% } %>
                </div>
            </div>
            <% } %>

            <!-- Fichiers joints -->
            <% if (fichiers != null && fichiers.length > 0) { %>
            <div class="detail-section fichiers-section">
                <div class="detail-header"><i class="fa fa-paperclip"></i> Fichiers joints (<%= fichiers.length %>)</div>
                <div class="detail-body" style="padding: 8px 16px;">
                    <% for (Object o : fichiers) {
                        PostFichier fichier = (PostFichier) o;
                        String iconClass = "fa-file-o";
                        if (fichier.getIdtypefichier() != null) {
                            if (fichier.getIdtypefichier().contains("IMAGE")) iconClass = "fa-file-image-o";
                            else if (fichier.getIdtypefichier().contains("PDF")) iconClass = "fa-file-pdf-o";
                            else if (fichier.getIdtypefichier().contains("DOCUMENT")) iconClass = "fa-file-word-o";
                        }
                    %>
                    <a href="<%= fichier.getChemin() %>" target="_blank" class="fichier-item">
                        <i class="fa <%= iconClass %>"></i>
                        <span><%= fichier.getNom_fichier() %></span>
                        <% if (fichier.getTaille_octets() > 0) { %>
                        <small>(<%= (int)(fichier.getTaille_octets() / 1024) %> Ko)</small>
                        <% } %>
                    </a>
                    <% } %>
                </div>
            </div>
            <% } %>

            <!-- Actions (Like / Commenter / Partager) -->
            <div class="post-actions">
                <button class="action-btn like-btn <%= hasLiked ? "liked" : "" %>" onclick="toggleLike()" id="like-btn">
                    <i class="fa <%= hasLiked ? "fa-heart" : "fa-heart-o" %>"></i>
                    <span id="likeCount"><%= post.getNb_likes() %></span>
                </button>
                <button class="action-btn" onclick="focusCommentInput()">
                    <i class="fa fa-comment-o"></i>
                    <span><%= post.getNb_commentaires() %></span>
                </button>
                <button class="action-btn" onclick="sharePost()">
                    <i class="fa fa-paper-plane-o"></i>
                    <span><%= post.getNb_partages() %></span>
                </button>
                <button class="action-btn bookmark-btn">
                    <i class="fa fa-bookmark-o"></i>
                </button>
            </div>

            <!-- Résumé likes -->
            <% if (post.getNb_likes() > 0) { %>
            <div class="post-likes-summary">
                <strong><%= post.getNb_likes() %> J'aime<%= post.getNb_likes() > 1 ? "s" : "" %></strong>
            </div>
            <% } %>
        </div>

        <!-- ===== SECTION COMMENTAIRES ===== -->
        <div class="post-card comments-card" id="comments-section">
            <div class="comments-header">
                <i class="fa fa-comments"></i> Commentaires (<span id="commentsCount"><%= (commentaires != null) ? commentaires.length : 0 %></span>)
            </div>

            <!-- Formulaire commentaire -->
            <form class="comment-form" action="<%= lien %>?but=publication/apresPublication.jsp" method="post">
                <input type="hidden" name="acte" value="addComment">
                <input type="hidden" name="id" value="<%= postId %>">
                <img class="avatar-comment" src="<%= photoUserConnecte %>" alt="Vous">
                <div class="comment-input-wrapper">
                    <input type="text" name="contenu" class="comment-input"
                           placeholder="&Eacute;crire un commentaire..." required>
                    <button type="submit" class="comment-send">
                        <i class="fa fa-paper-plane"></i>
                    </button>
                </div>
            </form>

            <!-- Liste des commentaires -->
            <div class="comments-list" id="commentsList">
                <% if (commentaires == null || commentaires.length == 0) { %>
                <p class="empty-comments">Aucun commentaire pour le moment. Soyez le premier &agrave; commenter !</p>
                <% } else {
                    for (Object o : commentaires) {
                        Commentaire comment = (Commentaire) o;
                        
                        UtilisateurPg commentAuteur = new UtilisateurPg();
                        Object[] commentAuteurResult = CGenUtil.rechercher(commentAuteur, null, null, " AND refuser = " + comment.getIdutilisateur());
                        String commentAuteurNom = "Utilisateur inconnu";
                        String commentAuteurPhoto = request.getContextPath() + "/assets/img/default-avatar.png";
                        if (commentAuteurResult != null && commentAuteurResult.length > 0) {
                            commentAuteur = (UtilisateurPg) commentAuteurResult[0];
                            commentAuteurNom = (commentAuteur.getNomuser() != null ? commentAuteur.getNomuser() : "") + " " + (commentAuteur.getPrenom() != null ? commentAuteur.getPrenom() : "");
                            if (commentAuteur.getPhoto() != null && !commentAuteur.getPhoto().isEmpty()) {
                                String cPhotoFile = commentAuteur.getPhoto();
                                if (cPhotoFile.contains("/")) cPhotoFile = cPhotoFile.substring(cPhotoFile.lastIndexOf("/") + 1);
                                commentAuteurPhoto = request.getContextPath() + "/profile-photo?file=" + cPhotoFile;
                            }
                        }
                        
                        boolean isCommentOwner = (comment.getIdutilisateur() == refuserInt);
                %>
                <div class="comment-item" id="comment-<%= comment.getId() %>">
                    <img class="avatar-comment" src="<%= commentAuteurPhoto %>" alt="<%= commentAuteurNom %>">
                    <div class="comment-body">
                        <div class="comment-bubble">
                            <a class="comment-author" href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= comment.getIdutilisateur() %>">
                                <%= commentAuteurNom %>
                            </a>
                            <p class="comment-text"><%= comment.getContenu() %></p>
                        </div>
                        <div class="comment-meta">
                            <span class="comment-time"><%= formatTempsRelatif(comment.getCreated_at()) %></span>
                            <% if (isCommentOwner) { %>
                            <a href="<%= lien %>?but=publication/apresPublication.jsp&acte=deleteComment&id=<%= comment.getId() %>&postId=<%= postId %>"
                               class="comment-delete" onclick="return confirm('Supprimer ce commentaire ?')">
                                Supprimer
                            </a>
                            <% } %>
                        </div>
                    </div>
                </div>
                <%
                    }
                } %>
            </div>
        </div>

    </div>

    <!-- ========== SIDEBAR DROITE ========== -->
    <div class="fiche-sidebar">
        <div class="sidebar-inner">

            <!-- Profil auteur -->
            <div class="sidebar-profile">
                <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= post.getIdutilisateur() %>" class="profile-link">
                    <img class="profile-avatar" src="<%= photoAuteur %>" alt="<%= nomAuteur %>">
                    <div class="profile-info">
                        <span class="profile-name"><%= nomAuteur %></span>
                        <span class="profile-subtitle">Auteur de la publication</span>
                    </div>
                </a>
            </div>

            <!-- Boutons auteur -->
            <div class="sidebar-section">
                <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= post.getIdutilisateur() %>" class="sidebar-btn primary">
                    <i class="fa fa-user"></i> Voir le profil
                </a>
                <% if (!isOwner && emailAuteur != null && !emailAuteur.isEmpty()) { %>
                <a href="mailto:<%= emailAuteur %>" class="sidebar-btn default">
                    <i class="fa fa-envelope"></i> Contacter
                </a>
                <% } %>
            </div>

            <!-- Détails publication -->
            <div class="sidebar-section">
                <div class="section-header"><span>D&eacute;tails</span></div>
                <div class="detail-list">
                    <div class="detail-item">
                        <i class="fa fa-tag"></i>
                        <div>
                            <span class="detail-item-label">Type</span>
                            <span class="detail-item-value"><%= typeLibelle %></span>
                        </div>
                    </div>
                    <div class="detail-item">
                        <i class="fa fa-eye"></i>
                        <div>
                            <span class="detail-item-label">Visibilit&eacute;</span>
                            <span class="detail-item-value"><%= visibiliteLibelle %></span>
                        </div>
                    </div>
                    <div class="detail-item">
                        <i class="fa fa-calendar"></i>
                        <div>
                            <span class="detail-item-label">Publi&eacute; le</span>
                            <span class="detail-item-value"><%= dateAffichage %></span>
                        </div>
                    </div>
                    <% if (post.getEdited_at() != null && !post.getEdited_at().equals(post.getCreated_at())) { %>
                    <div class="detail-item">
                        <i class="fa fa-edit"></i>
                        <div>
                            <span class="detail-item-label">Modifi&eacute; le</span>
                            <span class="detail-item-value"><%= sdf.format(post.getEdited_at()) %></span>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>

            <!-- Statistiques publication -->
            <div class="sidebar-section">
                <div class="section-header"><span>Statistiques</span></div>
                <div class="stats-grid">
                    <div class="stat-item">
                        <span class="stat-value"><%= post.getNb_likes() %></span>
                        <span class="stat-label">J'aime</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value"><%= post.getNb_commentaires() %></span>
                        <span class="stat-label">Commentaires</span>
                    </div>
                    <div class="stat-item">
                        <span class="stat-value"><%= post.getNb_partages() %></span>
                        <span class="stat-label">Partages</span>
                    </div>
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

<!-- ========== STYLES ========== -->
<style>
/* Layout */
.fiche-container {
    display: flex;
    max-width: 100%;
    margin: 0;
    padding: 20px;
    gap: 30px;
    min-height: calc(100vh - 100px);
    background: #fafafa;
}
.fiche-main {
    flex: 1;
    max-width: calc(100% - 320px);
}
.fiche-sidebar {
    width: 290px;
    flex-shrink: 0;
}
.sidebar-inner {
    position: sticky;
    top: 20px;
    width: 290px;
}

/* Back link */
.back-link {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    margin-bottom: 16px;
    font-size: 14px;
    color: #8e8e8e;
    text-decoration: none;
    transition: color 0.2s;
}
.back-link:hover {
    color: #262626;
}

/* Post Card */
.post-card {
    background: #fff;
    border: 1px solid #dbdbdb;
    border-radius: 8px;
    margin-bottom: 24px;
}

/* Post Header */
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
    font-weight: 600;
}
.post-time {
    font-size: 12px;
    color: #8e8e8e;
}
.post-edited {
    font-size: 11px;
    color: #b0b0b0;
    font-style: italic;
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
    border-radius: 50%;
    transition: background 0.2s;
}
.menu-btn:hover {
    background: #f0f0f0;
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
    min-width: 160px;
    z-index: 100;
    overflow: hidden;
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
    transition: background 0.15s;
}
.menu-dropdown a:hover {
    background: #fafafa;
}
.menu-dropdown a i {
    margin-right: 10px;
    width: 16px;
}

/* Post Content */
.post-content {
    padding: 16px;
}
.post-content p {
    margin: 0;
    font-size: 15px;
    line-height: 1.7;
    white-space: pre-wrap;
    color: #262626;
}

/* Detail Sections (stage/emploi/activité) */
.detail-section {
    margin: 0 16px 16px;
    border: 1px solid #efefef;
    border-radius: 8px;
    overflow: hidden;
}
.detail-header {
    background: #fafafa;
    padding: 12px 16px;
    font-weight: 600;
    font-size: 14px;
    color: #262626;
    border-bottom: 1px solid #efefef;
}
.detail-header i {
    margin-right: 8px;
    color: #0095f6;
}
.detail-body {
    padding: 0;
}
.detail-row {
    display: flex;
    padding: 10px 16px;
    border-bottom: 1px solid #f5f5f5;
    align-items: center;
}
.detail-row:last-child {
    border-bottom: none;
}
.detail-label {
    width: 160px;
    font-size: 13px;
    color: #8e8e8e;
    flex-shrink: 0;
}
.detail-value {
    flex: 1;
    font-size: 14px;
    color: #262626;
}
.detail-value i {
    margin-right: 4px;
    color: #8e8e8e;
}
.btn-apply {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 14px;
    background: #00a854;
    color: #fff;
    border-radius: 6px;
    font-size: 13px;
    text-decoration: none;
    font-weight: 600;
    transition: background 0.2s;
}
.btn-apply:hover {
    background: #008c46;
    color: #fff;
}

/* Fichiers */
.fichiers-section .detail-body {
    display: flex;
    flex-direction: column;
    gap: 4px;
}
.fichier-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 12px;
    border-radius: 6px;
    text-decoration: none;
    color: #262626;
    font-size: 14px;
    transition: background 0.15s;
}
.fichier-item:hover {
    background: #f5f5f5;
    color: #262626;
}
.fichier-item i {
    font-size: 18px;
    color: #0095f6;
    width: 20px;
    text-align: center;
}
.fichier-item small {
    color: #8e8e8e;
}

/* Post Actions */
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
    transition: color 0.15s;
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
    color: #262626;
}

/* Comments Card */
.comments-card {
    padding: 0;
}
.comments-header {
    padding: 14px 16px;
    font-weight: 600;
    font-size: 14px;
    color: #262626;
    border-bottom: 1px solid #efefef;
}
.comments-header i {
    margin-right: 6px;
    color: #0095f6;
}

/* Comment Form */
.comment-form {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    border-bottom: 1px solid #efefef;
}
.avatar-comment {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    object-fit: cover;
    flex-shrink: 0;
}
.comment-input-wrapper {
    flex: 1;
    display: flex;
    align-items: center;
    background: #f5f5f5;
    border: 1px solid #e0e0e0;
    border-radius: 20px;
    padding: 0 4px 0 16px;
    transition: border-color 0.2s;
}
.comment-input-wrapper:focus-within {
    border-color: #0095f6;
    background: #fff;
}
.comment-input {
    flex: 1;
    border: none;
    background: transparent;
    padding: 8px 0;
    font-size: 14px;
    outline: none;
}
.comment-send {
    background: none;
    border: none;
    color: #0095f6;
    cursor: pointer;
    padding: 8px;
    font-size: 16px;
    transition: color 0.15s;
}
.comment-send:hover {
    color: #0081d6;
}

/* Comment List */
.comments-list {
    max-height: 500px;
    overflow-y: auto;
    padding: 8px 16px;
}
.empty-comments {
    text-align: center;
    color: #8e8e8e;
    padding: 24px 0;
    font-size: 14px;
}
.comment-item {
    display: flex;
    gap: 10px;
    padding: 8px 0;
}
.comment-body {
    flex: 1;
    min-width: 0;
}
.comment-bubble {
    background: #f0f2f5;
    border-radius: 12px;
    padding: 8px 12px;
}
.comment-author {
    font-weight: 600;
    font-size: 13px;
    color: #262626;
    text-decoration: none;
}
.comment-author:hover {
    text-decoration: underline;
}
.comment-text {
    margin: 2px 0 0;
    font-size: 14px;
    line-height: 1.4;
    white-space: pre-wrap;
    color: #262626;
}
.comment-meta {
    display: flex;
    gap: 12px;
    padding: 4px 12px;
}
.comment-time {
    font-size: 12px;
    color: #8e8e8e;
}
.comment-delete {
    font-size: 12px;
    color: #ed4956;
    text-decoration: none;
    font-weight: 600;
}
.comment-delete:hover {
    text-decoration: underline;
    color: #ed4956;
}

/* Sidebar */
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

.sidebar-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
    width: 100%;
    padding: 10px;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    text-decoration: none;
    transition: all 0.2s;
    margin-bottom: 8px;
}
.sidebar-btn.primary {
    background: #0095f6;
    color: #fff;
}
.sidebar-btn.primary:hover {
    background: #0081d6;
    color: #fff;
}
.sidebar-btn.default {
    background: #fff;
    color: #262626;
    border: 1px solid #dbdbdb;
}
.sidebar-btn.default:hover {
    background: #fafafa;
    color: #262626;
}

/* Detail list in sidebar */
.detail-list {
    display: flex;
    flex-direction: column;
    gap: 4px;
}
.detail-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 10px 12px;
    border-radius: 8px;
    transition: background 0.15s;
}
.detail-item:hover {
    background: #fafafa;
}
.detail-item i {
    font-size: 16px;
    color: #8e8e8e;
    width: 20px;
    text-align: center;
}
.detail-item-label {
    font-size: 12px;
    color: #8e8e8e;
    display: block;
}
.detail-item-value {
    font-size: 14px;
    color: #262626;
    font-weight: 500;
    display: block;
}

/* Stats grid */
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
}
.stat-value {
    font-size: 20px;
    font-weight: 700;
    color: #262626;
}
.stat-label {
    font-size: 11px;
    color: #8e8e8e;
    margin-top: 4px;
    text-align: center;
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

/* Responsive */
@media (max-width: 992px) {
    .fiche-sidebar {
        display: none;
    }
    .fiche-main {
        max-width: 100%;
    }
    .fiche-container {
        padding: 15px;
    }
    .detail-label {
        width: 120px;
    }
}
</style>

<script>
var hasLiked = <%= hasLiked %>;
var likeCount = <%= post.getNb_likes() %>;

function toggleMenu(postId) {
    var dropdown = document.getElementById('menu-' + postId);
    if (dropdown) {
        dropdown.classList.toggle('show');
    }
}

// Fermer le menu au clic en dehors
document.addEventListener('click', function(e) {
    if (!e.target.closest('.post-menu')) {
        var dropdowns = document.querySelectorAll('.menu-dropdown.show');
        dropdowns.forEach(function(d) { d.classList.remove('show'); });
    }
});

function toggleLike() {
    if (hasLiked) {
        if (confirm('Retirer votre J\'aime ?')) {
            window.location.href = '<%= lien %>?but=publication/save-publication-apj.jsp&acte=unlike&postId=<%= postId %>';
        }
    } else {
        window.location.href = '<%= lien %>?but=publication/save-publication-apj.jsp&acte=like&postId=<%= postId %>';
    }
}

function sharePost() {
    if (confirm('Partager cette publication sur votre profil ?')) {
        window.location.href = '<%= lien %>?but=publication/save-publication-apj.jsp&acte=share&postId=<%= postId %>';
    }
}

function focusCommentInput() {
    document.getElementById('commentInput').focus();
}

// Commentaires gérés par formulaire standard (pas AJAX)
</script>

<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'><h4><i class='fa fa-ban'></i> Erreur</h4><p>" + e.getMessage() + "</p></div>");
} %>
