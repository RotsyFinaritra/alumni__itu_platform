<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="utilitaire.Utilitaire" %>
<%
    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        
        // Parametres de recherche
        String searchEntreprise = request.getParameter("entreprise");
        String searchLocalisation = request.getParameter("localisation");
        String searchDuree = request.getParameter("duree");
        String dateDebut = request.getParameter("date_debut");
        String dateFin = request.getParameter("date_fin");
        
        if (dateDebut == null || dateDebut.isEmpty()) dateDebut = Utilitaire.getDebutAnnee(Utilitaire.getAnnee(Utilitaire.dateDuJour()));
        if (dateFin == null || dateFin.isEmpty()) dateFin = Utilitaire.dateDuJour();
        
        // Construction de la requete
        StringBuilder sql = new StringBuilder();
        sql.append("SELECT v.post_id, v.entreprise, v.localisation, v.duree, v.auteur_nom, ");
        sql.append("v.nb_likes, v.nb_commentaires, v.created_at ");
        sql.append("FROM v_post_stage_cpl v WHERE 1=1 ");
        
        List<Object> params = new ArrayList<Object>();
        
        if (searchEntreprise != null && !searchEntreprise.trim().isEmpty()) {
            sql.append("AND LOWER(v.entreprise) LIKE LOWER(?) ");
            params.add("%" + searchEntreprise.trim() + "%");
        }
        if (searchLocalisation != null && !searchLocalisation.trim().isEmpty()) {
            sql.append("AND LOWER(v.localisation) LIKE LOWER(?) ");
            params.add("%" + searchLocalisation.trim() + "%");
        }
        if (searchDuree != null && !searchDuree.trim().isEmpty()) {
            sql.append("AND LOWER(v.duree) LIKE LOWER(?) ");
            params.add("%" + searchDuree.trim() + "%");
        }
        if (dateDebut != null && !dateDebut.isEmpty()) {
            sql.append("AND v.created_at >= ?::date ");
            params.add(dateDebut);
        }
        if (dateFin != null && !dateFin.isEmpty()) {
            sql.append("AND v.created_at <= ?::date + interval '1 day' ");
            params.add(dateFin);
        }
        sql.append("ORDER BY v.created_at DESC");
        
        PreparedStatement ps = conn.prepareStatement(sql.toString());
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
        }
        
        ResultSet rs = ps.executeQuery();
        List<String[]> listStage = new ArrayList<String[]>();
        while (rs.next()) {
            String[] row = {
                rs.getString("post_id"),
                rs.getString("entreprise") != null ? rs.getString("entreprise") : "-",
                rs.getString("localisation") != null ? rs.getString("localisation") : "-",
                rs.getString("duree") != null ? rs.getString("duree") : "-",
                rs.getString("auteur_nom") != null ? rs.getString("auteur_nom") : "-",
                String.valueOf(rs.getInt("nb_likes")),
                String.valueOf(rs.getInt("nb_commentaires")),
                rs.getTimestamp("created_at") != null ? rs.getTimestamp("created_at").toString().substring(0,10) : "-"
            };
            listStage.add(row);
        }
        rs.close(); ps.close();
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-graduation-cap"></i> Liste des offres de stage</h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-briefcase"></i> Espace Carri&egrave;re</a></li>
            <li class="active">Offres de stage</li>
        </ol>
    </section>
    <section class="content">
        <!-- Formulaire de recherche -->
        <div class="box box-success">
            <div class="box-header with-border">
                <h3 class="box-title"><i class="fa fa-search"></i> Recherche</h3>
                <div class="box-tools pull-right">
                    <a href="<%=lien%>?but=carriere/stage-saisie.jsp" class="btn btn-primary btn-sm">
                        <i class="fa fa-plus"></i> Nouvelle offre
                    </a>
                    <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i></button>
                </div>
            </div>
            <div class="box-body">
                <form action="<%=lien%>?but=carriere/stage-liste.jsp" method="post">
                    <div class="row">
                        <div class="col-md-3">
                            <div class="form-group">
                                <label>Entreprise / Organisme</label>
                                <input type="text" name="entreprise" class="form-control" value="<%=searchEntreprise != null ? searchEntreprise : ""%>" placeholder="Rechercher...">
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>Localisation</label>
                                <input type="text" name="localisation" class="form-control" value="<%=searchLocalisation != null ? searchLocalisation : ""%>" placeholder="Ville...">
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>Dur&eacute;e</label>
                                <input type="text" name="duree" class="form-control" value="<%=searchDuree != null ? searchDuree : ""%>" placeholder="Ex: 3 mois">
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>Date d&eacute;but</label>
                                <input type="date" name="date_debut" class="form-control" value="<%=dateDebut%>">
                            </div>
                        </div>
                        <div class="col-md-2">
                            <div class="form-group">
                                <label>Date fin</label>
                                <input type="date" name="date_fin" class="form-control" value="<%=dateFin%>">
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12 text-right">
                            <button type="submit" class="btn btn-success"><i class="fa fa-search"></i> Rechercher</button>
                            <a href="<%=lien%>?but=carriere/stage-liste.jsp" class="btn btn-default"><i class="fa fa-refresh"></i> R&eacute;initialiser</a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
        
        <!-- Tableau des resultats -->
        <div class="box box-info">
            <div class="box-header with-border">
                <h3 class="box-title"><i class="fa fa-list"></i> R&eacute;sultats (<%= listStage.size() %> offre(s))</h3>
            </div>
            <div class="box-body">
                <table class="table table-bordered table-striped table-hover">
                    <thead>
                        <tr>
                            <th>Date</th>
                            <th>Entreprise</th>
                            <th>Localisation</th>
                            <th>Dur&eacute;e</th>
                            <th>Publi&eacute; par</th>
                            <th style="text-align:center;">Likes</th>
                            <th style="text-align:center;">Comm.</th>
                            <th style="text-align:center;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                    <% if (listStage.isEmpty()) { %>
                        <tr><td colspan="8" class="text-center text-muted">Aucune offre trouv&eacute;e</td></tr>
                    <% } else { for (String[] row : listStage) { %>
                        <tr>
                            <td><%=row[7]%></td>
                            <td><%=row[1]%></td>
                            <td><%=row[2]%></td>
                            <td><%=row[3]%></td>
                            <td><%=row[4]%></td>
                            <td style="text-align:center;"><span class="badge bg-green"><%=row[5]%></span></td>
                            <td style="text-align:center;"><span class="badge bg-blue"><%=row[6]%></span></td>
                            <td style="text-align:center;">
                                <a href="<%=lien%>?but=carriere/stage-fiche.jsp&id=<%=row[0]%>" class="btn btn-success btn-xs">
                                    <i class="fa fa-eye"></i> Voir
                                </a>
                            </td>
                        </tr>
                    <% } } %>
                    </tbody>
                </table>
            </div>
        </div>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<div class="alert alert-danger" style="margin:20px;"><i class="fa fa-exclamation-circle"></i> Erreur: <%=e.getMessage()%></div>
<%
    } finally {
        if (conn != null) try { conn.close(); } catch(Exception ex) {}
    }
%>
