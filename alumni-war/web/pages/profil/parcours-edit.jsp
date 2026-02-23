<%@ page import="bean.Parcours, bean.Diplome, bean.Ecole, bean.Domaine, bean.CGenUtil" %>
<%@ page import="affichage.PageInsert" %>
<%@ page import="user.UserEJB" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    String refuser = request.getParameter("refuser");
    if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
    String id = request.getParameter("id");

    // Charger le parcours existant
    Parcours parc = new Parcours();
    if (id != null && !id.isEmpty()) {
        Object[] res = CGenUtil.rechercher(parc, null, null, " AND id = '" + id + "'");
        if (res != null && res.length > 0) parc = (Parcours) res[0];
    }

    PageInsert pi = new PageInsert(parc, request, u);
    pi.setLien(lien);

    affichage.Champ c;

    // Autocomplete FK
    pi.getFormu().getChamp("iddiplome").setPageAppelComplete("bean.Diplome", "id", "diplome");
    pi.getFormu().getChamp("idecole").setPageAppelComplete("bean.Ecole", "id", "ecole");
    pi.getFormu().getChamp("iddomaine").setPageAppelComplete("bean.Domaine", "id", "domaine");

    // Labels
    pi.getFormu().getChamp("datedebut").setLibelle("Date de d&eacute;but");
    pi.getFormu().getChamp("datefin").setLibelle("Date de fin (vide = en cours)");
    pi.getFormu().getChamp("iddiplome").setLibelle("Dipl&ocirc;me");
    pi.getFormu().getChamp("idecole").setLibelle("Etablissement");
    pi.getFormu().getChamp("iddomaine").setLibelle("Domaine d'&eacute;tude");

    // Pre-remplir les valeurs autocomplete
    if (parc.getIddiplome()  != null) pi.getFormu().getChamp("iddiplome").setValeur(parc.getIddiplome());
    if (parc.getIdecole()    != null) pi.getFormu().getChamp("idecole").setValeur(parc.getIdecole());
    if (parc.getIddomaine()  != null) pi.getFormu().getChamp("iddomaine").setValeur(parc.getIddomaine());
    if (parc.getDatedebut()  != null) pi.getFormu().getChamp("datedebut").setValeur(parc.getDatedebut().toString());
    if (parc.getDatefin()    != null) pi.getFormu().getChamp("datefin").setValeur(parc.getDatefin().toString());

    // Masquer id et idutilisateur
    c = pi.getFormu().getChamp("id");
    if (c != null) c.setVisible(false);
    c = pi.getFormu().getChamp("idutilisateur");
    if (c != null) { c.setVisible(false); c.setValeur(refuser); }

    pi.preparerDataFormu();
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-graduation-cap"></i> Modifier le parcours</h1>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-8 col-md-offset-2">
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title">Parcours acad&eacute;mique</h3>
                    </div>
                    <form action="<%= lien %>?but=apresTarif.jsp" method="post" name="sortie" id="formParcours">
                        <div class="box-body">
                            <%
                                pi.getFormu().makeHtmlInsertTabIndex();
                                out.println(pi.getFormu().getHtmlInsert());
                            %>
                        </div>
                        <div class="box-footer">
                            <input name="acte"     type="hidden" value="update">
                            <input name="bute"     type="hidden" value="profil/parcours-saisie.jsp">
                            <input name="classe"   type="hidden" value="bean.Parcours">
                            <input name="nomtable" type="hidden" value="parcours">
                            <input name="rajoutLien" type="hidden" value="refuser">
                            <input name="refuser"  type="hidden" value="<%= refuser %>">
                            <input name="id"       type="hidden" value="<%= id %>">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa fa-save"></i> Enregistrer
                            </button>
                            <a href="<%= lien %>?but=profil/parcours-saisie.jsp&refuser=<%= refuser %>" class="btn btn-default">
                                <i class="fa fa-times"></i> Annuler
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </section>
</div>
<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'><h4>Erreur</h4><p>" + e.getMessage() + "</p></div>");
} %>
