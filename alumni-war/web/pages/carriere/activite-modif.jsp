<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="affichage.*" %>
<%@ page import="bean.*" %>
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
        puPost.setTitre("Modifier l'activit&eacute;");

        // Liste pour visibilite
        TypeObjet visiType = new TypeObjet();
        visiType.setNomTable("visibilite_publication");
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
        if (c != null) c.setLibelle("Visibilit&eacute;");

        puPost.preparerDataFormu();

        // --- Section 2 : PostActivite ---
        PostActivite activiteModele = new PostActivite();
        activiteModele.setPost_id(postId);
        PageUpdate puActivite = new PageUpdate(activiteModele, request, u);
        puActivite.setLien(lien);

        c = puActivite.getFormu().getChamp("post_id");          if (c != null) c.setVisible(false);
        c = puActivite.getFormu().getChamp("places_restantes"); if (c != null) c.setVisible(false);
        c = puActivite.getFormu().getChamp("titre");            if (c != null) c.setLibelle("Titre de l'activit&eacute;");
        c = puActivite.getFormu().getChamp("idcategorie");      if (c != null) {
            c.setLibelle("Cat&eacute;gorie");
            c.setPageAppelComplete("bean.CategorieActivite", "id", "categorie_activite");
        }
        c = puActivite.getFormu().getChamp("lieu");             if (c != null) c.setLibelle("Lieu");
        c = puActivite.getFormu().getChamp("adresse");          if (c != null) c.setLibelle("Adresse");
        c = puActivite.getFormu().getChamp("date_debut");       if (c != null) { c.setLibelle("Date de d&eacute;but"); c.setType("datetime-local"); }
        c = puActivite.getFormu().getChamp("date_fin");         if (c != null) { c.setLibelle("Date de fin"); c.setType("datetime-local"); }
        c = puActivite.getFormu().getChamp("prix");             if (c != null) c.setLibelle("Prix (MGA)");
        c = puActivite.getFormu().getChamp("nombre_places");    if (c != null) c.setLibelle("Nombre de places");
        c = puActivite.getFormu().getChamp("contact_email");    if (c != null) c.setLibelle("Email de contact");
        c = puActivite.getFormu().getChamp("contact_tel");      if (c != null) c.setLibelle("T&eacute;l&eacute;phone de contact");
        c = puActivite.getFormu().getChamp("lien_inscription"); if (c != null) c.setLibelle("Lien d'inscription");
        c = puActivite.getFormu().getChamp("lien_externe");     if (c != null) c.setLibelle("Lien externe");

        puActivite.preparerDataFormu();

        // Charger les types de fichiers
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
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carri&egrave;re</a></li>
            <li><a href="<%=lien%>?but=carriere/activite-liste.jsp">Activit&eacute;s</a></li>
            <li class="active">Modifier</li>
        </ol>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-1"></div>
            <div class="col-md-10">
                <form method="post" action="<%=lien%>?but=carriere/apresCarriere.jsp" enctype="multipart/form-data">
                    <input type="hidden" name="acte" value="updateActivite">
                    <input type="hidden" name="bute" value="carriere/activite-fiche.jsp">
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

                    <!-- Section PostActivite -->
                    <div class="box box-danger">
                        <div class="box-header with-border">
                            <h3 class="box-title">D&eacute;tails de l'activit&eacute;</h3>
                        </div>
                        <div class="box-body">
                            <%= puActivite.getFormu().getHtmlInsert() %>
                            <%= puActivite.getHtmlAddOnPopup() %>
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
                                        '<img id="preview-img-' + compteurFichier + '" src="" alt="Apercu" ' +
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
                           href="<%=lien%>?but=carriere/post-fichiers.jsp&postId=<%=postId%>&type=activite">
                            <i class="fa fa-file"></i> G&eacute;rer les fichiers
                        </a>
                        <a class="btn btn-default pull-right"
                           href="<%=lien%>?but=carriere/activite-fiche.jsp&id=<%=postId%>">
                            <i class="fa fa-times"></i> Annuler
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
        String msgErr = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
%>
<script language="JavaScript">alert('Erreur activite-modif : <%=msgErr.replace("'", "\\'")%>');</script>
<%
    }
%>
