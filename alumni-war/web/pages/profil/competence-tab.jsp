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
<style>
.comp-list { max-width: 100%; margin: 0; padding: 0; list-style: none; }
.comp-item { display: flex; align-items: center; gap: 12px; padding: 12px 0; border-bottom: 1px solid #eee; }
.comp-item:last-child { border-bottom: none; }
.comp-item:hover { background: #fafafa; }
.comp-icon { width: 35px; height: 35px; background: #f39c12; border-radius: 4px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.comp-icon i { font-size: 16px; color: #fff; }
.comp-info { flex: 1; display: flex; align-items: center; gap: 10px; }
.comp-title { font-size: 15px; font-weight: 500; color: #333; margin: 0; }
.spec-icon { background: #00a65a; }
.comp-empty { text-align: center; padding: 40px 20px; color: #999; }
.comp-empty i { font-size: 40px; margin-bottom: 10px; opacity: 0.4; }
.comp-empty p { font-size: 14px; margin: 0; }
.comp-add-btn { background: #f39c12; color: #fff; border: none; padding: 8px 16px; border-radius: 4px; font-size: 13px; }
.comp-add-btn:hover { background: #e08e0b; color: #fff; }
.comp-add-btn i { margin-right: 6px; }
.comp-tab-content { padding: 20px; }
.comp-section { margin-bottom: 30px; }
.comp-section h4 { font-size: 16px; font-weight: 600; color: #555; margin: 0 0 15px 0; padding-bottom: 8px; border-bottom: 2px solid #eee; }
@media (max-width: 576px) { 
  .comp-item { flex-direction: column; align-items: flex-start; }
  .comp-info { width: 100%; flex-direction: column; align-items: flex-start; gap: 5px; }
}
</style>

<div class="comp-tab-content">
    <% if (isOwnProfile) { %>
    <div class="clearfix" style="margin-bottom:25px;">
        <a href="<%= lien %>?but=profil/competence-saisie.jsp&refuser=<%= refuser %>"
           class="btn comp-add-btn pull-right">
            <i class="fa fa-pencil"></i> G&eacute;rer mes comp&eacute;tences
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
