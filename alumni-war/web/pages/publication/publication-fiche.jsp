<%@ page import="bean.*, affichage.*, utilitaire.Utilitaire, java.util.*" %>
<%@ page import="user.UserEJB" %>
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
    
    // Charger le post
    Post post = new Post();
    post.setId(postId);
    Object[] postResult = CGenUtil.rechercher(post, null, null, "");
    if (postResult == null || postResult.length == 0) {
        throw new Exception("Publication introuvable");
    }
    post = (Post) postResult[0];
    
    // Charger l'auteur
    UtilisateurAcade auteur = new UtilisateurAcade();
    auteur.setRefuser(post.getIdutilisateur());
    Object[] auteurResult = CGenUtil.rechercher(auteur, null, null, "");
    String nomAuteur = "Utilisateur inconnu";
    String photoAuteur = "assets/img/default-avatar.png";
    String emailAuteur = "";
    if (auteurResult != null && auteurResult.length > 0) {
        auteur = (UtilisateurAcade) auteurResult[0];
        nomAuteur = auteur.getNomPrenom();
        emailAuteur = auteur.getEmail();
        if (auteur.getPhoto() != null && !auteur.getPhoto().isEmpty()) {
            photoAuteur = auteur.getPhoto();
        }
    }
    
    // Charger le type de publication
    TypePublication typePost = new TypePublication();
    typePost.setId(post.getIdtypepublication());
    Object[] typeResult = CGenUtil.rechercher(typePost, null, null, "");
    String typeLibelle = "";
    if (typeResult != null && typeResult.length > 0) {
        typePost = (TypePublication) typeResult[0];
        typeLibelle = typePost.getLibelle();
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
    
    // Charger les commentaires (sans parent = top-level)
    Commentaire commentaireFilter = new Commentaire();
    commentaireFilter.setPost_id(postId);
    Object[] commentaires = CGenUtil.rechercher(commentaireFilter, null, null, " AND parent_id IS NULL ORDER BY created_at DESC");
    
    // Vérifier si l'utilisateur a liké
    Like likeFilter = new Like();
    likeFilter.setIdutilisateur(refuserInt);
    likeFilter.setPost_id(postId);
    Object[] likeResult = CGenUtil.rechercher(likeFilter, null, null, "");
    boolean hasLiked = (likeResult != null && likeResult.length > 0);
    
    boolean isOwner = (post.getIdutilisateur() == refuserInt);
    String dateAffichage = Utilitaire.formatterDaty(post.getCreated_at());
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1>
            <i class="fa fa-newspaper-o"></i> Publication
            <small>Détails</small>
        </h1>
        <ol class="breadcrumb">
            <li><a href="<%= lien %>?but=pages/accueil.jsp"><i class="fa fa-home"></i> Accueil</a></li>
            <li><a href="<%= lien %>?but=publication/publication-liste.jsp">Publications</a></li>
            <li class="active">Détail</li>
        </ol>
    </section>
    
    <section class="content">
        <div class="row">
            <div class="col-md-8">
                <!-- Post principal -->
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <div class="user-block">
                            <img class="img-circle" src="<%= photoAuteur %>" alt="Photo <%= nomAuteur %>" 
                                 style="width: 50px; height: 50px;">
                            <span class="username">
                                <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= post.getIdutilisateur() %>">
                                    <%= nomAuteur %>
                                </a>
                            </span>
                            <span class="description">
                                Publié le <%= dateAffichage %>
                            </span>
                        </div>
                        <div class="box-tools pull-right">
                            <% if (isOwner) { %>
                            <a href="<%= lien %>?but=publication/publication-saisie.jsp&id=<%= postId %>" 
                               class="btn btn-box-tool" title="Modifier">
                                <i class="fa fa-edit"></i>
                            </a>
                            <a href="<%= lien %>?but=publication/save-publication-apj.jsp&acte=delete&id=<%= postId %>" 
                               class="btn btn-box-tool" title="Supprimer" 
                               onclick="return confirm('Voulez-vous vraiment supprimer cette publication ?');">
                                <i class="fa fa-trash text-danger"></i>
                            </a>
                            <% } %>
                        </div>
                    </div>
                    
                    <div class="box-body">
                        <h3 style="margin-top: 0;">
                            <span class="label label-<%= "TYPU00001".equals(post.getIdtypepublication()) ? "primary" : "TYPU00002".equals(post.getIdtypepublication()) ? "info" : "TYPU00003".equals(post.getIdtypepublication()) ? "warning" : "default" %>">
                                <%= typeLibelle %>
                            </span>
                        </h3>
                        
                        <p style="white-space: pre-wrap; font-size: 16px; line-height: 1.6;"><%= post.getContenu() %></p>
                        
                        <!-- Détails selon le type -->
                        <% if (stage != null) { %>
                        <div class="well" style="margin-top: 20px;">
                            <h4><i class="fa fa-briefcase"></i> Informations sur le stage</h4>
                            <table class="table table-striped" style="margin-bottom: 0;">
                                <tr>
                                    <th style="width: 200px;">Entreprise</th>
                                    <td><strong><%= stage.getEntreprise() %></strong></td>
                                </tr>
                                <% if (stage.getLocalisation() != null && !stage.getLocalisation().isEmpty()) { %>
                                <tr>
                                    <th>Localisation</th>
                                    <td><i class="fa fa-map-marker"></i> <%= stage.getLocalisation() %></td>
                                </tr>
                                <% } %>
                                <% if (stage.getDuree() != null && !stage.getDuree().isEmpty()) { %>
                                <tr>
                                    <th>Durée</th>
                                    <td><i class="fa fa-clock-o"></i> <%= stage.getDuree() %></td>
                                </tr>
                                <% } %>
                                <% if (stage.getIndemnite() != null && !stage.getIndemnite().isEmpty()) { %>
                                <tr>
                                    <th>Indemnité</th>
                                    <td><i class="fa fa-money"></i> <%= stage.getIndemnite() %></td>
                                </tr>
                                <% } %>
                                <% if (stage.getCompetences_requises() != null && !stage.getCompetences_requises().isEmpty()) { %>
                                <tr>
                                    <th>Compétences requises</th>
                                    <td><%= stage.getCompetences_requises() %></td>
                                </tr>
                                <% } %>
                                <% if (stage.getLien_candidature() != null && !stage.getLien_candidature().isEmpty()) { %>
                                <tr>
                                    <th>Candidature</th>
                                    <td><a href="<%= stage.getLien_candidature() %>" target="_blank" class="btn btn-success btn-sm">
                                        <i class="fa fa-external-link"></i> Postuler
                                    </a></td>
                                </tr>
                                <% } %>
                            </table>
                        </div>
                        <% } else if (emploi != null) { %>
                        <div class="well" style="margin-top: 20px;">
                            <h4><i class="fa fa-graduation-cap"></i> Informations sur l'emploi</h4>
                            <table class="table table-striped" style="margin-bottom: 0;">
                                <tr>
                                    <th style="width: 200px;">Entreprise</th>
                                    <td><strong><%= emploi.getEntreprise() %></strong></td>
                                </tr>
                                <tr>
                                    <th>Poste</th>
                                    <td><strong><%= emploi.getPoste() %></strong></td>
                                </tr>
                                <% if (emploi.getLocalisation() != null && !emploi.getLocalisation().isEmpty()) { %>
                                <tr>
                                    <th>Localisation</th>
                                    <td><i class="fa fa-map-marker"></i> <%= emploi.getLocalisation() %></td>
                                </tr>
                                <% } %>
                                <% if (emploi.getType_contrat() != null && !emploi.getType_contrat().isEmpty()) { %>
                                <tr>
                                    <th>Type de contrat</th>
                                    <td><%= emploi.getType_contrat() %></td>
                                </tr>
                                <% } %>
                                <% if (emploi.getSalaire_min() != null || emploi.getSalaire_max() != null) { %>
                                <tr>
                                    <th>Salaire</th>
                                    <td><i class="fa fa-money"></i> 
                                        <%= (emploi.getSalaire_min() != null ? emploi.getSalaire_min() + " Ar" : "") %>
                                        <%= (emploi.getSalaire_min() != null && emploi.getSalaire_max() != null ? " - " : "") %>
                                        <%= (emploi.getSalaire_max() != null ? emploi.getSalaire_max() + " Ar" : "") %>
                                    </td>
                                </tr>
                                <% } %>
                                <% if (emploi.getQualifications_requises() != null && !emploi.getQualifications_requises().isEmpty()) { %>
                                <tr>
                                    <th>Qualifications</th>
                                    <td><%= emploi.getQualifications_requises() %></td>
                                </tr>
                                <% } %>
                                <% if (emploi.getLien_candidature() != null && !emploi.getLien_candidature().isEmpty()) { %>
                                <tr>
                                    <th>Candidature</th>
                                    <td><a href="<%= emploi.getLien_candidature() %>" target="_blank" class="btn btn-success btn-sm">
                                        <i class="fa fa-external-link"></i> Postuler
                                    </a></td>
                                </tr>
                                <% } %>
                            </table>
                        </div>
                        <% } else if (activite != null) { %>
                        <div class="well" style="margin-top: 20px;">
                            <h4><i class="fa fa-calendar"></i> Informations sur l'activité</h4>
                            <table class="table table-striped" style="margin-bottom: 0;">
                                <tr>
                                    <th style="width: 200px;">Événement</th>
                                    <td><strong><%= activite.getTitre_evenement() %></strong></td>
                                </tr>
                                <% if (activite.getLieu() != null && !activite.getLieu().isEmpty()) { %>
                                <tr>
                                    <th>Lieu</th>
                                    <td><i class="fa fa-map-marker"></i> <%= activite.getLieu() %></td>
                                </tr>
                                <% } %>
                                <% if (activite.getDate_debut() != null && !activite.getDate_debut().isEmpty()) { %>
                                <tr>
                                    <th>Date de début</th>
                                    <td><i class="fa fa-calendar"></i> <%= Utilitaire.formatterDaty(activite.getDate_debut()) %></td>
                                </tr>
                                <% } %>
                                <% if (activite.getDate_fin() != null && !activite.getDate_fin().isEmpty()) { %>
                                <tr>
                                    <th>Date de fin</th>
                                    <td><i class="fa fa-calendar"></i> <%= Utilitaire.formatterDaty(activite.getDate_fin()) %></td>
                                </tr>
                                <% } %>
                                <% if (activite.getPrix() != null && !activite.getPrix().isEmpty()) { %>
                                <tr>
                                    <th>Prix</th>
                                    <td><i class="fa fa-ticket"></i> <%= activite.getPrix() %></td>
                                </tr>
                                <% } %>
                                <% if (activite.getLien_inscription() != null && !activite.getLien_inscription().isEmpty()) { %>
                                <tr>
                                    <th>Inscription</th>
                                    <td><a href="<%= activite.getLien_inscription() %>" target="_blank" class="btn btn-success btn-sm">
                                        <i class="fa fa-external-link"></i> S'inscrire
                                    </a></td>
                                </tr>
                                <% } %>
                            </table>
                        </div>
                        <% } %>
                        
                        <!-- Fichiers joints -->
                        <% if (fichiers != null && fichiers.length > 0) { %>
                        <div style="margin-top: 20px;">
                            <h4><i class="fa fa-paperclip"></i> Fichiers joints (<%= fichiers.length %>)</h4>
                            <div class="list-group">
                                <% for (Object o : fichiers) {
                                    PostFichier fichier = (PostFichier) o;
                                    String iconClass = "fa-file-o";
                                    if (fichier.getIdtypefichier() != null) {
                                        if (fichier.getIdtypefichier().contains("IMAGE")) iconClass = "fa-file-image-o";
                                        else if (fichier.getIdtypefichier().contains("PDF")) iconClass = "fa-file-pdf-o";
                                        else if (fichier.getIdtypefichier().contains("DOCUMENT")) iconClass = "fa-file-word-o";
                                    }
                                %>
                                <a href="<%= fichier.getChemin_fichier() %>" target="_blank" class="list-group-item">
                                    <i class="fa <%= iconClass %>"></i> <%= fichier.getNom_fichier() %>
                                    <% if (fichier.getTaille_fichier() != null) { %>
                                    <small class="text-muted">(<%= fichier.getTaille_fichier() / 1024 %> Ko)</small>
                                    <% } %>
                                </a>
                                <% } %>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    
                    <div class="box-footer">
                        <div class="row">
                            <div class="col-xs-4">
                                <button onclick="toggleLike()" class="btn btn-<%= hasLiked ? "primary" : "default" %> btn-sm btn-block">
                                    <i class="fa fa-thumbs-up"></i> <span id="likeText"><%= hasLiked ? "Vous aimez" : "J'aime" %></span> 
                                    (<span id="likeCount"><%= post.getNb_likes() %></span>)
                                </button>
                            </div>
                            <div class="col-xs-4">
                                <button onclick="focusCommentInput()" class="btn btn-default btn-sm btn-block">
                                    <i class="fa fa-comment"></i> Commenter (<%= post.getNb_commentaires() %>)
                                </button>
                            </div>
                            <div class="col-xs-4">
                                <button onclick="sharePost()" class="btn btn-default btn-sm btn-block">
                                    <i class="fa fa-share"></i> Partager (<%= post.getNb_partages() %>)
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Section commentaires -->
                <div class="box box-default">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa fa-comments"></i> Commentaires (<%= (commentaires != null) ? commentaires.length : 0 %>)</h3>
                    </div>
                    <div class="box-body">
                        <!-- Formulaire nouveau commentaire -->
                        <form action="<%= lien %>?but=publication/save-publication-apj.jsp" method="post" class="form-horizontal">
                            <input type="hidden" name="acte" value="comment">
                            <input type="hidden" name="postId" value="<%= postId %>">
                            <div class="form-group" style="margin-bottom: 10px;">
                                <div class="col-sm-12">
                                    <textarea name="contenu" id="commentInput" class="form-control" rows="2" 
                                              placeholder="Écrire un commentaire..." required></textarea>
                                </div>
                            </div>
                            <div class="form-group" style="margin-bottom: 0;">
                                <div class="col-sm-12 text-right">
                                    <button type="submit" class="btn btn-primary btn-sm">
                                        <i class="fa fa-send"></i> Publier
                                    </button>
                                </div>
                            </div>
                        </form>
                        
                        <hr>
                        
                        <!-- Liste des commentaires -->
                        <% if (commentaires == null || commentaires.length == 0) { %>
                        <p class="text-muted text-center">Aucun commentaire pour le moment. Soyez le premier à commenter !</p>
                        <% } else {
                            for (Object o : commentaires) {
                                Commentaire comment = (Commentaire) o;
                                
                                // Charger l'auteur du commentaire
                                UtilisateurAcade commentAuteur = new UtilisateurAcade();
                                commentAuteur.setRefuser(comment.getIdutilisateur());
                                Object[] commentAuteurResult = CGenUtil.rechercher(commentAuteur, null, null, "");
                                String commentAuteurNom = "Utilisateur inconnu";
                                String commentAuteurPhoto = "assets/img/default-avatar.png";
                                if (commentAuteurResult != null && commentAuteurResult.length > 0) {
                                    commentAuteur = (UtilisateurAcade) commentAuteurResult[0];
                                    commentAuteurNom = commentAuteur.getNomPrenom();
                                    if (commentAuteur.getPhoto() != null && !commentAuteur.getPhoto().isEmpty()) {
                                        commentAuteurPhoto = commentAuteur.getPhoto();
                                    }
                                }
                                
                                String commentDate = Utilitaire.formatterDaty(comment.getCreated_at());
                                boolean isCommentOwner = (comment.getIdutilisateur() == refuserInt);
                        %>
                        <div class="media" style="margin-top: 15px;">
                            <div class="media-left">
                                <img src="<%= commentAuteurPhoto %>" class="img-circle" alt="<%= commentAuteurNom %>" 
                                     style="width: 40px; height: 40px;">
                            </div>
                            <div class="media-body">
                                <h5 class="media-heading">
                                    <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= comment.getIdutilisateur() %>">
                                        <%= commentAuteurNom %>
                                    </a>
                                    <small class="text-muted"><%= commentDate %></small>
                                    <% if (isCommentOwner) { %>
                                    <a href="<%= lien %>?but=publication/save-publication-apj.jsp&acte=deleteComment&id=<%= comment.getId() %>&postId=<%= postId %>" 
                                       class="pull-right text-danger" 
                                       onclick="return confirm('Supprimer ce commentaire ?');">
                                        <i class="fa fa-trash"></i>
                                    </a>
                                    <% } %>
                                </h5>
                                <p style="white-space: pre-wrap;"><%= comment.getContenu() %></p>
                            </div>
                        </div>
                        <% 
                            }
                        } %>
                    </div>
                </div>
            </div>
            
            <!-- Sidebar droite -->
            <div class="col-md-4">
                <!-- Informations sur l'auteur -->
                <div class="box box-widget widget-user">
                    <div class="widget-user-header bg-aqua-active">
                        <h3 class="widget-user-username"><%= nomAuteur %></h3>
                        <h5 class="widget-user-desc">Auteur de la publication</h5>
                    </div>
                    <div class="widget-user-image">
                        <img class="img-circle" src="<%= photoAuteur %>" alt="<%= nomAuteur %>" 
                             style="width: 90px; height: 90px;">
                    </div>
                    <div class="box-footer">
                        <div class="row">
                            <div class="col-sm-12 border-right">
                                <div class="description-block">
                                    <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= post.getIdutilisateur() %>" 
                                       class="btn btn-primary btn-block">
                                        <i class="fa fa-user"></i> Voir le profil
                                    </a>
                                    <% if (!isOwner && emailAuteur != null && !emailAuteur.isEmpty()) { %>
                                    <a href="mailto:<%= emailAuteur %>" class="btn btn-default btn-block" style="margin-top: 5px;">
                                        <i class="fa fa-envelope"></i> Contacter
                                    </a>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Détails de la publication -->
                <div class="box box-default">
                    <div class="box-header with-border">
                        <h3 class="box-title">Détails</h3>
                    </div>
                    <div class="box-body">
                        <strong><i class="fa fa-tag"></i> Type</strong>
                        <p class="text-muted"><%= typeLibelle %></p>
                        <hr>
                        
                        <strong><i class="fa fa-eye"></i> Visibilité</strong>
                        <p class="text-muted"><%= visibiliteLibelle %></p>
                        <hr>
                        
                        <strong><i class="fa fa-calendar"></i> Publié le</strong>
                        <p class="text-muted"><%= dateAffichage %></p>
                        
                        <% if (post.getUpdated_at() != null && !post.getUpdated_at().equals(post.getCreated_at())) { %>
                        <hr>
                        <strong><i class="fa fa-edit"></i> Modifié le</strong>
                        <p class="text-muted"><%= Utilitaire.formatterDaty(post.getUpdated_at()) %></p>
                        <% } %>
                    </div>
                </div>
                
                <!-- Retour aux publications -->
                <a href="<%= lien %>?but=publication/publication-liste.jsp" class="btn btn-default btn-block">
                    <i class="fa fa-arrow-left"></i> Retour aux publications
                </a>
            </div>
        </div>
    </section>
</div>

<script>
var hasLiked = <%= hasLiked %>;
var likeCount = <%= post.getNb_likes() %>;

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
</script>

<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'><h4><i class='fa fa-ban'></i> Erreur</h4><p>" + e.getMessage() + "</p></div>");
} %>
