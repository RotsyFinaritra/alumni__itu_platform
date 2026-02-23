<%@ page import="bean.Parcours, bean.Diplome, bean.Ecole, bean.Domaine" %>
<%@ page import="affichage.PageInsert, affichage.Liste" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String refuser = request.getParameter("refuser");
        if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
        String acte = request.getParameter("acte") != null ? request.getParameter("acte") : "insert";

        PageInsert pi = new PageInsert(new Parcours(), request, u);
        pi.setLien(lien);

        // Libell&eacute;s (null-safe)
        affichage.Champ c;
        String[][] labels = {
            {"datedebut","Date de d&eacute;but"},
            {"datefin","Date de fin (laisser vide si en cours)"},
            {"iddiplome","Dipl&ocirc;me obtenu"},
            {"idecole","&Eacute;tablissement"},
            {"iddomaine","Domaine d'&eacute;tude"}
        };
        for (String[] lb : labels) {
            c = pi.getFormu().getChamp(lb[0]);
            if (c != null) c.setLibelle(lb[1]);
        }

        // Autocomplete dynamique pour les FK
        pi.getFormu().getChamp("iddiplome").setPageAppelComplete("bean.Diplome", "id", "diplome");
        pi.getFormu().getChamp("idecole").setPageAppelComplete("bean.Ecole", "id", "ecole");
        pi.getFormu().getChamp("iddomaine").setPageAppelComplete("bean.Domaine", "id", "domaine");

        pi.getFormu().getChamp("iddiplome").setLibelle("Dipl&ocirc;me");
        pi.getFormu().getChamp("idecole").setLibelle("Etablissement");
        pi.getFormu().getChamp("iddomaine").setLibelle("Domaine d'&eacute;tude");

        // Masquer idutilisateur (null-safe)
        c = pi.getFormu().getChamp("idutilisateur");
        if (c != null) c.setVisible(false);

        pi.preparerDataFormu();
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><%= "update".equals(acte) ? "Modifier un parcours" : "Ajouter un parcours acad&eacute;mique" %></h1>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-8 col-md-offset-2">
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa fa-graduation-cap"></i> Parcours acad&eacute;mique</h3>
                    </div>
                    <form action="<%= lien %>?but=apresTarif.jsp" method="post" name="sortie" id="formParcours">
                        <div class="box-body">
                            <%
                                pi.getFormu().makeHtmlInsertTabIndex();
                                out.println(pi.getFormu().getHtmlInsert());
                            %>
                        </div>
                        <div class="box-footer">
                            <input name="acte" type="hidden" value="<%= acte %>">
                            <input name="bute" type="hidden" value="profil/mon-profil.jsp">
                            <input name="classe" type="hidden" value="bean.Parcours">
                            <input name="nomtable" type="hidden" value="parcours">
                            <input name="idutilisateur" type="hidden" value="<%= refuser %>">
                            <input name="refuser" type="hidden" value="<%= refuser %>">
                            <% if ("update".equals(acte) && request.getParameter("id") != null) { %>
                            <input name="id" type="hidden" value="<%= request.getParameter("id") %>">
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
<%  } catch (Exception e) {
        e.printStackTrace();
    }
%>
