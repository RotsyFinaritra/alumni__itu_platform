<%@ page pageEncoding="UTF-8" %>
<%@ page import="bean.CalendrierScolaire" %>
<%@ page import="bean.Promotion" %>
<%@ page import="affichage.PageUpdate" %>
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

        String id = request.getParameter("id");

        CalendrierScolaire critere = new CalendrierScolaire();
        critere.setId(id);
        PageUpdate pu = new PageUpdate(critere, request, u);
        pu.setLien(lien);

        // Masquer les champs auto-gérés (avec null check)
        Champ c;
        c = pu.getFormu().getChamp("id");
        if (c != null) {
            c.setAutre("readonly");
            c.setVisible(false);
        }
        c = pu.getFormu().getChamp("created_by");
        if (c != null) c.setVisible(false);
        c = pu.getFormu().getChamp("created_at");
        if (c != null) c.setVisible(false);

        // Configuration des champs visibles (avec null check)
        c = pu.getFormu().getChamp("titre");
        if (c != null) {
            c.setLibelle("Titre");
            c.setAutre("required");
        }
        
        c = pu.getFormu().getChamp("description");
        if (c != null) {
            c.setLibelle("Description");
            c.setType("editor");
        }
        
        c = pu.getFormu().getChamp("date_debut");
        if (c != null) {
            c.setLibelle("Date de d&eacute;but");
            c.setAutre("required");
        }
        
        c = pu.getFormu().getChamp("date_fin");
        if (c != null) c.setLibelle("Date de fin");
        
        c = pu.getFormu().getChamp("heure_debut");
        if (c != null) {
            c.setLibelle("Heure de d&eacute;but");
            c.setType("time");
        }
        
        c = pu.getFormu().getChamp("heure_fin");
        if (c != null) {
            c.setLibelle("Heure de fin");
            c.setType("time");
        }
        
        c = pu.getFormu().getChamp("couleur");
        if (c != null) c.setLibelle("Couleur");
        
        c = pu.getFormu().getChamp("idpromotion");
        if (c != null) {
            c.setLibelle("Promotion (optionnel)");
            c.setPageAppelComplete("bean.Promotion", "libelle", "PROMOTION", "id;libelle;annee", "id;libelle");
        }

        // Ordre des champs
        pu.getFormu().setOrdre(new String[]{"titre", "description", "date_debut", "date_fin", "heure_debut", "heure_fin", "couleur", "idpromotion"});

        // IMPORTANT: Appeler preparerDataFormu() APRÈS toute configuration
        pu.preparerDataFormu();
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-edit"></i> Modifier l'&eacute;v&eacute;nement</h1>
        <ol class="breadcrumb">
            <li><a href="<%= lien %>?but=calendrier/calendrier-scolaire.jsp"><i class="fa fa-calendar"></i> Calendrier</a></li>
            <li class="active">Modifier</li>
        </ol>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-8 col-md-offset-2">
                <div class="box box-warning">
                    <div class="box-header with-border">
                        <h3 class="box-title">Modifier l'&eacute;v&eacute;nement</h3>
                    </div>
                    <div class="box-body">
                        <form action="<%= lien %>?but=calendrier/apresCalendrier.jsp&id=<%= id %>" method="post" data-parsley-validate>
                            <input type="hidden" name="acte" value="update" />
                            <input type="hidden" name="classe" value="bean.CalendrierScolaire" />
                            <input type="hidden" name="nomtable" value="calendrier_scolaire" />
                            <input type="hidden" name="bute" value="calendrier/calendrier-scolaire.jsp" />

                            <%= pu.getFormu().getHtmlInsert() %>

                            <div class="form-group" style="margin-top: 15px;">
                                <button type="submit" class="btn btn-warning">
                                    <i class="fa fa-save"></i> Modifier
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
document.addEventListener('DOMContentLoaded', function() {
    var couleurInput = document.getElementById('couleur');
    if (couleurInput) {
        couleurInput.type = 'color';
        couleurInput.style.height = '40px';
        couleurInput.style.padding = '2px';
    }
});
</script>

<% 
    } catch (Exception e) { 
        e.printStackTrace(); 
%>
<script language="JavaScript">
    alert('<%=e.getMessage()%>');
    history.back();
</script>
<% } %>
