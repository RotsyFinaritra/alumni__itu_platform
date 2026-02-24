<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        PostEmploi a = new PostEmploi();
        PageInsert pi = new PageInsert(a, request, u);
        pi.setLien(lien);

        // Configuration des libellés
        pi.getFormu().getChamp("poste").setLibelle("Intitul&eacute; du poste *");
        pi.getFormu().getChamp("type_contrat").setLibelle("Type de contrat");
        pi.getFormu().getChamp("salaire_min").setLibelle("Salaire minimum");
        pi.getFormu().getChamp("salaire_max").setLibelle("Salaire maximum");
        pi.getFormu().getChamp("devise").setLibelle("Devise");
        pi.getFormu().getChamp("experience_requise").setLibelle("Exp&eacute;rience requise");
        pi.getFormu().getChamp("niveau_etude_requis").setLibelle("Niveau d'&eacute;tude requis");
        pi.getFormu().getChamp("teletravail_possible").setLibelle("T&eacute;l&eacute;travail possible");
        pi.getFormu().getChamp("date_limite").setLibelle("Date limite de candidature");
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
        pi.getFormu().getChamp("devise").setDefaut("MGA");
        pi.getFormu().getChamp("teletravail_possible").setDefaut("0");

        // Ordre des champs (sans competences_requises)
        String[] ordre = {
            "identreprise",
            "poste",
            "type_contrat",
            "salaire_min",
            "salaire_max",
            "devise",
            "experience_requise",
            "niveau_etude_requis",
            "teletravail_possible",
            "date_limite",
            "contact_email",
            "contact_tel",
            "lien_candidature"
        };
        pi.getFormu().setOrdre(ordre);

        // Variables de navigation
        String classe = "bean.PostEmploi";
        String butApresPost = "carriere/emploi-liste.jsp";
        String nomTable = "POST_EMPLOI";

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
            <h1><i class="fas fa-briefcase"></i> Publier une offre d'emploi</h1>
        </div>
    </section>
    <section class="content">
        <div class="container-fluid">
            <div class="card card-primary">
                <div class="card-header">
                    <h3 class="card-title">Informations de l'offre</h3>
                </div>
                <form action="<%=pi.getLien()%>?but=carriere/apresCarriere.jsp" method="post" name="<%=nomTable%>" id="<%=nomTable%>" 
                      data-parsley-validate>
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
                                <p class="text-muted">Ajoutez des fichiers en cliquant sur le bouton +</p>
                                
                                <div id="fichiers-container">
                                    <!-- Les lignes de fichiers seront ajoutées ici dynamiquement -->
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
                            div.className = 'row mb-2 fichier-ligne';
                            div.id = 'fichier-ligne-' + compteurFichier;
                            div.innerHTML = 
                                '<div class="col-md-4">' +
                                    '<select name="typeFichier[]" class="form-control form-control-sm">' +
                                        typesFichiersOptions +
                                    '</select>' +
                                '</div>' +
                                '<div class="col-md-6">' +
                                    '<input type="text" name="fichierNom[]" class="form-control form-control-sm" placeholder="Nom ou URL du fichier">' +
                                '</div>' +
                                '<div class="col-md-2">' +
                                    '<button type="button" class="btn btn-sm btn-danger" onclick="supprimerLigneFichier(' + compteurFichier + ')">' +
                                        '<i class="fas fa-trash"></i>' +
                                    '</button>' +
                                '</div>';
                            container.appendChild(div);
                        }
                        
                        function supprimerLigneFichier(id) {
                            var ligne = document.getElementById('fichier-ligne-' + id);
                            if (ligne) {
                                ligne.remove();
                            }
                        }
                        </script>
                        
                        <input name="acte" type="hidden" value="insertEmploi">
                        <input name="bute" type="hidden" value="<%= butApresPost %>">
                        <input name="classe" type="hidden" value="<%= classe %>">
                        <input name="nomtable" type="hidden" value="<%= nomTable %>">
                    </div>
                    <div class="card-footer">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Enregistrer
                        </button>
                        <a href="<%=lien%>?but=carriere/emploi-liste.jsp" class="btn btn-secondary">
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
