<%@ page import="bean.UtilisateurSpecialite, bean.Specialite, bean.CGenUtil" %>
<%@ page import="affichage.PageInsertMultiple" %>
<%@ page import="user.UserEJB" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    String refuser = request.getParameter("refuser");
    if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
    int refuserInt = Integer.parseInt(refuser);

    // --- Charger les specialites existantes ---
    UtilisateurSpecialite filtreSpec = new UtilisateurSpecialite();
    filtreSpec.setIdutilisateur(refuserInt);
    Object[] specExistantes = CGenUtil.rechercher(filtreSpec, null, null, " AND idutilisateur = " + refuserInt);

    // --- PageInsertMultiple : mere = fille = UtilisateurSpecialite ---
    UtilisateurSpecialite mere = new UtilisateurSpecialite();
    UtilisateurSpecialite fille = new UtilisateurSpecialite();
    int nombreLigne = 5;

    PageInsertMultiple pi = new PageInsertMultiple(mere, fille, request, nombreLigne, u);
    pi.setLien(lien);
    pi.setTitre("Ajouter des sp&eacute;cialit&eacute;s");

    // Cacher TOUS les champs de la mere (on n'affiche pas le formulaire mere)
    pi.getFormu().getChamp("idspecialite").setVisible(false);

    // Fille : cacher idutilisateur et pre-remplir avec l'ID utilisateur courant
    pi.getFormufle().getChampMulitple("idutilisateur").setVisible(false);
    pi.getFormufle().getChampMulitple("idutilisateur").setValeur(String.valueOf(refuserInt));

    // Fille : autocomplete dynamique sur idspecialite
    affichage.Champ.setPageAppelComplete(
        pi.getFormufle().getChampFille("idspecialite"),
        "bean.Specialite", "id", "specialite"
    );

    // Label de la premiere ligne (= header du tableau)
    pi.getFormufle().getChamp("idspecialite_0").setLibelle("Sp&eacute;cialit&eacute;");

    // Ordre des colonnes affichees dans le tableau
    String[] orderCol = {"idspecialite"};
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
        <h1><i class="fa fa-tags"></i> G&eacute;rer mes sp&eacute;cialit&eacute;s</h1>
    </section>
    <section class="content">

        <%-- Liste des specialites existantes --%>
        <div class="row" style="padding: 0 30px;">
            <div class="col-md-12" style="background: white; padding: 15px; border-radius: 4px; margin-bottom: 10px;">
                <h3 class="box-title" style="margin-top:0;"><i class="fa fa-list"></i> Sp&eacute;cialit&eacute;s actuelles</h3>
                <% if (specExistantes == null || specExistantes.length == 0) { %>
                    <p class="text-muted">Aucune sp&eacute;cialit&eacute; enregistr&eacute;e.</p>
                <% } else { %>
                    <table class="table table-bordered table-striped">
                        <thead><tr>
                            <th>Sp&eacute;cialit&eacute;</th>
                            <th style="width:80px;text-align:center;">Action</th>
                        </tr></thead>
                        <tbody>
                        <% for (Object o : specExistantes) {
                            UtilisateurSpecialite us = (UtilisateurSpecialite) o;
                            String libelSpec = us.getIdspecialite();
                            Specialite spec = new Specialite();
                            spec.setId(us.getIdspecialite());
                            Object[] res = CGenUtil.rechercher(spec, null, null, "");
                            if (res != null && res.length > 0) libelSpec = ((Specialite) res[0]).getLibelle();
                        %>
                        <tr>
                            <td><%= libelSpec %></td>
                            <td style="text-align:center;">
                                <a href="<%= lien %>?but=profil/save-specialites-apj.jsp&acte=delete&idspecialite=<%= us.getIdspecialite() %>&refuser=<%= refuser %>"
                                   class="btn btn-xs btn-danger" onclick="return confirm('Supprimer cette sp\u00e9cialit\u00e9 ?');">
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

        <%-- Formulaire PageInsertMultiple pour ajouter des specialites --%>
        <form action="<%= lien %>?but=profil/save-specialites-apj.jsp" method="post">
            <%= pi.getFormufle().getHtmlTableauInsert() %>
            <input name="acte" type="hidden" value="insertSpecialites">
            <input name="refuser" type="hidden" value="<%= refuser %>">
            <input name="nombreLigne" type="hidden" value="<%= nombreLigne %>">
        </form>

        <%-- Bouton retour --%>
        <div class="row" style="padding: 0 30px; margin-top: 10px;">
            <div class="col-md-12 text-right">
                <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= refuser %>" class="btn btn-default">
                    <i class="fa fa-arrow-left"></i> Retour au profil
                </a>
            </div>
        </div>

    </section>
</div>
<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'><h4><i class='fa fa-ban'></i> Erreur</h4><p>" + e.getMessage() + "</p></div>");
} %>
