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

        // Charger toutes les comp&eacute;tences disponibles (utile pour le mode saisie)
        Specialite filtreSpec = new Specialite();
        UtilisateurSpecialite filtreSpecUtil = new UtilisateurSpecialite();
        filtreSpecUtil.setIdutilisateur(Integer.parseInt(refuser));
        Object[] specUtilList = CGenUtil.rechercher(filtreSpecUtil, null, null, " AND idutilisateur = " + refuser);
%>
<div class="competence-tab-content" style="padding:15px;">
    <% if (isOwnProfile) { %>
    <div class="clearfix" style="margin-bottom:15px;">
        <a href="<%= lien %>?but=profil/competence-saisie.jsp&refuser=<%= refuser %>"
           class="btn btn-success btn-sm pull-right">
            <i class="fa fa-pencil"></i> G&eacute;rer mes comp&eacute;tences
        </a>
    </div>
    <% } %>

    <!-- Comp&eacute;tences -->
    <div class="row">
        <div class="col-md-6">
            <h4><i class="fa fa-star text-yellow"></i> Comp&eacute;tences</h4>
            <% if (compUtilList == null || compUtilList.length == 0) { %>
            <p class="text-muted">Aucune comp&eacute;tence enregistr&eacute;e.</p>
            <% } else { %>
            <div>
                <% for (Object o : compUtilList) {
                    CompetenceUtilisateur cu = (CompetenceUtilisateur) o;
                    String libelComp = cu.getIdcompetence();
                    Competence comp = new Competence();
                    comp.setId(cu.getIdcompetence());
                    Object[] res = CGenUtil.rechercher(comp, null, null, "");
                    if (res != null && res.length > 0) libelComp = ((Competence) res[0]).getLibelle();
                %>
                <span class="label label-primary" style="font-size:13px; margin:3px; padding:6px 10px; display:inline-block;">
                    <i class="fa fa-check"></i> <%= libelComp %>
                </span>
                <% } %>
            </div>
            <% } %>
        </div>

        <div class="col-md-6">
            <h4><i class="fa fa-tags text-green"></i> Sp&eacute;cialit&eacute;s</h4>
            <% if (specUtilList == null || specUtilList.length == 0) { %>
            <p class="text-muted">Aucune sp&eacute;cialit&eacute; enregistr&eacute;e.</p>
            <% } else { %>
            <div>
                <% for (Object o : specUtilList) {
                    UtilisateurSpecialite us = (UtilisateurSpecialite) o;
                    String libelSpec = us.getIdspecialite();
                    Specialite spec = new Specialite();
                    spec.setId(us.getIdspecialite());
                    Object[] res = CGenUtil.rechercher(spec, null, null, "");
                    if (res != null && res.length > 0) libelSpec = ((Specialite) res[0]).getLibelle();
                %>
                <span class="label label-success" style="font-size:13px; margin:3px; padding:6px 10px; display:inline-block;">
                    <i class="fa fa-tag"></i> <%= libelSpec %>
                </span>
                <% } %>
            </div>
            <% } %>
        </div>
    </div>
</div>
<% } catch (Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'>Erreur : " + e.getMessage() + "</div>");
} %>
