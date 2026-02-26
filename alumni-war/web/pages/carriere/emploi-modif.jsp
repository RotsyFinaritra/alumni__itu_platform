<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="affichage.PageUpdate" %>
<%@ page import="affichage.Champ" %>
<%@ page import="affichage.Liste" %>
<%@ page import="bean.Post" %>
<%@ page import="bean.PostEmploi" %>
<%@ page import="bean.VisibilitePublication" %>
<%@ page import="bean.Competence" %>
<%@ page import="bean.EmploiCompetence" %>
<%@ page import="bean.TypeFichier" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.Set" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String postId = request.getParameter("id");

        // --- Section 1 : Post parent ---
        Post postModele = new Post();
        postModele.setId(postId);
        PageUpdate puPost = new PageUpdate(postModele, request, u);
        puPost.setLien(lien);
        puPost.setTitre("Modifier l'offre d'emploi");

        // Liste pour visibilite
        VisibilitePublication visiType = new VisibilitePublication();
        Champ[] listesPost = new Champ[1];
        listesPost[0] = new Liste("idvisibilite", visiType, "libelle", "id");
        puPost.getFormu().changerEnChamp(listesPost);

        Champ c;
        c = puPost.getFormu().getChamp("id");                  if (c != null) c.setVisible(false);
        c = puPost.getFormu().getChamp("idutilisateur");       if (c != null) c.setVisible(false);
        c = puPost.getFormu().getChamp("idtypepublication");   if (c != null) c.setVisible(false);
        c = puPost.getFormu().getChamp("idstatutpublication"); if (c != null) c.setVisible(false);
        c = puPost.getFormu().getChamp("idgroupe");            if (c != null) c.setVisible(false);
        c = puPost.getFormu().getChamp("epingle");             if (c != null) c.setVisible(false);
        c = puPost.getFormu().getChamp("supprime");            if (c != null) c.setVisible(false);
        c = puPost.getFormu().getChamp("date_suppression");    if (c != null) c.setVisible(false);
        c = puPost.getFormu().getChamp("edited_at");           if (c != null) c.setVisible(false);
        c = puPost.getFormu().getChamp("edited_by");           if (c != null) c.setVisible(false);
        c = puPost.getFormu().getChamp("created_at");          if (c != null) c.setVisible(false);
        c = puPost.getFormu().getChamp("nb_likes");            if (c != null) c.setVisible(false);
        c = puPost.getFormu().getChamp("nb_commentaires");     if (c != null) c.setVisible(false);
        c = puPost.getFormu().getChamp("nb_partages");         if (c != null) c.setVisible(false);

        c = puPost.getFormu().getChamp("contenu");
        if (c != null) { c.setLibelle("Description"); c.setType("editor"); }

        c = puPost.getFormu().getChamp("idvisibilite");
        if (c != null) c.setLibelle("Visibilite");

        puPost.preparerDataFormu();

        // --- Section 2 : PostEmploi ---
        PostEmploi emploiModele = new PostEmploi();
        emploiModele.setPost_id(postId);
        PageUpdate puEmploi = new PageUpdate(emploiModele, request, u);
        puEmploi.setLien(lien);

        // Listes statiques pour emploi
        Liste listeContrat = new Liste("type_contrat");
        String[] contratVals = {"CDI", "CDD", "Freelance", "Alternance", "Autre"};
        listeContrat.makeListeString(contratVals, contratVals);

        Liste listeTT = new Liste("teletravail_possible");
        String[] ttLabels = {"Non", "Oui"};
        String[] ttValues = {"0", "1"};
        listeTT.makeListeString(ttLabels, ttValues);

        Champ[] listesEmploi = new Champ[2];
        listesEmploi[0] = listeContrat;
        listesEmploi[1] = listeTT;
        puEmploi.getFormu().changerEnChamp(listesEmploi);

        c = puEmploi.getFormu().getChamp("post_id");            if (c != null) c.setVisible(false);
        c = puEmploi.getFormu().getChamp("identreprise");       if (c != null) c.setVisible(false);
        c = puEmploi.getFormu().getChamp("entreprise");         if (c != null) c.setLibelle("Entreprise");
        c = puEmploi.getFormu().getChamp("poste");              if (c != null) c.setLibelle("Poste");
        c = puEmploi.getFormu().getChamp("localisation");       if (c != null) c.setLibelle("Localisation");
        c = puEmploi.getFormu().getChamp("type_contrat");       if (c != null) c.setLibelle("Type de contrat");
        c = puEmploi.getFormu().getChamp("salaire_min");        if (c != null) c.setLibelle("Salaire minimum");
        c = puEmploi.getFormu().getChamp("salaire_max");        if (c != null) c.setLibelle("Salaire maximum");
        c = puEmploi.getFormu().getChamp("devise");             if (c != null) c.setLibelle("Devise");
        c = puEmploi.getFormu().getChamp("experience_requise"); if (c != null) c.setLibelle("Experience requise");
        c = puEmploi.getFormu().getChamp("niveau_etude_requis");if (c != null) c.setLibelle("Niveau d etude requis");
        c = puEmploi.getFormu().getChamp("teletravail_possible"); if (c != null) c.setLibelle("Teletravail possible");
        c = puEmploi.getFormu().getChamp("date_limite");        if (c != null) c.setLibelle("Date limite");
        c = puEmploi.getFormu().getChamp("contact_email");      if (c != null) c.setLibelle("Email de contact");
        c = puEmploi.getFormu().getChamp("contact_tel");        if (c != null) c.setLibelle("Telephone");
        c = puEmploi.getFormu().getChamp("lien_candidature");   if (c != null) c.setLibelle("Lien de candidature");

        puEmploi.preparerDataFormu();

        // Charger toutes les competences disponibles
        Competence compFiltre = new Competence();
        Object[] competences = CGenUtil.rechercher(compFiltre, null, null, " ORDER BY libelle");
        
        // Charger les competences deja associees a cet emploi
        Set<String> selectedCompetences = new HashSet<>();
        EmploiCompetence ecFiltre = new EmploiCompetence();
        ecFiltre.setPost_id(postId);
        Object[] existingComps = CGenUtil.rechercher(ecFiltre, null, null, " AND post_id = '" + postId + "'");
        if (existingComps != null) {
            for (Object o : existingComps) {
                EmploiCompetence ec = (EmploiCompetence) o;
                selectedCompetences.add(ec.getIdcompetence());
            }
        }
        
        // Charger les types de fichiers pour la liste déroulante (avec protection si table n'existe pas)
        Object[] typesFichiers = null;
        try {
            TypeFichier tfCritere = new TypeFichier();
            typesFichiers = CGenUtil.rechercher(tfCritere, null, null, " ORDER BY libelle");
        } catch (Exception e) {
            typesFichiers = new Object[0];
        }
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-edit"></i> <%= puPost.getTitre() %></h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carriere</a></li>
            <li><a href="<%=lien%>?but=carriere/emploi-liste.jsp">Offres d'emploi</a></li>
            <li class="active">Modifier</li>
        </ol>
    </section>
    <section class="content">
                <form method="post" action="<%=lien%>?but=carriere/apresCarriere.jsp" enctype="multipart/form-data">
                    <input type="hidden" name="acte" value="updateEmploi">
                    <input type="hidden" name="bute" value="carriere/emploi-fiche.jsp">
                    <input type="hidden" name="post_id" value="<%=postId%>">
                    <input type="hidden" name="id" value="<%=postId%>">

                    <!-- Section Post -->
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Publication</h3>
                        </div>
                        <div class="box-body">
                            <%= puPost.getFormu().getHtmlInsert() %>
                        </div>
                    </div>

                    <!-- Section PostEmploi -->
                    <div class="box box-warning">
                        <div class="box-header with-border">
                            <h3 class="box-title">Details de l offre d emploi</h3>
                        </div>
                        <div class="box-body">
                            <%= puEmploi.getFormu().getHtmlInsert() %>
                            
                            <!-- Selection multiple des competences -->
                            <div class="form-group">
                                <label>Competences requises</label>
                                <select name="competences[]" class="form-control select2" multiple="multiple" 
                                        data-placeholder="Selectionnez les competences" style="width: 100%;">
                                    <% if (competences != null) {
                                        for (Object o : competences) {
                                            Competence comp = (Competence) o;
                                            boolean isSelected = selectedCompetences.contains(comp.getId());
                                    %>
                                    <option value="<%= comp.getId() %>" <%= isSelected ? "selected" : "" %>><%= comp.getLibelle() %></option>
                                    <% }} %>
                                </select>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Section Fichiers joints -->
                    <div class="box box-info">
                        <div class="box-header with-border">
                            <h3 class="box-title"><i class="fa fa-paperclip"></i> Ajouter des fichiers</h3>
                            <div class="box-tools pull-right">
                                <button type="button" class="btn btn-box-tool" data-widget="collapse">
                                    <i class="fa fa-minus"></i>
                                </button>
                            </div>
                        </div>
                        <div class="box-body">
                            <p class="text-muted">Ajoutez des fichiers en cliquant sur le bouton +</p>
                            
                            <div id="fichiers-container">
                                <!-- Les lignes de fichiers seront ajoutées ici dynamiquement -->
                            </div>
                            
                            <button type="button" class="btn btn-sm btn-success" onclick="ajouterLigneFichier()" style="margin-top: 10px;">
                                <i class="fa fa-plus"></i> Ajouter un fichier
                            </button>
                            
                            <p class="text-info" style="margin-top: 10px;">
                                <i class="fa fa-info-circle"></i> 
                                Pour g&eacute;rer les fichiers existants, utilisez le bouton "G&eacute;rer les fichiers" ci-dessous.
                            </p>
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
                        div.className = 'fichier-ligne';
                        div.id = 'fichier-ligne-' + compteurFichier;
                        div.style.marginBottom = '15px';
                        div.style.padding = '10px';
                        div.style.border = '1px solid #ddd';
                        div.style.borderRadius = '5px';
                        div.innerHTML = 
                            '<div class="row" style="margin-bottom:10px;">' +
                                '<div class="col-md-4">' +
                                    '<select name="typeFichier[]" class="form-control input-sm">' +
                                        typesFichiersOptions +
                                    '</select>' +
                                '</div>' +
                                '<div class="col-md-6">' +
                                    '<input type="file" name="fichier[]" class="form-control input-sm" ' +
                                           'onchange="previewFichier(this, ' + compteurFichier + ')" accept="image/*,.pdf,.doc,.docx">' +
                                '</div>' +
                                '<div class="col-md-2">' +
                                    '<button type="button" class="btn btn-sm btn-danger" onclick="supprimerLigneFichier(' + compteurFichier + ')">' +
                                        '<i class="fa fa-trash"></i>' +
                                    '</button>' +
                                '</div>' +
                            '</div>' +
                            '<div class="row">' +
                                '<div class="col-xs-12">' +
                                    '<div id="preview-' + compteurFichier + '" class="preview-container" style="display:none;">' +
                                        '<img id="preview-img-' + compteurFichier + '" src="" alt="Aperçu" ' +
                                             'style="max-width:200px; max-height:150px; border-radius:5px; box-shadow:0 2px 5px rgba(0,0,0,0.2);">' +
                                        '<span id="preview-file-' + compteurFichier + '" class="label label-default" style="display:none; margin-left:10px;">' +
                                            '<i class="fa fa-file"></i> <span class="filename"></span>' +
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
                                    icon.className = 'fa fa-file-pdf-o text-danger';
                                } else if (fileType.includes('word') || fileType.includes('document')) {
                                    icon.className = 'fa fa-file-word-o text-primary';
                                } else {
                                    icon.className = 'fa fa-file-o';
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

                    <div class="box-footer">
                        <button type="submit" class="btn btn-warning">
                            <i class="fa fa-save"></i> Enregistrer les modifications
                        </button>
                        <a class="btn btn-info"
                           href="<%=lien%>?but=carriere/post-fichiers.jsp&postId=<%=postId%>&type=emploi">
                            <i class="fa fa-file"></i> G&eacute;rer les fichiers
                        </a>
                        <a class="btn btn-default pull-right"
                           href="<%=lien%>?but=carriere/emploi-fiche.jsp&id=<%=postId%>">
                            <i class="fa fa-times"></i> Annuler
                        </a>
                    </div>
                </form>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
        String msgErr = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
%>
<script language="JavaScript">alert('Erreur emploi-modif : <%=msgErr.replace("'", "\\'")%>');</script>
<%
    }
%>
