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

        // --- Section 1 : mise a jour du Post parent ---
        Post postModele = new Post();
        postModele.setNomTable("posts");
        PageUpdate puPost = new PageUpdate(postModele, request, u);
        puPost.setTitre("Modifier l'offre d'emploi");

        Champ c;
        c = puPost.getChampByName("post_id");        if (c != null) c.setVisible(false);
        c = puPost.getChampByName("idutilisateur");  if (c != null) c.setVisible(false);
        c = puPost.getChampByName("type");           if (c != null) c.setVisible(false);
        c = puPost.getChampByName("idstatutpublication"); if (c != null) c.setVisible(false);
        c = puPost.getChampByName("idgroupe");       if (c != null) c.setVisible(false);
        c = puPost.getChampByName("epingle");        if (c != null) c.setVisible(false);
        c = puPost.getChampByName("supprime");       if (c != null) c.setVisible(false);
        c = puPost.getChampByName("edited_at");      if (c != null) c.setVisible(false);
        c = puPost.getChampByName("created_at");     if (c != null) c.setVisible(false);

        Champ champContenu = puPost.getChampByName("contenu");
        if (champContenu != null) {
            champContenu.setLibelle("Description");
            champContenu.setType("editor");
            champContenu.setObligatoire(true);
        }

        Champ champVisi = puPost.getChampByName("idvisibilite");
        if (champVisi != null) {
            champVisi.setLibelle("Visibilite");
            champVisi.setObligatoire(true);
            Liste listeVisi = new Liste(new VisibilitePublication(), u,
                    "idvisibilite", "libelle");
            champVisi.setListe(listeVisi);
        }

        // --- Section 2 : mise a jour du PostEmploi ---
        PostEmploi emploiModele = new PostEmploi();
        PageUpdate puEmploi = new PageUpdate(emploiModele, request, u);

        c = puEmploi.getChampByName("post_id");      if (c != null) c.setVisible(false);

        puEmploi.getChampByName("entreprise").setLibelle("Entreprise");
        puEmploi.getChampByName("entreprise").setObligatoire(true);
        puEmploi.getChampByName("poste").setLibelle("Poste");
        puEmploi.getChampByName("poste").setObligatoire(true);
        puEmploi.getChampByName("localisation").setLibelle("Localisation");
        puEmploi.getChampByName("salaire_min").setLibelle("Salaire minimum");
        puEmploi.getChampByName("salaire_max").setLibelle("Salaire maximum");
        puEmploi.getChampByName("devise").setLibelle("Devise");
        puEmploi.getChampByName("experience_requise").setLibelle("Experience requise");
        puEmploi.getChampByName("niveau_etude_requis").setLibelle("Niveau d etude requis");
        puEmploi.getChampByName("date_limite").setLibelle("Date limite");
        puEmploi.getChampByName("contact_email").setLibelle("Email de contact");
        puEmploi.getChampByName("contact_tel").setLibelle("Telephone");
        puEmploi.getChampByName("lien_candidature").setLibelle("Lien de candidature");

        Champ champContrat = puEmploi.getChampByName("type_contrat");
        if (champContrat != null) {
            champContrat.setLibelle("Type de contrat");
            Liste listeContrat = new Liste();
            listeContrat.ajouterLigne("CDI", "CDI");
            listeContrat.ajouterLigne("CDD", "CDD");
            listeContrat.ajouterLigne("Freelance", "Freelance");
            listeContrat.ajouterLigne("Alternance", "Alternance");
            listeContrat.ajouterLigne("Autre", "Autre");
            champContrat.setListe(listeContrat);
        }

        Champ champTeletravail = puEmploi.getChampByName("teletravail_possible");
        if (champTeletravail != null) {
            champTeletravail.setLibelle("Teletravail possible");
            Liste listeTT = new Liste();
            listeTT.ajouterLigne("0", "Non");
            listeTT.ajouterLigne("1", "Oui");
            champTeletravail.setListe(listeTT);
        }

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
        <div class="row">
            <div class="col-md-1"></div>
            <div class="col-md-10">
                <form method="post" action="CarriereFormServlet" enctype="multipart/form-data">
                    <input type="hidden" name="acte" value="updateEmploi">
                    <input type="hidden" name="bute" value="carriere/emploi-fiche.jsp">
                    <input type="hidden" name="id" value="<%=postId%>">

                    <!-- Section Post -->
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Publication</h3>
                        </div>
                        <div class="box-body">
                            <%= puPost.getHtml() %>
                        </div>
                    </div>

                    <!-- Section PostEmploi -->
                    <div class="box box-warning">
                        <div class="box-header with-border">
                            <h3 class="box-title">Details de l offre d emploi</h3>
                        </div>
                        <div class="box-body">
                            <%= puEmploi.getHtml() %>
                            
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
                            <p class="text-muted">Vous pouvez ajouter jusqu'&agrave; 3 fichiers suppl&eacute;mentaires (PDF, images, documents...)</p>
                            
                            <!-- Fichier 1 -->
                            <div class="row mb-2" style="margin-bottom: 10px;">
                                <div class="col-md-4">
                                    <select name="typeFichier1" class="form-control input-sm">
                                        <option value="">-- Type de fichier --</option>
                                        <% if (typesFichiers != null) {
                                            for (Object o : typesFichiers) {
                                                TypeFichier tf = (TypeFichier) o;
                                        %>
                                        <option value="<%= tf.getId() %>"><%= tf.getLibelle() %></option>
                                        <% }} %>
                                    </select>
                                </div>
                                <div class="col-md-8">
                                    <input type="file" name="fichier1" class="form-control input-sm">
                                </div>
                            </div>
                            
                            <!-- Fichier 2 -->
                            <div class="row mb-2" style="margin-bottom: 10px;">
                                <div class="col-md-4">
                                    <select name="typeFichier2" class="form-control input-sm">
                                        <option value="">-- Type de fichier --</option>
                                        <% if (typesFichiers != null) {
                                            for (Object o : typesFichiers) {
                                                TypeFichier tf = (TypeFichier) o;
                                        %>
                                        <option value="<%= tf.getId() %>"><%= tf.getLibelle() %></option>
                                        <% }} %>
                                    </select>
                                </div>
                                <div class="col-md-8">
                                    <input type="file" name="fichier2" class="form-control input-sm">
                                </div>
                            </div>
                            
                            <!-- Fichier 3 -->
                            <div class="row mb-2" style="margin-bottom: 10px;">
                                <div class="col-md-4">
                                    <select name="typeFichier3" class="form-control input-sm">
                                        <option value="">-- Type de fichier --</option>
                                        <% if (typesFichiers != null) {
                                            for (Object o : typesFichiers) {
                                                TypeFichier tf = (TypeFichier) o;
                                        %>
                                        <option value="<%= tf.getId() %>"><%= tf.getLibelle() %></option>
                                        <% }} %>
                                    </select>
                                </div>
                                <div class="col-md-8">
                                    <input type="file" name="fichier3" class="form-control input-sm">
                                </div>
                            </div>
                            
                            <p class="text-info">
                                <i class="fa fa-info-circle"></i> 
                                Pour g&eacute;rer les fichiers existants, utilisez le bouton "G&eacute;rer les fichiers" ci-dessous.
                            </p>
                        </div>
                    </div>

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
            </div>
        </div>
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
