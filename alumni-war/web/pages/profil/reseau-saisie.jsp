<%@ page import="bean.ReseauUtilisateur, bean.ReseauxSociaux" %>
<%@ page import="affichage.PageInsert, affichage.Liste" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String refuser = request.getParameter("refuser");
        if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
        String id = request.getParameter("id");
        String acte = (id != null && !id.isEmpty()) ? "update" : "insert";

        // Créer l'objet ReseauUtilisateur et définir idutilisateur AVANT PageInsert
        ReseauUtilisateur reseau = new ReseauUtilisateur();
        reseau.setIdutilisateur(Integer.parseInt(refuser));
        if ("update".equals(acte) && id != null) {
            Object[] res = bean.CGenUtil.rechercher(reseau, null, null, " AND id = '" + id + "'");
            if (res != null && res.length > 0) reseau = (ReseauUtilisateur) res[0];
        }

        PageInsert pi = new PageInsert(reseau, request, u);
        pi.setLien(lien);

        // Libell&eacute;s
        // Listes d&eacute;roulantes pour les FK (APJ : changerEnChamp remplace les Champ par des Liste)
        Liste[] listes = new Liste[1];
        listes[0] = new Liste("idreseauxsociaux", new ReseauxSociaux(), "libelle", "id");
        pi.getFormu().changerEnChamp(listes);
        affichage.Champ c;
        c = pi.getFormu().getChamp("idreseauxsociaux");
        pi.getFormu().getChamp("lien").setLibelle("Lien vers le profil du reseau social");
        if (c != null) c.setLibelle("R&eacute;seau social");

        // Masquer idutilisateur et id (auto-g&eacute;n&eacute;r&eacute;s) — null-safe
        c = pi.getFormu().getChamp("idutilisateur");
        if (c != null) {
            c.setValeur(refuser);
            c.setVisible(false);
        }
        c = pi.getFormu().getChamp("id");
        if (c != null) { c.setVisible(false); if (id != null) c.setValeur(id); }

        if ("update".equals(acte)) {
            if (reseau.getIdreseauxsociaux() != null) pi.getFormu().getChamp("idreseauxsociaux").setValeur(reseau.getIdreseauxsociaux());
            if (reseau.getLien() != null) pi.getFormu().getChamp("lien").setValeur(reseau.getLien());
        }

        pi.preparerDataFormu();
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><%= "update".equals(acte) ? "Modifier le r&eacute;seau social" : "Ajouter un r&eacute;seau social" %></h1>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-6 col-md-offset-3">
                <div class="box box-info">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa fa-share-alt"></i> R&eacute;seau social</h3>
                    </div>
                    <form action="<%= lien %>?but=apresTarif.jsp" method="post" name="sortie" id="formReseau">
                        <div class="box-body">
                            <%
                                pi.getFormu().makeHtmlInsertTabIndex();
                                out.println(pi.getFormu().getHtmlInsert());
                            %>
                        </div>
                        <div class="box-footer">
                            <input name="acte"     type="hidden" value="<%= acte %>">
                            <input name="bute"     type="hidden" value="profil/mon-profil.jsp">
                            <input name="classe"   type="hidden" value="bean.ReseauUtilisateur">
                            <input name="nomtable" type="hidden" value="reseau_utilisateur">
                            <input name="rajoutLien" type="hidden" value="refuser">
                            <input name="refuser"  type="hidden" value="<%= refuser %>">
                            <% if ("update".equals(acte)) { %>
                            <input name="id" type="hidden" value="<%= id %>">
                            <% } %>
                            <button type="submit" class="btn btn-primary">
                                <i class="fa fa-save"></i> Enregistrer
                            </button>
                            <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= refuser %>" class="btn btn-default">
                                <i class="fa fa-times"></i> Annuler
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </section>
</div>
<script>
// Supprimer les champs FK vides avant soumission pour éviter les erreurs de contraintes
document.getElementById('formReseau').addEventListener('submit', function(e) {
    var select = this.querySelector('select[name="idreseauxsociaux"]');
    if (select && (select.value === '' || select.value === null)) {
        select.removeAttribute('name');
    }
});
</script>
<%  } catch (Exception e) {
        e.printStackTrace();
    }
%>
