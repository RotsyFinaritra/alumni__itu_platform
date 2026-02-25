<%@ page import="bean.*, utilitaire.Utilitaire, java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="user.UserEJB" %>
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
    StringBuilder apresWhere = new StringBuilder(" AND idstatutpublication = 'STPU00001'"); // Seulement publiés
    
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
    TypePublication[] typesPublication = (TypePublication[]) CGenUtil.rechercher(new TypePublication(), null, null, " AND actif = true ORDER BY ordre");
    VisibilitePublication[] visibilites = (VisibilitePublication[]) CGenUtil.rechercher(new VisibilitePublication(), null, null, " AND actif = true ORDER BY ordre");
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1>
            <i class="fa fa-newspaper-o"></i> Publications
            <small>Fil d'actualité</small>
        </h1>
    </section>
    
    <section class="content">
        <div class="row">
            <!-- Sidebar gauche (filtres) -->
            <div class="col-md-3">
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa fa-filter"></i> Filtres</h3>
                    </div>
                    <div class="box-body">
                        <form method="get" action="<%= lien %>">
                            <input type="hidden" name="but" value="publication/publication-liste.jsp">
                            
                            <div class="form-group">
                                <label>Type de publication</label>
                                <select name="type" class="form-control" onchange="this.form.submit()">
                                    <option value="">-- Tous --</option>
                                    <% if (typesPublication != null) {
                                        for (TypePublication tp : typesPublication) { %>
                                    <option value="<%= tp.getId() %>" <%= (tp.getId().equals(typePublicationFilter)) ? "selected" : "" %>>
                                        <%= tp.getLibelle() %>
                                    </option>
                                    <% }
                                    } %>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label>Visibilité</label>
                                <select name="visibilite" class="form-control" onchange="this.form.submit()">
                                    <option value="">-- Toutes --</option>
                                    <% if (visibilites != null) {
                                        for (VisibilitePublication vp : visibilites) { %>
                                    <option value="<%= vp.getId() %>" <%= (vp.getId().equals(visibiliteFilter)) ? "selected" : "" %>>
                                        <%= vp.getLibelle() %>
                                    </option>
                                    <% }
                                    } %>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label>Recherche</label>
                                <input type="text" name="q" class="form-control" placeholder="Mot-clé..." 
                                       value="<%= (searchQuery != null) ? searchQuery : "" %>">
                            </div>
                            
                            <button type="submit" class="btn btn-primary btn-block">
                                <i class="fa fa-search"></i> Rechercher
                            </button>
                            <% if (typePublicationFilter != null || visibiliteFilter != null || searchQuery != null) { %>
                            <a href="<%= lien %>?but=publication/publication-liste.jsp" class="btn btn-default btn-block">
                                <i class="fa fa-times"></i> Réinitialiser
                            </a>
                            <% } %>
                        </form>
                    </div>
                </div>
                
                <!-- Bouton créer publication -->
                <a href="<%= lien %>?but=publication/publication-saisie.jsp" class="btn btn-success btn-block btn-lg">
                    <i class="fa fa-plus"></i> Nouvelle publication
                </a>
            </div>
            
            <!-- Zone principale (feed) -->
            <div class="col-md-9">
                <% if (posts == null || posts.length == 0) { %>
                <div class="box box-default">
                    <div class="box-body text-center" style="padding: 50px;">
                        <i class="fa fa-inbox" style="font-size: 64px; color: #ccc;"></i>
                        <h4 style="margin-top: 20px;">Aucune publication trouvée</h4>
                        <p class="text-muted">Soyez le premier à publier quelque chose !</p>
                        <a href="<%= lien %>?but=publication/publication-saisie.jsp" class="btn btn-primary">
                            <i class="fa fa-plus"></i> Créer une publication
                        </a>
                    </div>
                </div>
                <% } else {
                    for (Object o : posts) {
                        Post post = (Post) o;
                        
                        // Charger l'auteur
                        UtilisateurAcade auteur = new UtilisateurAcade();
                        auteur.setRefuser(post.getIdutilisateur());
                        Object[] auteurResult = CGenUtil.rechercher(auteur, null, null, "");
                        String nomAuteur = "Utilisateur inconnu";
                        String photoAuteur = "assets/img/default-avatar.png";
                        if (auteurResult != null && auteurResult.length > 0) {
                            auteur = (UtilisateurAcade) auteurResult[0];
                            nomAuteur = (auteur.getNomuser() != null ? auteur.getNomuser() : "") + " " + (auteur.getPrenom() != null ? auteur.getPrenom() : "");
                            if (auteur.getPhoto() != null && !auteur.getPhoto().isEmpty()) {
                                photoAuteur = auteur.getPhoto();
                            }
                        }
                        
                        // Charger le type de publication
                        TypePublication typePost = new TypePublication();
                        typePost.setId(post.getIdtypepublication());
                        Object[] typeResult = CGenUtil.rechercher(typePost, null, null, "");
                        String typeLibelle = "";
                        String typeIcon = "fa-file-text-o";
                        if (typeResult != null && typeResult.length > 0) {
                            typePost = (TypePublication) typeResult[0];
                            typeLibelle = typePost.getLibelle();
                            if ("TYP00001".equals(typePost.getId())) typeIcon = "fa-briefcase";
                            else if ("TYP00002".equals(typePost.getId())) typeIcon = "fa-graduation-cap";
                            else if ("TYP00003".equals(typePost.getId())) typeIcon = "fa-calendar";
                            else if ("TYP00004".equals(typePost.getId())) typeIcon = "fa-comments";
                        }
                        
                        // Determiner la couleur selon le type
                        String boxClass = "box-default";
                        if ("TYP00001".equals(post.getIdtypepublication())) boxClass = "box-primary";
                        else if ("TYP00002".equals(post.getIdtypepublication())) boxClass = "box-info";
                        else if ("TYP00003".equals(post.getIdtypepublication())) boxClass = "box-warning";
                        
                        // Formatter la date
                        SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy HH:mm");
                        String dateAffichage = sdf.format(post.getCreated_at());
                        
                        // Vérifier si l'utilisateur a déjà liké
                        Like likeChk = new Like();
                        Object[] likeChkRes = CGenUtil.rechercher(likeChk, null, null, " AND post_id = '" + post.getId() + "' AND idutilisateur = " + refuserInt);
                        boolean postLiked = (likeChkRes != null && likeChkRes.length > 0);
                %>
                
                <!-- Post Card -->
                <div class="box <%= boxClass %>">
                    <div class="box-header with-border">
                        <div class="user-block">
                            <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= post.getIdutilisateur() %>">
                                <img class="img-circle" src="<%= photoAuteur %>" alt="Photo <%= nomAuteur %>" 
                                     style="width: 40px; height: 40px; cursor: pointer;">
                            </a>
                            <span class="username">
                                <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= post.getIdutilisateur() %>">
                                    <%= nomAuteur %>
                                </a>
                            </span>
                            <span class="description">
                                <i class="fa <%= typeIcon %>"></i> <%= typeLibelle %> - <%= dateAffichage %>
                            </span>
                        </div>
                        <div class="box-tools pull-right">
                            <% if (post.getIdutilisateur() == refuserInt) { %>
                            <a href="<%= lien %>?but=publication/publication-saisie.jsp&id=<%= post.getId() %>" 
                               class="btn btn-box-tool" title="Modifier">
                                <i class="fa fa-edit"></i>
                            </a>
                            <% } %>
                            <a href="<%= lien %>?but=publication/publication-fiche.jsp&id=<%= post.getId() %>" 
                               class="btn btn-box-tool" title="Voir détails">
                                <i class="fa fa-eye"></i>
                            </a>
                        </div>
                    </div>
                    
                    <div class="box-body">
                        <p style="white-space: pre-wrap; font-size: 14px;"><%= post.getContenu() %></p>
                        
                        <% 
                        // Afficher les détails selon le type
                        if ("TYP00001".equals(post.getIdtypepublication())) {
                            // Stage
                            PostStage stage = new PostStage();
                            stage.setPost_id(post.getId());
                            Object[] stageResult = CGenUtil.rechercher(stage, null, null, "");
                            if (stageResult != null && stageResult.length > 0) {
                                stage = (PostStage) stageResult[0];
                        %>
                        <div class="detail-summary detail-summary-stage" style="margin-top: 12px; padding: 12px 16px; border-radius: 8px; background: #eaf4fd; border-left: 4px solid #3498db;">
                            <strong><i class="fa fa-building-o"></i> <%= stage.getEntreprise() != null ? stage.getEntreprise() : "" %></strong>
                            <div style="margin-top: 6px; font-size: 13px; color: #555; display: flex; flex-wrap: wrap; gap: 10px;">
                                <% if (stage.getLocalisation() != null && !stage.getLocalisation().isEmpty()) { %>
                                <span><i class="fa fa-map-marker"></i> <%= stage.getLocalisation() %></span>
                                <% } %>
                                <% if (stage.getDuree() != null && !stage.getDuree().isEmpty()) { %>
                                <span><i class="fa fa-clock-o"></i> <%= stage.getDuree() %></span>
                                <% } %>
                                <% if (stage.getIndemnite() > 0) { %>
                                <span style="color: #e65100; font-weight: 600;"><i class="fa fa-money"></i> <%= String.format("%,.0f", stage.getIndemnite()) %> Ar</span>
                                <% } %>
                            </div>
                        </div>
                        <% 
                            }
                        } else if ("TYP00002".equals(post.getIdtypepublication())) {
                            // Emploi
                            PostEmploi emploi = new PostEmploi();
                            emploi.setPost_id(post.getId());
                            Object[] emploiResult = CGenUtil.rechercher(emploi, null, null, "");
                            if (emploiResult != null && emploiResult.length > 0) {
                                emploi = (PostEmploi) emploiResult[0];
                        %>
                        <div class="detail-summary detail-summary-emploi" style="margin-top: 12px; padding: 12px 16px; border-radius: 8px; background: #e8f5e9; border-left: 4px solid #2ecc71;">
                            <strong><i class="fa fa-building-o"></i> <%= emploi.getEntreprise() != null ? emploi.getEntreprise() : "" %></strong>
                            <% if (emploi.getPoste() != null && !emploi.getPoste().isEmpty()) { %>
                            <span style="margin-left: 8px; color: #333;">- <%= emploi.getPoste() %></span>
                            <% } %>
                            <div style="margin-top: 6px; font-size: 13px; color: #555; display: flex; flex-wrap: wrap; gap: 10px;">
                                <% if (emploi.getLocalisation() != null && !emploi.getLocalisation().isEmpty()) { %>
                                <span><i class="fa fa-map-marker"></i> <%= emploi.getLocalisation() %></span>
                                <% } %>
                                <% if (emploi.getType_contrat() != null && !emploi.getType_contrat().isEmpty()) { %>
                                <span><i class="fa fa-file-text-o"></i> <%= emploi.getType_contrat() %></span>
                                <% } %>
                                <% if (emploi.getSalaire_min() > 0 || emploi.getSalaire_max() > 0) { %>
                                <span style="color: #e65100; font-weight: 600;"><i class="fa fa-money"></i> 
                                    <%= (emploi.getSalaire_min() > 0 ? String.format("%,.0f", emploi.getSalaire_min()) : "") %>
                                    <%= (emploi.getSalaire_min() > 0 && emploi.getSalaire_max() > 0 ? " - " : "") %>
                                    <%= (emploi.getSalaire_max() > 0 ? String.format("%,.0f", emploi.getSalaire_max()) : "") %> Ar
                                </span>
                                <% } %>
                            </div>
                        </div>
                        <% 
                            }
                        } else if ("TYP00003".equals(post.getIdtypepublication())) {
                            // Activité
                            PostActivite activite = new PostActivite();
                            activite.setPost_id(post.getId());
                            Object[] activiteResult = CGenUtil.rechercher(activite, null, null, "");
                            if (activiteResult != null && activiteResult.length > 0) {
                                activite = (PostActivite) activiteResult[0];
                                SimpleDateFormat sdfActivite = new SimpleDateFormat("dd/MM/yyyy");
                        %>
                        <div class="detail-summary detail-summary-activite" style="margin-top: 12px; padding: 12px 16px; border-radius: 8px; background: #fce4ec; border-left: 4px solid #e74c3c;">
                            <strong><i class="fa fa-calendar"></i> <%= activite.getTitre() != null ? activite.getTitre() : "" %></strong>
                            <div style="margin-top: 6px; font-size: 13px; color: #555; display: flex; flex-wrap: wrap; gap: 10px;">
                                <% if (activite.getLieu() != null && !activite.getLieu().isEmpty()) { %>
                                <span><i class="fa fa-map-marker"></i> <%= activite.getLieu() %></span>
                                <% } %>
                                <% if (activite.getDate_debut() != null) { %>
                                <span><i class="fa fa-calendar-check-o"></i> <%= sdfActivite.format(activite.getDate_debut()) %></span>
                                <% } %>
                                <% if (activite.getPrix() > 0) { %>
                                <span style="color: #e65100; font-weight: 600;"><i class="fa fa-ticket"></i> <%= String.format("%,.0f", activite.getPrix()) %> Ar</span>
                                <% } else { %>
                                <span style="color: #2e7d32;"><i class="fa fa-gift"></i> Gratuit</span>
                                <% } %>
                            </div>
                        </div>
                        <% 
                            }
                        }
                        %>
                    </div>
                    
                    <div class="box-footer">
                        <div class="row">
                            <div class="col-xs-4">
                                <a href="javascript:void(0)" onclick="likePost('<%= post.getId() %>')" 
                                   class="btn btn-sm <%= postLiked ? "btn-danger" : "btn-default" %>">
                                    <i class="fa <%= postLiked ? "fa-heart" : "fa-heart-o" %>"></i> J'aime 
                                    <span class="badge"><%= post.getNb_likes() %></span>
                                </a>
                            </div>
                            <div class="col-xs-4">
                                <a href="<%= lien %>?but=publication/publication-fiche.jsp&id=<%= post.getId() %>" 
                                   class="btn btn-default btn-sm">
                                    <i class="fa fa-comment"></i> Commenter 
                                    <span class="badge"><%= post.getNb_commentaires() %></span>
                                </a>
                            </div>
                            <div class="col-xs-4">
                                <a href="javascript:void(0)" onclick="sharePost('<%= post.getId() %>')" 
                                   class="btn btn-default btn-sm">
                                    <i class="fa fa-share"></i> Partager 
                                    <span class="badge"><%= post.getNb_partages() %></span>
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                
                <% 
                    }
                } %>
                
                <!-- Pagination -->
                <% if (totalPages > 1) { %>
                <div class="text-center">
                    <ul class="pagination">
                        <% if (page > 1) { %>
                        <li>
                            <a href="<%= lien %>?but=publication/publication-liste.jsp&page=<%= page - 1 %><%= (typePublicationFilter != null ? "&type=" + typePublicationFilter : "") %><%= (visibiliteFilter != null ? "&visibilite=" + visibiliteFilter : "") %><%= (searchQuery != null ? "&q=" + searchQuery : "") %>">
                                &laquo;
                            </a>
                        </li>
                        <% } %>
                        
                        <% for (int i = Math.max(1, page - 2); i <= Math.min(totalPages, page + 2); i++) { %>
                        <li class="<%= (i == page) ? "active" : "" %>">
                            <a href="<%= lien %>?but=publication/publication-liste.jsp&page=<%= i %><%= (typePublicationFilter != null ? "&type=" + typePublicationFilter : "") %><%= (visibiliteFilter != null ? "&visibilite=" + visibiliteFilter : "") %><%= (searchQuery != null ? "&q=" + searchQuery : "") %>">
                                <%= i %>
                            </a>
                        </li>
                        <% } %>
                        
                        <% if (page < totalPages) { %>
                        <li>
                            <a href="<%= lien %>?but=publication/publication-liste.jsp&page=<%= page + 1 %><%= (typePublicationFilter != null ? "&type=" + typePublicationFilter : "") %><%= (visibiliteFilter != null ? "&visibilite=" + visibiliteFilter : "") %><%= (searchQuery != null ? "&q=" + searchQuery : "") %>">
                                &raquo;
                            </a>
                        </li>
                        <% } %>
                    </ul>
                </div>
                <% } %>
                
            </div>
        </div>
    </section>
</div>

<script>
function likePost(postId) {
    window.location.href = '<%= lien %>?but=publication/apresPublication.jsp&acte=like&id=' + postId + '&bute=publication/publication-liste.jsp';
}

function sharePost(postId) {
    if (confirm('Partager cette publication ?')) {
        window.location.href = '<%= lien %>?but=publication/apresPublication.jsp&acte=share&id=' + postId + '&bute=publication/publication-liste.jsp';
    }
}
</script>

<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'><h4><i class='fa fa-ban'></i> Erreur</h4><p>" + e.getMessage() + "</p></div>");
} %>
