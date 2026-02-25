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

        int nbEmploi = 0, nbStage = 0;
        List<String[]> listeRecentsEmploi = new ArrayList<String[]>();
        List<String[]> listeRecentsStage = new ArrayList<String[]>();
        
        // Charger emplois
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM posts WHERE idtypepublication = 'TYP00002' AND supprime = 0");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) nbEmploi = rs.getInt(1);
            rs.close(); ps.close();
            
            ps = conn.prepareStatement("SELECT id, contenu, nb_likes, created_at FROM posts WHERE idtypepublication = 'TYP00002' AND supprime = 0 ORDER BY created_at DESC LIMIT 5");
            rs = ps.executeQuery();
            while (rs.next()) {
                String[] row = {rs.getString("id"), rs.getString("contenu"), String.valueOf(rs.getInt("nb_likes")), 
                    rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString().substring(0,10) : ""};
                listeRecentsEmploi.add(row);
            }
            rs.close(); ps.close();
        } catch(Exception ex) { ex.printStackTrace(); }
        
        // Charger stages
        try {
            PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM posts WHERE idtypepublication = 'TYP00003' AND supprime = 0");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) nbStage = rs.getInt(1);
            rs.close(); ps.close();
            
            ps = conn.prepareStatement("SELECT id, contenu, nb_likes, created_at FROM posts WHERE idtypepublication = 'TYP00003' AND supprime = 0 ORDER BY created_at DESC LIMIT 5");
            rs = ps.executeQuery();
            while (rs.next()) {
                String[] row = {rs.getString("id"), rs.getString("contenu"), String.valueOf(rs.getInt("nb_likes")),
                    rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString().substring(0,10) : ""};
                listeRecentsStage.add(row);
            }
            rs.close(); ps.close();
        } catch(Exception ex) { ex.printStackTrace(); }
%>
<style>
    .career-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 8px; color: #fff; margin-bottom: 25px; }
    .career-header h1 { margin: 0; font-weight: 300; font-size: 28px; }
    .career-header p { margin: 8px 0 0; opacity: 0.9; }
    .stat-card { background: #fff; border-radius: 12px; padding: 25px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); transition: transform 0.2s, box-shadow 0.2s; border: none; margin-bottom: 20px; }
    .stat-card:hover { transform: translateY(-3px); box-shadow: 0 8px 25px rgba(0,0,0,0.12); }
    .stat-card .icon { width: 60px; height: 60px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px; color: #fff; }
    .stat-card .icon.blue { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
    .stat-card .icon.green { background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); }
    .stat-card .icon.orange { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
    .stat-card h3 { font-size: 32px; font-weight: 600; margin: 15px 0 5px; color: #2d3748; }
    .stat-card p { color: #718096; margin: 0; font-size: 14px; }
    .action-btn { display: inline-flex; align-items: center; gap: 10px; padding: 12px 24px; border-radius: 8px; font-weight: 500; transition: all 0.2s; border: none; }
    .action-btn.primary { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #fff; }
    .action-btn.success { background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); color: #fff; }
    .action-btn:hover { transform: translateY(-2px); box-shadow: 0 4px 15px rgba(0,0,0,0.2); color: #fff; }
    .modern-box { background: #fff; border-radius: 12px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); border: none; overflow: hidden; }
    .modern-box .box-header { background: #f8fafc; padding: 18px 20px; border-bottom: 1px solid #e2e8f0; }
    .modern-box .box-header h3 { margin: 0; font-size: 16px; font-weight: 600; color: #2d3748; }
    .modern-box .box-body { padding: 0; }
    .modern-table { margin: 0; }
    .modern-table th { background: #f8fafc; font-weight: 600; color: #4a5568; font-size: 12px; text-transform: uppercase; letter-spacing: 0.5px; padding: 12px 16px; border: none; }
    .modern-table td { padding: 14px 16px; border-bottom: 1px solid #edf2f7; color: #4a5568; vertical-align: middle; }
    .modern-table tr:last-child td { border-bottom: none; }
    .modern-table tr:hover { background: #f7fafc; }
    .modern-table a { color: #667eea; font-weight: 500; }
    .badge-modern { padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 500; }
    .badge-modern.green { background: #c6f6d5; color: #22543d; }
    .badge-modern.blue { background: #bee3f8; color: #2a4365; }
    .empty-state { padding: 40px; text-align: center; color: #a0aec0; }
    .empty-state i { font-size: 48px; margin-bottom: 15px; opacity: 0.5; }
</style>

<div class="content-wrapper" style="background: #f4f6f9;">
    <section class="content" style="padding: 25px;">
        
        <!-- Header -->
        <div class="career-header">
            <h1><i class="fa fa-rocket"></i> Espace Carriere</h1>
            <p>Decouvrez les opportunites professionnelles et stages pour les alumni ITU</p>
        </div>

        <!-- Stats -->
        <div class="row">
            <div class="col-md-4">
                <div class="stat-card">
                    <div class="icon blue"><i class="fa fa-suitcase"></i></div>
                    <h3><%= nbEmploi %></h3>
                    <p>Offres d'emploi actives</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <div class="icon green"><i class="fa fa-graduation-cap"></i></div>
                    <h3><%= nbStage %></h3>
                    <p>Offres de stage actives</p>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stat-card">
                    <div class="icon orange"><i class="fa fa-star"></i></div>
                    <h3><%= nbEmploi + nbStage %></h3>
                    <p>Total des opportunites</p>
                </div>
            </div>
        </div>

        <!-- Actions -->
        <div class="row" style="margin-bottom: 25px;">
            <div class="col-md-12">
                <a href="<%=lien%>?but=carriere/emploi-saisie.jsp" class="action-btn primary">
                    <i class="fa fa-plus"></i> Publier une offre d'emploi
                </a>
                <a href="<%=lien%>?but=carriere/stage-saisie.jsp" class="action-btn success" style="margin-left: 10px;">
                    <i class="fa fa-plus"></i> Publier une offre de stage
                </a>
            </div>
        </div>

        <!-- Listes recentes -->
        <div class="row">
            <div class="col-md-6">
                <div class="modern-box">
                    <div class="box-header">
                        <h3><i class="fa fa-suitcase" style="color: #667eea;"></i> &nbsp;Dernieres offres d'emploi</h3>
                    </div>
                    <div class="box-body">
                        <% if (listeRecentsEmploi.size() > 0) { %>
                        <table class="table modern-table">
                            <thead><tr><th>Publication</th><th>Date</th><th>Likes</th></tr></thead>
                            <tbody>
                            <% for (String[] row : listeRecentsEmploi) {
                                String contenu = row[1] != null ? row[1].replaceAll("<[^>]*>", "") : "";
                                if (contenu.length() > 40) contenu = contenu.substring(0, 40) + "...";
                            %>
                            <tr>
                                <td><a href="<%=lien%>?but=carriere/emploi-fiche.jsp&id=<%=row[0]%>"><%=contenu%></a></td>
                                <td style="white-space:nowrap;"><%=row[3]%></td>
                                <td><span class="badge-modern green"><%=row[2]%> <i class="fa fa-heart"></i></span></td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                        <% } else { %>
                        <div class="empty-state">
                            <i class="fa fa-inbox"></i>
                            <p>Aucune offre d'emploi pour le moment</p>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>

            <div class="col-md-6">
                <div class="modern-box">
                    <div class="box-header">
                        <h3><i class="fa fa-graduation-cap" style="color: #38ef7d;"></i> &nbsp;Dernieres offres de stage</h3>
                    </div>
                    <div class="box-body">
                        <% if (listeRecentsStage.size() > 0) { %>
                        <table class="table modern-table">
                            <thead><tr><th>Publication</th><th>Date</th><th>Likes</th></tr></thead>
                            <tbody>
                            <% for (String[] row : listeRecentsStage) {
                                String contenu = row[1] != null ? row[1].replaceAll("<[^>]*>", "") : "";
                                if (contenu.length() > 40) contenu = contenu.substring(0, 40) + "...";
                            %>
                            <tr>
                                <td><a href="<%=lien%>?but=carriere/stage-fiche.jsp&id=<%=row[0]%>"><%=contenu%></a></td>
                                <td style="white-space:nowrap;"><%=row[3]%></td>
                                <td><span class="badge-modern blue"><%=row[2]%> <i class="fa fa-heart"></i></span></td>
                            </tr>
                            <% } %>
                            </tbody>
                        </table>
                        <% } else { %>
                        <div class="empty-state">
                            <i class="fa fa-inbox"></i>
                            <p>Aucune offre de stage pour le moment</p>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>

    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<div class="alert alert-danger" style="margin:20px;"><i class="fa fa-exclamation-circle"></i> Une erreur est survenue.</div>
<%
    } finally {
        if (conn != null) try { conn.close(); } catch(Exception ex) {}
    }
%>

