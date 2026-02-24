<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        PostStage a = new PostStage();
        PageInsert pi = new PageInsert(a, request, u);
        pi.setLien((String) session.getValue("lien"));

        // Pas de listes déroulantes spécifiques pour PostStage

        // Configuration des libellés
        pi.getFormu().getChamp("duree").setLibelle("Dur&eacute;e du stage *");
        pi.getFormu().getChamp("localisation").setLibelle("Localisation");
        pi.getFormu().getChamp("date_debut").setLibelle("Date de d&eacute;but");
        pi.getFormu().getChamp("date_fin").setLibelle("Date de fin");
        pi.getFormu().getChamp("indemnite").setLibelle("Indemnit&eacute; (MGA)");
        pi.getFormu().getChamp("niveau_etude_requis").setLibelle("Niveau d'&eacute;tude requis");
        pi.getFormu().getChamp("competences_requises").setLibelle("Comp&eacute;tences requises");
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
        pi.getFormu().getChamp("localisation").setPageAppelComplete("bean.Ville", "id", "ville");
        pi.getFormu().getChamp("niveau_etude_requis").setPageAppelComplete("bean.Diplome", "id", "diplome");
        pi.getFormu().getChamp("competences_requises").setPageAppelComplete("bean.Competence", "id", "competence");

        // Valeurs par défaut
        pi.getFormu().getChamp("convention_requise").setDefaut("0");
        pi.getFormu().getChamp("places_disponibles").setDefaut("1");

        // Ordre des champs
        String[] ordre = {
            "identreprise",
            "duree",
            "localisation",
            "date_debut",
            "date_fin",
            "indemnite",
            "niveau_etude_requis",
            "competences_requises",
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
                <form action="<%=pi.getLien()%>?but=apresCarriere.jsp" method="post" name="<%=nomTable%>" id="<%=nomTable%>" data-parsley-validate>
                    <div class="card-body">
                        <%
                            out.println(pi.getFormu().getHtmlInsert());
                            out.println(pi.getHtmlAddOnPopup());
                        %>
                        <input name="acte" type="hidden" value="insertStage">
                        <input name="bute" type="hidden" value="<%= butApresPost %>">
                        <input name="classe" type="hidden" value="<%= classe %>">
                        <input name="nomtable" type="hidden" value="<%= nomTable %>">
                    </div>
                    <div class="card-footer">
                        <button type="submit" class="btn btn-success">
                            <i class="fas fa-save"></i> Enregistrer
                        </button>
                        <a href="<%=pi.getLien()%>?but=carriere/stage-liste.jsp" class="btn btn-secondary">
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
