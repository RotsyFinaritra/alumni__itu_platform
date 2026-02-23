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
<style>
.parcours-list { max-width: 100%; margin: 0; padding: 0; list-style: none; }
.parcours-item { display: flex; align-items: center; gap: 12px; padding: 12px 0; border-bottom: 1px solid #eee; }
.parcours-item:last-child { border-bottom: none; }
.parcours-item:hover { background: #fafafa; }
.parcours-icon { width: 35px; height: 35px; background: #3c8dbc; border-radius: 4px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.parcours-icon i { font-size: 16px; color: #fff; }
.parcours-info { flex: 1; display: flex; align-items: center; gap: 15px; flex-wrap: wrap; }
.parcours-title { font-size: 15px; font-weight: 600; color: #333; margin: 0; min-width: 180px; }
.parcours-subtitle { font-size: 14px; color: #666; margin: 0; min-width: 150px; }
.parcours-date { font-size: 13px; color: #999; white-space: nowrap; }
.parcours-badge { padding: 3px 8px; background: #e8f4fd; color: #3c8dbc; border-radius: 3px; font-size: 12px; }
.parcours-actions { display: flex; gap: 6px; margin-left: auto; }
.btn-parcours { padding: 5px 10px; font-size: 12px; border-radius: 3px; border: none; cursor: pointer; white-space: nowrap; }
.btn-parcours i { margin-right: 4px; }
.btn-parcours-edit { background: #3c8dbc; color: #fff; }
.btn-parcours-edit:hover { background: #357ca5; }
.btn-parcours-delete { background: #d32f2f; color: #fff; }
.btn-parcours-delete:hover { background: #c62828; }
.parcours-empty { text-align: center; padding: 40px 20px; color: #999; }
.parcours-empty i { font-size: 40px; margin-bottom: 10px; opacity: 0.4; }
.parcours-empty p { font-size: 14px; margin: 0; }
.parcours-add-btn { background: #3c8dbc; color: #fff; border: none; padding: 8px 16px; border-radius: 4px; font-size: 13px; }
.parcours-add-btn:hover { background: #357ca5; color: #fff; }
.parcours-add-btn i { margin-right: 6px; }
.parcours-tab-content { padding: 20px; }
@media (max-width: 992px) { 
  .parcours-info { flex-wrap: wrap; }
  .parcours-title, .parcours-subtitle { min-width: auto; }
  .parcours-actions { width: 100%; justify-content: flex-end; margin-left: 0; margin-top: 8px; }
}
@media (max-width: 576px) { 
  .parcours-item { flex-direction: column; align-items: flex-start; }
  .parcours-info { width: 100%; flex-direction: column; align-items: flex-start; gap: 5px; }
  .parcours-actions { width: 100%; justify-content: flex-start; }
  .btn-parcours { padding: 6px 12px; }
}
</style>

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
