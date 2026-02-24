<%@ page import="bean.CompetenceUtilisateur, bean.Competence, bean.CGenUtil" %>
<%@ page import="affichage.PageInsertMultiple" %>
<%@ page import="user.UserEJB" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    String refuser = request.getParameter("refuser");
    if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
    int refuserInt = Integer.parseInt(refuser);

    // --- Charger les competences existantes ---
    CompetenceUtilisateur filtreComp = new CompetenceUtilisateur();
    filtreComp.setIdutilisateur(refuserInt);
    Object[] compExistantes = CGenUtil.rechercher(filtreComp, null, null, " AND idutilisateur = " + refuserInt);

    // --- PageInsertMultiple : mere = fille = CompetenceUtilisateur ---
    CompetenceUtilisateur mere = new CompetenceUtilisateur();
    CompetenceUtilisateur fille = new CompetenceUtilisateur();
    int nombreLigne = 5;

    PageInsertMultiple pi = new PageInsertMultiple(mere, fille, request, nombreLigne, u);
    pi.setLien(lien);
    pi.setTitre("Ajouter des comp&eacute;tences");

    // Cacher TOUS les champs de la mere (on n'affiche pas le formulaire mere)
    pi.getFormu().getChamp("idutilisateur").setVisible(false);

    // Fille : cacher idutilisateur et pre-remplir avec l'ID utilisateur courant
    pi.getFormufle().getChampMulitple("idutilisateur").setVisible(false);
    pi.getFormufle().getChampMulitple("idutilisateur").setValeur(String.valueOf(refuserInt));

    // Fille : autocomplete dynamique sur idcompetence
    affichage.Champ.setPageAppelComplete(
        pi.getFormufle().getChampFille("idcompetence"),
        "bean.Competence", "id", "competence"
    );

    // Label de la premiere ligne (= header du tableau)
    pi.getFormufle().getChamp("idcompetence_0").setLibelle("Comp&eacute;tence");

    // Ordre des colonnes affichees dans le tableau
    String[] orderCol = {"idcompetence"};
    pi.getFormufle().setColOrdre(orderCol);

    // Preparer les donnees (charge les autocomplete depuis la BDD)
    pi.preparerDataFormu();

    // Generer le HTML du tableau fille
    pi.getFormufle().makeHtmlInsertTableauIndex();
%>
<div class="content-wrapper">
    <section class="content-header">
        <div style="margin-bottom: 15px;">
            <a href="<%= lien %>?but=profil/mon-profil.jsp&tab=competence" class="btn btn-default">
                <i class="fa fa-arrow-left"></i> Retour au profil
            </a>
        </div>
        <h1><i class="fa fa-star"></i> G&eacute;rer mes comp&eacute;tences</h1>
    </section>
    <section class="content">

        <%-- Liste des competences existantes --%>
        <div class="row" style="padding: 0 30px;">
            <div class="col-md-12" style="background: white; padding: 15px; border-radius: 4px; margin-bottom: 10px;">
                <h3 class="box-title" style="margin-top:0;"><i class="fa fa-list"></i> Comp&eacute;tences actuelles</h3>
                <% if (compExistantes == null || compExistantes.length == 0) { %>
                    <p class="text-muted">Aucune comp&eacute;tence enregistr&eacute;e.</p>
                <% } else { %>
                    <table class="table table-bordered table-striped">
                        <thead><tr>
                            <th>Comp&eacute;tence</th>
                            <th style="width:80px;text-align:center;">Action</th>
                        </tr></thead>
                        <tbody>
                        <% for (Object o : compExistantes) {
                            CompetenceUtilisateur cu = (CompetenceUtilisateur) o;
                            String libelComp = cu.getIdcompetence();
                            Competence comp = new Competence();
                            comp.setId(cu.getIdcompetence());
                            Object[] res = CGenUtil.rechercher(comp, null, null, "");
                            if (res != null && res.length > 0) libelComp = ((Competence) res[0]).getLibelle();
                        %>
                        <tr>
                            <td><%= libelComp %></td>
                            <td style="text-align:center;">
                                <a href="<%= lien %>?but=profil/save-competences-apj.jsp&acte=delete&idcompetence=<%= cu.getIdcompetence() %>&refuser=<%= refuser %>"
                                   class="btn btn-xs btn-danger" onclick="return confirm('Supprimer cette comp\u00e9tence ?');">
                                    <i class="fa fa-trash"></i>
                                </a>
                            </td>
                        </tr>
                        <% } %>
                        </tbody>
                    </table>
                <% } %>
            </div>
        </div>

        <%-- Formulaire PageInsertMultiple pour ajouter des competences --%>
        <form action="<%= lien %>?but=profil/save-competences-apj.jsp" method="post">
            <%= pi.getFormufle().getHtmlTableauInsert() %>
            <input name="acte" type="hidden" value="insertCompetences">
            <input name="refuser" type="hidden" value="<%= refuser %>">
            <input name="nombreLigne" type="hidden" value="<%= nombreLigne %>">
        </form>

    </section>
</div>
<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'><h4><i class='fa fa-ban'></i> Erreur</h4><p>" + e.getMessage() + "</p></div>");
} %>
