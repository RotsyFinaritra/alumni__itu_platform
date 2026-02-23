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
<div class="parcours-tab-content" style="padding:15px;">
    <% if (isOwnProfile) { %>
    <div class="clearfix" style="margin-bottom:15px;">
        <a href="<%= lien %>?but=profil/parcours-saisie.jsp&acte=insert&refuser=<%= refuser %>"
           class="btn btn-success btn-sm pull-right">
            <i class="fa fa-plus"></i> Ajouter un parcours
        </a>
    </div>
    <% } %>

    <% if (parcoursList == null || parcoursList.length == 0) { %>
    <div class="alert alert-info">
        <i class="fa fa-info-circle"></i> Aucun parcours acad&eacute;mique enregistr&eacute;.
    </div>
    <% } else { %>
    <div class="timeline">
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
        <div>
            <i class="fa fa-graduation-cap bg-blue"></i>
            <div class="timeline-item">
                <span class="time text-muted">
                    <i class="fa fa-calendar"></i>
                    <%= p.getDatedebut() != null ? p.getDatedebut().toString() : "?" %>
                    — <%= p.getDatefin() != null ? p.getDatefin().toString() : "en cours" %>
                </span>
                <h3 class="timeline-header">
                    <strong><%= libelDiplome.isEmpty() ? "Dipl&ocirc;me non pr&eacute;cis&eacute;" : libelDiplome %></strong>
                    <% if (!libelEcole.isEmpty()) { %> — <%= libelEcole %><% } %>
                </h3>
                <div class="timeline-body">
                    <% if (!libelDomaine.isEmpty()) { %>
                    <span class="label label-primary"><i class="fa fa-book"></i> <%= libelDomaine %></span>
                    <% } %>
                </div>
                <% if (isOwnProfile) { %>
                <div class="timeline-footer">
                    <a class="btn btn-xs btn-primary"
                       href="<%= lien %>?but=profil/parcours-saisie.jsp&acte=update&classe=bean.Parcours&nomtable=parcours&id=<%= p.getId() %>">
                        <i class="fa fa-pencil"></i> Modifier
                    </a>
                    <a class="btn btn-xs btn-danger"
                       href="<%= lien %>?but=apresTarif.jsp&acte=delete&classe=bean.Parcours&nomtable=parcours&bute=profil/mon-profil.jsp&id=<%= p.getId() %>&refuser=<%= refuser %>"
                       onclick="return confirm('Supprimer ce parcours ?')">
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
