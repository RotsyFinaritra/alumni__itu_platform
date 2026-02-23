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

        // Charger les r&eacute;seaux sociaux de cet utilisateur
        ReseauUtilisateur filtreReseau = new ReseauUtilisateur();
        filtreReseau.setIdutilisateur(Integer.parseInt(refuser));
        Object[] reseauList = CGenUtil.rechercher(filtreReseau, null, null, " AND idutilisateur = " + refuser);
%>
<style>
.reseau-list { max-width: 100%; margin: 0; padding: 0; list-style: none; }
.reseau-item { display: flex; align-items: center; gap: 12px; padding: 12px 0; border-bottom: 1px solid #eee; }
.reseau-item:last-child { border-bottom: none; }
.reseau-item:hover { background: #fafafa; }
.reseau-icon { width: 35px; height: 35px; background: #3c8dbc; border-radius: 4px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
.reseau-icon i { font-size: 16px; color: #fff; }
.reseau-info { flex: 1; display: flex; align-items: center; gap: 10px; }
.reseau-title { font-size: 15px; font-weight: 500; color: #333; margin: 0; }
.reseau-actions { display: flex; gap: 6px; margin-left: auto; }
.btn-reseau { padding: 5px 10px; font-size: 12px; border-radius: 3px; border: none; cursor: pointer; white-space: nowrap; }
.btn-reseau i { margin-right: 4px; }
.btn-reseau-edit { background: #3c8dbc; color: #fff; }
.btn-reseau-edit:hover { background: #357ca5; }
.btn-reseau-delete { background: #d32f2f; color: #fff; }
.btn-reseau-delete:hover { background: #c62828; }
.reseau-empty { text-align: center; padding: 40px 20px; color: #999; }
.reseau-empty i { font-size: 40px; margin-bottom: 10px; opacity: 0.4; }
.reseau-empty p { font-size: 14px; margin: 0; }
.reseau-add-btn { background: #3c8dbc; color: #fff; border: none; padding: 8px 16px; border-radius: 4px; font-size: 13px; }
.reseau-add-btn:hover { background: #357ca5; color: #fff; }
.reseau-add-btn i { margin-right: 6px; }
.reseaux-tab-content { padding: 20px; }
@media (max-width: 992px) { 
  .reseau-info { flex-wrap: wrap; }
  .reseau-actions { width: 100%; justify-content: flex-end; margin-left: 0; margin-top: 8px; }
}
@media (max-width: 576px) { 
  .reseau-item { flex-direction: column; align-items: flex-start; }
  .reseau-info { width: 100%; flex-direction: column; align-items: flex-start; gap: 5px; }
  .reseau-actions { width: 100%; justify-content: flex-start; }
}
</style>

<div class="reseaux-tab-content">
    <% if (isOwnProfile) { %>
    <div class="clearfix" style="margin-bottom:25px;">
        <a href="<%= lien %>?but=profil/reseau-saisie.jsp&acte=insert&refuser=<%= refuser %>"
           class="btn reseau-add-btn pull-right">
            <i class="fa fa-plus"></i> Ajouter un r&eacute;seau
        </a>
    </div>
    <% } %>

    <% if (reseauList == null || reseauList.length == 0) { %>
    <div class="reseau-empty">
        <i class="fa fa-share-alt"></i>
        <p>Aucun r&eacute;seau social enregistr&eacute;</p>
    </div>
    <% } else { %>
    <div class="reseau-list">
        <% for (Object o : reseauList) {
            ReseauUtilisateur ru = (ReseauUtilisateur) o;
            String libelReseau = ru.getIdreseauxsociaux();
            String icone = "fa-link";
            ReseauxSociaux rs = new ReseauxSociaux();
            rs.setId(ru.getIdreseauxsociaux());
            Object[] res = CGenUtil.rechercher(rs, null, null, "");
            if (res != null && res.length > 0) {
                ReseauxSociaux rsData = (ReseauxSociaux) res[0];
                libelReseau = rsData.getLibelle();
                if (rsData.getIcone() != null && !rsData.getIcone().isEmpty()) {
                    icone = rsData.getIcone();
                }
            }
        %>
        <div class="reseau-item">
            <div class="reseau-icon">
                <i class="fa <%= icone %>"></i>
            </div>
            <div class="reseau-info">
                <div class="reseau-title"><%= libelReseau %></div>
                <% String lienReseau = ru.getLien();
                   if (lienReseau != null && !lienReseau.isEmpty()) { %>
                <a href="<%= lienReseau.startsWith("http") ? lienReseau : "https://" + lienReseau %>" 
                   target="_blank" style="color:#3c8dbc; font-size:13px; word-break:break-all;">
                    <i class="fa fa-external-link" style="margin-right:4px;"></i><%= lienReseau %>
                </a>
                <% } %>
            </div>
            <% if (isOwnProfile) { %>
            <div class="reseau-actions">
                <a class="btn btn-reseau btn-reseau-edit"
                   href="<%= lien %>?but=profil/reseau-saisie.jsp&id=<%= ru.getId() %>&refuser=<%= refuser %>">
                    <i class="fa fa-pencil"></i> Modifier
                </a>
                <a class="btn btn-reseau btn-reseau-delete"
                   href="<%= lien %>?but=apresTarif.jsp&acte=delete&classe=bean.ReseauUtilisateur&nomtable=reseau_utilisateur&bute=profil/mon-profil.jsp&id=<%= ru.getId() %>&refuser=<%= refuser %>&rajoutLien=refuser"
                   onclick="return confirm('Supprimer ce r&eacute;seau ?')">
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
