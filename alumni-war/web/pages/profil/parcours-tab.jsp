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

        // Charger les parcours de cet utilisateur
        Parcours filtre = new Parcours();
        filtre.setIdutilisateur(Integer.parseInt(refuser));
        Object[] parcoursList = CGenUtil.rechercher(filtre, null, null, " AND idutilisateur = " + refuser + " ORDER BY datedebut DESC");

%>
<link href="${pageContext.request.contextPath}/assets/css/profil-tabs.css" rel="stylesheet" type="text/css" />

<div class="parcours-tab-content">
    <% if (isOwnProfile) { %>
    <div class="clearfix" style="margin-bottom:25px;">
        <a href="<%= lien %>?but=profil/parcours-saisie.jsp&refuser=<%= refuser %>"
           class="btn parcours-add-btn pull-right">
            <i class="fa fa-pencil"></i> G&eacute;rer mes parcours
        </a>
    </div>
    <% } %>

    <% if (parcoursList == null || parcoursList.length == 0) { %>
    <div class="parcours-empty">
        <i class="fa fa-graduation-cap"></i>
        <p>Aucun parcours acad&eacute;mique enregistr&eacute;</p>
    </div>
    <% } else { %>
    <div class="parcours-list">
        <% for (Object o : parcoursList) {
            Parcours p = (Parcours) o;

            // R&eacute;soudre les FK — libell&eacute;s
            String libelDiplome = "";
            if (p.getIddiplome() != null && !p.getIddiplome().isEmpty()) {
                Diplome d = new Diplome();
                d.setId(p.getIddiplome());
                Object[] res = CGenUtil.rechercher(d, null, null, "");
                if (res != null && res.length > 0) libelDiplome = ((Diplome) res[0]).getLibelle();
            }
            String libelEcole = "";
            if (p.getIdecole() != null && !p.getIdecole().isEmpty()) {
                Ecole e = new Ecole();
                e.setId(p.getIdecole());
                Object[] res = CGenUtil.rechercher(e, null, null, "");
                if (res != null && res.length > 0) libelEcole = ((Ecole) res[0]).getLibelle();
            }
            String libelDomaine = "";
            if (p.getIddomaine() != null && !p.getIddomaine().isEmpty()) {
                Domaine dom = new Domaine();
                dom.setId(p.getIddomaine());
                Object[] res = CGenUtil.rechercher(dom, null, null, "");
                if (res != null && res.length > 0) libelDomaine = ((Domaine) res[0]).getLibelle();
            }
        %>
        <div class="parcours-item">
            <div class="parcours-icon">
                <i class="fa fa-graduation-cap"></i>
            </div>
            <div class="parcours-info">
                <div class="parcours-title">
                    <%= libelDiplome.isEmpty() ? "Dipl&ocirc;me non pr&eacute;cis&eacute;" : libelDiplome %>
                </div>
                <% if (!libelEcole.isEmpty()) { %>
                <div class="parcours-subtitle"><%= libelEcole %></div>
                <% } %>
                <div class="parcours-date">
                    <%= p.getDatedebut() != null ? p.getDatedebut().toString() : "?" %> — <%= p.getDatefin() != null ? p.getDatefin().toString() : "en cours" %>
                </div>
                <% if (!libelDomaine.isEmpty()) { %>
                <span class="parcours-badge"><%= libelDomaine %></span>
                <% } %>
            </div>
            <% if (isOwnProfile) { %>
            <div class="parcours-actions">
                <a class="btn btn-parcours btn-parcours-edit"
                   href="<%= lien %>?but=profil/parcours-edit.jsp&id=<%= p.getId() %>&refuser=<%= refuser %>">
                    <i class="fa fa-pencil"></i> Modifier
                </a>
                <a class="btn btn-parcours btn-parcours-delete"
                   href="<%= lien %>?but=profil/save-parcours-apj.jsp&acte=delete&id=<%= p.getId() %>&refuser=<%= refuser %>"
                   onclick="return confirm('Supprimer ce parcours ?')">
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
