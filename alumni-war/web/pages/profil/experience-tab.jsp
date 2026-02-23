<%@ page import="bean.*" %>
<%@ page import="user.UserEJB" %>
<%@ page import="bean.CGenUtil" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String refuser = request.getParameter("refuser");
        if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
        boolean isOwnProfile = refuser.equals(u.getUser().getTuppleID());

        // Charger les exp&eacute;riences de cet utilisateur
        Experience filtre = new Experience();
        filtre.setIdutilisateur(Integer.parseInt(refuser));
        Object[] expList = CGenUtil.rechercher(filtre, null, null, " AND idutilisateur = " + refuser + " ORDER BY datedebut DESC");

%>
<div class="experience-tab-content" style="padding:15px;">
    <% if (isOwnProfile) { %>
    <div class="clearfix" style="margin-bottom:15px;">
        <a href="<%= lien %>?but=profil/experience-saisie.jsp&acte=insert&refuser=<%= refuser %>"
           class="btn btn-success btn-sm pull-right">
            <i class="fa fa-plus"></i> Ajouter une exp&eacute;rience
        </a>
    </div>
    <% } %>

    <% if (expList == null || expList.length == 0) { %>
    <div class="alert alert-info">
        <i class="fa fa-info-circle"></i> Aucune exp&eacute;rience professionnelle enregistr&eacute;e.
    </div>
    <% } else { %>
    <div class="timeline">
        <% for (Object o : expList) {
            Experience exp = (Experience) o;

            // R&eacute;soudre les FK
            String libelEntreprise = "";
            if (exp.getIdentreprise() != null && !exp.getIdentreprise().isEmpty()) {
                Entreprise ent = new Entreprise();
                ent.setId(exp.getIdentreprise());
                Object[] res = CGenUtil.rechercher(ent, null, null, "");
                if (res != null && res.length > 0) libelEntreprise = ((Entreprise) res[0]).getLibelle();
            }
            String libelDomaine = "";
            if (exp.getIddomaine() != null && !exp.getIddomaine().isEmpty()) {
                Domaine dom = new Domaine();
                dom.setId(exp.getIddomaine());
                Object[] res = CGenUtil.rechercher(dom, null, null, "");
                if (res != null && res.length > 0) libelDomaine = ((Domaine) res[0]).getLibelle();
            }
            String libelTypeEmploi = "";
            if (exp.getIdtypeemploie() != null && !exp.getIdtypeemploie().isEmpty()) {
                TypeEmploie te = new TypeEmploie();
                te.setId(exp.getIdtypeemploie());
                Object[] res = CGenUtil.rechercher(te, null, null, "");
                if (res != null && res.length > 0) libelTypeEmploi = ((TypeEmploie) res[0]).getLibelle();
            }
        %>
        <div>
            <i class="fa fa-briefcase bg-green"></i>
            <div class="timeline-item">
                <span class="time text-muted">
                    <i class="fa fa-calendar"></i>
                    <%= exp.getDatedebut() != null ? exp.getDatedebut().toString() : "?" %>
                    — <%= exp.getDatefin() != null ? exp.getDatefin().toString() : "en cours" %>
                </span>
                <h3 class="timeline-header">
                    <strong><%= exp.getPoste() != null ? exp.getPoste() : "Poste non pr&eacute;cis&eacute;" %></strong>
                    <% if (!libelEntreprise.isEmpty()) { %> — <%= libelEntreprise %><% } %>
                </h3>
                <div class="timeline-body">
                    <% if (!libelDomaine.isEmpty()) { %>
                    <span class="label label-primary"><i class="fa fa-book"></i> <%= libelDomaine %></span>
                    <% } %>
                    <% if (!libelTypeEmploi.isEmpty()) { %>
                    <span class="label label-default"><%= libelTypeEmploi %></span>
                    <% } %>
                </div>
                <% if (isOwnProfile) { %>
                <div class="timeline-footer">
                    <a class="btn btn-xs btn-primary"
                       href="<%= lien %>?but=profil/experience-saisie.jsp&acte=update&classe=bean.Experience&nomtable=experience&id=<%= exp.getId() %>">
                        <i class="fa fa-pencil"></i> Modifier
                    </a>
                    <a class="btn btn-xs btn-danger"
                       href="<%= lien %>?but=apresTarif.jsp&acte=delete&classe=bean.Experience&nomtable=experience&bute=profil/mon-profil.jsp&id=<%= exp.getId() %>&refuser=<%= refuser %>"
                       onclick="return confirm('Supprimer cette exp&eacute;rience ?')">
                        <i class="fa fa-trash"></i> Supprimer
                    </a>
                </div>
                <% } %>
            </div>
        </div>
        <% } %>
    </div>
    <% } %>
</div>
<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'>Erreur : " + e.getMessage() + "</div>");
} %>
