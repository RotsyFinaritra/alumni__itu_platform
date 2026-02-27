<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page import="utils.PublicationPermission" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        
        // === CONTRÔLE D'ACCÈS PAR RÔLE ===
        // boolean peutPublier = PublicationPermission.peutPublier(u);
        boolean peutPublier = true;
        if (!peutPublier) {
            String messageErreur = PublicationPermission.getMessageErreur(u);
%>
<div class="content-wrapper">
    <section class="content">
        <div class="alert alert-danger" style="margin: 50px;">
            <h4><i class="fa fa-ban"></i> Acc&egrave;s refus&eacute;</h4>
            <p><%= messageErreur %></p>
            <a href="<%=lien%>?but=carriere/stage-liste.jsp" class="btn btn-secondary">
                <i class="fa fa-arrow-left"></i> Retour &agrave; la liste
            </a>
        </div>
    </section>
</div>
<%
            return;
        }
        // === FIN CONTRÔLE D'ACCÈS ===
        
        PostStage a = new PostStage();
        PageInsert pi = new PageInsert(a, request, u);
        pi.setLien(lien);

        // Pas de listes déroulantes spécifiques pour PostStage

        // Configuration des libellés
        pi.getFormu().getChamp("duree").setLibelle("Dur&eacute;e du stage *");
        pi.getFormu().getChamp("date_debut").setLibelle("Date de d&eacute;but");
        pi.getFormu().getChamp("date_fin").setLibelle("Date de fin");
        pi.getFormu().getChamp("indemnite").setLibelle("Indemnit&eacute; (MGA)");
        pi.getFormu().getChamp("niveau_etude_requis").setLibelle("Niveau d'&eacute;tude requis");
        pi.getFormu().getChamp("convention_requise").setLibelle("Convention requise");
        pi.getFormu().getChamp("places_disponibles").setLibelle("Places disponibles");
        pi.getFormu().getChamp("contact_email").setLibelle("Email de contact");
        pi.getFormu().getChamp("contact_tel").setLibelle("T&eacute;l&eacute;phone de contact");
        pi.getFormu().getChamp("lien_candidature").setLibelle("Lien de candidature");
        pi.getFormu().getChamp("identreprise").setLibelle("Entreprise *");
        
        // Masquer le champ texte 'entreprise' (doublon avec l'autocomplete identreprise)
        pi.getFormu().getChamp("entreprise").setVisible(false);
        // pi.getFormu().getChamp("localisation").setVisible(false);
        // pi.getFormu().getChamp("post_id").setVisible(false);

        // Configuration des autocomplete (nomClasse, colId, tableName)
        // Entreprise avec bouton + pour ajouter
        pi.getFormu().getChamp("identreprise").setPageAppelCompleteInsert(
            "bean.Entreprise", "id", "entreprise",
            "carriere/entreprise-saisie.jsp", "id;libelle"
        );
        pi.getFormu().getChamp("niveau_etude_requis").setPageAppelComplete("bean.Diplome", "id", "diplome");

        // Valeurs par défaut
        pi.getFormu().getChamp("convention_requise").setDefaut("0");
        pi.getFormu().getChamp("places_disponibles").setDefaut("1");

        // Ordre des champs (sans competences_requises)
        String[] ordre = {
            "identreprise",
            "duree",
            "date_debut",
            "date_fin",
            "indemnite",
            "niveau_etude_requis",
            "convention_requise",
            "places_disponibles",
            "contact_email",
            "contact_tel",
            "lien_candidature"
        };
        pi.getFormu().setOrdre(ordre);

        // Variables de navigation
        String classe = "bean.PostStage";
        String butApresPost = "carriere/stage-liste.jsp";
        String nomTable = "POST_STAGE";

        // Charger la liste des compétences pour le select multiple
        Competence compFiltre = new Competence();
        Object[] competences = CGenUtil.rechercher(compFiltre, null, null, " ORDER BY libelle");

        // Charger les types de fichiers pour la liste déroulante (avec protection si table n'existe pas)
        Object[] typesFichiers = null;
        try {
            TypeFichier tfCritere = new TypeFichier();
            typesFichiers = CGenUtil.rechercher(tfCritere, null, null, " ORDER BY libelle");
        } catch (Exception e) {
            // Table type_fichier n'existe pas encore
            typesFichiers = new Object[0];
        }

        // Générer les affichages
        pi.preparerDataFormu();
        pi.getFormu().makeHtmlInsertTabIndex();
%>
<div class="content-wrapper">
    <section class="content-header">
        <div class="container-fluid" style="display: flex; justify-content: space-between; align-items: center;">
            <h1><i class="fa fa-graduation-cap"></i> Publier une offre de stage</h1>
            <a href="<%=lien%>?but=carriere/stage-liste.jsp" class="btn btn-default">
                <i class="fa fa-arrow-left"></i> Retour &agrave; la liste
            </a>
        </div>
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="card card-success">
                <div class="card-header">
                    <h3 class="card-title">Informations du stage</h3>
                </div>
                <form action="<%=pi.getLien()%>?but=carriere/apresCarriere.jsp" method="post" name="<%=nomTable%>" id="<%=nomTable%>" 
                      enctype="multipart/form-data" data-parsley-validate>
                    <div class="card-body">
                        <!-- Contenu / Description (stocké dans la table posts) -->
                        <div class="form-group">
                            <label>Description du stage</label>
                            <textarea name="contenu" class="form-control" rows="5" 
                                      placeholder="D&eacute;crivez l'offre de stage en d&eacute;tail..."></textarea>
                        </div>
                        
                        <%
                            out.println(pi.getFormu().getHtmlInsert());
                            out.println(pi.getHtmlAddOnPopup());
                        %>
                        
                        <!-- Sélection multiple des compétences -->
                        <div class="form-group">
                            <label>Comp&eacute;tences requises</label>
                            <select name="competences[]" class="form-control select2" multiple="multiple" 
                                    data-placeholder="S&eacute;lectionnez les comp&eacute;tences" style="width: 100%;">
                                <% if (competences != null) {
                                    for (Object o : competences) {
                                        Competence c = (Competence) o;
                                %>
                                <option value="<%= c.getId() %>"><%= c.getLibelle() %></option>
                                <% }} %>
                            </select>
                            <small class="form-text text-muted">Maintenez Ctrl pour s&eacute;lectionner plusieurs comp&eacute;tences</small>
                        </div>
                        
                        <!-- Section fichiers -->
                        <div class="form-group mt-4">
                            <label><i class="fa fa-paperclip"></i> Fichiers joints <small class="text-muted">(optionnel)</small></label>
                            <div id="fichiers-container" style="margin-top: 10px;">
                                <!-- Première ligne ajoutée automatiquement -->
                            </div>
                            <button type="button" class="btn btn-sm btn-outline-primary mt-2" onclick="ajouterLigneFichier()">
                                <i class="fa fa-plus"></i> Ajouter un autre fichier
                            </button>
                        </div>
                        
                        <script>
                        var compteurFichier = 0;
                        var typesFichiersOptions = '<option value="">-- Type de fichier --</option>';
                        <% if (typesFichiers != null) {
                            for (Object o : typesFichiers) {
                                TypeFichier tf = (TypeFichier) o;
                        %>
                        typesFichiersOptions += '<option value="<%= tf.getId() %>"><%= tf.getLibelle() %></option>';
                        <% }} %>
                        
                        function ajouterLigneFichier() {
                            compteurFichier++;
                            var container = document.getElementById('fichiers-container');
                            var div = document.createElement('div');
                            div.className = 'fichier-ligne mb-2';
                            div.id = 'fichier-ligne-' + compteurFichier;
                            div.style.padding = '10px';
                            div.style.background = '#f8f9fa';
                            div.style.borderRadius = '6px';
                            div.style.border = '1px solid #e9ecef';
                            div.innerHTML = 
                                '<div class="row align-items-center">' +
                                    '<div class="col-md-3">' +
                                        '<select name="typeFichier[]" class="form-control form-control-sm" required>' +
                                            typesFichiersOptions +
                                        '</select>' +
                                    '</div>' +
                                    '<div class="col-md-7">' +
                                        '<input type="file" name="fichier[]" class="form-control form-control-sm" ' +
                                               'onchange="previewFichier(this, ' + compteurFichier + ')" accept="image/*,.pdf,.doc,.docx" required>' +
                                    '</div>' +
                                    '<div class="col-md-2 text-right">' +
                                        '<button type="button" class="btn btn-sm btn-outline-secondary" onclick="supprimerLigneFichier(' + compteurFichier + ')" title="Supprimer">' +
                                            '<i class="fa fa-times"></i>' +
                                        '</button>' +
                                    '</div>' +
                                '</div>' +
                                '<div class="row mt-2">' +
                                    '<div class="col-12">' +
                                        '<div id="preview-' + compteurFichier + '" class="preview-container" style="display:none; padding:8px;">' +
                                            '<img id="preview-img-' + compteurFichier + '" src="" alt="Aperçu" ' +
                                                 'style="max-width:150px; max-height:100px; border-radius:4px; border:1px solid #dee2e6;">' +
                                            '<span id="preview-file-' + compteurFichier + '" class="badge badge-light ml-2" style="display:none; border: 1px solid #dee2e6;">' +
                                                '<i class="fa fa-file-o"></i> <span class="filename"></span>' +
                                            '</span>' +
                                        '</div>' +
                                    '</div>' +
                                '</div>';
                            container.appendChild(div);
                        }
                        
                        function previewFichier(input, id) {
                            var previewContainer = document.getElementById('preview-' + id);
                            var previewImg = document.getElementById('preview-img-' + id);
                            var previewFile = document.getElementById('preview-file-' + id);
                            
                            if (input.files && input.files[0]) {
                                var file = input.files[0];
                                var fileType = file.type;
                                
                                previewContainer.style.display = 'block';
                                
                                if (fileType.startsWith('image/')) {
                                    // Aperçu image
                                    var reader = new FileReader();
                                    reader.onload = function(e) {
                                        previewImg.src = e.target.result;
                                        previewImg.style.display = 'inline-block';
                                        previewFile.style.display = 'none';
                                    };
                                    reader.readAsDataURL(file);
                                } else {
                                    // Fichier non-image (PDF, DOC, etc.)
                                    previewImg.style.display = 'none';
                                    previewFile.style.display = 'inline-block';
                                    previewFile.querySelector('.filename').textContent = file.name;
                                    
                                    // Icône selon le type
                                    var icon = previewFile.querySelector('i');
                                    if (fileType === 'application/pdf') {
                                        icon.className = 'fa fa-file-pdf-o text-danger';
                                    } else if (fileType.includes('word') || fileType.includes('document')) {
                                        icon.className = 'fa fa-file-word-o text-primary';
                                    } else {
                                        icon.className = 'fa fa-file-o text-secondary';
                                    }
                                }
                            } else {
                                previewContainer.style.display = 'none';
                            }
                        }
                        
                        function supprimerLigneFichier(id) {
                            var ligne = document.getElementById('fichier-ligne-' + id);
                            if (ligne) {
                                ligne.remove();
                            }
                        }
                        
                        // Ajouter automatiquement la première ligne au chargement
                        window.addEventListener('DOMContentLoaded', function() {
                            ajouterLigneFichier();
                        });
                        </script>
                        
                        <input name="acte" type="hidden" value="insertStage">
                        <input name="bute" type="hidden" value="<%= butApresPost %>">
                        <input name="classe" type="hidden" value="<%= classe %>">
                        <input name="nomtable" type="hidden" value="<%= nomTable %>">
                    </div>
                    <div class="card-footer">
                        <button type="submit" class="btn btn-success">
                            <i class="fa fa-floppy-o"></i> Enregistrer
                        </button>
                        <a href="<%=lien%>?but=carriere/stage-liste.jsp" class="btn btn-secondary">
                            <i class="fa fa-arrow-left"></i> Retour
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<div class="alert alert-danger">
    Erreur : <%= e.getMessage() %>
</div>
<%
    }
%>
