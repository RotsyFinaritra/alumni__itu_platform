<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*, utilitaire.Utilitaire, java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="user.UserEJB, utilisateurAcade.UtilisateurAcade" %>
<%@ page import="java.sql.*, utilitaire.UtilDB" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    if (u == null || lien == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int refuserInt = u.getUser().getRefuser();
    String nomUser = u.getUser().getNomuser() != null ? u.getUser().getNomuser() : "";
    
    // Info utilisateur (prenom, photo)
    String prenomUser = "";
    String photoUser = request.getContextPath() + "/assets/img/default-avatar.png";
    UtilisateurAcade userCritere = new UtilisateurAcade();
    Object[] userResult = CGenUtil.rechercher(userCritere, null, null, " AND refuser = " + refuserInt);
    if (userResult != null && userResult.length > 0) {
        UtilisateurAcade userInfo = (UtilisateurAcade) userResult[0];
        prenomUser = userInfo.getPrenom() != null ? userInfo.getPrenom() : "";
        if (userInfo.getPhoto() != null && !userInfo.getPhoto().isEmpty()) {
            String photoFileName = userInfo.getPhoto();
            if (photoFileName.contains("/")) {
                photoFileName = photoFileName.substring(photoFileName.lastIndexOf("/") + 1);
            }
            photoUser = request.getContextPath() + "/profile-photo?file=" + photoFileName;
        }
    }
    
    // Parametres de filtrage
    String typeFilter = request.getParameter("type");
    String vuFilter = request.getParameter("vu");
    int currentPage = 1;
    try { 
        currentPage = Integer.parseInt(request.getParameter("page")); 
    } catch (Exception ignored) {}
    int notifsPerPage = 20;
    
    // Charger les types de notification pour le filtre
    TypeNotification[] typesNotif = (TypeNotification[]) CGenUtil.rechercher(new TypeNotification(), null, null, " AND actif = 1 ORDER BY ordre");
    
    // Construire la requete SQL avec jointures
    Connection conn = new UtilDB().GetConn();
    
    StringBuilder sql = new StringBuilder();
    sql.append("SELECT n.*, ");
    sql.append("tn.libelle as type_libelle, tn.icon as type_icon, tn.couleur as type_couleur, ");
    sql.append("e.nomuser as emetteur_nom, e.prenom as emetteur_prenom, e.photo as emetteur_photo ");
    sql.append("FROM notifications n ");
    sql.append("LEFT JOIN type_notification tn ON n.idtypenotification = tn.id ");
    sql.append("LEFT JOIN utilisateur e ON n.emetteur_id = e.refuser ");
    sql.append("WHERE n.idutilisateur = ? ");
    
    // Filtres
    List<Object> params = new ArrayList<>();
    params.add(refuserInt);
    
    if (typeFilter != null && !typeFilter.isEmpty()) {
        sql.append("AND n.idtypenotification = ? ");
        params.add(typeFilter);
    }
    if (vuFilter != null && !vuFilter.isEmpty()) {
        sql.append("AND n.vu = ? ");
        params.add(Integer.parseInt(vuFilter));
    }
    
    // Compter le total
    String countSql = sql.toString().replace("SELECT n.*, tn.libelle as type_libelle, tn.icon as type_icon, tn.couleur as type_couleur, e.nomuser as emetteur_nom, e.prenom as emetteur_prenom, e.photo as emetteur_photo", "SELECT COUNT(*)");
    PreparedStatement psCount = conn.prepareStatement(countSql);
    for (int i = 0; i < params.size(); i++) {
        psCount.setObject(i + 1, params.get(i));
    }
    ResultSet rsCount = psCount.executeQuery();
    int totalNotifs = 0;
    if (rsCount.next()) totalNotifs = rsCount.getInt(1);
    rsCount.close();
    psCount.close();
    
    int totalPages = (int) Math.ceil((double) totalNotifs / notifsPerPage);
    
    // Ajouter ORDER BY et LIMIT
    sql.append("ORDER BY n.created_at DESC LIMIT ? OFFSET ?");
    params.add(notifsPerPage);
    params.add((currentPage - 1) * notifsPerPage);
    
    PreparedStatement ps = conn.prepareStatement(sql.toString());
    for (int i = 0; i < params.size(); i++) {
        ps.setObject(i + 1, params.get(i));
    }
    ResultSet rs = ps.executeQuery();
    
    // Compter les non lues
    PreparedStatement psNonLu = conn.prepareStatement("SELECT COUNT(*) FROM notifications WHERE idutilisateur = ? AND vu = 0");
    psNonLu.setInt(1, refuserInt);
    ResultSet rsNonLu = psNonLu.executeQuery();
    int countNonLu = 0;
    if (rsNonLu.next()) countNonLu = rsNonLu.getInt(1);
    rsNonLu.close();
    psNonLu.close();
%>

<%!
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
            return "A l'instant";
        }
    }
%>

<div class="content-wrapper" style="background: #fafafa;">
    <section class="content" style="padding: 0;">
        <div class="notif-feed-container">
            
            <!-- ========== MAIN : NOTIFICATIONS ========== -->
            <div class="notif-feed-main">
                
                <!-- Header -->
                <div class="notif-page-header">
                    <div class="notif-header-left">
                        <a href="<%= lien %>" class="notif-back-btn"><i class="fa fa-arrow-left"></i></a>
                        <h1>Notifications</h1>
                        <% if (countNonLu > 0) { %>
                        <span class="notif-badge-count"><%= countNonLu %></span>
                        <% } %>
                    </div>
                    <% if (countNonLu > 0) { %>
                    <button type="button" class="notif-mark-all-btn" onclick="marquerToutLu()">
                        <i class="fa fa-check-double"></i> Tout marquer comme lu
                    </button>
                    <% } %>
                </div>
                
                <!-- Filtre rapide (pills) -->
                <div class="notif-filter-pills">
                    <a href="<%= lien %>?but=notification/notification-liste.jsp" 
                       class="notif-pill <%= (typeFilter == null && vuFilter == null) ? "active" : "" %>">
                        Toutes
                    </a>
                    <a href="<%= lien %>?but=notification/notification-liste.jsp&vu=0" 
                       class="notif-pill <%= "0".equals(vuFilter) ? "active" : "" %>">
                        <i class="fa fa-circle" style="font-size: 8px; color: #0095f6;"></i> Non lues
                    </a>
                    <a href="<%= lien %>?but=notification/notification-liste.jsp&vu=1" 
                       class="notif-pill <%= "1".equals(vuFilter) ? "active" : "" %>">
                        Lues
                    </a>
                    <% if (typesNotif != null) {
                        for (TypeNotification tn : typesNotif) { 
                            String couleur = tn.getCouleur() != null ? tn.getCouleur() : "#8e8e8e";
                    %>
                    <a href="<%= lien %>?but=notification/notification-liste.jsp&type=<%= tn.getId() %>" 
                       class="notif-pill <%= tn.getId().equals(typeFilter) ? "active" : "" %>">
                        <i class="fa <%= tn.getIcon() != null ? tn.getIcon() : "fa-bell" %>" style="color: <%= couleur %>;"></i>
                        <%= tn.getLibelle() %>
                    </a>
                    <% }
                    } %>
                </div>
                
                <!-- Liste des notifications -->
                <% if (totalNotifs == 0) { %>
                <div class="notif-empty">
                    <div class="notif-empty-icon">
                        <i class="fa fa-bell-slash"></i>
                    </div>
                    <p>Aucune notification</p>
                    <span>Vous n'avez pas encore de notifications<%= vuFilter != null || typeFilter != null ? " avec ces filtres" : "" %></span>
                </div>
                <% } else { 
                    String lastDateGroup = "";
                    while (rs.next()) {
                        String notifId = rs.getString("id");
                        String contenu = rs.getString("contenu");
                        String lienNotif = rs.getString("lien");
                        int vu = rs.getInt("vu");
                        Timestamp createdAt = rs.getTimestamp("created_at");
                        String typeIcon = rs.getString("type_icon");
                        String typeCouleur = rs.getString("type_couleur");
                        String typeLibelle = rs.getString("type_libelle");
                        String emetteurNom = rs.getString("emetteur_nom");
                        String emetteurPrenom = rs.getString("emetteur_prenom");
                        String emetteurPhoto = rs.getString("emetteur_photo");
                        
                        String emetteurNomComplet = "";
                        if (emetteurPrenom != null) emetteurNomComplet += emetteurPrenom + " ";
                        if (emetteurNom != null) emetteurNomComplet += emetteurNom;
                        
                        if (typeIcon == null) typeIcon = "fa-bell";
                        if (typeCouleur == null) typeCouleur = "#3498db";
                        
                        // Grouper par jour
                        String dateGroup = "";
                        if (createdAt != null) {
                            long diffDays = (System.currentTimeMillis() - createdAt.getTime()) / (1000 * 60 * 60 * 24);
                            if (diffDays == 0) dateGroup = "Aujourd'hui";
                            else if (diffDays == 1) dateGroup = "Hier";
                            else if (diffDays < 7) dateGroup = "Cette semaine";
                            else dateGroup = "Plus ancien";
                        }
                        
                        if (!dateGroup.equals(lastDateGroup)) {
                            lastDateGroup = dateGroup;
                %>
                <div class="notif-date-group"><%= dateGroup %></div>
                <%      } %>
                
                <div class="notif-card <%= vu == 0 ? "unread" : "" %>" data-id="<%= notifId %>">
                    <div class="notif-card-indicator"></div>
                    <div class="notif-card-avatar">
                        <% if (emetteurPhoto != null && !emetteurPhoto.isEmpty()) { 
                            String emPhotoName = emetteurPhoto;
                            if (emPhotoName.contains("/")) emPhotoName = emPhotoName.substring(emPhotoName.lastIndexOf("/") + 1);
                        %>
                        <img src="<%= request.getContextPath() %>/profile-photo?file=<%= emPhotoName %>" alt="Photo">
                        <% } else { %>
                        <div class="notif-avatar-placeholder" style="background-color: <%= typeCouleur %>;">
                            <i class="fa <%= typeIcon %>"></i>
                        </div>
                        <% } %>
                    </div>
                    <div class="notif-card-body">
                        <% if (lienNotif != null && !lienNotif.isEmpty()) { %>
                        <a href="<%= lienNotif %>" class="notif-card-link" onclick="event.preventDefault(); marquerLu('<%= notifId %>', '<%= lienNotif %>')">
                        <% } %>
                        <p class="notif-card-text">
                            <% if (!emetteurNomComplet.trim().isEmpty()) { %>
                            <strong><%= emetteurNomComplet %></strong> 
                            <% } %>
                            <%= contenu != null ? contenu : typeLibelle %>
                        </p>
                        <% if (lienNotif != null && !lienNotif.isEmpty()) { %>
                        </a>
                        <% } %>
                        <div class="notif-card-meta">
                            <span class="notif-card-time">
                                <i class="fa fa-clock-o"></i> <%= formatTempsRelatif(createdAt) %>
                            </span>
                            <span class="notif-card-type" style="background-color: <%= typeCouleur %>;">
                                <i class="fa <%= typeIcon %>"></i> <%= typeLibelle %>
                            </span>
                        </div>
                    </div>
                    <div class="notif-card-actions">
                        <% if (vu == 0) { %>
                        <button type="button" class="notif-action-btn" onclick="marquerLu('<%= notifId %>')" title="Marquer comme lu">
                            <i class="fa fa-check"></i>
                        </button>
                        <% } else { %>
                        <button type="button" class="notif-action-btn" onclick="marquerNonLu('<%= notifId %>')" title="Marquer comme non lu">
                            <i class="fa fa-eye-slash"></i>
                        </button>
                        <% } %>
                        <button type="button" class="notif-action-btn delete" onclick="supprimerNotif('<%= notifId %>')" title="Supprimer">
                            <i class="fa fa-trash"></i>
                        </button>
                    </div>
                </div>
                <% }
                } %>
                
                <!-- Pagination -->
                <% if (totalPages > 1) { %>
                <div class="notif-pagination">
                    <% if (currentPage > 1) { %>
                    <a href="<%= lien %>?but=notification/notification-liste.jsp&page=<%= currentPage - 1 %><%= typeFilter != null ? "&type=" + typeFilter : "" %><%= vuFilter != null ? "&vu=" + vuFilter : "" %>" class="notif-page-btn">
                        <i class="fa fa-chevron-left"></i>
                    </a>
                    <% } %>
                    <% 
                    int startPage = Math.max(1, currentPage - 2);
                    int endPage = Math.min(totalPages, currentPage + 2);
                    for (int i = startPage; i <= endPage; i++) { 
                    %>
                    <a href="<%= lien %>?but=notification/notification-liste.jsp&page=<%= i %><%= typeFilter != null ? "&type=" + typeFilter : "" %><%= vuFilter != null ? "&vu=" + vuFilter : "" %>" 
                       class="notif-page-btn <%= i == currentPage ? "active" : "" %>"><%= i %></a>
                    <% } %>
                    <% if (currentPage < totalPages) { %>
                    <a href="<%= lien %>?but=notification/notification-liste.jsp&page=<%= currentPage + 1 %><%= typeFilter != null ? "&type=" + typeFilter : "" %><%= vuFilter != null ? "&vu=" + vuFilter : "" %>" class="notif-page-btn">
                        <i class="fa fa-chevron-right"></i>
                    </a>
                    <% } %>
                </div>
                <% } %>
                
            </div>
            
            <!-- ========== SIDEBAR DROITE ========== -->
            <div class="notif-feed-sidebar">
                <div class="notif-sidebar-inner">
                    
                    <!-- Profil utilisateur -->
                    <div class="sidebar-profile">
                        <a href="<%= lien %>?but=profil/mon-profil.jsp" class="profile-link">
                            <img class="profile-avatar" src="<%= photoUser %>" alt="Photo">
                            <div class="profile-info">
                                <span class="profile-name"><%= prenomUser %> <%= nomUser %></span>
                                <span class="profile-subtitle">Membre Alumni ITU</span>
                            </div>
                        </a>
                    </div>
                    
                    <!-- Resume notifications -->
                    <div class="sidebar-section">
                        <div class="section-header">
                            <span>R&eacute;sum&eacute;</span>
                        </div>
                        <div class="notif-stats-row">
                            <div class="notif-stat-card">
                                <span class="notif-stat-number <%= countNonLu > 0 ? "has-notif" : "" %>"><%= countNonLu %></span>
                                <span class="notif-stat-text">Non lues</span>
                            </div>
                            <div class="notif-stat-card">
                                <span class="notif-stat-number"><%= totalNotifs %></span>
                                <span class="notif-stat-text">Total</span>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Raccourcis -->
                    <div class="sidebar-section">
                        <div class="section-header">
                            <span>Raccourcis</span>
                        </div>
                        <nav class="sidebar-nav">
                            <a href="<%= lien %>">
                                <i class="fa fa-home"></i> Accueil
                            </a>
                            <a href="<%= lien %>?but=chatbot/alumni-chat.jsp" class="chat-link">
                                <i class="fa fa-comments"></i> Assistant Alumni
                                <span class="badge-new">IA</span>
                            </a>
                            <a href="<%= lien %>?but=carriere/emploi-liste.jsp">
                                <i class="fa fa-briefcase"></i> Offres d'emploi
                            </a>
                            <a href="<%= lien %>?but=carriere/stage-liste.jsp">
                                <i class="fa fa-graduation-cap"></i> Stages
                            </a>
                            <a href="<%= lien %>?but=annuaire/annuaire-liste.jsp">
                                <i class="fa fa-users"></i> Annuaire
                            </a>
                        </nav>
                    </div>
                    
                    <!-- Footer -->
                    <div class="sidebar-footer">
                        <p>Alumni ITU Platform &copy; 2026</p>
                    </div>
                    
                </div>
            </div>
            
        </div>
    </section>
</div>

<style>
/* ========== LAYOUT CONTAINER ========== */
.notif-feed-container {
    display: flex;
    max-width: 100%;
    margin: 0;
    padding: 20px;
    gap: 30px;
    min-height: calc(100vh - 100px);
    background: #fafafa;
}
.notif-feed-main {
    flex: 1;
    max-width: calc(100% - 320px);
}
.notif-feed-sidebar {
    width: 290px;
    flex-shrink: 0;
}
.notif-sidebar-inner {
    position: sticky;
    top: 20px;
    width: 290px;
}

/* ========== PAGE HEADER ========== */
.notif-page-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: #fff;
    border: 1px solid #dbdbdb;
    border-radius: 8px;
    padding: 16px 20px;
    margin-bottom: 16px;
}
.notif-header-left {
    display: flex;
    align-items: center;
    gap: 12px;
}
.notif-header-left h1 {
    margin: 0;
    font-size: 20px;
    font-weight: 700;
    color: #262626;
}
.notif-back-btn {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: #262626;
    text-decoration: none;
    transition: background 0.2s;
}
.notif-back-btn:hover {
    background: #efefef;
    color: #262626;
    text-decoration: none;
}
.notif-badge-count {
    background: #ed4956;
    color: #fff;
    font-size: 12px;
    font-weight: 600;
    padding: 2px 10px;
    border-radius: 12px;
}
.notif-mark-all-btn {
    background: none;
    border: 1px solid #dbdbdb;
    color: #0095f6;
    font-size: 13px;
    font-weight: 600;
    padding: 8px 16px;
    border-radius: 8px;
    cursor: pointer;
    transition: all 0.2s;
}
.notif-mark-all-btn:hover {
    background: #0095f6;
    color: #fff;
    border-color: #0095f6;
}

/* ========== FILTER PILLS ========== */
.notif-filter-pills {
    display: flex;
    gap: 8px;
    margin-bottom: 16px;
    overflow-x: auto;
    padding-bottom: 4px;
}
.notif-pill {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 8px 16px;
    border-radius: 20px;
    font-size: 13px;
    font-weight: 500;
    color: #262626;
    background: #fff;
    border: 1px solid #dbdbdb;
    text-decoration: none;
    white-space: nowrap;
    transition: all 0.2s;
}
.notif-pill:hover {
    background: #efefef;
    text-decoration: none;
    color: #262626;
}
.notif-pill.active {
    background: #262626;
    color: #fff;
    border-color: #262626;
}
.notif-pill.active i {
    color: #fff !important;
}

/* ========== DATE GROUP ========== */
.notif-date-group {
    font-size: 13px;
    font-weight: 600;
    color: #8e8e8e;
    padding: 12px 0 8px;
    text-transform: uppercase;
    letter-spacing: 0.5px;
}

/* ========== NOTIFICATION CARD ========== */
.notif-card {
    display: flex;
    align-items: flex-start;
    background: #fff;
    border: 1px solid #dbdbdb;
    border-radius: 8px;
    padding: 14px 16px;
    margin-bottom: 8px;
    position: relative;
    transition: all 0.2s;
    overflow: hidden;
}
.notif-card:hover {
    border-color: #b8b8b8;
    box-shadow: 0 1px 3px rgba(0,0,0,0.06);
}
.notif-card.unread {
    background: #f0f7ff;
    border-left: 3px solid #0095f6;
}
.notif-card-indicator {
    display: none;
}
.notif-card.unread .notif-card-indicator {
    display: block;
    position: absolute;
    top: 50%;
    left: 6px;
    transform: translateY(-50%);
    width: 8px;
    height: 8px;
    background: #0095f6;
    border-radius: 50%;
}

/* Avatar */
.notif-card-avatar {
    flex-shrink: 0;
    margin-right: 12px;
}
.notif-card-avatar img {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    object-fit: cover;
}
.notif-avatar-placeholder {
    width: 48px;
    height: 48px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
}
.notif-avatar-placeholder i {
    color: #fff;
    font-size: 20px;
}

/* Body */
.notif-card-body {
    flex: 1;
    min-width: 0;
}
.notif-card-link {
    text-decoration: none;
}
.notif-card-link:hover {
    text-decoration: none;
}
.notif-card-text {
    margin: 0 0 6px;
    font-size: 14px;
    line-height: 1.5;
    color: #262626;
}
.notif-card.unread .notif-card-text {
    font-weight: 500;
}
.notif-card-meta {
    display: flex;
    align-items: center;
    gap: 8px;
    flex-wrap: wrap;
}
.notif-card-time {
    font-size: 12px;
    color: #8e8e8e;
}
.notif-card-type {
    font-size: 10px;
    padding: 2px 8px;
    border-radius: 3px;
    color: #fff;
    font-weight: 500;
}

/* Actions */
.notif-card-actions {
    display: flex;
    gap: 4px;
    flex-shrink: 0;
    margin-left: 12px;
    opacity: 0;
    transition: opacity 0.2s;
}
.notif-card:hover .notif-card-actions {
    opacity: 1;
}
.notif-action-btn {
    width: 32px;
    height: 32px;
    border-radius: 50%;
    border: none;
    background: #efefef;
    color: #262626;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    transition: all 0.2s;
    font-size: 13px;
}
.notif-action-btn:hover {
    background: #dbdbdb;
}
.notif-action-btn.delete:hover {
    background: #ed4956;
    color: #fff;
}

/* ========== EMPTY STATE ========== */
.notif-empty {
    background: #fff;
    border: 1px solid #dbdbdb;
    border-radius: 8px;
    text-align: center;
    padding: 60px 20px;
}
.notif-empty-icon {
    width: 80px;
    height: 80px;
    border-radius: 50%;
    background: #fafafa;
    border: 2px solid #dbdbdb;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 20px;
}
.notif-empty-icon i {
    font-size: 32px;
    color: #8e8e8e;
}
.notif-empty p {
    font-size: 16px;
    font-weight: 600;
    color: #262626;
    margin: 0 0 4px;
}
.notif-empty span {
    font-size: 13px;
    color: #8e8e8e;
}

/* ========== PAGINATION ========== */
.notif-pagination {
    display: flex;
    justify-content: center;
    gap: 4px;
    padding: 20px 0;
}
.notif-page-btn {
    width: 36px;
    height: 36px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    text-decoration: none;
    font-size: 13px;
    font-weight: 500;
    color: #262626;
    background: #fff;
    border: 1px solid #dbdbdb;
    transition: all 0.2s;
}
.notif-page-btn:hover {
    background: #efefef;
    text-decoration: none;
    color: #262626;
}
.notif-page-btn.active {
    background: #262626;
    color: #fff;
    border-color: #262626;
}

/* ========== SIDEBAR STYLES ========== */
.sidebar-profile {
    padding: 16px 0;
    border-bottom: 1px solid #efefef;
    margin-bottom: 12px;
}
.profile-link {
    display: flex;
    align-items: center;
    text-decoration: none;
}
.profile-link:hover { text-decoration: none; }
.profile-avatar {
    width: 56px;
    height: 56px;
    border-radius: 50%;
    object-fit: cover;
    margin-right: 12px;
}
.profile-info {
    display: flex;
    flex-direction: column;
}
.profile-name {
    font-weight: 600;
    font-size: 14px;
    color: #262626;
}
.profile-subtitle {
    font-size: 12px;
    color: #8e8e8e;
}
.sidebar-section {
    margin-bottom: 20px;
}
.section-header {
    display: flex;
    justify-content: space-between;
    padding: 4px 0 12px;
}
.section-header span {
    font-weight: 600;
    font-size: 14px;
    color: #8e8e8e;
}

/* Notification stats */
.notif-stats-row {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 12px;
}
.notif-stat-card {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding: 16px 8px;
    background: #fafafa;
    border-radius: 8px;
}
.notif-stat-number {
    font-size: 24px;
    font-weight: 700;
    color: #262626;
}
.notif-stat-number.has-notif {
    color: #ed4956;
}
.notif-stat-text {
    font-size: 11px;
    color: #8e8e8e;
    margin-top: 4px;
}

/* Sidebar nav */
.sidebar-nav a {
    display: flex;
    align-items: center;
    padding: 12px;
    text-decoration: none;
    color: #262626;
    font-size: 14px;
    border-radius: 8px;
    margin-bottom: 4px;
}
.sidebar-nav a:hover {
    background: #fafafa;
    text-decoration: none;
}
.sidebar-nav a i {
    width: 24px;
    font-size: 18px;
    margin-right: 12px;
    color: #262626;
}
.nav-badge {
    margin-left: auto;
    background: #ed4956;
    color: #fff;
    font-size: 11px;
    padding: 2px 8px;
    border-radius: 10px;
}
.badge-new {
    margin-left: auto;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: #fff;
    font-size: 10px;
    padding: 2px 8px;
    border-radius: 10px;
    font-weight: 600;
}
.chat-link {
    background: linear-gradient(135deg, #f5f7fa 0%, #e8edf5 100%) !important;
    border-left: 3px solid #667eea !important;
}
.chat-link:hover {
    background: linear-gradient(135deg, #e8edf5 0%, #dce3f0 100%) !important;
}
.chat-link i {
    color: #667eea !important;
}
.sidebar-footer {
    padding-top: 20px;
    border-top: 1px solid #efefef;
}
.sidebar-footer p {
    font-size: 11px;
    color: #c7c7c7;
    margin: 0;
}

/* ========== RESPONSIVE ========== */
@media (max-width: 992px) {
    .notif-feed-sidebar {
        display: none;
    }
    .notif-feed-main {
        max-width: 100%;
    }
    .notif-feed-container {
        padding: 15px;
    }
    .notif-page-header {
        flex-direction: column;
        gap: 12px;
        align-items: flex-start;
    }
    .notif-mark-all-btn {
        width: 100%;
    }
    .notif-card-actions {
        opacity: 1;
    }
}
@media (max-width: 576px) {
    .notif-filter-pills {
        gap: 6px;
    }
    .notif-pill {
        padding: 6px 12px;
        font-size: 12px;
    }
}
</style>

<script>
var lien = '<%= lien %>';

function marquerLu(id, redirect) {
    if (redirect) {
        window.location.href = lien + '?but=notification/apresNotification.jsp&acte=marquer_lu&id=' + id + '&redirect=' + encodeURIComponent(redirect);
    } else {
        window.location.href = lien + '?but=notification/apresNotification.jsp&acte=marquer_lu&id=' + id;
    }
}

function marquerNonLu(id) {
    window.location.href = lien + '?but=notification/apresNotification.jsp&acte=marquer_non_lu&id=' + id;
}

function supprimerNotif(id) {
    if (!confirm('Supprimer cette notification ?')) return;
    window.location.href = lien + '?but=notification/apresNotification.jsp&acte=supprimer&id=' + id;
}

function marquerToutLu() {
    window.location.href = lien + '?but=notification/apresNotification.jsp&acte=marquer_tout_lu';
}
</script>

<%
    rs.close();
    ps.close();
    conn.close();
} catch (Exception e) {
    e.printStackTrace();
%>
<div class="content-wrapper">
    <section class="content">
        <div class="alert alert-danger">
            <i class="fa fa-exclamation-triangle"></i> Erreur: <%= e.getMessage() %>
        </div>
    </section>
</div>
<% } %>
