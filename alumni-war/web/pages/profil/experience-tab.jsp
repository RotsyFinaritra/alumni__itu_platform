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
<style>
.exp-list { max-width: 100%; margin: 0; padding: 0; list-style: none; }
.exp-item { display: flex; align-items: center; gap: 12px; padding: 12px 0; border-bottom: 1px solid #eee; }
.exp-item:last-child { border-bottom: none; }
.exp-item:hover { background: #fafafa; }
.exp-icon { width: 35px; height: 35px; background: #00a65a; border-radius: 4px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.exp-icon i { font-size: 16px; color: #fff; }
.exp-info { flex: 1; display: flex; align-items: center; gap: 15px; flex-wrap: wrap; }
.exp-title { font-size: 15px; font-weight: 600; color: #333; margin: 0; min-width: 180px; }
.exp-subtitle { font-size: 14px; color: #666; margin: 0; min-width: 150px; }
.exp-date { font-size: 13px; color: #999; white-space: nowrap; }
.exp-badge { padding: 3px 8px; background: #e8f5e9; color: #2e7d32; border-radius: 3px; font-size: 12px; }
.exp-badge-type { background: #f5f5f5; color: #666; }
.exp-actions { display: flex; gap: 6px; margin-left: auto; }
.btn-exp { padding: 5px 10px; font-size: 12px; border-radius: 3px; border: none; cursor: pointer; white-space: nowrap; }
.btn-exp i { margin-right: 4px; }
.btn-exp-edit { background: #00a65a; color: #fff; }
.btn-exp-edit:hover { background: #008d4c; }
.btn-exp-edit { background: #00a65a; color: #fff; }
.btn-exp-edit:hover { background: #008d4c; }
.btn-exp-delete { background: #d32f2f; color: #fff; }
.btn-exp-delete:hover { background: #c62828; }
.exp-empty { text-align: center; padding: 40px 20px; color: #999; }
.exp-empty i { font-size: 40px; margin-bottom: 10px; opacity: 0.4; }
.exp-empty p { font-size: 14px; margin: 0; }
.exp-add-btn { background: #00a65a; color: #fff; border: none; padding: 8px 16px; border-radius: 4px; font-size: 13px; }
.exp-add-btn:hover { background: #008d4c; color: #fff; }
.exp-add-btn i { margin-right: 6px; }
.experience-tab-content { padding: 20px; }
@media (max-width: 992px) { 
  .exp-info { flex-wrap: wrap; }
  .exp-title, .exp-subtitle { min-width: auto; }
  .exp-actions { width: 100%; justify-content: flex-end; margin-left: 0; margin-top: 8px; }
}
@media (max-width: 576px) { 
  .exp-item { flex-direction: column; align-items: flex-start; }
  .exp-info { width: 100%; flex-direction: column; align-items: flex-start; gap: 5px; }
  .exp-actions { width: 100%; justify-content: flex-start; }
  .btn-exp { padding: 6px 12px; }
}
</style>

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
