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

        // Charger les comp&eacute;tences de cet utilisateur via competence_utilisateur
        CompetenceUtilisateur filtreComp = new CompetenceUtilisateur();
        filtreComp.setIdutilisateur(Integer.parseInt(refuser));
        Object[] compUtilList = CGenUtil.rechercher(filtreComp, null, null, " AND idutilisateur = " + refuser);

        // Charger les sp&eacute;cialit&eacute;s
        UtilisateurSpecialite filtreSpecUtil = new UtilisateurSpecialite();
        filtreSpecUtil.setIdutilisateur(Integer.parseInt(refuser));
        Object[] specUtilList = CGenUtil.rechercher(filtreSpecUtil, null, null, " AND idutilisateur = " + refuser);
%>
<link href="${pageContext.request.contextPath}/assets/css/profil-tabs.css" rel="stylesheet" type="text/css" />

<div class="comp-tab-content">
    <% if (isOwnProfile) { %>
    <div class="clearfix" style="margin-bottom:25px;">
        <a href="<%= lien %>?but=profil/specialite-saisie.jsp&refuser=<%= refuser %>"
           class="btn comp-add-btn pull-right" style="margin-left:10px; background:#00a65a;">
            <i class="fa fa-tags"></i> G&eacute;rer mes sp&eacute;cialit&eacute;s
        </a>
        <a href="<%= lien %>?but=profil/competence-saisie.jsp&refuser=<%= refuser %>"
           class="btn comp-add-btn pull-right">
            <i class="fa fa-star"></i> G&eacute;rer mes comp&eacute;tences
        </a>
    </div>
    <% } %>

    <!-- Comp&eacute;tences -->
    <div class="comp-section">
        <h4><i class="fa fa-star" style="color:#f39c12;"></i> Comp&eacute;tences</h4>
        <% if (compUtilList == null || compUtilList.length == 0) { %>
        <div class="comp-empty">
            <i class="fa fa-star"></i>
            <p>Aucune comp&eacute;tence enregistr&eacute;e</p>
        </div>
        <% } else { %>
        <div class="comp-list">
            <% for (Object o : compUtilList) {
                CompetenceUtilisateur cu = (CompetenceUtilisateur) o;
                String libelComp = cu.getIdcompetence();
                Competence comp = new Competence();
                comp.setId(cu.getIdcompetence());
                Object[] res = CGenUtil.rechercher(comp, null, null, "");
                if (res != null && res.length > 0) libelComp = ((Competence) res[0]).getLibelle();
            %>
            <div class="comp-item">
                <div class="comp-icon">
                    <i class="fa fa-check"></i>
                </div>
                <div class="comp-info">
                    <div class="comp-title"><%= libelComp %></div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>

    <!-- Sp&eacute;cialit&eacute;s -->
    <div class="comp-section">
        <h4><i class="fa fa-tags" style="color:#00a65a;"></i> Sp&eacute;cialit&eacute;s</h4>
        <% if (specUtilList == null || specUtilList.length == 0) { %>
        <div class="comp-empty">
            <i class="fa fa-tags"></i>
            <p>Aucune sp&eacute;cialit&eacute; enregistr&eacute;e</p>
        </div>
        <% } else { %>
        <div class="comp-list">
            <% for (Object o : specUtilList) {
                UtilisateurSpecialite us = (UtilisateurSpecialite) o;
                String libelSpec = us.getIdspecialite();
                Specialite spec = new Specialite();
                spec.setId(us.getIdspecialite());
                Object[] res = CGenUtil.rechercher(spec, null, null, "");
                if (res != null && res.length > 0) libelSpec = ((Specialite) res[0]).getLibelle();
            %>
            <div class="comp-item">
                <div class="comp-icon spec-icon">
                    <i class="fa fa-tag"></i>
                </div>
                <div class="comp-info">
                    <div class="comp-title"><%= libelSpec %></div>
                </div>
            </div>
            <% } %>
        </div>
        <% } %>
    </div>
</div>
<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'>Erreur : " + e.getMessage() + "</div>");
} %>
