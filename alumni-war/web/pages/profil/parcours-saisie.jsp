<%@ page import="bean.Parcours, bean.Diplome, bean.Ecole, bean.Domaine, bean.CGenUtil" %>
<%@ page import="affichage.PageInsertMultiple" %>
<%@ page import="user.UserEJB" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    String refuser = request.getParameter("refuser");
    if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
    int refuserInt = Integer.parseInt(refuser);

    // --- Charger les parcours existants ---
    Parcours filtre = new Parcours();
    filtre.setIdutilisateur(refuserInt);
    Object[] listExistants = CGenUtil.rechercher(filtre, null, null, " AND idutilisateur = " + refuserInt + " ORDER BY datedebut DESC");

    // --- PageInsertMultiple : mere = fille = Parcours ---
    Parcours mere = new Parcours();
    Parcours fille = new Parcours();
    int nombreLigne = 3;

    PageInsertMultiple pi = new PageInsertMultiple(mere, fille, request, nombreLigne, u);
    pi.setLien(lien);
    pi.setTitre("Ajouter des parcours acad&eacute;miques");

    // Masquer tous les champs de la mere
    pi.getFormu().getChamp("idutilisateur").setVisible(false);
    pi.getFormu().getChamp("datedebut").setVisible(false);
    pi.getFormu().getChamp("datefin").setVisible(false);
    pi.getFormu().getChamp("iddiplome").setVisible(false);
    pi.getFormu().getChamp("idecole").setVisible(false);
    pi.getFormu().getChamp("iddomaine").setVisible(false);

    // Fille : masquer id (auto-genere) et idutilisateur (pre-rempli)
    pi.getFormufle().getChampMulitple("id").setVisible(false);
    pi.getFormufle().getChampMulitple("idutilisateur").setVisible(false);
    pi.getFormufle().getChampMulitple("idutilisateur").setValeur(String.valueOf(refuserInt));

    // Fille : autocomplete sur les FK
    affichage.Champ.setPageAppelComplete(pi.getFormufle().getChampFille("iddiplome"), "bean.Diplome", "id", "diplome");
    affichage.Champ.setPageAppelComplete(pi.getFormufle().getChampFille("idecole"), "bean.Ecole", "id", "ecole");
    affichage.Champ.setPageAppelComplete(pi.getFormufle().getChampFille("iddomaine"), "bean.Domaine", "id", "domaine");

    // Labels de l'en-tete
    pi.getFormufle().getChamp("datedebut_0").setLibelle("Date d&eacute;but");
    pi.getFormufle().getChamp("datefin_0").setLibelle("Date fin (vide = en cours)");
    pi.getFormufle().getChamp("iddiplome_0").setLibelle("Dipl&ocirc;me");
    pi.getFormufle().getChamp("idecole_0").setLibelle("Etablissement");
    pi.getFormufle().getChamp("iddomaine_0").setLibelle("Domaine");

    // Colonnes visibles dans le tableau
    pi.getFormufle().setColOrdre(new String[]{"datedebut", "datefin", "iddiplome", "idecole", "iddomaine"});

    pi.preparerDataFormu();
    pi.getFormufle().makeHtmlInsertTableauIndex();
%>
<div class="content-wrapper">
    <section class="content-header">
        <div style="margin-bottom: 15px;">
            <a href="<%= lien %>?but=profil/mon-profil.jsp&tab=parcours" class="btn btn-default">
                <i class="fa fa-arrow-left"></i> Retour au profil
            </a>
        </div>
        <h1><i class="fa fa-graduation-cap"></i> G&eacute;rer mes parcours acad&eacute;miques</h1>
    </section>
    <section class="content">

        <%-- Liste des parcours existants --%>
        <div class="row" style="padding: 0 30px;">
            <div class="col-md-12" style="background: white; padding: 15px; border-radius: 4px; margin-bottom: 10px;">
                <h3 class="box-title" style="margin-top:0;"><i class="fa fa-list"></i> Parcours actuels</h3>
                <% if (listExistants == null || listExistants.length == 0) { %>
                    <p class="text-muted">Aucun parcours enregistr&eacute;.</p>
                <% } else { %>
                    <table class="table table-bordered table-striped">
                        <thead><tr>
                            <th>Dipl&ocirc;me</th>
                            <th>Etablissement</th>
                            <th>Domaine</th>
                            <th>D&eacute;but</th>
                            <th>Fin</th>
                            <th style="width:80px;text-align:center;">Action</th>
                        </tr></thead>
                        <tbody>
                        <% for (Object o : listExistants) {
                            Parcours p = (Parcours) o;
                            String libelDiplome = p.getIddiplome() != null ? p.getIddiplome() : "";
                            String libelEcole    = p.getIdecole()  != null ? p.getIdecole()  : "";
                            String libelDomaine  = p.getIddomaine() != null ? p.getIddomaine() : "";
                            if (p.getIddiplome() != null && !p.getIddiplome().isEmpty()) {
                                Diplome d = new Diplome(); d.setId(p.getIddiplome());
                                Object[] res = CGenUtil.rechercher(d, null, null, "");
                                if (res != null && res.length > 0) libelDiplome = ((Diplome) res[0]).getLibelle();
                            }
                            if (p.getIdecole() != null && !p.getIdecole().isEmpty()) {
                                Ecole e = new Ecole(); e.setId(p.getIdecole());
                                Object[] res = CGenUtil.rechercher(e, null, null, "");
                                if (res != null && res.length > 0) libelEcole = ((Ecole) res[0]).getLibelle();
                            }
                            if (p.getIddomaine() != null && !p.getIddomaine().isEmpty()) {
                                Domaine dom = new Domaine(); dom.setId(p.getIddomaine());
                                Object[] res = CGenUtil.rechercher(dom, null, null, "");
                                if (res != null && res.length > 0) libelDomaine = ((Domaine) res[0]).getLibelle();
                            }
                        %>
                        <tr>
                            <td><%= libelDiplome.isEmpty() ? "<em>-</em>" : libelDiplome %></td>
                            <td><%= libelEcole.isEmpty()   ? "<em>-</em>" : libelEcole %></td>
                            <td><%= libelDomaine.isEmpty() ? "<em>-</em>" : libelDomaine %></td>
                            <td><%= p.getDatedebut() != null ? p.getDatedebut().toString() : "-" %></td>
                            <td><%= p.getDatefin()   != null ? p.getDatefin().toString()   : "<em>en cours</em>" %></td>
                            <td style="text-align:center;">
                                <a href="<%= lien %>?but=profil/save-parcours-apj.jsp&acte=delete&id=<%= p.getId() %>&refuser=<%= refuser %>"
                                   class="btn btn-xs btn-danger" onclick="return confirm('Supprimer ce parcours ?');">
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

        <%-- Formulaire PageInsertMultiple pour ajouter des parcours --%>
        <form action="<%= lien %>?but=profil/save-parcours-apj.jsp" method="post">
            <%= pi.getFormufle().getHtmlTableauInsert() %>
            <input name="acte" type="hidden" value="insertParcours">
            <input name="refuser" type="hidden" value="<%= refuser %>">
            <input name="nombreLigne" type="hidden" value="<%= nombreLigne %>">
        </form>

    </section>
</div>
<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'><h4><i class='fa fa-ban'></i> Erreur</h4><p>" + e.getMessage() + "</p></div>");
} %>
