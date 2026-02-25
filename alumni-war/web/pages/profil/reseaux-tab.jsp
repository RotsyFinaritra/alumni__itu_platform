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
<link href="${pageContext.request.contextPath}/assets/css/profil-tabs.css" rel="stylesheet" type="text/css" />

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
