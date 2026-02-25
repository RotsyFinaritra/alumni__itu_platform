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
<link href="${pageContext.request.contextPath}/assets/css/profil-tabs.css" rel="stylesheet" type="text/css" />

<div class="experience-tab-content">
    <% if (isOwnProfile) { %>
    <div class="clearfix" style="margin-bottom:25px;">
        <a href="<%= lien %>?but=profil/experience-saisie.jsp&refuser=<%= refuser %>"
           class="btn exp-add-btn pull-right">
            <i class="fa fa-pencil"></i> G&eacute;rer mes exp&eacute;riences
        </a>
    </div>
    <% } %>

    <% if (expList == null || expList.length == 0) { %>
    <div class="exp-empty">
        <i class="fa fa-briefcase"></i>
        <p>Aucune exp&eacute;rience professionnelle enregistr&eacute;e</p>
    </div>
    <% } else { %>
    <div class="exp-list">
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
        <div class="exp-item">
            <div class="exp-icon">
                <i class="fa fa-briefcase"></i>
            </div>
            <div class="exp-info">
                <div class="exp-title">
                    <%= exp.getPoste() != null ? exp.getPoste() : "Poste non pr&eacute;cis&eacute;" %>
                </div>
                <% if (!libelEntreprise.isEmpty()) { %>
                <div class="exp-subtitle"><%= libelEntreprise %></div>
                <% } %>
                <div class="exp-date">
                    <%= exp.getDatedebut() != null ? exp.getDatedebut().toString() : "?" %> — <%= exp.getDatefin() != null ? exp.getDatefin().toString() : "en cours" %>
                </div>
                <% if (!libelDomaine.isEmpty()) { %>
                <span class="exp-badge"><%= libelDomaine %></span>
                <% } %>
                <% if (!libelTypeEmploi.isEmpty()) { %>
                <span class="exp-badge exp-badge-type"><%= libelTypeEmploi %></span>
                <% } %>
            </div>
            <% if (isOwnProfile) { %>
            <div class="exp-actions">
                <a class="btn btn-exp btn-exp-edit"
                   href="<%= lien %>?but=profil/experience-edit.jsp&id=<%= exp.getId() %>&refuser=<%= refuser %>">
                    <i class="fa fa-pencil"></i> Modifier
                </a>
                <a class="btn btn-exp btn-exp-delete"
                   href="<%= lien %>?but=profil/save-experience-apj.jsp&acte=delete&id=<%= exp.getId() %>&refuser=<%= refuser %>"
                   onclick="return confirm('Supprimer cette exp&eacute;rience ?')">
                    <i class="fa fa-trash"></i> Supprimer
                </a>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>
    <% } %>
</div>
<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'>Erreur : " + e.getMessage() + "</div>");
} %>
