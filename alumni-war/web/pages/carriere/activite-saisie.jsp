<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        PostActivite a = new PostActivite();
        PageInsert pi = new PageInsert(a, request, u);
        pi.setLien(lien);

        // Configuration des libellés
        pi.getFormu().getChamp("titre").setLibelle("Titre de l'activit&eacute; *");
        pi.getFormu().getChamp("idcategorie").setLibelle("Cat&eacute;gorie *");
        pi.getFormu().getChamp("idcategorie").setPageAppelComplete("bean.CategorieActivite", "id", "categorie_activite");
        pi.getFormu().getChamp("lieu").setLibelle("Lieu");
        pi.getFormu().getChamp("adresse").setLibelle("Adresse");
        pi.getFormu().getChamp("date_debut").setLibelle("Date de d&eacute;but");
        pi.getFormu().getChamp("date_debut").setType("datetime-local");
        pi.getFormu().getChamp("date_fin").setLibelle("Date de fin");
        pi.getFormu().getChamp("date_fin").setType("datetime-local");
        pi.getFormu().getChamp("prix").setLibelle("Prix (MGA)");
        pi.getFormu().getChamp("nombre_places").setLibelle("Nombre de places");
        pi.getFormu().getChamp("contact_email").setLibelle("Email de contact");
        pi.getFormu().getChamp("contact_tel").setLibelle("T&eacute;l&eacute;phone de contact");
        pi.getFormu().getChamp("lien_inscription").setLibelle("Lien d'inscription");
        pi.getFormu().getChamp("lien_externe").setLibelle("Lien externe");

        // Masquer places_restantes (géré automatiquement)
        pi.getFormu().getChamp("places_restantes").setVisible(false);

        // Ordre des champs
        String[] ordre = {
            "titre",
            "idcategorie",
            "lieu",
            "adresse",
            "date_debut",
            "date_fin",
            "prix",
            "nombre_places",
            "contact_email",
            "contact_tel",
            "lien_inscription",
            "lien_externe"
        };
        pi.getFormu().setOrdre(ordre);

        // Variables de navigation
        String classe = "bean.PostActivite";
        String butApresPost = "carriere/activite-liste.jsp";
        String nomTable = "POST_ACTIVITE";

        // Charger les types de fichiers pour la liste déroulante
        Object[] typesFichiers = null;
        try {
            TypeFichier tfCritere = new TypeFichier();
            typesFichiers = CGenUtil.rechercher(tfCritere, null, null, " ORDER BY libelle");
        } catch (Exception e) {
            typesFichiers = new Object[0];
        }

        // Générer les affichages
        pi.preparerDataFormu();
        pi.getFormu().makeHtmlInsertTabIndex();
%>
<div class="content-wrapper">
    <section class="content-header">
        <div class="container-fluid">
            <h1><i class="fas fa-calendar"></i> Publier une activit&eacute; / &eacute;v&eacute;nement</h1>
        </div>
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="card card-danger">
                <div class="card-header">
                    <h3 class="card-title">Informations de l'activit&eacute;</h3>
                </div>
                <form action="<%=pi.getLien()%>?but=carriere/apresCarriere.jsp" method="post" name="<%=nomTable%>" id="<%=nomTable%>" 
                      enctype="multipart/form-data" data-parsley-validate>
                    <div class="card-body">
                        <%
                            out.println(pi.getFormu().getHtmlInsert());
                            out.println(pi.getHtmlAddOnPopup());
                        %>
                        
                        <!-- Section fichiers -->
                        <div class="card card-outline card-info mt-3">
                            <div class="card-header">
                                <h4 class="card-title"><i class="fas fa-paperclip"></i> Fichiers joints (optionnel)</h4>
                                <div class="card-tools">
                                    <button type="button" class="btn btn-tool" data-card-widget="collapse">
                                        <i class="fas fa-minus"></i>
                                    </button>
                                </div>
                            </div>
                            <div class="card-body">
                                <p class="text-muted">Ajoutez des fichiers en cliquant sur le bouton +</p>
                                
                                <div id="fichiers-container">
                                </div>
                                
                                <button type="button" class="btn btn-sm btn-success mt-2" onclick="ajouterLigneFichier()">
                                    <i class="fas fa-plus"></i> Ajouter un fichier
                                </button>
                            </div>
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
                            div.className = 'fichier-ligne mb-3 p-2 border rounded';
                            div.id = 'fichier-ligne-' + compteurFichier;
                            div.innerHTML = 
                                '<div class="row mb-2">' +
                                    '<div class="col-md-4">' +
                                        '<select name="typeFichier[]" class="form-control form-control-sm">' +
                                            typesFichiersOptions +
                                        '</select>' +
                                    '</div>' +
                                    '<div class="col-md-6">' +
                                        '<input type="file" name="fichier[]" class="form-control form-control-sm" ' +
                                               'onchange="previewFichier(this, ' + compteurFichier + ')" accept="image/*,.pdf,.doc,.docx">' +
                                    '</div>' +
                                    '<div class="col-md-2">' +
                                        '<button type="button" class="btn btn-sm btn-danger" onclick="supprimerLigneFichier(' + compteurFichier + ')">' +
                                            '<i class="fas fa-trash"></i>' +
                                        '</button>' +
                                    '</div>' +
                                '</div>' +
                                '<div class="row">' +
                                    '<div class="col-12">' +
                                        '<div id="preview-' + compteurFichier + '" class="preview-container" style="display:none;">' +
                                            '<img id="preview-img-' + compteurFichier + '" src="" alt="Aperçu" ' +
                                                 'style="max-width:200px; max-height:150px; border-radius:5px; box-shadow:0 2px 5px rgba(0,0,0,0.2);">' +
                                            '<span id="preview-file-' + compteurFichier + '" class="badge badge-secondary ml-2" style="display:none;">' +
                                                '<i class="fas fa-file"></i> <span class="filename"></span>' +
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
                                    var reader = new FileReader();
                                    reader.onload = function(e) {
                                        previewImg.src = e.target.result;
                                        previewImg.style.display = 'inline-block';
                                        previewFile.style.display = 'none';
                                    };
                                    reader.readAsDataURL(file);
                                } else {
                                    previewImg.style.display = 'none';
                                    previewFile.style.display = 'inline-block';
                                    previewFile.querySelector('.filename').textContent = file.name;
                                    
                                    var icon = previewFile.querySelector('i');
                                    if (fileType === 'application/pdf') {
                                        icon.className = 'fas fa-file-pdf text-danger';
                                    } else if (fileType.includes('word') || fileType.includes('document')) {
                                        icon.className = 'fas fa-file-word text-primary';
                                    } else {
                                        icon.className = 'fas fa-file text-secondary';
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
                        </script>
                        
                        <input name="acte" type="hidden" value="insertActivite">
                        <input name="bute" type="hidden" value="<%= butApresPost %>">
                        <input name="classe" type="hidden" value="<%= classe %>">
                        <input name="nomtable" type="hidden" value="<%= nomTable %>">
                    </div>
                    <div class="card-footer">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Enregistrer
                        </button>
                        <a href="<%=lien%>?but=carriere/activite-liste.jsp" class="btn btn-secondary">
                            <i class="fas fa-arrow-left"></i> Retour
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
