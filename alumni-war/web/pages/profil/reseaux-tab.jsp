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
<div class="reseaux-tab-content" style="padding:15px;">
    <% if (isOwnProfile) { %>
    <div class="clearfix" style="margin-bottom:15px;">
        <a href="<%= lien %>?but=profil/reseau-saisie.jsp&acte=insert&refuser=<%= refuser %>"
           class="btn btn-success btn-sm pull-right">
            <i class="fa fa-plus"></i> Ajouter un r&eacute;seau
        </a>
    </div>
    <% } %>

    <% if (reseauList == null || reseauList.length == 0) { %>
    <div class="alert alert-info">
        <i class="fa fa-info-circle"></i> Aucun r&eacute;seau social enregistr&eacute;.
    </div>
    <% } else { %>
    <div class="row">
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
        <div class="col-md-4" style="margin-bottom:10px;">
            <div class="box box-default">
                <div class="box-body text-center">
                    <i class="fa <%= icone %> fa-2x" style="margin-bottom:5px;"></i>
                    <p><strong><%= libelReseau %></strong></p>
                    <% if (isOwnProfile) { %>
                    <a href="<%= lien %>?but=apresTarif.jsp&acte=delete&classe=bean.ReseauUtilisateur&nomtable=reseau_utilisateur&bute=profil/mon-profil.jsp&id=<%= ru.getId() %>&refuser=<%= refuser %>"
                       class="btn btn-xs btn-danger"
                       onclick="return confirm('Supprimer ce r&eacute;seau ?')">
                        <i class="fa fa-trash"></i> Supprimer
                    </a>
                    <% } %>
                </div>
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
