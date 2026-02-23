<%@ page import="bean.Experience, bean.Domaine, bean.Entreprise, bean.TypeEmploie" %>
<%@ page import="affichage.PageInsert, affichage.Liste" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String refuser = request.getParameter("refuser");
        if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
        String acte = request.getParameter("acte") != null ? request.getParameter("acte") : "insert";

        // Créer l'objet Experience et définir idutilisateur AVANT PageInsert
        Experience exp = new Experience();
        exp.setIdutilisateur(Integer.parseInt(refuser));
        
        PageInsert pi = new PageInsert(exp, request, u);
        pi.setLien(lien);

        // Libell&eacute;s (null-safe)
        affichage.Champ c;
        String[][] labels = {
            {"poste","Intitul&eacute; du poste"}, {"datedebut","Date de d&eacute;but"},
            {"datefin","Date de fin (laisser vide si en cours)"},
            {"iddomaine","Domaine d'activit&eacute;"}, {"identreprise","Entreprise"},
            {"idtypeemploie","Type de contrat"}
        };
        for (String[] lb : labels) {
            c = pi.getFormu().getChamp(lb[0]);
            if (c != null) c.setLibelle(lb[1]);
        }

        // Listes d&eacute;roulantes pour les FK (APJ : changerEnChamp remplace les Champ par des Liste)
        Liste[] listes = new Liste[3];
        listes[0] = new Liste("iddomaine", new Domaine(), "libelle", "id");
        listes[1] = new Liste("identreprise", new Entreprise(), "libelle", "id");
        listes[2] = new Liste("idtypeemploie", new TypeEmploie(), "libelle", "id");
        pi.getFormu().changerEnChamp(listes);

        // Masquer idutilisateur et définir sa valeur (null-safe)
        c = pi.getFormu().getChamp("idutilisateur");
        if (c != null) {
            c.setValeur(refuser);
            c.setVisible(false);
        }

        pi.preparerDataFormu();
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><%= "update".equals(acte) ? "Modifier une exp&eacute;rience" : "Ajouter une exp&eacute;rience professionnelle" %></h1>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-8 col-md-offset-2">
                <div class="box box-success">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa fa-briefcase"></i> Exp&eacute;rience professionnelle</h3>
                    </div>
                    <form action="<%= lien %>?but=apresTarif.jsp" method="post" name="sortie" id="formExperience">
                        <div class="box-body">
                            <%
                                pi.getFormu().makeHtmlInsertTabIndex();
                                out.println(pi.getFormu().getHtmlInsert());
                            %>
                        </div>
                        <div class="box-footer">
                            <input name="acte" type="hidden" value="<%= acte %>">
                            <input name="bute" type="hidden" value="profil/mon-profil.jsp">
                            <input name="classe" type="hidden" value="bean.Experience">
                            <input name="nomtable" type="hidden" value="experience">
                            <input name="rajoutLien" type="hidden" value="refuser">
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
<script>
// Supprimer les champs FK vides avant soumission pour éviter les erreurs de contraintes
document.getElementById('formExperience').addEventListener('submit', function(e) {
    var selects = this.querySelectorAll('select[name="iddomaine"], select[name="identreprise"], select[name="idtypeemploie"]');
    selects.forEach(function(select) {
        if (select.value === '' || select.value === null) {
            select.removeAttribute('name');
        }
    });
});
</script>
<%  } catch (Exception e) {
        e.printStackTrace();
    }
%>
