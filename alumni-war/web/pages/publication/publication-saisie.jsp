<%@ page import="bean.*, affichage.*, user.UserEJB" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    if (u == null || lien == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int refuserInt = Integer.parseInt(u.getUser().getTuppleID());
    String postId = request.getParameter("id");
    boolean isEdit = (postId != null && !postId.isEmpty());
    
    // Charger le post si en mode edition
    Post existingPost = null;
    PostStage existingStage = null;
    PostEmploi existingEmploi = null;
    PostActivite existingActivite = null;
    
    if (isEdit) {
        Post filter = new Post();
        filter.setId(postId);
        Object[] result = CGenUtil.rechercher(filter, null, null, "");
        if (result != null && result.length > 0) {
            existingPost = (Post) result[0];
            
            // Verifier les permissions
            if (existingPost.getIdutilisateur() != refuserInt) {
                throw new Exception("Vous n'avez pas la permission de modifier cette publication.");
            }
            
            // Charger les details selon le type
            if ("TYPU00001".equals(existingPost.getIdtypepublication())) {
                PostStage stageFilter = new PostStage();
                stageFilter.setPost_id(postId);
                Object[] stageResult = CGenUtil.rechercher(stageFilter, null, null, "");
                if (stageResult != null && stageResult.length > 0) {
                    existingStage = (PostStage) stageResult[0];
                }
            } else if ("TYPU00002".equals(existingPost.getIdtypepublication())) {
                PostEmploi emploiFilter = new PostEmploi();
                emploiFilter.setPost_id(postId);
                Object[] emploiResult = CGenUtil.rechercher(emploiFilter, null, null, "");
                if (emploiResult != null && emploiResult.length > 0) {
                    existingEmploi = (PostEmploi) emploiResult[0];
                }
            } else if ("TYPU00003".equals(existingPost.getIdtypepublication())) {
                PostActivite activiteFilter = new PostActivite();
                activiteFilter.setPost_id(postId);
                Object[] activiteResult = CGenUtil.rechercher(activiteFilter, null, null, "");
                if (activiteResult != null && activiteResult.length > 0) {
                    existingActivite = (PostActivite) activiteResult[0];
                }
            }
        }
    }
    
    // Utiliser PageInsert pour le post principal
    Post post = isEdit ? existingPost : new Post();
    PageInsert pi = new PageInsert(post, request, u);
    pi.setLien(lien);
    pi.setTitre(isEdit ? "Modifier la publication" : "Nouvelle publication");
    
    // Cacher les champs automatiques
    pi.getFormu().getChamp("id").setVisible(false);
    pi.getFormu().getChamp("idutilisateur").setVisible(false);
    pi.getFormu().getChamp("idutilisateur").setDefaut(String.valueOf(refuserInt));
    pi.getFormu().getChamp("nb_likes").setVisible(false);
    pi.getFormu().getChamp("nb_commentaires").setVisible(false);
    pi.getFormu().getChamp("nb_partages").setVisible(false);
    pi.getFormu().getChamp("created_at").setVisible(false);
    pi.getFormu().getChamp("updated_at").setVisible(false);
    
    // Configuration des champs
    pi.getFormu().getChamp("idtypepublication").setLibelle("Type de publication *");
    pi.getFormu().getChamp("idstatutpublication").setLibelle("Statut *");
    pi.getFormu().getChamp("idvisibilite").setLibelle("Visibilit&eacute; *");
    pi.getFormu().getChamp("contenu").setLibelle("Contenu *");
    pi.getFormu().getChamp("contenu").setType("textarea");
    
    // Charger les donnees de reference pour les selects
    TypePublication[] typesPublication = (TypePublication[]) CGenUtil.rechercher(new TypePublication(), null, null, " AND actif = true ORDER BY ordre");
    StatutPublication[] statutsPublication = (StatutPublication[]) CGenUtil.rechercher(new StatutPublication(), null, null, " AND actif = true ORDER BY ordre");
    VisibilitePublication[] visibilites = (VisibilitePublication[]) CGenUtil.rechercher(new VisibilitePublication(), null, null, " AND actif = true ORDER BY ordre");
    
    // Preparer les donnees
    pi.preparerDataFormu();
    pi.getFormu().makeHtmlInsert();
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1>
            <i class="fa fa-<%= isEdit ? "edit" : "plus" %>"></i> <%= isEdit ? "Modifier" : "Nouvelle" %> publication
        </h1>
    </section>
    
    <section class="content">
        <form action="<%= lien %>?but=publication/save-publication-apj.jsp" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
            <input type="hidden" name="acte" value="<%= isEdit ? "update" : "insert" %>">
            <% if (isEdit) { %>
            <input type="hidden" name="id" value="<%= postId %>">
            <% } %>
            
            <div class="row">
                <div class="col-md-8">
                    <!-- Informations principales -->
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Informations principales</h3>
                        </div>
                        <div class="box-body">
                            <div class="form-group">
                                <label>Type de publication *</label>
                                <select name="idtypepublication" id="idtypepublication" class="form-control" required 
                                        onchange="toggleTypeSpecificFields()" <%= isEdit ? "disabled" : "" %>>
                                    <option value="">-- Sélectionner --</option>
                                    <% if (typesPublication != null) {
                                        for (TypePublication tp : typesPublication) { %>
                                    <option value="<%= tp.getId() %>" 
                                            <%= (existingPost != null && tp.getId().equals(existingPost.getIdtypepublication())) ? "selected" : "" %>>
                                        <%= tp.getLibelle() %>
                                    </option>
                                    <% }
                                    } %>
                                </select>
                                <% if (isEdit) { %>
                                <input type="hidden" name="idtypepublication" value="<%= existingPost.getIdtypepublication() %>">
                                <% } %>
                            </div>
                            
                            <div class="form-group">
                                <label>Contenu *</label>
                                <textarea name="contenu" id="contenu" class="form-control" rows="6" required 
                                          placeholder="Décrivez votre publication..."><%= (existingPost != null && existingPost.getContenu() != null) ? existingPost.getContenu() : "" %></textarea>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Champs spécifiques : Stage -->
                    <div class="box box-info" id="stageFields" style="display: none;">
                        <div class="box-header with-border">
                            <h3 class="box-title"><i class="fa fa-briefcase"></i> Détails du stage</h3>
                        </div>
                        <div class="box-body">
                            <div class="form-group">
                                <label>Entreprise *</label>
                                <input type="text" name="stage_entreprise" class="form-control" 
                                       value="<%= (existingStage != null && existingStage.getEntreprise() != null) ? existingStage.getEntreprise() : "" %>">
                            </div>
                            <div class="form-group">
                                <label>Localisation</label>
                                <input type="text" name="stage_localisation" class="form-control" 
                                       value="<%= (existingStage != null && existingStage.getLocalisation() != null) ? existingStage.getLocalisation() : "" %>">
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Durée</label>
                                        <input type="text" name="stage_duree" class="form-control" placeholder="Ex: 3 mois" 
                                               value="<%= (existingStage != null && existingStage.getDuree() != null) ? existingStage.getDuree() : "" %>">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Indemnité</label>
                                        <input type="text" name="stage_indemnite" class="form-control" placeholder="Ex: 500 000 Ar/mois" 
                                               value="<%= (existingStage != null && existingStage.getIndemnite() != null) ? existingStage.getIndemnite() : "" %>">
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Compétences requises</label>
                                <textarea name="stage_competences" class="form-control" rows="3" 
                                          placeholder="Liste des compétences..."><%= (existingStage != null && existingStage.getCompetences_requises() != null) ? existingStage.getCompetences_requises() : "" %></textarea>
                            </div>
                            <div class="form-group">
                                <label>Lien de candidature</label>
                                <input type="url" name="stage_lien" class="form-control" placeholder="https://..." 
                                       value="<%= (existingStage != null && existingStage.getLien_candidature() != null) ? existingStage.getLien_candidature() : "" %>">
                            </div>
                        </div>
                    </div>
                    
                    <!-- Champs spécifiques : Emploi -->
                    <div class="box box-info" id="emploiFields" style="display: none;">
                        <div class="box-header with-border">
                            <h3 class="box-title"><i class="fa fa-graduation-cap"></i> Détails de l'emploi</h3>
                        </div>
                        <div class="box-body">
                            <div class="form-group">
                                <label>Entreprise *</label>
                                <input type="text" name="emploi_entreprise" class="form-control" 
                                       value="<%= (existingEmploi != null && existingEmploi.getEntreprise() != null) ? existingEmploi.getEntreprise() : "" %>">
                            </div>
                            <div class="form-group">
                                <label>Poste *</label>
                                <input type="text" name="emploi_poste" class="form-control" 
                                       value="<%= (existingEmploi != null && existingEmploi.getPoste() != null) ? existingEmploi.getPoste() : "" %>">
                            </div>
                            <div class="form-group">
                                <label>Localisation</label>
                                <input type="text" name="emploi_localisation" class="form-control" 
                                       value="<%= (existingEmploi != null && existingEmploi.getLocalisation() != null) ? existingEmploi.getLocalisation() : "" %>">
                            </div>
                            <div class="form-group">
                                <label>Type de contrat</label>
                                <select name="emploi_type_contrat" class="form-control">
                                    <option value="">-- Sélectionner --</option>
                                    <option value="CDI" <%= (existingEmploi != null && "CDI".equals(existingEmploi.getType_contrat())) ? "selected" : "" %>>CDI</option>
                                    <option value="CDD" <%= (existingEmploi != null && "CDD".equals(existingEmploi.getType_contrat())) ? "selected" : "" %>>CDD</option>
                                    <option value="Freelance" <%= (existingEmploi != null && "Freelance".equals(existingEmploi.getType_contrat())) ? "selected" : "" %>>Freelance</option>
                                    <option value="Stage" <%= (existingEmploi != null && "Stage".equals(existingEmploi.getType_contrat())) ? "selected" : "" %>>Stage</option>
                                </select>
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Salaire min (Ar)</label>
                                        <input type="number" name="emploi_salaire_min" class="form-control" 
                                               value="<%= (existingEmploi != null && existingEmploi.getSalaire_min() != null) ? existingEmploi.getSalaire_min() : "" %>">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Salaire max (Ar)</label>
                                        <input type="number" name="emploi_salaire_max" class="form-control" 
                                               value="<%= (existingEmploi != null && existingEmploi.getSalaire_max() != null) ? existingEmploi.getSalaire_max() : "" %>">
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Qualifications requises</label>
                                <textarea name="emploi_qualifications" class="form-control" rows="3"><%= (existingEmploi != null && existingEmploi.getQualifications_requises() != null) ? existingEmploi.getQualifications_requises() : "" %></textarea>
                            </div>
                            <div class="form-group">
                                <label>Lien de candidature</label>
                                <input type="url" name="emploi_lien" class="form-control" placeholder="https://..." 
                                       value="<%= (existingEmploi != null && existingEmploi.getLien_candidature() != null) ? existingEmploi.getLien_candidature() : "" %>">
                            </div>
                        </div>
                    </div>
                    
                    <!-- Champs spécifiques : Activité -->
                    <div class="box box-info" id="activiteFields" style="display: none;">
                        <div class="box-header with-border">
                            <h3 class="box-title"><i class="fa fa-calendar"></i> Détails de l'activité</h3>
                        </div>
                        <div class="box-body">
                            <div class="form-group">
                                <label>Titre de l'&eacute;v&egrave;nement *</label>
                                <input type="text" name="activite_titre" class="form-control" 
                                       value="<%= (existingActivite != null && existingActivite.getTitre_evenement() != null) ? existingActivite.getTitre_evenement() : "" %>">
                            </div>
                            <div class="form-group">
                                <label>Lieu</label>
                                <input type="text" name="activite_lieu" class="form-control" 
                                       value="<%= (existingActivite != null && existingActivite.getLieu() != null) ? existingActivite.getLieu() : "" %>">
                            </div>
                            <div class="row">
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Date de d&eacute;but</label>
                                        <input type="date" name="activite_date_debut" class="form-control" 
                                               value="<%= (existingActivite != null && existingActivite.getDate_debut() != null) ? existingActivite.getDate_debut() : "" %>">
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-group">
                                        <label>Date de fin</label>
                                        <input type="date" name="activite_date_fin" class="form-control" 
                                               value="<%= (existingActivite != null && existingActivite.getDate_fin() != null) ? existingActivite.getDate_fin() : "" %>">
                                    </div>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Prix</label>
                                <input type="text" name="activite_prix" class="form-control" placeholder="Ex: Gratuit, 10 000 Ar" 
                                       value="<%= (existingActivite != null && existingActivite.getPrix() != null) ? existingActivite.getPrix() : "" %>">
                            </div>
                            <div class="form-group">
                                <label>Lien d'inscription</label>
                                <input type="url" name="activite_lien" class="form-control" placeholder="https://..." 
                                       value="<%= (existingActivite != null && existingActivite.getLien_inscription() != null) ? existingActivite.getLien_inscription() : "" %>">
                            </div>
                        </div>
                    </div>
                    
                </div>
                
                <!-- Sidebar droite -->
                <div class="col-md-4">
                    <!-- Paramètres de publication -->
                    <div class="box box-default">
                        <div class="box-header with-border">
                            <h3 class="box-title">Param&egrave;tres</h3>
                        </div>
                        <div class="box-body">
                            <div class="form-group">
                                <label>Visibilit&eacute; *</label>
                                <select name="idvisibilite" class="form-control" required>
                                    <% if (visibilites != null) {
                                        for (VisibilitePublication vp : visibilites) { %>
                                    <option value="<%= vp.getId() %>" 
                                            <%= (existingPost != null && vp.getId().equals(existingPost.getIdvisibilite())) ? "selected" : "" %>>
                                        <%= vp.getLibelle() %>
                                    </option>
                                    <% }
                                    } %>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label>Statut *</label>
                                <select name="idstatutpublication" class="form-control" required>
                                    <% if (statutsPublication != null) {
                                        for (StatutPublication sp : statutsPublication) { %>
                                    <option value="<%= sp.getId() %>" 
                                            <%= (existingPost != null && sp.getId().equals(existingPost.getIdstatutpublication())) ? "selected" : "" %>>
                                        <%= sp.getLibelle() %>
                                    </option>
                                    <% }
                                    } %>
                                </select>
                                <small class="text-muted">Brouillon : visible par vous seulement<br>Publié : visible selon la visibilité choisie</small>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Fichiers joints -->
                    <div class="box box-default">
                        <div class="box-header with-border">
                            <h3 class="box-title"><i class="fa fa-paperclip"></i> Fichiers joints</h3>
                        </div>
                        <div class="box-body">
                            <input type="file" name="fichiers" id="fichiers" multiple class="form-control">
                            <small class="text-muted">Max 5 fichiers, 10 Mo chacun</small>
                        </div>
                    </div>
                    
                    <!-- Boutons d'action -->
                    <div class="box">
                        <div class="box-body">
                            <button type="submit" class="btn btn-primary btn-block">
                                <i class="fa fa-check"></i> <%= isEdit ? "Mettre à jour" : "Publier" %>
                            </button>
                            <a href="<%= lien %>?but=publication/publication-liste.jsp" class="btn btn-default btn-block">
                                <i class="fa fa-times"></i> Annuler
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </form>
    </section>
</div>

<script>
function toggleTypeSpecificFields() {
    var type = document.getElementById('idtypepublication').value;
    document.getElementById('stageFields').style.display = 'none';
    document.getElementById('emploiFields').style.display = 'none';
    document.getElementById('activiteFields').style.display = 'none';
    
    if (type === 'TYPU00001') {
        document.getElementById('stageFields').style.display = 'block';
    } else if (type === 'TYPU00002') {
        document.getElementById('emploiFields').style.display = 'block';
    } else if (type === 'TYPU00003') {
        document.getElementById('activiteFields').style.display = 'block';
    }
}

function validateForm() {
    var type = document.getElementById('idtypepublication').value;
    
    if (type === 'TYPU00001') {
        if (!document.querySelector('[name="stage_entreprise"]').value) {
            alert('L\'entreprise est requise pour un stage');
            return false;
        }
    } else if (type === 'TYPU00002') {
        if (!document.querySelector('[name="emploi_entreprise"]').value || !document.querySelector('[name="emploi_poste"]').value) {
            alert('L\'entreprise et le poste sont requis pour un emploi');
            return false;
        }
    } else if (type === 'TYPU00003') {
        if (!document.querySelector('[name="activite_titre"]').value) {
            alert('Le titre de l\'événement est requis pour une activité');
            return false;
        }
    }
    
    return true;
}

// Initialiser l'affichage au chargement de la page
window.onload = function() {
    toggleTypeSpecificFields();
};
</script>

<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'><h4><i class='fa fa-ban'></i> Erreur</h4><p>" + e.getMessage() + "</p></div>");
} %>
