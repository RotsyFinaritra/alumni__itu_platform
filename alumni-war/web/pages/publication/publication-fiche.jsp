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
        // Redirection vers la liste si publication introuvable
        response.sendRedirect(lien + "?but=publication/publication-liste.jsp&erreur=Publication%20introuvable");
        return;
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
    String entrepriseNom = "";
    String categorieActiviteNom = "";
    
    if ("TYP00001".equals(post.getIdtypepublication())) {
        PostStage stageFilter = new PostStage();
        stageFilter.setPost_id(postId);
        Object[] stageResult = CGenUtil.rechercher(stageFilter, null, null, "");
        if (stageResult != null && stageResult.length > 0) {
            stage = (PostStage) stageResult[0];
            // Charger le nom de l'entreprise
            if (stage.getIdentreprise() != null && !stage.getIdentreprise().isEmpty()) {
                Entreprise ent = new Entreprise();
                ent.setId(stage.getIdentreprise());
                Object[] entR = CGenUtil.rechercher(ent, null, null, "");
                if (entR != null && entR.length > 0) entrepriseNom = ((Entreprise) entR[0]).getLibelle();
            }
            if (entrepriseNom.isEmpty() && stage.getEntreprise() != null) entrepriseNom = stage.getEntreprise();
        }
    } else if ("TYP00002".equals(post.getIdtypepublication())) {
        PostEmploi emploiFilter = new PostEmploi();
        emploiFilter.setPost_id(postId);
        Object[] emploiResult = CGenUtil.rechercher(emploiFilter, null, null, "");
        if (emploiResult != null && emploiResult.length > 0) {
            emploi = (PostEmploi) emploiResult[0];
            // Charger le nom de l'entreprise
            if (emploi.getIdentreprise() != null && !emploi.getIdentreprise().isEmpty()) {
                Entreprise ent = new Entreprise();
                ent.setId(emploi.getIdentreprise());
                Object[] entR = CGenUtil.rechercher(ent, null, null, "");
                if (entR != null && entR.length > 0) entrepriseNom = ((Entreprise) entR[0]).getLibelle();
            }
            if (entrepriseNom.isEmpty() && emploi.getEntreprise() != null) entrepriseNom = emploi.getEntreprise();
        }
    } else if ("TYP00003".equals(post.getIdtypepublication())) {
        PostActivite activiteFilter = new PostActivite();
        activiteFilter.setPost_id(postId);
        Object[] activiteResult = CGenUtil.rechercher(activiteFilter, null, null, "");
        if (activiteResult != null && activiteResult.length > 0) {
            activite = (PostActivite) activiteResult[0];
            // Charger la catégorie
            if (activite.getIdcategorie() != null && !activite.getIdcategorie().isEmpty()) {
                CategorieActivite cat = new CategorieActivite();
                cat.setId(activite.getIdcategorie());
                Object[] catR = CGenUtil.rechercher(cat, null, null, "");
                if (catR != null && catR.length > 0) categorieActiviteNom = ((CategorieActivite) catR[0]).getLibelle();
            }
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
                <div class="post-menu">
                    <button class="menu-btn" onclick="toggleMenu('<%= postId %>')">
                        <i class="fa fa-ellipsis-h"></i>
                    </button>
                    <div class="menu-dropdown" id="menu-<%= postId %>">
                        <% if (isOwner) { %>
                        <a href="<%= lien %>?but=publication/publication-saisie.jsp&id=<%= postId %>"><i class="fa fa-edit"></i> Modifier</a>
                        <a href="<%= lien %>?but=publication/apresPublication.jsp&acte=supprimer&id=<%= postId %>&bute=publication/publication-liste.jsp"
                           onclick="return confirm('Voulez-vous vraiment supprimer cette publication ?');">
                            <i class="fa fa-trash"></i> Supprimer
                        </a>
                        <% } else { %>
                        <a href="<%= lien %>?but=publication/signalement-saisie.jsp&post_id=<%= postId %>">
                            <i class="fa fa-flag" style="color:#e74c3c"></i> Signaler
                        </a>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Contenu -->
            <div class="post-content">
                <p><%= post.getContenu() != null ? post.getContenu() : "" %></p>
            </div>

            <!-- ===== DÉTAILS STAGE ===== -->
            <% if (stage != null) { %>
            <div class="detail-card detail-stage">
                <div class="detail-card-header">
                    <div class="detail-card-icon stage-icon"><i class="fa fa-briefcase"></i></div>
                    <div class="detail-card-title">
                        <h3>Offre de Stage</h3>
                        <% if (!entrepriseNom.isEmpty()) { %>
                        <span class="detail-company"><i class="fa fa-building-o"></i> <%= entrepriseNom %></span>
                        <% } %>
                    </div>
                </div>
                <div class="detail-card-body">
                    <div class="detail-grid">
                        <% if (stage.getLocalisation() != null && !stage.getLocalisation().isEmpty()) { %>
                        <div class="detail-chip"><i class="fa fa-map-marker"></i> <%= stage.getLocalisation() %></div>
                        <% } %>
                        <% if (stage.getDuree() != null && !stage.getDuree().isEmpty()) { %>
                        <div class="detail-chip"><i class="fa fa-clock-o"></i> <%= stage.getDuree() %></div>
                        <% } %>
                        <% if (stage.getIndemnite() > 0) { %>
                        <div class="detail-chip highlight"><i class="fa fa-money"></i> <%= String.format("%,.0f", stage.getIndemnite()) %> Ar</div>
                        <% } %>
                        <% if (stage.getNiveau_etude_requis() != null && !stage.getNiveau_etude_requis().isEmpty()) { %>
                        <div class="detail-chip"><i class="fa fa-graduation-cap"></i> <%= stage.getNiveau_etude_requis() %></div>
                        <% } %>
                        <% if (stage.getPlaces_disponibles() > 0) { %>
                        <div class="detail-chip"><i class="fa fa-users"></i> <%= stage.getPlaces_disponibles() %> place<%= stage.getPlaces_disponibles() > 1 ? "s" : "" %></div>
                        <% } %>
                        <% if (stage.getConvention_requise() == 1) { %>
                        <div class="detail-chip"><i class="fa fa-file-text-o"></i> Convention requise</div>
                        <% } %>
                    </div>
                    <% if (stage.getDate_debut() != null || stage.getDate_fin() != null) { %>
                    <div class="detail-dates">
                        <i class="fa fa-calendar"></i>
                        <% if (stage.getDate_debut() != null) { %>Du <strong><%= new SimpleDateFormat("dd/MM/yyyy").format(stage.getDate_debut()) %></strong><% } %>
                        <% if (stage.getDate_fin() != null) { %> au <strong><%= new SimpleDateFormat("dd/MM/yyyy").format(stage.getDate_fin()) %></strong><% } %>
                    </div>
                    <% } %>
                    <% if ((stage.getContact_email() != null && !stage.getContact_email().isEmpty()) || 
                           (stage.getContact_tel() != null && !stage.getContact_tel().isEmpty())) { %>
                    <div class="detail-contact">
                        <% if (stage.getContact_email() != null && !stage.getContact_email().isEmpty()) { %>
                        <a href="mailto:<%= stage.getContact_email() %>" class="contact-link"><i class="fa fa-envelope"></i> <%= stage.getContact_email() %></a>
                        <% } %>
                        <% if (stage.getContact_tel() != null && !stage.getContact_tel().isEmpty()) { %>
                        <a href="tel:<%= stage.getContact_tel() %>" class="contact-link"><i class="fa fa-phone"></i> <%= stage.getContact_tel() %></a>
                        <% } %>
                    </div>
                    <% } %>
                </div>
                <% if (stage.getLien_candidature() != null && !stage.getLien_candidature().isEmpty()) { %>
                <div class="detail-card-footer">
                    <a href="<%= stage.getLien_candidature() %>" target="_blank" class="btn-postuler">
                        <i class="fa fa-paper-plane"></i> Postuler maintenant
                    </a>
                </div>
                <% } %>
            </div>

            <% } else if (emploi != null) { %>
            <!-- ===== DÉTAILS EMPLOI ===== -->
            <div class="detail-card detail-emploi">
                <div class="detail-card-header">
                    <div class="detail-card-icon emploi-icon"><i class="fa fa-suitcase"></i></div>
                    <div class="detail-card-title">
                        <h3><%= emploi.getPoste() != null && !emploi.getPoste().isEmpty() ? emploi.getPoste() : "Offre d'emploi" %></h3>
                        <% if (!entrepriseNom.isEmpty()) { %>
                        <span class="detail-company"><i class="fa fa-building-o"></i> <%= entrepriseNom %></span>
                        <% } %>
                    </div>
                </div>
                <div class="detail-card-body">
                    <div class="detail-grid">
                        <% if (emploi.getLocalisation() != null && !emploi.getLocalisation().isEmpty()) { %>
                        <div class="detail-chip"><i class="fa fa-map-marker"></i> <%= emploi.getLocalisation() %></div>
                        <% } %>
                        <% if (emploi.getType_contrat() != null && !emploi.getType_contrat().isEmpty()) { %>
                        <div class="detail-chip"><i class="fa fa-file-text-o"></i> <%= emploi.getType_contrat() %></div>
                        <% } %>
                        <% if (emploi.getSalaire_min() > 0 || emploi.getSalaire_max() > 0) { %>
                        <div class="detail-chip highlight"><i class="fa fa-money"></i>
                            <%= (emploi.getSalaire_min() > 0 ? String.format("%,.0f", emploi.getSalaire_min()) : "") %>
                            <%= (emploi.getSalaire_min() > 0 && emploi.getSalaire_max() > 0 ? " - " : "") %>
                            <%= (emploi.getSalaire_max() > 0 ? String.format("%,.0f", emploi.getSalaire_max()) : "") %>
                            <%= (emploi.getDevise() != null && !emploi.getDevise().isEmpty() ? emploi.getDevise() : "Ar") %>
                        </div>
                        <% } %>
                        <% if (emploi.getExperience_requise() != null && !emploi.getExperience_requise().isEmpty()) { %>
                        <div class="detail-chip"><i class="fa fa-star"></i> <%= emploi.getExperience_requise() %></div>
                        <% } %>
                        <% if (emploi.getNiveau_etude_requis() != null && !emploi.getNiveau_etude_requis().isEmpty()) { %>
                        <div class="detail-chip"><i class="fa fa-graduation-cap"></i> <%= emploi.getNiveau_etude_requis() %></div>
                        <% } %>
                        <% if (emploi.getTeletravail_possible() == 1) { %>
                        <div class="detail-chip success"><i class="fa fa-home"></i> T&eacute;l&eacute;travail possible</div>
                        <% } %>
                    </div>
                    <% if (emploi.getDate_limite() != null) { %>
                    <div class="detail-dates">
                        <i class="fa fa-hourglass-end"></i> Date limite : <strong><%= new SimpleDateFormat("dd/MM/yyyy").format(emploi.getDate_limite()) %></strong>
                    </div>
                    <% } %>
                    <% if ((emploi.getContact_email() != null && !emploi.getContact_email().isEmpty()) || 
                           (emploi.getContact_tel() != null && !emploi.getContact_tel().isEmpty())) { %>
                    <div class="detail-contact">
                        <% if (emploi.getContact_email() != null && !emploi.getContact_email().isEmpty()) { %>
                        <a href="mailto:<%= emploi.getContact_email() %>" class="contact-link"><i class="fa fa-envelope"></i> <%= emploi.getContact_email() %></a>
                        <% } %>
                        <% if (emploi.getContact_tel() != null && !emploi.getContact_tel().isEmpty()) { %>
                        <a href="tel:<%= emploi.getContact_tel() %>" class="contact-link"><i class="fa fa-phone"></i> <%= emploi.getContact_tel() %></a>
                        <% } %>
                    </div>
                    <% } %>
                </div>
                <% if (emploi.getLien_candidature() != null && !emploi.getLien_candidature().isEmpty()) { %>
                <div class="detail-card-footer">
                    <a href="<%= emploi.getLien_candidature() %>" target="_blank" class="btn-postuler">
                        <i class="fa fa-paper-plane"></i> Postuler maintenant
                    </a>
                </div>
                <% } %>
            </div>

            <% } else if (activite != null) { %>
            <!-- ===== DÉTAILS ACTIVITÉ ===== -->
            <div class="detail-card detail-activite">
                <div class="detail-card-header">
                    <div class="detail-card-icon activite-icon"><i class="fa fa-calendar"></i></div>
                    <div class="detail-card-title">
                        <h3><%= activite.getTitre() != null && !activite.getTitre().isEmpty() ? activite.getTitre() : "&Eacute;v&eacute;nement" %></h3>
                        <% if (!categorieActiviteNom.isEmpty()) { %>
                        <span class="detail-company"><i class="fa fa-tag"></i> <%= categorieActiviteNom %></span>
                        <% } %>
                    </div>
                </div>
                <div class="detail-card-body">
                    <div class="detail-grid">
                        <% if (activite.getLieu() != null && !activite.getLieu().isEmpty()) { %>
                        <div class="detail-chip"><i class="fa fa-map-marker"></i> <%= activite.getLieu() %></div>
                        <% } %>
                        <% if (activite.getAdresse() != null && !activite.getAdresse().isEmpty()) { %>
                        <div class="detail-chip"><i class="fa fa-map"></i> <%= activite.getAdresse() %></div>
                        <% } %>
                        <% if (activite.getPrix() > 0) { %>
                        <div class="detail-chip highlight"><i class="fa fa-ticket"></i> <%= String.format("%,.0f", activite.getPrix()) %> Ar</div>
                        <% } else { %>
                        <div class="detail-chip success"><i class="fa fa-gift"></i> Gratuit</div>
                        <% } %>
                        <% if (activite.getNombre_places() > 0) { %>
                        <div class="detail-chip"><i class="fa fa-users"></i> <%= activite.getPlaces_restantes() %>/<%= activite.getNombre_places() %> places</div>
                        <% } %>
                    </div>
                    <% if (activite.getDate_debut() != null || activite.getDate_fin() != null) { %>
                    <div class="detail-dates">
                        <i class="fa fa-calendar"></i>
                        <% if (activite.getDate_debut() != null) { %>Du <strong><%= sdf.format(activite.getDate_debut()) %></strong><% } %>
                        <% if (activite.getDate_fin() != null) { %> au <strong><%= sdf.format(activite.getDate_fin()) %></strong><% } %>
                    </div>
                    <% } %>
                    <% if ((activite.getContact_email() != null && !activite.getContact_email().isEmpty()) || 
                           (activite.getContact_tel() != null && !activite.getContact_tel().isEmpty())) { %>
                    <div class="detail-contact">
                        <% if (activite.getContact_email() != null && !activite.getContact_email().isEmpty()) { %>
                        <a href="mailto:<%= activite.getContact_email() %>" class="contact-link"><i class="fa fa-envelope"></i> <%= activite.getContact_email() %></a>
                        <% } %>
                        <% if (activite.getContact_tel() != null && !activite.getContact_tel().isEmpty()) { %>
                        <a href="tel:<%= activite.getContact_tel() %>" class="contact-link"><i class="fa fa-phone"></i> <%= activite.getContact_tel() %></a>
                        <% } %>
                    </div>
                    <% } %>
                    <% if (activite.getLien_externe() != null && !activite.getLien_externe().isEmpty()) { %>
                    <div class="detail-contact">
                        <a href="<%= activite.getLien_externe() %>" target="_blank" class="contact-link"><i class="fa fa-external-link"></i> Site web</a>
                    </div>
                    <% } %>
                </div>
                <% if (activite.getLien_inscription() != null && !activite.getLien_inscription().isEmpty()) { %>
                <div class="detail-card-footer">
                    <a href="<%= activite.getLien_inscription() %>" target="_blank" class="btn-postuler btn-inscrire">
                        <i class="fa fa-check-circle"></i> S'inscrire
                    </a>
                </div>
                <% } %>
            </div>
            <% } %>

            <!-- Fichiers joints (images, vidéos, documents) -->
            <% if (fichiers != null && fichiers.length > 0) {
                // Séparer par type
                java.util.List<PostFichier> images = new java.util.ArrayList<>();
                java.util.List<PostFichier> videos = new java.util.ArrayList<>();
                java.util.List<PostFichier> documents = new java.util.ArrayList<>();
                for (Object o : fichiers) {
                    PostFichier f = (PostFichier) o;
                    String typeFic = f.getIdtypefichier() != null ? f.getIdtypefichier() : "";
                    String mime = f.getMime_type() != null ? f.getMime_type().toLowerCase() : "";
                    if ("TFIC00001".equals(typeFic) || mime.startsWith("image/")) {
                        images.add(f);
                    } else if ("TFIC00003".equals(typeFic) || mime.startsWith("video/")) {
                        videos.add(f);
                    } else {
                        documents.add(f);
                    }
                }
            %>

            <% if (!images.isEmpty()) { %>
            <!-- ===== IMAGES ===== -->
            <div class="post-media post-images <%= images.size() == 1 ? "single-image" : (images.size() == 2 ? "two-images" : "multi-images") %>">
                <% for (PostFichier img : images) {
                    String imgSrc = request.getContextPath() + "/PostFichierServlet?action=view&id=" + img.getId();
                %>
                <div class="media-image-wrapper">
                    <img src="<%= imgSrc %>" alt="<%= img.getNom_original() != null ? img.getNom_original() : "Image" %>" class="post-image" onclick="openImageModal(this.src)">
                </div>
                <% } %>
            </div>
            <% } %>

            <% if (!videos.isEmpty()) { %>
            <!-- ===== VIDEOS ===== -->
            <% for (PostFichier vid : videos) {
                String vidSrc = request.getContextPath() + "/PostFichierServlet?action=view&id=" + vid.getId();
                String vidMime = vid.getMime_type() != null ? vid.getMime_type() : "video/mp4";
            %>
            <div class="post-media post-video-wrapper">
                <video class="post-video" controls preload="metadata">
                    <source src="<%= vidSrc %>" type="<%= vidMime %>">
                    Votre navigateur ne supporte pas la lecture vid&eacute;o.
                </video>
            </div>
            <% } %>
            <% } %>

            <% if (!documents.isEmpty()) { %>
            <!-- ===== DOCUMENTS ===== -->
            <div class="post-documents">
                <% for (PostFichier doc : documents) {
                    String docSrc = request.getContextPath() + "/PostFichierServlet?action=download&id=" + doc.getId();
                    String docName = doc.getNom_original() != null ? doc.getNom_original() : doc.getNom_fichier();
                    String docIcon = "fa-file-o";
                    String docMime = doc.getMime_type() != null ? doc.getMime_type().toLowerCase() : "";
                    if (docMime.contains("pdf")) docIcon = "fa-file-pdf-o";
                    else if (docMime.contains("word") || docMime.contains("doc")) docIcon = "fa-file-word-o";
                    else if (docMime.contains("excel") || docMime.contains("sheet") || docMime.contains("xls")) docIcon = "fa-file-excel-o";
                    else if (docMime.contains("powerpoint") || docMime.contains("presentation") || docMime.contains("ppt")) docIcon = "fa-file-powerpoint-o";
                    else if (docMime.contains("zip") || docMime.contains("rar") || docMime.contains("archive")) docIcon = "fa-file-archive-o";
                    long tailleKo = (long)(doc.getTaille_octets() / 1024);
                    String tailleStr = tailleKo > 1024 ? String.format("%.1f Mo", tailleKo / 1024.0) : (tailleKo + " Ko");
                %>
                <a href="<%= docSrc %>" target="_blank" download class="document-item">
                    <div class="document-icon">
                        <i class="fa <%= docIcon %>"></i>
                    </div>
                    <div class="document-info">
                        <span class="document-name"><%= docName %></span>
                        <% if (doc.getTaille_octets() > 0) { %>
                        <span class="document-size"><%= tailleStr %></span>
                        <% } %>
                    </div>
                    <div class="document-download">
                        <i class="fa fa-download"></i>
                    </div>
                </a>
                <% } %>
            </div>
            <% } %>

            <% } /* fin if fichiers */ %>

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
    top: 70px;
    width: 290px;
    max-height: calc(100vh - 80px);
    overflow-y: auto;
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

/* ======== DETAIL CARDS (stage/emploi/activité) ======== */
.detail-card {
    margin: 0 16px 16px;
    border-radius: 12px;
    overflow: hidden;
    border: 1px solid #e8e8e8;
    background: #fff;
}
.detail-card-header {
    display: flex;
    align-items: center;
    gap: 14px;
    padding: 16px 20px;
    border-bottom: 1px solid #f0f0f0;
}
.detail-card-icon {
    width: 44px;
    height: 44px;
    border-radius: 12px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    color: #fff;
    flex-shrink: 0;
}
.stage-icon { background: linear-gradient(135deg, #3498db, #2980b9); }
.emploi-icon { background: linear-gradient(135deg, #2ecc71, #27ae60); }
.activite-icon { background: linear-gradient(135deg, #e74c3c, #c0392b); }
.detail-card-title h3 {
    margin: 0;
    font-size: 16px;
    font-weight: 700;
    color: #1a1a2e;
    line-height: 1.3;
}
.detail-company {
    display: inline-flex;
    align-items: center;
    gap: 5px;
    font-size: 13px;
    color: #666;
    margin-top: 2px;
}
.detail-company i { font-size: 12px; }
.detail-card-body {
    padding: 16px 20px;
}
.detail-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    margin-bottom: 4px;
}
.detail-chip {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 6px 14px;
    background: #f4f6f8;
    border-radius: 20px;
    font-size: 13px;
    color: #444;
    border: 1px solid #e8ecf0;
}
.detail-chip i {
    font-size: 13px;
    color: #888;
}
.detail-chip.highlight {
    background: #fff8e1;
    border-color: #ffe082;
    color: #e65100;
    font-weight: 600;
}
.detail-chip.highlight i { color: #e65100; }
.detail-chip.success {
    background: #e8f5e9;
    border-color: #a5d6a7;
    color: #2e7d32;
}
.detail-chip.success i { color: #2e7d32; }
.detail-dates {
    margin-top: 12px;
    padding: 10px 14px;
    background: #f8f9fc;
    border-radius: 8px;
    font-size: 13px;
    color: #555;
    border-left: 3px solid #0095f6;
}
.detail-dates i {
    margin-right: 6px;
    color: #0095f6;
}
.detail-contact {
    margin-top: 10px;
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
}
.contact-link {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    font-size: 13px;
    color: #0095f6;
    text-decoration: none;
    padding: 6px 12px;
    border-radius: 6px;
    background: #f0f7ff;
    transition: all 0.2s;
}
.contact-link:hover {
    background: #e0efff;
    color: #0077cc;
}
.contact-link i { font-size: 14px; }
.detail-card-footer {
    padding: 14px 20px;
    border-top: 1px solid #f0f0f0;
    background: #fafbfc;
    text-align: center;
}
.btn-postuler {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    padding: 10px 28px;
    background: linear-gradient(135deg, #0095f6, #0077cc);
    color: #fff;
    border-radius: 8px;
    font-size: 14px;
    text-decoration: none;
    font-weight: 600;
    transition: all 0.3s;
    box-shadow: 0 2px 8px rgba(0, 149, 246, 0.3);
}
.btn-postuler:hover {
    background: linear-gradient(135deg, #0077cc, #005fa3);
    color: #fff;
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(0, 149, 246, 0.4);
}
.btn-inscrire {
    background: linear-gradient(135deg, #e74c3c, #c0392b);
    box-shadow: 0 2px 8px rgba(231, 76, 60, 0.3);
}
.btn-inscrire:hover {
    background: linear-gradient(135deg, #c0392b, #a93226);
    box-shadow: 0 4px 12px rgba(231, 76, 60, 0.4);
}
/* Stage detail card accent */
.detail-stage { border-top: 3px solid #3498db; }
.detail-emploi { border-top: 3px solid #2ecc71; }
.detail-activite { border-top: 3px solid #e74c3c; }

/* ======== MEDIA : Images ======== */
.post-media {
    margin: 0;
    overflow: hidden;
}
.post-images {
    display: grid;
    gap: 3px;
}
.post-images.single-image {
    grid-template-columns: 1fr;
}
.post-images.two-images {
    grid-template-columns: 1fr 1fr;
}
.post-images.multi-images {
    grid-template-columns: 1fr 1fr;
}
.media-image-wrapper {
    overflow: hidden;
    background: #f0f0f0;
    position: relative;
}
.single-image .media-image-wrapper {
    max-height: 550px;
}
.two-images .media-image-wrapper,
.multi-images .media-image-wrapper {
    height: 280px;
}
.post-image {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
    cursor: pointer;
    transition: transform 0.2s;
}
.post-image:hover {
    transform: scale(1.02);
}

/* ======== MEDIA : Videos ======== */
.post-video-wrapper {
    background: #000;
    max-height: 500px;
    display: flex;
    align-items: center;
    justify-content: center;
}
.post-video {
    width: 100%;
    max-height: 500px;
    outline: none;
}

/* ======== MEDIA : Documents ======== */
.post-documents {
    padding: 12px 16px;
    display: flex;
    flex-direction: column;
    gap: 8px;
}
.document-item {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 12px 16px;
    border: 1px solid #e0e0e0;
    border-radius: 10px;
    text-decoration: none;
    color: #262626;
    background: #fafafa;
    transition: all 0.2s;
}
.document-item:hover {
    background: #f0f0f0;
    border-color: #ccc;
    color: #262626;
    text-decoration: none;
}
.document-icon {
    width: 44px;
    height: 44px;
    border-radius: 10px;
    background: #e8f4fd;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
}
.document-icon i {
    font-size: 20px;
    color: #0095f6;
}
.document-info {
    flex: 1;
    min-width: 0;
}
.document-name {
    display: block;
    font-size: 14px;
    font-weight: 500;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
}
.document-size {
    display: block;
    font-size: 12px;
    color: #8e8e8e;
    margin-top: 2px;
}
.document-download {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background: #0095f6;
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    transition: background 0.2s;
}
.document-item:hover .document-download {
    background: #0077cc;
}
.document-download i {
    font-size: 14px;
}

/* ======== Modal Image ======== */
.image-modal-overlay {
    display: none;
    position: fixed;
    top: 0; left: 0; right: 0; bottom: 0;
    background: rgba(0,0,0,0.9);
    z-index: 99999;
    align-items: center;
    justify-content: center;
    cursor: pointer;
}
.image-modal-overlay.active {
    display: flex;
}
.image-modal-overlay img {
    max-width: 90%;
    max-height: 90%;
    object-fit: contain;
    border-radius: 4px;
}
.image-modal-close {
    position: absolute;
    top: 20px;
    right: 30px;
    color: #fff;
    font-size: 36px;
    cursor: pointer;
    z-index: 100000;
    background: none;
    border: none;
    line-height: 1;
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
    window.location.href = '<%= lien %>?but=publication/apresPublication.jsp&acte=like&id=<%= postId %>&bute=publication/publication-fiche.jsp';
}

function sharePost() {
    if (confirm('Partager cette publication sur votre profil ?')) {
        window.location.href = '<%= lien %>?but=publication/apresPublication.jsp&acte=share&id=<%= postId %>&bute=publication/publication-fiche.jsp';
    }
}

function focusCommentInput() {
    document.getElementById('commentInput').focus();
}

// Commentaires gérés par formulaire standard (pas AJAX)

// ======== Modal Image plein écran ========
function openImageModal(src) {
    var overlay = document.getElementById('imageModalOverlay');
    var img = document.getElementById('imageModalImg');
    img.src = src;
    overlay.classList.add('active');
}
function closeImageModal() {
    document.getElementById('imageModalOverlay').classList.remove('active');
}
</script>

<!-- Modal pour agrandir les images -->
<div class="image-modal-overlay" id="imageModalOverlay" onclick="closeImageModal()">
    <button class="image-modal-close" onclick="closeImageModal()">&times;</button>
    <img id="imageModalImg" src="" alt="Image agrandie">
</div>

<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'><h4><i class='fa fa-ban'></i> Erreur</h4><p>" + e.getMessage() + "</p></div>");
} %>
