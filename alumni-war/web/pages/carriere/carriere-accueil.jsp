<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*, utilitaire.Utilitaire, java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="user.UserEJB, utilisateurAcade.UtilisateurAcade" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement, java.sql.ResultSet" %>
<%@ page import="utilitaire.UtilDB" %>
<%
    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        int refuserInt = u.getUser().getRefuser();
        
        // === STATISTIQUES ===
        int nbEmplois = 0, nbStages = 0, nbActivites = 0, nbTotalOpportunites = 0;
        int nbPublicationsMois = 0, nbAlumniActifs = 0;
        int totalViews = 0, totalLikes = 0;
        
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        // Emplois actifs
        ps = conn.prepareStatement("SELECT COUNT(*) FROM posts WHERE idtypepublication = 'TYP00002' AND supprime = 0 AND idstatutpublication = 'STAT00002'");
        rs = ps.executeQuery();
        if (rs.next()) nbEmplois = rs.getInt(1);
        rs.close(); ps.close();
        
        // Stages actifs
        ps = conn.prepareStatement("SELECT COUNT(*) FROM posts WHERE idtypepublication = 'TYP00003' AND supprime = 0 AND idstatutpublication = 'STAT00002'");
        rs = ps.executeQuery();
        if (rs.next()) nbStages = rs.getInt(1);
        rs.close(); ps.close();
        
        // Activités actives
        ps = conn.prepareStatement("SELECT COUNT(*) FROM posts WHERE idtypepublication = 'TYP00001' AND supprime = 0 AND idstatutpublication = 'STAT00002'");
        rs = ps.executeQuery();
        if (rs.next()) nbActivites = rs.getInt(1);
        rs.close(); ps.close();
        
        nbTotalOpportunites = nbEmplois + nbStages + nbActivites;
        
        // Publications ce mois (carrière)
        ps = conn.prepareStatement("SELECT COUNT(*) FROM posts WHERE idtypepublication IN ('TYP00001', 'TYP00002', 'TYP00003') AND DATE_TRUNC('month', created_at) = DATE_TRUNC('month', CURRENT_DATE) AND supprime = 0");
        rs = ps.executeQuery();
        if (rs.next()) nbPublicationsMois = rs.getInt(1);
        rs.close(); ps.close();
        
        // Alumni/utilisateurs actifs (connectés ce mois)
        ps = conn.prepareStatement("SELECT COUNT(DISTINCT refuser) FROM utilisateur WHERE created_at >= DATE_TRUNC('month', CURRENT_DATE)");
        rs = ps.executeQuery();
        if (rs.next()) nbAlumniActifs = rs.getInt(1);
        rs.close(); ps.close();
        
        // Total likes sur publications carrière
        ps = conn.prepareStatement("SELECT COALESCE(SUM(nb_likes), 0) FROM posts WHERE idtypepublication IN ('TYP00001', 'TYP00002', 'TYP00003') AND supprime = 0");
        rs = ps.executeQuery();
        if (rs.next()) totalLikes = rs.getInt(1);
        rs.close(); ps.close();
        
        // Total vues (placeholder - à implémenter si table vues existe)
        totalViews = totalLikes * 8; // Estimation: ~8 vues par like
        
        // === CHARGER LES PUBLICATIONS RÉCENTES (format carte comme accueil.jsp) ===
        Post postFilter = new Post();
        String apresWhere = " AND idtypepublication IN ('TYP00001', 'TYP00002', 'TYP00003') AND supprime = 0 ORDER BY created_at DESC LIMIT 6";
        Object[] postsResult = CGenUtil.rechercher(postFilter, null, null, apresWhere);
%>

<%!
    // Formater le temps relatif
    public String formatTempsRelatif(java.sql.Timestamp date) {
        if (date == null) return "";
        long diff = System.currentTimeMillis() - date.getTime();
        long seconds = diff / 1000;
        long minutes = seconds / 60;
        long hours = minutes / 60;
        long days = hours / 24;
        
        if (days > 7) {
            return new java.text.SimpleDateFormat("dd/MM/yyyy").format(date);
        } else if (days > 0) {
            return "Il y a " + days + " jour" + (days > 1 ? "s" : "");
        } else if (hours > 0) {
            return "Il y a " + hours + " heure" + (hours > 1 ? "s" : "");
        } else if (minutes > 0) {
            return "Il y a " + minutes + " minute" + (minutes > 1 ? "s" : "");
        } else {
            return "À l'instant";
        }
    }
%>

<style>
    /* === LAYOUT === */
    .dashboard-container {
        max-width: 1400px;
        margin: 0 auto;
        padding: 25px;
    }
    
    /* === STATISTIQUES === */
    .stats-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }
    
    .stat-card {
        background: #fff;
        border-radius: 12px;
        padding: 24px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        border: 1px solid #f0f0f0;
        position: relative;
        overflow: hidden;
    }
    
    .stat-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 4px;
        height: 100%;
        background: var(--accent-color, #667eea);
        transform: scaleY(0);
        transition: transform 0.3s;
    }
    
    .stat-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 8px 24px rgba(0,0,0,0.12);
    }
    
    .stat-card:hover::before {
        transform: scaleY(1);
    }
    
    .stat-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 16px;
    }
    
    .stat-icon {
        width: 48px;
        height: 48px;
        border-radius: 12px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 20px;
        color: #fff;
        background: var(--accent-color, #667eea);
    }
    
    .stat-trend {
        font-size: 11px;
        font-weight: 600;
        padding: 4px 8px;
        border-radius: 20px;
        background: #e8f5e9;
        color: #2e7d32;
    }
    
    .stat-value {
        font-size: 36px;
        font-weight: 700;
        color: #1a1a1a;
        line-height: 1;
        margin-bottom: 8px;
    }
    
    .stat-label {
        font-size: 13px;
        color: #757575;
        font-weight: 500;
    }
    
    /* Couleurs des cartes */
    .stat-card.blue { --accent-color: #667eea; }
    .stat-card.blue .stat-icon { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); }
    
    .stat-card.green { --accent-color: #11998e; }
    .stat-card.green .stat-icon { background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%); }
    
    .stat-card.orange { --accent-color: #f093fb; }
    .stat-card.orange .stat-icon { background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); }
    
    .stat-card.purple { --accent-color: #7c3aed; }
    .stat-card.purple .stat-icon { background: linear-gradient(135deg, #7c3aed 0%, #a78bfa 100%); }
    
    .stat-card.teal { --accent-color: #14b8a6; }
    .stat-card.teal .stat-icon { background: linear-gradient(135deg, #14b8a6 0%, #06b6d4 100%); }
    
    .stat-card.yellow { --accent-color: #f59e0b; }
    .stat-card.yellow .stat-icon { background: linear-gradient(135deg, #f59e0b 0%, #fbbf24 100%); }
    
    /* === ACTIONS RAPIDES === */
    .quick-actions {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 15px;
        margin-bottom: 30px;
    }
    
    .action-card {
        background: #fff;
        border: 2px solid #e0e0e0;
        border-radius: 10px;
        padding: 18px 20px;
        text-align: center;
        text-decoration: none;
        color: #333;
        transition: all 0.3s;
        display: flex;
        flex-direction: column;
        align-items: center;
        gap: 10px;
    }
    
    .action-card:hover {
        border-color: #667eea;
        background: #f8f9ff;
        transform: translateY(-2px);
        text-decoration: none;
        color: #667eea;
    }
    
    .action-card i {
        font-size: 28px;
        margin-bottom: 5px;
    }
    
    .action-card span {
        font-weight: 600;
        font-size: 14px;
    }
    
    /* === PUBLICATIONS RÉCENTES === */
    .section-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 20px;
    }
    
    .section-header h2 {
        font-size: 22px;
        font-weight: 600;
        color: #1a1a1a;
        margin: 0;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .section-link {
        color: #667eea;
        font-weight: 500;
        font-size: 14px;
        text-decoration: none;
    }
    
    .section-link:hover {
        text-decoration: underline;
    }
    
    .posts-grid {
        display: grid;
        grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
        gap: 20px;
        margin-bottom: 30px;
    }
    
    .post-mini-card {
        background: #fff;
        border: 1px solid #e0e0e0;
        border-radius: 12px;
        overflow: hidden;
        transition: all 0.3s;
        cursor: pointer;
        text-decoration: none;
        display: block;
        color: inherit;
    }
    
    .post-mini-card:hover {
        transform: translateY(-4px);
        box-shadow: 0 12px 24px rgba(0,0,0,0.1);
        text-decoration: none;
    }
    
    .post-mini-header {
        padding: 14px 16px;
        border-bottom: 1px solid #f0f0f0;
        display: flex;
        align-items: center;
        gap: 10px;
    }
    
    .post-mini-avatar {
        width: 36px;
        height: 36px;
        border-radius: 50%;
        object-fit: cover;
    }
    
    .post-mini-author-info {
        flex: 1;
    }
    
    .post-mini-author-name {
        font-weight: 600;
        font-size: 13px;
        color: #262626;
        display: block;
    }
    
    .post-mini-time {
        font-size: 11px;
        color: #999;
    }
    
    .post-mini-badge {
        padding: 4px 10px;
        border-radius: 20px;
        font-size: 11px;
        font-weight: 600;
        color: #fff;
    }
    
    .post-mini-badge.emploi { background: #667eea; }
    .post-mini-badge.stage { background: #11998e; }
    .post-mini-badge.activite { background: #f093fb; }
    
    .post-mini-content {
        padding: 16px;
    }
    
    .post-mini-text {
        font-size: 14px;
        color: #333;
        line-height: 1.5;
        display: -webkit-box;
        -webkit-line-clamp: 3;
        -webkit-box-orient: vertical;
        overflow: hidden;
        margin-bottom: 12px;
    }
    
    .post-mini-details {
        display: flex;
        gap: 12px;
        flex-wrap: wrap;
        margin-bottom: 10px;
    }
    
    .post-mini-detail {
        font-size: 12px;
        color: #666;
        display: flex;
        align-items: center;
        gap: 5px;
    }
    
    .post-mini-detail i {
        color: #999;
        font-size: 11px;
    }
    
    .post-mini-footer {
        padding: 10px 16px;
        border-top: 1px solid #f0f0f0;
        display: flex;
        gap: 15px;
        font-size: 12px;
        color: #666;
    }
    
    .post-mini-stat {
        display: flex;
        align-items: center;
        gap: 5px;
    }
    
    .empty-state {
        text-align: center;
        padding: 60px 30px;
        background: #fff;
        border-radius: 12px;
        border: 1px solid #e0e0e0;
    }
    
    .empty-state i {
        font-size: 64px;
        color: #ccc;
        margin-bottom: 20px;
    }
    
    .empty-state h3 {
        font-size: 20px;
        color: #555;
        margin-bottom: 10px;
    }
    
    .empty-state p {
        color: #999;
    }
</style>

<div class="content-wrapper" style="background: #f8f9fc;">
    <section class="content-header">
        <h1><i class="fa fa-briefcase"></i> Tableau de Bord Carrière</h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=accueil.jsp"><i class="fa fa-home"></i> Accueil</a></li>
            <li class="active">Espace Carrière</li>
        </ol>
    </section>
    <section class="content">
        <div class="dashboard-container">

        <!-- Statistiques -->
        <div class="stats-grid">
            <div class="stat-card blue">
                <div class="stat-header">
                    <div class="stat-icon"><i class="fa fa-briefcase"></i></div>
                    <span class="stat-trend">Actifs</span>
                </div>
                <div class="stat-value"><%= nbEmplois %></div>
                <div class="stat-label">Offres d'Emploi</div>
            </div>
            
            <div class="stat-card green">
                <div class="stat-header">
                    <div class="stat-icon"><i class="fa fa-graduation-cap"></i></div>
                    <span class="stat-trend">Actifs</span>
                </div>
                <div class="stat-value"><%= nbStages %></div>
                <div class="stat-label">Offres de Stage</div>
            </div>
            
            <div class="stat-card orange">
                <div class="stat-header">
                    <div class="stat-icon"><i class="fa fa-calendar"></i></div>
                    <span class="stat-trend">Actifs</span>
                </div>
                <div class="stat-value"><%= nbActivites %></div>
                <div class="stat-label">Activités / Événements</div>
            </div>
            
            <div class="stat-card purple">
                <div class="stat-header">
                    <div class="stat-icon"><i class="fa fa-trophy"></i></div>
                    <span class="stat-trend">Total</span>
                </div>
                <div class="stat-value"><%= nbTotalOpportunites %></div>
                <div class="stat-label">Opportunités Totales</div>
            </div>
            
            <div class="stat-card teal">
                <div class="stat-header">
                    <div class="stat-icon"><i class="fa fa-bar-chart"></i></div>
                    <span class="stat-trend">Ce mois</span>
                </div>
                <div class="stat-value"><%= nbPublicationsMois %></div>
                <div class="stat-label">Publications</div>
            </div>
            
            <div class="stat-card yellow">
                <div class="stat-header">
                    <div class="stat-icon"><i class="fa fa-eye"></i></div>
                    <span class="stat-trend">Global</span>
                </div>
                <div class="stat-value"><%= totalViews %></div>
                <div class="stat-label">Vues Totales</div>
            </div>
        </div>

        <!-- Actions Rapides -->
        <div class="section-header">
            <h2><i class="material-symbols-rounded" style="font-size:24px">bolt</i> Actions Rapides</h2>
        </div>
        <div class="quick-actions">
            <a href="<%=lien%>?but=carriere/emploi-saisie.jsp" class="action-card">
                <i class="fa fa-plus-circle" style="color:#667eea;"></i>
                <span>Publier un Emploi</span>
            </a>
            <a href="<%=lien%>?but=carriere/stage-saisie.jsp" class="action-card">
                <i class="fa fa-plus-circle" style="color:#11998e;"></i>
                <span>Publier un Stage</span>
            </a>
            <a href="<%=lien%>?but=carriere/activite-saisie.jsp" class="action-card">
                <i class="fa fa-plus-circle" style="color:#f093fb;"></i>
                <span>Créer une Activité</span>
            </a>
            <a href="<%=lien%>?but=carriere/emploi-liste.jsp" class="action-card">
                <i class="fa fa-list" style="color:#7c3aed;"></i>
                <span>Voir Tous les Emplois</span>
            </a>
            <a href="<%=lien%>?but=carriere/stage-liste.jsp" class="action-card">
                <i class="fa fa-list" style="color:#14b8a6;"></i>
                <span>Voir Tous les Stages</span>
            </a>
            <a href="<%=lien%>?but=carriere/activite-liste.jsp" class="action-card">
                <i class="fa fa-calendar-o" style="color:#f59e0b;"></i>
                <span>Voir Toutes les Activités</span>
            </a>
        </div>

        <!-- Publications Récentes -->
        <div class="section-header">
            <h2><i class="material-symbols-rounded" style="font-size:24px">new_releases</i> Publications Récentes</h2>
            <a href="<%=lien%>?but=accueil.jsp" class="section-link">Voir le fil complet <i class="fa fa-arrow-right"></i></a>
        </div>
        
        <% if (postsResult == null || postsResult.length == 0) { %>
        <div class="empty-state">
            <i class="fa fa-inbox"></i>
            <h3>Aucune publication récente</h3>
            <p>Les nouvelles opportunités apparaîtront ici</p>
        </div>
        <% } else { %>
        <div class="posts-grid">
            <% for (Object postObj : postsResult) {
                Post post = (Post) postObj;
                String postId = post.getId();
                String contenu = post.getContenu();
                if (contenu != null) {
                    contenu = contenu.replaceAll("<[^>]*>", ""); // Strip HTML
                }
                java.sql.Timestamp createdAt = post.getCreated_at();
                int postAuteurId = post.getIdutilisateur();
                int nbLikes = post.getNb_likes();
                int nbComments = post.getNb_commentaires();
                
                // Charger l'auteur
                String nomComplet = "Utilisateur";
                String photoAuteur = request.getContextPath() + "/assets/img/default-avatar.png";
                UtilisateurAcade auteurCritere = new UtilisateurAcade();
                Object[] auteurResult = CGenUtil.rechercher(auteurCritere, null, null, " AND refuser = " + postAuteurId);
                if (auteurResult != null && auteurResult.length > 0) {
                    UtilisateurAcade auteur = (UtilisateurAcade) auteurResult[0];
                    String prenom = auteur.getPrenom() != null ? auteur.getPrenom() : "";
                    String nom = auteur.getNomuser() != null ? auteur.getNomuser() : "";
                    nomComplet = (prenom + " " + nom).trim();
                    if (nomComplet.isEmpty()) nomComplet = "Utilisateur";
                    if (auteur.getPhoto() != null && !auteur.getPhoto().isEmpty()) {
                        String auteurPhotoFile = auteur.getPhoto();
                        if (auteurPhotoFile.contains("/")) {
                            auteurPhotoFile = auteurPhotoFile.substring(auteurPhotoFile.lastIndexOf("/") + 1);
                        }
                        photoAuteur = request.getContextPath() + "/profile-photo?file=" + auteurPhotoFile;
                    }
                }
                
                // Type de publication
                String typeCode = post.getIdtypepublication();
                String typeLabel = "Publication";
                String badgeClass = "emploi";
                String detailsHtml = "";
                String ficheUrl = lien + "?but=publication/publication-fiche.jsp&id=" + postId;
                
                if ("TYP00002".equals(typeCode)) {
                    typeLabel = "Emploi";
                    badgeClass = "emploi";
                    ficheUrl = lien + "?but=carriere/emploi-fiche.jsp&id=" + postId;
                    
                    // Charger détails emploi
                    PostEmploi empFilter = new PostEmploi();
                    empFilter.setPost_id(postId);
                    Object[] empResult = CGenUtil.rechercher(empFilter, null, null, "");
                    if (empResult != null && empResult.length > 0) {
                        PostEmploi emp = (PostEmploi) empResult[0];
                        String entreprise = emp.getEntreprise() != null ? emp.getEntreprise() : "";
                        String localisation = emp.getLocalisation() != null ? emp.getLocalisation() : "";
                        String typeContrat = emp.getType_contrat() != null ? emp.getType_contrat() : "";
                        
                        if (!entreprise.isEmpty()) detailsHtml += "<div class='post-mini-detail'><i class='fa fa-building'></i> " + entreprise + "</div>";
                        if (!localisation.isEmpty()) detailsHtml += "<div class='post-mini-detail'><i class='fa fa-map-marker'></i> " + localisation + "</div>";
                        if (!typeContrat.isEmpty()) detailsHtml += "<div class='post-mini-detail'><i class='fa fa-briefcase'></i> " + typeContrat + "</div>";
                    }
                } else if ("TYP00003".equals(typeCode)) {
                    typeLabel = "Stage";
                    badgeClass = "stage";
                    ficheUrl = lien + "?but=carriere/stage-fiche.jsp&id=" + postId;
                    
                    // Charger détails stage
                    PostStage stgFilter = new PostStage();
                    stgFilter.setPost_id(postId);
                    Object[] stgResult = CGenUtil.rechercher(stgFilter, null, null, "");
                    if (stgResult != null && stgResult.length > 0) {
                        PostStage stg = (PostStage) stgResult[0];
                        String entreprise = stg.getEntreprise() != null ? stg.getEntreprise() : "";
                        String localisation = stg.getLocalisation() != null ? stg.getLocalisation() : "";
                        String duree = stg.getDuree() != null ? stg.getDuree() : "";
                        
                        if (!entreprise.isEmpty()) detailsHtml += "<div class='post-mini-detail'><i class='fa fa-building'></i> " + entreprise + "</div>";
                        if (!localisation.isEmpty()) detailsHtml += "<div class='post-mini-detail'><i class='fa fa-map-marker'></i> " + localisation + "</div>";
                        if (!duree.isEmpty()) detailsHtml += "<div class='post-mini-detail'><i class='fa fa-clock-o'></i> " + duree + "</div>";
                    }
                } else if ("TYP00001".equals(typeCode)) {
                    typeLabel = "Activité";
                    badgeClass = "activite";
                    ficheUrl = lien + "?but=carriere/activite-fiche.jsp&id=" + postId;
                    
                    // Charger détails activité
                    PostActivite actFilter = new PostActivite();
                    actFilter.setPost_id(postId);
                    Object[] actResult = CGenUtil.rechercher(actFilter, null, null, "");
                    if (actResult != null && actResult.length > 0) {
                        PostActivite act = (PostActivite) actResult[0];
                        String lieu = act.getLieu() != null ? act.getLieu() : "";
                        java.sql.Timestamp dateDebut = act.getDate_debut();
                        
                        if (!lieu.isEmpty()) detailsHtml += "<div class='post-mini-detail'><i class='fa fa-map-marker'></i> " + lieu + "</div>";
                        if (dateDebut != null) detailsHtml += "<div class='post-mini-detail'><i class='fa fa-calendar'></i> " + new java.text.SimpleDateFormat("dd/MM/yyyy").format(dateDebut) + "</div>";
                    }
                }
            %>
            <a href="<%= ficheUrl %>" class="post-mini-card">
                <div class="post-mini-header">
                    <img src="<%= photoAuteur %>" class="post-mini-avatar" alt="Photo">
                    <div class="post-mini-author-info">
                        <span class="post-mini-author-name"><%= nomComplet %></span>
                        <span class="post-mini-time"><%= formatTempsRelatif(createdAt) %></span>
                    </div>
                    <span class="post-mini-badge <%= badgeClass %>"><%= typeLabel %></span>
                </div>
                <div class="post-mini-content">
                    <div class="post-mini-text"><%= contenu != null ? contenu : "" %></div>
                    <% if (!detailsHtml.isEmpty()) { %>
                    <div class="post-mini-details"><%= detailsHtml %></div>
                    <% } %>
                </div>
                <div class="post-mini-footer">
                    <div class="post-mini-stat"><i class="fa fa-heart"></i> <%= nbLikes %></div>
                    <div class="post-mini-stat"><i class="fa fa-comment"></i> <%= nbComments %></div>
                </div>
            </a>
            <% } %>
        </div>
        <% } %>

        </div>
    </section>
</div>

<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<div class="content-wrapper" style="background: #f8f9fc;">
    <div class="dashboard-container">
        <div class="empty-state">
            <i class="fa fa-exclamation-triangle" style="color: #e74c3c;"></i>
            <h3>Erreur de chargement</h3>
            <p>Une erreur est survenue lors du chargement du tableau de bord.</p>
            <p style="font-size:12px; color:#999;"><%= e.getMessage() %></p>
        </div>
    </div>
</div>
<%
    } finally {
        if (conn != null) try { conn.close(); } catch(Exception ex) {}
    }
%>

