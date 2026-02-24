<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
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
        <div class="container-fluid">
            <h1><i class="fas fa-graduation-cap"></i> Publier une offre de stage</h1>
        </div>
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="card card-success">
                <div class="card-header">
                    <h3 class="card-title">Informations du stage</h3>
                </div>
                <form action="CarriereFormServlet" method="post" name="<%=nomTable%>" id="<%=nomTable%>" 
                      enctype="multipart/form-data" data-parsley-validate>
                    <div class="card-body">
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
                                <p class="text-muted">Vous pouvez joindre jusqu'&agrave; 3 fichiers (PDF, images, documents...)</p>
                                
                                <!-- Fichier 1 -->
                                <div class="row mb-2">
                                    <div class="col-md-4">
                                        <select name="typeFichier1" class="form-control form-control-sm">
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
                                        <input type="file" name="fichier1" class="form-control form-control-sm">
                                    </div>
                                </div>
                                
                                <!-- Fichier 2 -->
                                <div class="row mb-2">
                                    <div class="col-md-4">
                                        <select name="typeFichier2" class="form-control form-control-sm">
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
                                        <input type="file" name="fichier2" class="form-control form-control-sm">
                                    </div>
                                </div>
                                
                                <!-- Fichier 3 -->
                                <div class="row mb-2">
                                    <div class="col-md-4">
                                        <select name="typeFichier3" class="form-control form-control-sm">
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
                                        <input type="file" name="fichier3" class="form-control form-control-sm">
                                    </div>
                                </div>
                            </div>
                        </div>
                        
                        <input name="acte" type="hidden" value="insertStage">
                        <input name="bute" type="hidden" value="<%= butApresPost %>">
                        <input name="classe" type="hidden" value="<%= classe %>">
                        <input name="nomtable" type="hidden" value="<%= nomTable %>">
                    </div>
                    <div class="card-footer">
                        <button type="submit" class="btn btn-success">
                            <i class="fas fa-save"></i> Enregistrer
                        </button>
                        <a href="<%=lien%>?but=carriere/stage-liste.jsp" class="btn btn-secondary">
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
