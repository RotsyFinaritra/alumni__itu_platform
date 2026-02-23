<%@ page import="bean.Experience, bean.Domaine, bean.Entreprise, bean.TypeEmploie, bean.CGenUtil" %>
<%@ page import="affichage.PageInsert" %>
<%@ page import="user.UserEJB" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    String refuser = request.getParameter("refuser");
    if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
    String id = request.getParameter("id");

    // Charger l'experience existante
    Experience exp = new Experience();
    if (id != null && !id.isEmpty()) {
        Object[] res = CGenUtil.rechercher(exp, null, null, " AND id = '" + id + "'");
        if (res != null && res.length > 0) exp = (Experience) res[0];
    }

    PageInsert pi = new PageInsert(exp, request, u);
    pi.setLien(lien);

    affichage.Champ c;

    // Autocomplete FK
    pi.getFormu().getChamp("iddomaine").setPageAppelComplete("bean.Domaine", "id", "domaine");
    pi.getFormu().getChamp("identreprise").setPageAppelComplete("bean.Entreprise", "id", "entreprise");
    pi.getFormu().getChamp("idtypeemploie").setPageAppelComplete("bean.TypeEmploie", "id", "type_emploie");

    // Labels
    pi.getFormu().getChamp("poste").setLibelle("Intitul&eacute; du poste");
    pi.getFormu().getChamp("datedebut").setLibelle("Date de d&eacute;but");
    pi.getFormu().getChamp("datefin").setLibelle("Date de fin (vide = en cours)");
    pi.getFormu().getChamp("iddomaine").setLibelle("Domaine d'activit&eacute;");
    pi.getFormu().getChamp("identreprise").setLibelle("Entreprise");
    pi.getFormu().getChamp("idtypeemploie").setLibelle("Type de contrat");

    // Pre-remplir les valeurs
    if (exp.getPoste()         != null) pi.getFormu().getChamp("poste").setValeur(exp.getPoste());
    if (exp.getIddomaine()     != null) pi.getFormu().getChamp("iddomaine").setValeur(exp.getIddomaine());
    if (exp.getIdentreprise()  != null) pi.getFormu().getChamp("identreprise").setValeur(exp.getIdentreprise());
    if (exp.getIdtypeemploie() != null) pi.getFormu().getChamp("idtypeemploie").setValeur(exp.getIdtypeemploie());
    if (exp.getDatedebut()     != null) pi.getFormu().getChamp("datedebut").setValeur(exp.getDatedebut().toString());
    if (exp.getDatefin()       != null) pi.getFormu().getChamp("datefin").setValeur(exp.getDatefin().toString());

    // Masquer id et idutilisateur
    c = pi.getFormu().getChamp("id");
    if (c != null) c.setVisible(false);
    c = pi.getFormu().getChamp("idutilisateur");
    if (c != null) { c.setVisible(false); c.setValeur(refuser); }

    pi.preparerDataFormu();
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-briefcase"></i> Modifier l'exp&eacute;rience</h1>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-8 col-md-offset-2">
                <div class="box box-success">
                    <div class="box-header with-border">
                        <h3 class="box-title">Exp&eacute;rience professionnelle</h3>
                    </div>
                    <form action="<%= lien %>?but=apresTarif.jsp" method="post" name="sortie" id="formExperience">
                        <div class="box-body">
                            <%
                                pi.getFormu().makeHtmlInsertTabIndex();
                                out.println(pi.getFormu().getHtmlInsert());
                            %>
                        </div>
                        <div class="box-footer">
                            <input name="acte"     type="hidden" value="update">
                            <input name="bute"     type="hidden" value="profil/experience-saisie.jsp">
                            <input name="classe"   type="hidden" value="bean.Experience">
                            <input name="nomtable" type="hidden" value="experience">
                            <input name="rajoutLien" type="hidden" value="refuser">
                            <input name="refuser"  type="hidden" value="<%= refuser %>">
                            <input name="id"       type="hidden" value="<%= id %>">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa fa-save"></i> Enregistrer
                            </button>
                            <a href="<%= lien %>?but=profil/experience-saisie.jsp&refuser=<%= refuser %>" class="btn btn-default">
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
