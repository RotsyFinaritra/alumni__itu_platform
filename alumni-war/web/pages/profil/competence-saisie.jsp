<%@ page import="bean.Competence, bean.Specialite" %>
<%@ page import="profil.CompetenceProfilService" %>
<%@ page import="user.UserEJB" %>
<%@ page import="java.util.Set" %>
<%
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    String refuser = request.getParameter("refuser");
    if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
    int refuserInt = Integer.parseInt(refuser);

    // Récupérer et afficher l'erreur si présente
    String errorMessage = (String) session.getAttribute("errorMessage");
    if (errorMessage != null) {
        session.removeAttribute("errorMessage");
    }

    try {
        // Chargement des donn&eacute;es pour affichage
        Object[] toutesComps = CompetenceProfilService.getToutesCompetences();
        Set<String> compActuelles = CompetenceProfilService.getCompetencesUtilisateur(refuserInt);
        Object[] toutesSpecs = CompetenceProfilService.getToutesSpecialites();
        Set<String> specActuelles = CompetenceProfilService.getSpecialitesUtilisateur(refuserInt);
%>
<style>
.comp-saisie-wrapper { max-width: 900px; margin: 0 auto; padding: 30px 20px; }
.comp-saisie-header { text-align: center; margin-bottom: 40px; }
.comp-saisie-header h1 { font-size: 28px; font-weight: 300; color: #333; margin: 0 0 10px 0; }
.comp-saisie-header p { color: #999; font-size: 14px; margin: 0; }
.comp-section { margin-bottom: 40px; }
.comp-section-title { font-size: 18px; font-weight: 600; color: #555; margin: 0 0 20px 0; padding-left: 10px; border-left: 4px solid #f39c12; }
.spec-section-title { border-left-color: #00a65a; }
.comp-chips-container { display: flex; flex-wrap: wrap; gap: 10px; }
.comp-chip { position: relative; display: inline-block; }
.comp-chip input[type="checkbox"] { position: absolute; opacity: 0; width: 0; height: 0; }
.comp-chip label { display: block; padding: 10px 18px; background: #f5f5f5; border: 2px solid #e0e0e0; border-radius: 25px; cursor: pointer; font-size: 14px; color: #666; transition: all 0.2s ease; user-select: none; }
.comp-chip label:hover { background: #ebebeb; border-color: #d0d0d0; }
.comp-chip input[type="checkbox"]:checked + label { background: #f39c12; border-color: #f39c12; color: #fff; font-weight: 500; }
.comp-chip input[type="checkbox"]:checked + label:before { content: "✓ "; font-weight: bold; }
.spec-chip input[type="checkbox"]:checked + label { background: #00a65a; border-color: #00a65a; }
.comp-actions-bar { position: sticky; bottom: 0; background: #fff; border-top: 1px solid #eee; padding: 20px; text-align: center; box-shadow: 0 -2px 10px rgba(0,0,0,0.05); margin: 40px -20px -30px -20px; }
.btn-save-modern { background: #f39c12; color: #fff; border: none; padding: 12px 40px; border-radius: 25px; font-size: 15px; font-weight: 500; cursor: pointer; transition: all 0.3s ease; }
.btn-save-modern:hover { background: #e08e0b; transform: translateY(-2px); box-shadow: 0 4px 12px rgba(243,156,18,0.3); }
.btn-cancel-modern { background: transparent; color: #999; border: none; padding: 12px 30px; font-size: 15px; margin-left: 10px; cursor: pointer; }
.btn-cancel-modern:hover { color: #666; }
.comp-empty { text-align: center; padding: 40px; color: #ccc; font-style: italic; }
@media (max-width: 768px) {
  .comp-saisie-wrapper { padding: 20px 15px; }
  .comp-saisie-header h1 { font-size: 24px; }
  .comp-chips-container { gap: 8px; }
  .comp-chip label { padding: 8px 14px; font-size: 13px; }
  .btn-save-modern { width: 100%; margin-bottom: 10px; }
  .btn-cancel-modern { width: 100%; margin-left: 0; }
}
</style>

<div class="content-wrapper">
    <div class="comp-saisie-wrapper">
        <div class="comp-saisie-header">
            <h1><i class="fa fa-star" style="color:#f39c12;"></i> Comp&eacute;tences & Sp&eacute;cialit&eacute;s</h1>
            <p>Cliquez sur les badges pour s&eacute;lectionner vos comp&eacute;tences et sp&eacute;cialit&eacute;s</p>
        </div>

        <% if (errorMessage != null) { %>
        <div class="alert alert-danger alert-dismissible" style="margin-bottom:30px;">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <strong><i class="fa fa-exclamation-triangle"></i> Erreur</strong><br>
            <%= errorMessage %>
        </div>
        <% } %>

        <form action="<%= lien %>?but=profil/save-competences.jsp&refuser=<%= refuser %>"
              method="post" id="formCompetences">
            
            <!-- Comp&eacute;tences -->
            <div class="comp-section">
                <h3 class="comp-section-title">
                    <i class="fa fa-check-circle"></i> Comp&eacute;tences
                </h3>
                <% if (toutesComps != null && toutesComps.length > 0) { %>
                <div class="comp-chips-container">
                    <% for (Object o : toutesComps) {
                        Competence comp = (Competence) o;
                        boolean checked = compActuelles.contains(comp.getId());
                    %>
                    <div class="comp-chip">
                        <input type="checkbox" 
                               id="comp-<%= comp.getId() %>"
                               name="competences"
                               value="<%= comp.getId() %>"
                               <%= checked ? "checked" : "" %>>
                        <label for="comp-<%= comp.getId() %>"><%= comp.getLibelle() %></label>
                    </div>
                    <% } %>
                </div>
                <% } else { %>
                <div class="comp-empty">Aucune comp&eacute;tence disponible</div>
                <% } %>
            </div>

            <!-- Sp&eacute;cialit&eacute;s -->
            <div class="comp-section">
                <h3 class="comp-section-title spec-section-title">
                    <i class="fa fa-tags"></i> Sp&eacute;cialit&eacute;s
                </h3>
                <% if (toutesSpecs != null && toutesSpecs.length > 0) { %>
                <div class="comp-chips-container">
                    <% for (Object o : toutesSpecs) {
                        Specialite spec = (Specialite) o;
                        boolean checked = specActuelles.contains(spec.getId());
                    %>
                    <div class="comp-chip spec-chip">
                        <input type="checkbox" 
                               id="spec-<%= spec.getId() %>"
                               name="specialites"
                               value="<%= spec.getId() %>"
                               <%= checked ? "checked" : "" %>>
                        <label for="spec-<%= spec.getId() %>"><%= spec.getLibelle() %></label>
                    </div>
                    <% } %>
                </div>
                <% } else { %>
                <div class="comp-empty">Aucune sp&eacute;cialit&eacute; disponible</div>
                <% } %>
            </div>

            <!-- Actions -->
            <div class="comp-actions-bar">
                <button type="submit" class="btn-save-modern">
                    <i class="fa fa-check"></i> Enregistrer mes choix
                </button>
                <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= refuser %>"
                   class="btn-cancel-modern">
                    Annuler
                </a>
            </div>
        </form>
    </div>
</div>
<%  } catch (Exception e) {
        e.printStackTrace();
%>
<div class="content-wrapper">
    <div class="comp-saisie-wrapper">
        <div class="alert alert-danger">
            <h4><i class="fa fa-ban"></i> Erreur</h4>
            <p><%= e.getMessage() %></p>
        </div>
    </div>
</div>
<%  }
%>
