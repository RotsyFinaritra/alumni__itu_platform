<%@ page pageEncoding="UTF-8" %>
<%@ page import="bean.CalendrierScolaire" %>
<%@ page import="bean.Promotion" %>
<%@ page import="affichage.PageInsert" %>
<%@ page import="affichage.Champ" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String idrole = u.getUser().getIdrole() != null ? u.getUser().getIdrole() : "";
        if (!"admin".equalsIgnoreCase(idrole)) {
%>
<script>document.location.replace('<%= lien %>?but=calendrier/calendrier-scolaire.jsp');</script>
<%
            return;
        }

        // Formulaire APJ
        CalendrierScolaire cs = new CalendrierScolaire();
        PageInsert pi = new PageInsert(cs, request, u);
        pi.setLien(lien);

        // Masquer les champs auto-gérés (avec null check)
        Champ c;
        c = pi.getFormu().getChamp("id");
        if (c != null) c.setVisible(false);
        c = pi.getFormu().getChamp("created_by");
        if (c != null) c.setVisible(false);
        c = pi.getFormu().getChamp("created_at");
        if (c != null) c.setVisible(false);

        // Configuration des champs visibles (avec null check)
        c = pi.getFormu().getChamp("titre");
        if (c != null) {
            c.setLibelle("Titre");
            c.setAutre("required");
        }
        
        c = pi.getFormu().getChamp("description");
        if (c != null) {
            c.setLibelle("Description");
            c.setType("editor");
        }
        
        c = pi.getFormu().getChamp("date_debut");
        if (c != null) {
            c.setLibelle("Date de d&eacute;but");
            c.setAutre("required");
        }
        
        c = pi.getFormu().getChamp("date_fin");
        if (c != null) c.setLibelle("Date de fin");
        
        c = pi.getFormu().getChamp("heure_debut");
        if (c != null) {
            c.setLibelle("Heure de d&eacute;but");
            c.setType("time");
        }
        
        c = pi.getFormu().getChamp("heure_fin");
        if (c != null) {
            c.setLibelle("Heure de fin");
            c.setType("time");
        }
        
        c = pi.getFormu().getChamp("couleur");
        if (c != null) {
            c.setLibelle("Couleur");
            c.setDefaut("#0095DA");
        }
        
        c = pi.getFormu().getChamp("idpromotion");
        if (c != null) {
            c.setLibelle("Promotion (optionnel)");
            c.setPageAppelComplete("bean.Promotion", "libelle", "PROMOTION", "id;libelle;annee", "id;libelle");
        }

        // Ordre des champs
        pi.getFormu().setOrdre(new String[]{"titre", "description", "date_debut", "date_fin", "heure_debut", "heure_fin", "couleur", "idpromotion"});

        // IMPORTANT: Appeler preparerDataFormu() APRÈS toute configuration
        pi.preparerDataFormu();
        pi.getFormu().makeHtmlInsertTabIndex();
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-calendar-plus-o"></i> Nouvel &eacute;v&eacute;nement</h1>
        <ol class="breadcrumb">
            <li><a href="<%= lien %>?but=calendrier/calendrier-scolaire.jsp"><i class="fa fa-calendar"></i> Calendrier</a></li>
            <li class="active">Nouvel &eacute;v&eacute;nement</li>
        </ol>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-8 col-md-offset-2">
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title">Informations de l'&eacute;v&eacute;nement</h3>
                    </div>
                    <div class="box-body">
                        <form action="<%= pi.getLien() %>?but=calendrier/apresCalendrier.jsp" method="post" name="calendrier_scolaire" id="calendrier_scolaire" data-parsley-validate>
                            <%= pi.getFormu().getHtmlInsert() %>
                            
                            <input name="acte" type="hidden" value="insert">
                            <input name="bute" type="hidden" value="calendrier/calendrier-scolaire.jsp">
                            <input name="classe" type="hidden" value="bean.CalendrierScolaire">
                            <input name="nomtable" type="hidden" value="calendrier_scolaire">

                            <div class="form-group" style="margin-top: 15px;">
                                <button type="submit" class="btn btn-primary">
                                    <i class="fa fa-save"></i> Enregistrer
                                </button>
                                <a href="<%= lien %>?but=calendrier/calendrier-scolaire.jsp" class="btn btn-default">
                                    <i class="fa fa-times"></i> Annuler
                                </a>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>

<script>
// Améliorer le champ couleur en input color HTML5
document.addEventListener('DOMContentLoaded', function() {
    var couleurInput = document.getElementById('couleur');
    if (couleurInput) {
        couleurInput.type = 'color';
        couleurInput.style.height = '40px';
        couleurInput.style.padding = '2px';
    }
});
</script>

<% } catch (Exception e) {
    e.printStackTrace();
    String errorMsg = e.getMessage() != null ? e.getMessage().replace("'", "\\'") : "Une erreur est survenue";
%>
<script language="JavaScript">
    alert('<%= errorMsg %>');
    history.back();
</script>
<% } %>
