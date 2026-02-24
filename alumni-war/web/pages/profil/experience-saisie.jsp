<%@ page import="bean.Experience, bean.Domaine, bean.Entreprise, bean.TypeEmploie, bean.CGenUtil" %>
<%@ page import="affichage.PageInsertMultiple" %>
<%@ page import="user.UserEJB" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    String refuser = request.getParameter("refuser");
    if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
    int refuserInt = Integer.parseInt(refuser);

    // --- Charger les experiences existantes ---
    Experience filtre = new Experience();
    filtre.setIdutilisateur(refuserInt);
    Object[] listExistants = CGenUtil.rechercher(filtre, null, null, " AND idutilisateur = " + refuserInt + " ORDER BY datedebut DESC");

    // --- PageInsertMultiple : mere = fille = Experience ---
    Experience mere = new Experience();
    Experience fille = new Experience();
    int nombreLigne = 3;

    PageInsertMultiple pi = new PageInsertMultiple(mere, fille, request, nombreLigne, u);
    pi.setLien(lien);
    pi.setTitre("Ajouter des exp&eacute;riences professionnelles");

    // Masquer tous les champs de la mere
    pi.getFormu().getChamp("idutilisateur").setVisible(false);
    pi.getFormu().getChamp("poste").setVisible(false);
    pi.getFormu().getChamp("datedebut").setVisible(false);
    pi.getFormu().getChamp("datefin").setVisible(false);
    pi.getFormu().getChamp("iddomaine").setVisible(false);
    pi.getFormu().getChamp("identreprise").setVisible(false);
    pi.getFormu().getChamp("idtypeemploie").setVisible(false);

    // Fille : masquer id (auto-genere) et idutilisateur (pre-rempli)
    pi.getFormufle().getChampMulitple("id").setVisible(false);
    pi.getFormufle().getChampMulitple("idutilisateur").setVisible(false);
    pi.getFormufle().getChampMulitple("idutilisateur").setValeur(String.valueOf(refuserInt));

    // Fille : autocomplete sur les FK
    affichage.Champ.setPageAppelComplete(pi.getFormufle().getChampFille("iddomaine"),    "bean.Domaine",    "id", "domaine");
    affichage.Champ.setPageAppelComplete(pi.getFormufle().getChampFille("identreprise"), "bean.Entreprise", "id", "entreprise");
    affichage.Champ.setPageAppelComplete(pi.getFormufle().getChampFille("idtypeemploie"),"bean.TypeEmploie","id", "type_emploie");

    // Labels de l'en-tete
    pi.getFormufle().getChamp("poste_0").setLibelle("Intitul&eacute; du poste");
    pi.getFormufle().getChamp("datedebut_0").setLibelle("Date d&eacute;but");
    pi.getFormufle().getChamp("datefin_0").setLibelle("Date fin (vide = en cours)");
    pi.getFormufle().getChamp("identreprise_0").setLibelle("Entreprise");
    pi.getFormufle().getChamp("iddomaine_0").setLibelle("Domaine");
    pi.getFormufle().getChamp("idtypeemploie_0").setLibelle("Type de contrat");

    // Colonnes visibles dans le tableau
    pi.getFormufle().setColOrdre(new String[]{"poste", "datedebut", "datefin", "identreprise", "iddomaine", "idtypeemploie"});

    pi.preparerDataFormu();
    pi.getFormufle().makeHtmlInsertTableauIndex();
%>
<div class="content-wrapper">
    <section class="content-header">
        <div style="margin-bottom: 15px;">
            <a href="<%= lien %>?but=profil/mon-profil.jsp&tab=experience" class="btn btn-default">
                <i class="fa fa-arrow-left"></i> Retour au profil
            </a>
        </div>
        <h1><i class="fa fa-briefcase"></i> G&eacute;rer mes exp&eacute;riences professionnelles</h1>
    </section>
    <section class="content">

        <%-- Liste des experiences existantes --%>
        <div class="row" style="padding: 0 30px;">
            <div class="col-md-12" style="background: white; padding: 15px; border-radius: 4px; margin-bottom: 10px;">
                <h3 class="box-title" style="margin-top:0;"><i class="fa fa-list"></i> Exp&eacute;riences actuelles</h3>
                <% if (listExistants == null || listExistants.length == 0) { %>
                    <p class="text-muted">Aucune exp&eacute;rience enregistr&eacute;e.</p>
                <% } else { %>
                    <table class="table table-bordered table-striped">
                        <thead><tr>
                            <th>Poste</th>
                            <th>Entreprise</th>
                            <th>Domaine</th>
                            <th>Type</th>
                            <th>D&eacute;but</th>
                            <th>Fin</th>
                            <th style="width:80px;text-align:center;">Action</th>
                        </tr></thead>
                        <tbody>
                        <% for (Object o : listExistants) {
                            Experience exp = (Experience) o;
                            String libelEntreprise = exp.getIdentreprise() != null ? exp.getIdentreprise() : "";
                            String libelDomaine    = exp.getIddomaine()    != null ? exp.getIddomaine()    : "";
                            String libelType       = exp.getIdtypeemploie() != null ? exp.getIdtypeemploie() : "";
                            if (exp.getIdentreprise() != null && !exp.getIdentreprise().isEmpty()) {
                                Entreprise en = new Entreprise(); en.setId(exp.getIdentreprise());
                                Object[] res = CGenUtil.rechercher(en, null, null, "");
                                if (res != null && res.length > 0) libelEntreprise = ((Entreprise) res[0]).getLibelle();
                            }
                            if (exp.getIddomaine() != null && !exp.getIddomaine().isEmpty()) {
                                Domaine dom = new Domaine(); dom.setId(exp.getIddomaine());
                                Object[] res = CGenUtil.rechercher(dom, null, null, "");
                                if (res != null && res.length > 0) libelDomaine = ((Domaine) res[0]).getLibelle();
                            }
                            if (exp.getIdtypeemploie() != null && !exp.getIdtypeemploie().isEmpty()) {
                                TypeEmploie te = new TypeEmploie(); te.setId(exp.getIdtypeemploie());
                                Object[] res = CGenUtil.rechercher(te, null, null, "");
                                if (res != null && res.length > 0) libelType = ((TypeEmploie) res[0]).getLibelle();
                            }
                        %>
                        <tr>
                            <td><%= exp.getPoste() != null ? exp.getPoste() : "<em>-</em>" %></td>
                            <td><%= libelEntreprise.isEmpty() ? "<em>-</em>" : libelEntreprise %></td>
                            <td><%= libelDomaine.isEmpty()    ? "<em>-</em>" : libelDomaine %></td>
                            <td><%= libelType.isEmpty()       ? "<em>-</em>" : libelType %></td>
                            <td><%= exp.getDatedebut() != null ? exp.getDatedebut().toString() : "-" %></td>
                            <td><%= exp.getDatefin()   != null ? exp.getDatefin().toString()   : "<em>en cours</em>" %></td>
                            <td style="text-align:center;">
                                <a href="<%= lien %>?but=profil/save-experience-apj.jsp&acte=delete&id=<%= exp.getId() %>&refuser=<%= refuser %>"
                                   class="btn btn-xs btn-danger" onclick="return confirm('Supprimer cette exp\u00e9rience ?');">
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

        <%-- Formulaire PageInsertMultiple pour ajouter des experiences --%>
        <form action="<%= lien %>?but=profil/save-experience-apj.jsp" method="post">
            <%= pi.getFormufle().getHtmlTableauInsert() %>
            <input name="acte" type="hidden" value="insertExperiences">
            <input name="refuser" type="hidden" value="<%= refuser %>">
            <input name="nombreLigne" type="hidden" value="<%= nombreLigne %>">
        </form>

    </section>
</div>
<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'><h4><i class='fa fa-ban'></i> Erreur</h4><p>" + e.getMessage() + "</p></div>");
} %>
