<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.Post" %>
<%@ page import="bean.PostFichier" %>
<%@ page import="bean.PostEmploi" %>
<%@ page import="bean.PostStage" %>
<%@ page import="bean.PostActivite" %>
<%@ page import="bean.TypePublication" %>
<%@ page import="bean.VisibilitePublication" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="user.UserEJB" %>
<%@ page import="utilisateurAcade.UtilisateurAcade" %>
<%@ page import="java.util.*" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        if (u == null || lien == null) {
            response.sendRedirect("security-login.jsp");
            return;
        }

        int refuserInt = u.getUser().getRefuser();
        String postId = request.getParameter("id");

        if (postId == null || postId.isEmpty()) {
            throw new Exception("ID de publication manquant");
        }

        String bute = request.getParameter("bute");
        if (bute == null || bute.isEmpty()) bute = "accueil.jsp";

        // Charger le post
        Post post = new Post();
        post.setId(postId);
        Object[] postResult = CGenUtil.rechercher(post, null, null, "");
        if (postResult == null || postResult.length == 0) {
            throw new Exception("Publication introuvable");
        }
        post = (Post) postResult[0];

        // Vérifier propriétaire
        if (post.getIdutilisateur() != refuserInt) {
            throw new Exception("Vous n'&ecirc;tes pas autoris&eacute; &agrave; modifier cette publication");
        }

        // Déterminer le type de publication lié
        String typeCode = post.getIdtypepublication(); // TYP00001=stage, TYP00002=emploi, TYP00003=activite
        boolean hasEmploi = false, hasStage = false, hasActivite = false;
        PostEmploi emploi = null;
        PostStage stage = null;
        PostActivite activite = null;

        if ("TYP00002".equals(typeCode)) {
            try {
                PostEmploi empCritere = new PostEmploi();
                empCritere.setPost_id(postId);
                Object[] empResult = CGenUtil.rechercher(empCritere, null, null, " AND post_id = '" + postId + "'");
                if (empResult != null && empResult.length > 0) {
                    emploi = (PostEmploi) empResult[0];
                    hasEmploi = true;
                }
            } catch (Exception ignored) {}
        } else if ("TYP00001".equals(typeCode)) {
            try {
                PostStage stgCritere = new PostStage();
                stgCritere.setPost_id(postId);
                Object[] stgResult = CGenUtil.rechercher(stgCritere, null, null, " AND post_id = '" + postId + "'");
                if (stgResult != null && stgResult.length > 0) {
                    stage = (PostStage) stgResult[0];
                    hasStage = true;
                }
            } catch (Exception ignored) {}
        } else if ("TYP00003".equals(typeCode)) {
            try {
                PostActivite actCritere = new PostActivite();
                actCritere.setPost_id(postId);
                Object[] actResult = CGenUtil.rechercher(actCritere, null, null, " AND post_id = '" + postId + "'");
                if (actResult != null && actResult.length > 0) {
                    activite = (PostActivite) actResult[0];
                    hasActivite = true;
                }
            } catch (Exception ignored) {}
        }

        boolean hasLinkedEntity = hasEmploi || hasStage || hasActivite;
        String linkedTypeLabel = hasEmploi ? "Offre d'emploi" : hasStage ? "Offre de stage" : hasActivite ? "Activit&eacute; / &Eacute;v&eacute;nement" : "";
        String linkedTypeIcon = hasEmploi ? "fa-briefcase" : hasStage ? "fa-graduation-cap" : hasActivite ? "fa-calendar" : "";
        String linkedTypeColor = hasEmploi ? "#2ecc71" : hasStage ? "#3498db" : hasActivite ? "#e74c3c" : "#666";

        // Charger les types de publication
        TypePublication[] typesPublication = (TypePublication[]) CGenUtil.rechercher(
            new TypePublication(), null, null, " AND actif = 1 ORDER BY ordre");

        // Charger les visibilités
        VisibilitePublication[] visibilites = (VisibilitePublication[]) CGenUtil.rechercher(
            new VisibilitePublication(), null, null, " AND actif = 1 ORDER BY ordre");

        // Fichiers joints existants
        PostFichier pfCritere = new PostFichier();
        pfCritere.setPost_id(postId);
        Object[] fichiers = null;
        try {
            fichiers = CGenUtil.rechercher(pfCritere, null, null, " AND post_id = '" + postId + "' ORDER BY ordre");
        } catch (Exception ex) {
            fichiers = new Object[0];
        }

        // Récupérer photo et prénom via UtilisateurAcade
        String defaultAvatar = request.getContextPath() + "/assets/img/user-placeholder.svg";
        String photoUser = defaultAvatar;
        String prenomUser = u.getUser().getNomuser() != null ? u.getUser().getNomuser() : "";
        try {
            UtilisateurAcade userCritere = new UtilisateurAcade();
            Object[] userResult = CGenUtil.rechercher(userCritere, null, null, " AND refuser = " + refuserInt);
            if (userResult != null && userResult.length > 0) {
                UtilisateurAcade userInfo = (UtilisateurAcade) userResult[0];
                prenomUser = userInfo.getPrenom() != null ? userInfo.getPrenom() : prenomUser;
                if (userInfo.getPhoto() != null && !userInfo.getPhoto().isEmpty()) {
                    String photoFileName = userInfo.getPhoto();
                    if (photoFileName.contains("/")) {
                        photoFileName = photoFileName.substring(photoFileName.lastIndexOf("/") + 1);
                    }
                    if (!"user-placeholder.svg".equals(photoFileName)) {
                        photoUser = request.getContextPath() + "/profile-photo?file=" + photoFileName;
                    }
                }
            }
        } catch (Exception ignored) {}
%>
<div class="content-wrapper">
    <section class="content">
        <div class="pub-modif-container">
            
            <!-- Header -->
            <div class="pub-modif-header">
                <a href="<%=lien%>?but=<%=bute%>&id=<%=postId%>" class="pub-modif-back">
                    <i class="fa fa-arrow-left"></i>
                </a>
                <h2 class="pub-modif-title"><i class="fa fa-edit"></i> Modifier la publication</h2>
                <% if (hasLinkedEntity) { %>
                <span class="pub-modif-badge" style="background: <%= linkedTypeColor %>15; color: <%= linkedTypeColor %>; border: 1px solid <%= linkedTypeColor %>33;">
                    <i class="fa <%= linkedTypeIcon %>"></i> <%= linkedTypeLabel %>
                </span>
                <% } %>
            </div>

            <!-- Formulaire de publication principal -->
            <form method="post" action="<%=lien%>?but=publication/apresPublication.jsp" id="formModifPost">
                <input type="hidden" name="acte" value="update">
                <input type="hidden" name="id" value="<%=postId%>">
                <input type="hidden" name="bute" value="<%=bute%>">

                <div class="pub-modif-card">
                    <div class="pub-modif-card-header">
                        <i class="fa fa-pencil"></i> Contenu de la publication
                    </div>

                    <!-- Images du post (lecture seule) -->
                    <%
                        // Séparer images et autres fichiers
                        java.util.List<PostFichier> imagesList = new java.util.ArrayList<PostFichier>();
                        java.util.List<PostFichier> otherFilesList = new java.util.ArrayList<PostFichier>();
                        if (fichiers != null) {
                            for (int i = 0; i < fichiers.length; i++) {
                                PostFichier pf = (PostFichier) fichiers[i];
                                String mt = pf.getMime_type() != null ? pf.getMime_type() : "";
                                if (mt.startsWith("image/")) {
                                    imagesList.add(pf);
                                } else {
                                    otherFilesList.add(pf);
                                }
                            }
                        }
                    %>
                    <% if (!imagesList.isEmpty()) { %>
                    <div class="pub-modif-images-readonly">
                        <% if (imagesList.size() == 1) { %>
                        <div class="pub-modif-img-single">
                            <img src="PostFichierServlet?id=<%= imagesList.get(0).getId() %>&action=view" alt="Image">
                        </div>
                        <% } else if (imagesList.size() == 2) { %>
                        <div class="pub-modif-img-duo">
                            <% for (PostFichier img : imagesList) { %>
                            <div class="pub-modif-img-item">
                                <img src="PostFichierServlet?id=<%= img.getId() %>&action=view" alt="Image">
                            </div>
                            <% } %>
                        </div>
                        <% } else { %>
                        <div class="pub-modif-img-grid-<%= Math.min(imagesList.size(), 4) %>">
                            <% for (int gi = 0; gi < imagesList.size() && gi < 4; gi++) {
                                PostFichier img = imagesList.get(gi);
                            %>
                            <div class="pub-modif-img-item<%= (gi == 3 && imagesList.size() > 4) ? " pub-modif-img-more" : "" %>">
                                <img src="PostFichierServlet?id=<%= img.getId() %>&action=view" alt="Image">
                                <% if (gi == 3 && imagesList.size() > 4) { %>
                                <div class="pub-modif-img-overlay">+<%= imagesList.size() - 4 %></div>
                                <% } %>
                            </div>
                            <% } %>
                        </div>
                        <% } %>
                        <div class="pub-modif-images-notice">
                            <i class="fa fa-lock"></i> Les images ne sont pas modifiables depuis cette page
                        </div>
                    </div>
                    <% } %>

                    <!-- Autres fichiers joints -->
                    <% if (!otherFilesList.isEmpty()) { %>
                    <div class="pub-modif-fichiers">
                        <div class="pub-modif-fichiers-label">
                            <i class="fa fa-paperclip"></i> Fichiers joints (<%= otherFilesList.size() %>)
                        </div>
                        <div class="pub-modif-fichiers-grid">
                            <% for (PostFichier pf : otherFilesList) {
                                String mimeType = pf.getMime_type() != null ? pf.getMime_type() : "";
                                String nomOriginal = pf.getNom_original() != null ? pf.getNom_original() : pf.getNom_fichier();
                            %>
                            <div class="pub-modif-fichier-thumb">
                                <div class="pub-modif-fichier-icon">
                                    <i class="fa <%= mimeType.contains("pdf") ? "fa-file-pdf-o" : 
                                                    mimeType.contains("word") ? "fa-file-word-o" : 
                                                    "fa-file-o" %>"></i>
                                </div>
                                <a href="PostFichierServlet?id=<%= pf.getId() %>&action=download" 
                                   class="pub-modif-fichier-dl" title="T&eacute;l&eacute;charger <%= nomOriginal %>">
                                    <i class="fa fa-download"></i>
                                </a>
                            </div>
                            <% } %>
                        </div>
                    </div>
                    <% } %>

                    <!-- Zone texte + avatar -->
                    <div class="pub-modif-editor">
                        <img class="pub-modif-avatar" src="<%= photoUser %>" alt="Photo">
                        <div class="pub-modif-editor-right">
                            <span class="pub-modif-username"><%= prenomUser %></span>
                            <textarea name="contenu" class="pub-modif-textarea" placeholder="Modifier votre publication..." required rows="4" oninput="autoResizeModif(this)"><%= post.getContenu() != null ? post.getContenu() : "" %></textarea>
                        </div>
                    </div>

                    <!-- Options publication -->
                    <div class="pub-modif-options">
                        <div class="pub-modif-selects">
                            <div class="pub-modif-select-wrapper">
                                <label><i class="fa fa-tag"></i> Type</label>
                                <select name="idtypepublication" class="pub-modif-select" disabled>
                                    <% if (typesPublication != null) {
                                        for (TypePublication tp : typesPublication) { %>
                                    <option value="<%= tp.getId() %>" <%= tp.getId().equals(post.getIdtypepublication()) ? "selected" : "" %>>
                                        <%= tp.getLibelle() %>
                                    </option>
                                    <% } } %>
                                </select>
                                <input type="hidden" name="idtypepublication" value="<%= post.getIdtypepublication() %>">
                            </div>
                            <div class="pub-modif-select-wrapper">
                                <label><i class="fa fa-eye"></i> Visibilit&eacute;</label>
                                <select name="idvisibilite" class="pub-modif-select">
                                    <% if (visibilites != null) {
                                        for (VisibilitePublication vp : visibilites) { %>
                                    <option value="<%= vp.getId() %>" <%= vp.getId().equals(post.getIdvisibilite()) ? "selected" : "" %>>
                                        <%= vp.getLibelle() %>
                                    </option>
                                    <% } } %>
                                </select>
                            </div>
                        </div>
                        <button type="submit" class="pub-modif-btn-save">
                            <i class="fa fa-check"></i> Enregistrer
                        </button>
                    </div>
                </div>
            </form>

            <%-- ============ SECTION EMPLOI ============ --%>
            <% if (hasEmploi && emploi != null) { %>
            <form method="post" action="<%=lien%>?but=carriere/apresCarriere.jsp" id="formModifEmploi" enctype="multipart/form-data">
                <input type="hidden" name="acte" value="updateEmploi">
                <input type="hidden" name="bute" value="<%=bute%>">
                <input type="hidden" name="post_id" value="<%=postId%>">
                <input type="hidden" name="id" value="<%=postId%>">

                <div class="pub-modif-card pub-modif-card-linked" style="--accent-color: #2ecc71;">
                    <div class="pub-modif-card-header" style="background: linear-gradient(135deg, #2ecc7112, #27ae6012); border-left: 3px solid #2ecc71;">
                        <i class="fa fa-briefcase" style="color: #2ecc71;"></i> D&eacute;tails de l'offre d'emploi
                    </div>
                    <div class="pub-modif-card-body">
                        <div class="pub-modif-grid">
                            <div class="pub-modif-field">
                                <label>Entreprise</label>
                                <input type="text" name="entreprise" class="pub-modif-input" value="<%= emploi.getEntreprise() != null ? emploi.getEntreprise() : "" %>" placeholder="Nom de l'entreprise">
                            </div>
                            <div class="pub-modif-field">
                                <label>Poste</label>
                                <input type="text" name="poste" class="pub-modif-input" value="<%= emploi.getPoste() != null ? emploi.getPoste() : "" %>" placeholder="Intitul&eacute; du poste">
                            </div>
                            <div class="pub-modif-field">
                                <label>Localisation</label>
                                <input type="text" name="localisation" class="pub-modif-input" value="<%= emploi.getLocalisation() != null ? emploi.getLocalisation() : "" %>" placeholder="Ville, pays">
                            </div>
                            <div class="pub-modif-field">
                                <label>Type de contrat</label>
                                <select name="type_contrat" class="pub-modif-select">
                                    <option value="">-- S&eacute;lectionner --</option>
                                    <% String[] contrats = {"CDI", "CDD", "Freelance", "Alternance", "Autre"};
                                       for (String ct : contrats) { %>
                                    <option value="<%= ct %>" <%= ct.equals(emploi.getType_contrat()) ? "selected" : "" %>><%= ct %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="pub-modif-field">
                                <label>Salaire min</label>
                                <input type="number" name="salaire_min" class="pub-modif-input" value="<%= emploi.getSalaire_min() != 0 ? emploi.getSalaire_min() : "" %>" placeholder="0" step="any">
                            </div>
                            <div class="pub-modif-field">
                                <label>Salaire max</label>
                                <input type="number" name="salaire_max" class="pub-modif-input" value="<%= emploi.getSalaire_max() != 0 ? emploi.getSalaire_max() : "" %>" placeholder="0" step="any">
                            </div>
                            <div class="pub-modif-field">
                                <label>Devise</label>
                                <input type="text" name="devise" class="pub-modif-input" value="<%= emploi.getDevise() != null ? emploi.getDevise() : "MGA" %>" placeholder="MGA">
                            </div>
                            <div class="pub-modif-field">
                                <label>Exp&eacute;rience requise</label>
                                <input type="text" name="experience_requise" class="pub-modif-input" value="<%= emploi.getExperience_requise() != null ? emploi.getExperience_requise() : "" %>" placeholder="Ex: 2 ans">
                            </div>
                            <div class="pub-modif-field">
                                <label>Niveau d'&eacute;tude</label>
                                <input type="text" name="niveau_etude_requis" class="pub-modif-input" value="<%= emploi.getNiveau_etude_requis() != null ? emploi.getNiveau_etude_requis() : "" %>" placeholder="Ex: Licence, Master">
                            </div>
                            <div class="pub-modif-field">
                                <label>T&eacute;l&eacute;travail</label>
                                <select name="teletravail_possible" class="pub-modif-select">
                                    <option value="0" <%= emploi.getTeletravail_possible() == 0 ? "selected" : "" %>>Non</option>
                                    <option value="1" <%= emploi.getTeletravail_possible() == 1 ? "selected" : "" %>>Oui</option>
                                </select>
                            </div>
                            <div class="pub-modif-field">
                                <label>Date limite</label>
                                <input type="date" name="date_limite" class="pub-modif-input" value="<%= emploi.getDate_limite() != null ? emploi.getDate_limite() : "" %>">
                            </div>
                            <div class="pub-modif-field">
                                <label>Email de contact</label>
                                <input type="email" name="contact_email" class="pub-modif-input" value="<%= emploi.getContact_email() != null ? emploi.getContact_email() : "" %>" placeholder="email@example.com">
                            </div>
                            <div class="pub-modif-field">
                                <label>T&eacute;l&eacute;phone</label>
                                <input type="text" name="contact_tel" class="pub-modif-input" value="<%= emploi.getContact_tel() != null ? emploi.getContact_tel() : "" %>" placeholder="+261 ...">
                            </div>
                            <div class="pub-modif-field pub-modif-field-full">
                                <label>Lien de candidature</label>
                                <input type="url" name="lien_candidature" class="pub-modif-input" value="<%= emploi.getLien_candidature() != null ? emploi.getLien_candidature() : "" %>" placeholder="https://...">
                            </div>
                        </div>
                    </div>
                    <div class="pub-modif-card-footer">
                        <button type="submit" class="pub-modif-btn-linked" style="background: #2ecc71;">
                            <i class="fa fa-save"></i> Mettre &agrave; jour l'offre d'emploi
                        </button>
                    </div>
                </div>
            </form>
            <% } %>

            <%-- ============ SECTION STAGE ============ --%>
            <% if (hasStage && stage != null) { %>
            <form method="post" action="<%=lien%>?but=carriere/apresCarriere.jsp" id="formModifStage" enctype="multipart/form-data">
                <input type="hidden" name="acte" value="updateStage">
                <input type="hidden" name="bute" value="<%=bute%>">
                <input type="hidden" name="post_id" value="<%=postId%>">
                <input type="hidden" name="id" value="<%=postId%>">

                <div class="pub-modif-card pub-modif-card-linked" style="--accent-color: #3498db;">
                    <div class="pub-modif-card-header" style="background: linear-gradient(135deg, #3498db12, #2980b912); border-left: 3px solid #3498db;">
                        <i class="fa fa-graduation-cap" style="color: #3498db;"></i> D&eacute;tails de l'offre de stage
                    </div>
                    <div class="pub-modif-card-body">
                        <div class="pub-modif-grid">
                            <div class="pub-modif-field">
                                <label>Entreprise / Organisme</label>
                                <input type="text" name="entreprise" class="pub-modif-input" value="<%= stage.getEntreprise() != null ? stage.getEntreprise() : "" %>" placeholder="Nom de l'entreprise">
                            </div>
                            <div class="pub-modif-field">
                                <label>Localisation</label>
                                <input type="text" name="localisation" class="pub-modif-input" value="<%= stage.getLocalisation() != null ? stage.getLocalisation() : "" %>" placeholder="Ville, pays">
                            </div>
                            <div class="pub-modif-field">
                                <label>Dur&eacute;e</label>
                                <input type="text" name="duree" class="pub-modif-input" value="<%= stage.getDuree() != null ? stage.getDuree() : "" %>" placeholder="Ex: 3 mois">
                            </div>
                            <div class="pub-modif-field">
                                <label>Date de d&eacute;but</label>
                                <input type="date" name="date_debut" class="pub-modif-input" value="<%= stage.getDate_debut() != null ? stage.getDate_debut() : "" %>">
                            </div>
                            <div class="pub-modif-field">
                                <label>Date de fin</label>
                                <input type="date" name="date_fin" class="pub-modif-input" value="<%= stage.getDate_fin() != null ? stage.getDate_fin() : "" %>">
                            </div>
                            <div class="pub-modif-field">
                                <label>Indemnit&eacute; (MGA)</label>
                                <input type="number" name="indemnite" class="pub-modif-input" value="<%= stage.getIndemnite() != 0 ? stage.getIndemnite() : "" %>" placeholder="0" step="any">
                            </div>
                            <div class="pub-modif-field">
                                <label>Niveau d'&eacute;tude</label>
                                <input type="text" name="niveau_etude_requis" class="pub-modif-input" value="<%= stage.getNiveau_etude_requis() != null ? stage.getNiveau_etude_requis() : "" %>" placeholder="Ex: L3, M1">
                            </div>
                            <div class="pub-modif-field">
                                <label>Convention requise</label>
                                <select name="convention_requise" class="pub-modif-select">
                                    <option value="0" <%= stage.getConvention_requise() == 0 ? "selected" : "" %>>Non</option>
                                    <option value="1" <%= stage.getConvention_requise() == 1 ? "selected" : "" %>>Oui</option>
                                </select>
                            </div>
                            <div class="pub-modif-field">
                                <label>Places disponibles</label>
                                <input type="number" name="places_disponibles" class="pub-modif-input" value="<%= stage.getPlaces_disponibles() != 0 ? stage.getPlaces_disponibles() : "" %>" placeholder="0">
                            </div>
                            <div class="pub-modif-field">
                                <label>Email de contact</label>
                                <input type="email" name="contact_email" class="pub-modif-input" value="<%= stage.getContact_email() != null ? stage.getContact_email() : "" %>" placeholder="email@example.com">
                            </div>
                            <div class="pub-modif-field">
                                <label>T&eacute;l&eacute;phone</label>
                                <input type="text" name="contact_tel" class="pub-modif-input" value="<%= stage.getContact_tel() != null ? stage.getContact_tel() : "" %>" placeholder="+261 ...">
                            </div>
                            <div class="pub-modif-field pub-modif-field-full">
                                <label>Lien de candidature</label>
                                <input type="url" name="lien_candidature" class="pub-modif-input" value="<%= stage.getLien_candidature() != null ? stage.getLien_candidature() : "" %>" placeholder="https://...">
                            </div>
                        </div>
                    </div>
                    <div class="pub-modif-card-footer">
                        <button type="submit" class="pub-modif-btn-linked" style="background: #3498db;">
                            <i class="fa fa-save"></i> Mettre &agrave; jour l'offre de stage
                        </button>
                    </div>
                </div>
            </form>
            <% } %>

            <%-- ============ SECTION ACTIVITE ============ --%>
            <% if (hasActivite && activite != null) { %>
            <form method="post" action="<%=lien%>?but=carriere/apresCarriere.jsp" id="formModifActivite" enctype="multipart/form-data">
                <input type="hidden" name="acte" value="updateActivite">
                <input type="hidden" name="bute" value="<%=bute%>">
                <input type="hidden" name="post_id" value="<%=postId%>">
                <input type="hidden" name="id" value="<%=postId%>">

                <div class="pub-modif-card pub-modif-card-linked" style="--accent-color: #e74c3c;">
                    <div class="pub-modif-card-header" style="background: linear-gradient(135deg, #e74c3c12, #c0392b12); border-left: 3px solid #e74c3c;">
                        <i class="fa fa-calendar" style="color: #e74c3c;"></i> D&eacute;tails de l'activit&eacute; / &eacute;v&eacute;nement
                    </div>
                    <div class="pub-modif-card-body">
                        <div class="pub-modif-grid">
                            <div class="pub-modif-field pub-modif-field-full">
                                <label>Titre</label>
                                <input type="text" name="titre" class="pub-modif-input" value="<%= activite.getTitre() != null ? activite.getTitre() : "" %>" placeholder="Titre de l'activit&eacute;">
                            </div>
                            <div class="pub-modif-field">
                                <label>Lieu</label>
                                <input type="text" name="lieu" class="pub-modif-input" value="<%= activite.getLieu() != null ? activite.getLieu() : "" %>" placeholder="Lieu">
                            </div>
                            <div class="pub-modif-field">
                                <label>Adresse</label>
                                <input type="text" name="adresse" class="pub-modif-input" value="<%= activite.getAdresse() != null ? activite.getAdresse() : "" %>" placeholder="Adresse compl&egrave;te">
                            </div>
                            <div class="pub-modif-field">
                                <label>Date de d&eacute;but</label>
                                <input type="datetime-local" name="date_debut" class="pub-modif-input" value="<%= activite.getDate_debut() != null ? activite.getDate_debut().toString().replace(" ", "T").substring(0, Math.min(16, activite.getDate_debut().toString().length())) : "" %>">
                            </div>
                            <div class="pub-modif-field">
                                <label>Date de fin</label>
                                <input type="datetime-local" name="date_fin" class="pub-modif-input" value="<%= activite.getDate_fin() != null ? activite.getDate_fin().toString().replace(" ", "T").substring(0, Math.min(16, activite.getDate_fin().toString().length())) : "" %>">
                            </div>
                            <div class="pub-modif-field">
                                <label>Prix (MGA)</label>
                                <input type="number" name="prix" class="pub-modif-input" value="<%= activite.getPrix() != 0 ? activite.getPrix() : "" %>" placeholder="0" step="any">
                            </div>
                            <div class="pub-modif-field">
                                <label>Nombre de places</label>
                                <input type="number" name="nombre_places" class="pub-modif-input" value="<%= activite.getNombre_places() != 0 ? activite.getNombre_places() : "" %>" placeholder="0">
                            </div>
                            <div class="pub-modif-field">
                                <label>Email de contact</label>
                                <input type="email" name="contact_email" class="pub-modif-input" value="<%= activite.getContact_email() != null ? activite.getContact_email() : "" %>" placeholder="email@example.com">
                            </div>
                            <div class="pub-modif-field">
                                <label>T&eacute;l&eacute;phone</label>
                                <input type="text" name="contact_tel" class="pub-modif-input" value="<%= activite.getContact_tel() != null ? activite.getContact_tel() : "" %>" placeholder="+261 ...">
                            </div>
                            <div class="pub-modif-field">
                                <label>Lien d'inscription</label>
                                <input type="url" name="lien_inscription" class="pub-modif-input" value="<%= activite.getLien_inscription() != null ? activite.getLien_inscription() : "" %>" placeholder="https://...">
                            </div>
                        </div>
                    </div>
                    <div class="pub-modif-card-footer">
                        <button type="submit" class="pub-modif-btn-linked" style="background: #e74c3c;">
                            <i class="fa fa-save"></i> Mettre &agrave; jour l'activit&eacute;
                        </button>
                    </div>
                </div>
            </form>
            <% } %>

        </div>
    </section>
</div>

<style>
/* ===== LAYOUT ===== */
.pub-modif-container {
    width: 100%;
    padding: 20px 15px 40px;
}

/* ===== HEADER ===== */
.pub-modif-header {
    display: flex;
    align-items: center;
    gap: 12px;
    margin-bottom: 20px;
    flex-wrap: wrap;
}
.pub-modif-back {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    width: 36px;
    height: 36px;
    border-radius: 50%;
    background: #fff;
    border: 1px solid #e0e0e0;
    color: #555;
    text-decoration: none;
    transition: all 0.2s;
    flex-shrink: 0;
}
.pub-modif-back:hover {
    background: #f5f5f5;
    color: #333;
    border-color: #ccc;
}
.pub-modif-title {
    font-size: 18px;
    font-weight: 600;
    color: #1a1a2e;
    margin: 0;
    flex: 1;
}
.pub-modif-badge {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
    white-space: nowrap;
}

/* ===== CARDS ===== */
.pub-modif-card {
    background: #fff;
    border: 1px solid #e8e8e8;
    border-radius: 14px;
    overflow: hidden;
    margin-bottom: 20px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 1px 2px rgba(0,0,0,0.06);
    transition: box-shadow 0.2s;
}
.pub-modif-card:hover {
    box-shadow: 0 4px 12px rgba(0,0,0,0.07), 0 1px 3px rgba(0,0,0,0.06);
}
.pub-modif-card-header {
    padding: 14px 18px;
    font-size: 14px;
    font-weight: 600;
    color: #444;
    background: #fafbfc;
    border-bottom: 1px solid #f0f0f0;
    display: flex;
    align-items: center;
    gap: 8px;
}
.pub-modif-card-body {
    padding: 20px 18px;
}
.pub-modif-card-footer {
    padding: 14px 18px;
    background: #fafbfc;
    border-top: 1px solid #f0f0f0;
    display: flex;
    justify-content: flex-end;
}

/* ===== IMAGES READONLY ===== */
.pub-modif-images-readonly {
    border-bottom: 1px solid #f0f0f0;
    overflow: hidden;
}
.pub-modif-img-single {
    width: 100%;
    max-height: 420px;
    overflow: hidden;
}
.pub-modif-img-single img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
}
.pub-modif-img-duo {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 2px;
    max-height: 360px;
    overflow: hidden;
}
.pub-modif-img-grid-3 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-template-rows: 1fr 1fr;
    gap: 2px;
    max-height: 400px;
    overflow: hidden;
}
.pub-modif-img-grid-3 .pub-modif-img-item:first-child {
    grid-row: 1 / 3;
}
.pub-modif-img-grid-4 {
    display: grid;
    grid-template-columns: 1fr 1fr;
    grid-template-rows: 1fr 1fr;
    gap: 2px;
    max-height: 400px;
    overflow: hidden;
}
.pub-modif-img-item {
    position: relative;
    overflow: hidden;
    min-height: 0;
}
.pub-modif-img-item img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
}
.pub-modif-img-more {
    position: relative;
}
.pub-modif-img-overlay {
    position: absolute;
    inset: 0;
    background: rgba(0,0,0,0.45);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 28px;
    font-weight: 700;
    color: #fff;
    letter-spacing: 1px;
}
.pub-modif-images-notice {
    padding: 8px 18px;
    font-size: 11px;
    color: #999;
    background: #fafbfc;
    border-top: 1px solid #f0f0f0;
    display: flex;
    align-items: center;
    gap: 6px;
}
.pub-modif-images-notice i {
    font-size: 10px;
    color: #bbb;
}

/* ===== FICHIERS ===== */
.pub-modif-fichiers {
    padding: 14px 18px;
    background: #f8f9fb;
    border-bottom: 1px solid #f0f0f0;
}
.pub-modif-fichiers-label {
    font-size: 12px;
    font-weight: 500;
    color: #888;
    margin-bottom: 10px;
}
.pub-modif-fichiers-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}
.pub-modif-fichier-thumb {
    position: relative;
    width: 72px;
    height: 72px;
    border-radius: 10px;
    overflow: hidden;
    border: 1px solid #e0e0e0;
    background: #f5f5f5;
    transition: transform 0.15s;
}
.pub-modif-fichier-thumb:hover {
    transform: scale(1.05);
}
.pub-modif-fichier-thumb img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}
.pub-modif-fichier-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    font-size: 22px;
    color: #aaa;
}
.pub-modif-fichier-dl {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    background: rgba(0,0,0,0.55);
    color: #fff;
    text-align: center;
    padding: 5px 0;
    font-size: 11px;
    opacity: 0;
    transition: opacity 0.2s;
    text-decoration: none;
}
.pub-modif-fichier-thumb:hover .pub-modif-fichier-dl {
    opacity: 1;
}

/* ===== EDITOR ZONE ===== */
.pub-modif-editor {
    display: flex;
    align-items: flex-start;
    gap: 12px;
    padding: 16px 18px;
}
.pub-modif-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    object-fit: cover;
    flex-shrink: 0;
    border: 2px solid #f0f0f0;
}
.pub-modif-editor-right {
    flex: 1;
    min-width: 0;
}
.pub-modif-username {
    font-size: 13px;
    font-weight: 600;
    color: #333;
    display: block;
    margin-bottom: 6px;
}
.pub-modif-textarea {
    width: 100%;
    border: 1px solid #e8e8e8;
    border-radius: 10px;
    padding: 10px 14px;
    font-size: 14px;
    line-height: 1.55;
    color: #262626;
    background: #fafbfc;
    resize: none;
    min-height: 80px;
    max-height: 260px;
    overflow-y: auto;
    font-family: inherit;
    outline: none;
    transition: border-color 0.2s, background 0.2s;
    box-sizing: border-box;
}
.pub-modif-textarea:focus {
    border-color: #0095f6;
    background: #fff;
    box-shadow: 0 0 0 3px rgba(0, 149, 246, 0.08);
}
.pub-modif-textarea::placeholder {
    color: #b5b5b5;
}

/* ===== OPTIONS ===== */
.pub-modif-options {
    display: flex;
    align-items: flex-end;
    gap: 12px;
    padding: 14px 18px;
    border-top: 1px solid #f0f0f0;
    background: #fafbfc;
    flex-wrap: wrap;
}
.pub-modif-selects {
    display: flex;
    gap: 10px;
    flex: 1;
    flex-wrap: wrap;
}
.pub-modif-select-wrapper {
    flex: 1;
    min-width: 140px;
}
.pub-modif-select-wrapper label {
    display: block;
    font-size: 11px;
    font-weight: 600;
    color: #888;
    margin-bottom: 4px;
    text-transform: uppercase;
    letter-spacing: 0.3px;
}
.pub-modif-select {
    width: 100%;
    padding: 8px 12px;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    font-size: 13px;
    background: #fff;
    color: #444;
    outline: none;
    transition: border-color 0.2s;
    cursor: pointer;
}
.pub-modif-select:focus {
    border-color: #0095f6;
}
.pub-modif-btn-save {
    background: linear-gradient(135deg, #0095f6, #0077cc);
    color: #fff;
    border: none;
    border-radius: 8px;
    padding: 9px 22px;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    white-space: nowrap;
    box-shadow: 0 2px 6px rgba(0, 149, 246, 0.25);
}
.pub-modif-btn-save:hover {
    background: linear-gradient(135deg, #0081d6, #0066b3);
    box-shadow: 0 3px 10px rgba(0, 149, 246, 0.35);
    transform: translateY(-1px);
}

/* ===== LINKED ENTITY FORM ===== */
.pub-modif-grid {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 16px;
}
.pub-modif-field {
    display: flex;
    flex-direction: column;
}
.pub-modif-field-full {
    grid-column: 1 / -1;
}
.pub-modif-field label {
    font-size: 12px;
    font-weight: 600;
    color: #666;
    margin-bottom: 5px;
    text-transform: uppercase;
    letter-spacing: 0.2px;
}
.pub-modif-input {
    padding: 9px 12px;
    border: 1px solid #e0e0e0;
    border-radius: 8px;
    font-size: 13px;
    color: #333;
    background: #fff;
    outline: none;
    transition: border-color 0.2s, box-shadow 0.2s;
    font-family: inherit;
}
.pub-modif-input:focus {
    border-color: var(--accent-color, #0095f6);
    box-shadow: 0 0 0 3px color-mix(in srgb, var(--accent-color, #0095f6) 10%, transparent);
}
.pub-modif-input::placeholder {
    color: #bbb;
}
.pub-modif-btn-linked {
    color: #fff;
    border: none;
    border-radius: 8px;
    padding: 9px 22px;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
    white-space: nowrap;
    box-shadow: 0 2px 6px rgba(0,0,0,0.15);
}
.pub-modif-btn-linked:hover {
    opacity: 0.9;
    box-shadow: 0 3px 10px rgba(0,0,0,0.2);
    transform: translateY(-1px);
}

/* ===== RESPONSIVE ===== */
@media (max-width: 600px) {
    .pub-modif-container {
        padding: 12px 8px 30px;
    }
    .pub-modif-grid {
        grid-template-columns: 1fr;
    }
    .pub-modif-title {
        font-size: 16px;
    }
    .pub-modif-options {
        flex-direction: column;
        align-items: stretch;
    }
    .pub-modif-btn-save,
    .pub-modif-btn-linked {
        width: 100%;
        text-align: center;
    }
}
</style>

<script>
function autoResizeModif(textarea) {
    textarea.style.height = 'auto';
    textarea.style.height = Math.min(textarea.scrollHeight, 260) + 'px';
}
// Auto-resize on load
document.addEventListener('DOMContentLoaded', function() {
    var ta = document.querySelector('.pub-modif-textarea');
    if (ta) autoResizeModif(ta);
});
</script>

<%
    } catch (Exception e) {
        e.printStackTrace();
        String msgErr = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
%>
<script language="JavaScript">
    alert('Erreur : <%=msgErr.replace("'", "\\'")%>');
    history.back();
</script>
<% } %>
