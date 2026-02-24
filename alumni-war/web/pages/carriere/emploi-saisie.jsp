<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        PostEmploi a = new PostEmploi();
        PageInsert pi = new PageInsert(a, request, u);
        pi.setLien((String) session.getValue("lien"));

        // Configuration des libellés
        pi.getFormu().getChamp("poste").setLibelle("Intitul&eacute; du poste *");
        pi.getFormu().getChamp("type_contrat").setLibelle("Type de contrat");
        pi.getFormu().getChamp("localisation").setLibelle("Localisation");
        pi.getFormu().getChamp("salaire_min").setLibelle("Salaire minimum");
        pi.getFormu().getChamp("salaire_max").setLibelle("Salaire maximum");
        pi.getFormu().getChamp("devise").setLibelle("Devise");
        pi.getFormu().getChamp("experience_requise").setLibelle("Exp&eacute;rience requise");
        pi.getFormu().getChamp("competences_requises").setLibelle("Comp&eacute;tences requises");
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
        pi.getFormu().getChamp("localisation").setPageAppelComplete("bean.Ville", "id", "ville");
        pi.getFormu().getChamp("niveau_etude_requis").setPageAppelComplete("bean.Diplome", "id", "diplome");
        pi.getFormu().getChamp("competences_requises").setPageAppelComplete("bean.Competence", "id", "competence");

        // Valeurs par défaut
        pi.getFormu().getChamp("devise").setDefaut("MGA");
        pi.getFormu().getChamp("teletravail_possible").setDefaut("0");

        // Ordre des champs
        String[] ordre = {
            "identreprise",
            "poste",
            "type_contrat",
            "localisation",
            "salaire_min",
            "salaire_max",
            "devise",
            "experience_requise",
            "competences_requises",
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
                <form action="<%=pi.getLien()%>?but=apresCarriere.jsp" method="post" name="<%=nomTable%>" id="<%=nomTable%>" data-parsley-validate>
                    <div class="card-body">
                        <%
                            out.println(pi.getFormu().getHtmlInsert());
                            out.println(pi.getHtmlAddOnPopup());
                        %>
                        <input name="acte" type="hidden" value="insertEmploi">
                        <input name="bute" type="hidden" value="<%= butApresPost %>">
                        <input name="classe" type="hidden" value="<%= classe %>">
                        <input name="nomtable" type="hidden" value="<%= nomTable %>">
                    </div>
                    <div class="card-footer">
                        <button type="submit" class="btn btn-primary">
                            <i class="fas fa-save"></i> Enregistrer
                        </button>
                        <a href="<%=pi.getLien()%>?but=carriere/emploi-liste.jsp" class="btn btn-secondary">
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
