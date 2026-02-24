<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="utilitaire.UtilDB" %>
<%
    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");

        // Charger les offres d'emploi via SQL direct
        List<String[]> listEmploi = new ArrayList<String[]>();
        try {
            PreparedStatement ps = conn.prepareStatement(
                "SELECT id, contenu, nb_likes, nb_commentaires, created_at FROM posts WHERE idtypepublication = 'TYP00002' AND supprime = 0 ORDER BY created_at DESC");
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                String[] row = new String[5];
                row[0] = rs.getString("id");
                row[1] = rs.getString("contenu");
                row[2] = String.valueOf(rs.getInt("nb_likes"));
                row[3] = String.valueOf(rs.getInt("nb_commentaires"));
                row[4] = rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString().substring(0,10) : "";
                listEmploi.add(row);
            }
            rs.close(); ps.close();
        } catch(Exception ex) { ex.printStackTrace(); }
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-suitcase"></i> Offres d'emploi</h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carriere</a></li>
            <li class="active">Offres d'emploi</li>
        </ol>
    </section>
    <section class="content">
        <div class="box box-primary">
            <div class="box-header with-border">
                <h3 class="box-title"><i class="fa fa-list"></i> Liste des offres</h3>
            </div>
            <div class="box-body">
                <table class="table table-bordered table-striped">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Contenu</th>
                            <th>Likes</th>
                            <th>Commentaires</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (listEmploi != null && listEmploi.size() > 0) {
                            for (String[] row : listEmploi) {
                                String id = row[0];
                                String contenu = row[1] != null ? row[1] : "";
                                if (contenu.length() > 100) contenu = contenu.substring(0, 100) + "...";
                        %>
                        <tr>
                            <td><%=row[4]%></td>
                            <td><%=contenu%></td>
                            <td><span class="badge bg-green"><%=row[2]%></span></td>
                            <td><span class="badge bg-blue"><%=row[3]%></span></td>
                            <td>
                                <a href="<%=lien%>?but=carriere/emploi-fiche.jsp&id=<%=id%>" class="btn btn-xs btn-info">
                                    <i class="fa fa-eye"></i> Voir
                                </a>
                            </td>
                        </tr>
                        <% }
                           } else { %>
                        <tr><td colspan="5" class="text-center text-muted">Aucune offre d'emploi.</td></tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </div>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
        String msgErr = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
%>
<script language="JavaScript">alert('Erreur emploi-liste : <%=msgErr.replace("'", "\\'")%>');</script>
<%
    } finally {
        if (conn != null) try { conn.close(); } catch(Exception ex) {}
    }
%>
