<%@ page import="bean.*, utilitaire.Utilitaire, java.util.*, java.text.SimpleDateFormat" %>
<%@ page import="user.UserEJB, utilisateurAcade.UtilisateurPg" %>
<%@ page import="java.sql.*, utilitaire.UtilDB" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    if (u == null || lien == null) {
        response.sendRedirect("login.jsp");
        return;
    }
    
    int refuserInt = u.getUser().getRefuser();
    
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
    // Formater le temps relatif (il y a X minutes, heures, etc.)
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

<div class="content-wrapper">
    <section class="content-header">
        <h1>
            <i class="fa fa-bell"></i> Notifications
            <% if (countNonLu > 0) { %>
            <span class="badge bg-red"><%= countNonLu %> non lue<%= countNonLu > 1 ? "s" : "" %></span>
            <% } %>
        </h1>
        <ol class="breadcrumb">
            <li><a href="<%= lien %>"><i class="fa fa-home"></i> Accueil</a></li>
            <li class="active">Notifications</li>
        </ol>
    </section>
    
    <section class="content">
        <div class="row">
            <!-- Sidebar filtre -->
            <div class="col-md-3">
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa fa-filter"></i> Filtres</h3>
                    </div>
                    <div class="box-body">
                        <form method="get" action="<%= lien %>" id="filterForm">
                            <input type="hidden" name="but" value="notification/notification-liste.jsp">
                            
                            <div class="form-group">
                                <label>Type</label>
                                <select name="type" class="form-control" onchange="this.form.submit()">
                                    <option value="">-- Tous --</option>
                                    <% if (typesNotif != null) {
                                        for (TypeNotification tn : typesNotif) { %>
                                    <option value="<%= tn.getId() %>" <%= (tn.getId().equals(typeFilter)) ? "selected" : "" %>>
                                        <i class="fa <%= tn.getIcon() %>"></i> <%= tn.getLibelle() %>
                                    </option>
                                    <% }
                                    } %>
                                </select>
                            </div>
                            
                            <div class="form-group">
                                <label>Statut</label>
                                <select name="vu" class="form-control" onchange="this.form.submit()">
                                    <option value="">-- Tous --</option>
                                    <option value="0" <%= "0".equals(vuFilter) ? "selected" : "" %>>Non lues</option>
                                    <option value="1" <%= "1".equals(vuFilter) ? "selected" : "" %>>Lues</option>
                                </select>
                            </div>
                            
                            <% if (typeFilter != null || vuFilter != null) { %>
                            <a href="<%= lien %>?but=notification/notification-liste.jsp" class="btn btn-default btn-block">
                                <i class="fa fa-times"></i> Effacer les filtres
                            </a>
                            <% } %>
                        </form>
                    </div>
                </div>
                
                <!-- Actions rapides -->
                <div class="box box-info">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa fa-bolt"></i> Actions</h3>
                    </div>
                    <div class="box-body">
                        <% if (countNonLu > 0) { %>
                        <button type="button" class="btn btn-primary btn-block" onclick="marquerToutLu()">
                            <i class="fa fa-check-double"></i> Tout marquer comme lu
                        </button>
                        <% } %>
                    </div>
                </div>
            </div>
            
            <!-- Liste des notifications -->
            <div class="col-md-9">
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title">
                            <i class="fa fa-list"></i> 
                            <%= totalNotifs %> notification<%= totalNotifs > 1 ? "s" : "" %>
                        </h3>
                    </div>
                    <div class="box-body" id="notificationList">
                        <% if (totalNotifs == 0) { %>
                        <div class="text-center" style="padding: 40px;">
                            <i class="fa fa-bell-slash fa-3x text-muted"></i>
                            <p class="text-muted" style="margin-top: 15px;">Aucune notification</p>
                        </div>
                        <% } else { 
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
                        %>
                        <div class="notification-item <%= vu == 0 ? "unread" : "" %>" data-id="<%= notifId %>" style="<%= vu == 0 ? "background-color: #f0f7ff;" : "" %>">
                            <div class="media" style="padding: 12px; border-bottom: 1px solid #eee;">
                                <div class="media-left">
                                    <% if (emetteurPhoto != null && !emetteurPhoto.isEmpty()) { %>
                                    <img src="<%= emetteurPhoto %>" class="media-object" style="width: 45px; height: 45px; border-radius: 50%; object-fit: cover;">
                                    <% } else { %>
                                    <div style="width: 45px; height: 45px; border-radius: 50%; background-color: <%= typeCouleur %>; display: flex; align-items: center; justify-content: center;">
                                        <i class="fa <%= typeIcon %>" style="color: white; font-size: 18px;"></i>
                                    </div>
                                    <% } %>
                                </div>
                                <div class="media-body" style="vertical-align: middle;">
                                    <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                                        <div style="flex: 1;">
                                            <% if (lienNotif != null && !lienNotif.isEmpty()) { %>
                                            <a href="<%= lienNotif %>" class="notification-link" onclick="marquerLu('<%= notifId %>')">
                                            <% } %>
                                            <p style="margin: 0; color: #333; <%= vu == 0 ? "font-weight: 600;" : "" %>">
                                                <% if (!emetteurNomComplet.trim().isEmpty()) { %>
                                                <strong><%= emetteurNomComplet %></strong> - 
                                                <% } %>
                                                <%= contenu != null ? contenu : typeLibelle %>
                                            </p>
                                            <% if (lienNotif != null && !lienNotif.isEmpty()) { %>
                                            </a>
                                            <% } %>
                                            <small class="text-muted">
                                                <i class="fa fa-clock-o"></i> <%= formatTempsRelatif(createdAt) %>
                                                <span class="label" style="background-color: <%= typeCouleur %>; margin-left: 5px;">
                                                    <i class="fa <%= typeIcon %>"></i> <%= typeLibelle %>
                                                </span>
                                            </small>
                                        </div>
                                        <div class="notification-actions" style="white-space: nowrap;">
                                            <% if (vu == 0) { %>
                                            <button type="button" class="btn btn-xs btn-default" onclick="marquerLu('<%= notifId %>')" title="Marquer comme lu">
                                                <i class="fa fa-check"></i>
                                            </button>
                                            <% } else { %>
                                            <button type="button" class="btn btn-xs btn-default" onclick="marquerNonLu('<%= notifId %>')" title="Marquer comme non lu">
                                                <i class="fa fa-eye-slash"></i>
                                            </button>
                                            <% } %>
                                            <button type="button" class="btn btn-xs btn-danger" onclick="supprimerNotif('<%= notifId %>')" title="Supprimer">
                                                <i class="fa fa-trash"></i>
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <% }
                        } %>
                    </div>
                    
                    <% if (totalPages > 1) { %>
                    <div class="box-footer clearfix">
                        <ul class="pagination pagination-sm no-margin pull-right">
                            <% if (currentPage > 1) { %>
                            <li><a href="<%= lien %>?but=notification/notification-liste.jsp&page=<%= currentPage - 1 %><%= typeFilter != null ? "&type=" + typeFilter : "" %><%= vuFilter != null ? "&vu=" + vuFilter : "" %>">&laquo;</a></li>
                            <% } %>
                            
                            <% 
                            int startPage = Math.max(1, currentPage - 2);
                            int endPage = Math.min(totalPages, currentPage + 2);
                            for (int i = startPage; i <= endPage; i++) { 
                            %>
                            <li class="<%= i == currentPage ? "active" : "" %>">
                                <a href="<%= lien %>?but=notification/notification-liste.jsp&page=<%= i %><%= typeFilter != null ? "&type=" + typeFilter : "" %><%= vuFilter != null ? "&vu=" + vuFilter : "" %>"><%= i %></a>
                            </li>
                            <% } %>
                            
                            <% if (currentPage < totalPages) { %>
                            <li><a href="<%= lien %>?but=notification/notification-liste.jsp&page=<%= currentPage + 1 %><%= typeFilter != null ? "&type=" + typeFilter : "" %><%= vuFilter != null ? "&vu=" + vuFilter : "" %>">&raquo;</a></li>
                            <% } %>
                        </ul>
                    </div>
                    <% } %>
                </div>
            </div>
        </div>
    </section>
</div>

<style>
.notification-item:hover {
    background-color: #f5f5f5 !important;
}
.notification-item.unread {
    border-left: 3px solid #3498db;
}
.notification-actions {
    opacity: 0.3;
    transition: opacity 0.2s;
}
.notification-item:hover .notification-actions {
    opacity: 1;
}
.notification-link {
    text-decoration: none;
}
.notification-link:hover {
    text-decoration: none;
}
</style>

<script>
var lien = '<%= lien %>';

function marquerLu(id) {
    $.ajax({
        url: lien + '?but=notification/apresNotification.jsp',
        type: 'POST',
        data: { acte: 'marquer_lu', id: id },
        success: function(response) {
            var item = $('[data-id="' + id + '"]');
            item.removeClass('unread').css('background-color', '');
            item.find('.notification-actions').html(
                '<button type="button" class="btn btn-xs btn-default" onclick="marquerNonLu(\'' + id + '\')" title="Marquer comme non lu"><i class="fa fa-eye-slash"></i></button> ' +
                '<button type="button" class="btn btn-xs btn-danger" onclick="supprimerNotif(\'' + id + '\')" title="Supprimer"><i class="fa fa-trash"></i></button>'
            );
            item.find('p').css('font-weight', 'normal');
            updateBadge(-1);
        }
    });
}

function marquerNonLu(id) {
    $.ajax({
        url: lien + '?but=notification/apresNotification.jsp',
        type: 'POST',
        data: { acte: 'marquer_non_lu', id: id },
        success: function(response) {
            var item = $('[data-id="' + id + '"]');
            item.addClass('unread').css('background-color', '#f0f7ff');
            item.find('.notification-actions').html(
                '<button type="button" class="btn btn-xs btn-default" onclick="marquerLu(\'' + id + '\')" title="Marquer comme lu"><i class="fa fa-check"></i></button> ' +
                '<button type="button" class="btn btn-xs btn-danger" onclick="supprimerNotif(\'' + id + '\')" title="Supprimer"><i class="fa fa-trash"></i></button>'
            );
            item.find('p').css('font-weight', '600');
            updateBadge(1);
        }
    });
}

function supprimerNotif(id) {
    if (!confirm('Supprimer cette notification ?')) return;
    
    $.ajax({
        url: lien + '?but=notification/apresNotification.jsp',
        type: 'POST',
        data: { acte: 'supprimer', id: id },
        success: function(response) {
            var item = $('[data-id="' + id + '"]');
            var wasUnread = item.hasClass('unread');
            item.fadeOut(300, function() {
                $(this).remove();
                if (wasUnread) updateBadge(-1);
            });
        }
    });
}

function marquerToutLu() {
    $.ajax({
        url: lien + '?but=notification/apresNotification.jsp',
        type: 'POST',
        data: { acte: 'marquer_tout_lu' },
        success: function(response) {
            location.reload();
        }
    });
}

function updateBadge(delta) {
    var badge = $('.content-header .badge');
    if (badge.length) {
        var count = parseInt(badge.text()) + delta;
        if (count <= 0) {
            badge.remove();
        } else {
            badge.text(count + ' non lue' + (count > 1 ? 's' : ''));
        }
    } else if (delta > 0) {
        $('.content-header h1').append(' <span class="badge bg-red">' + delta + ' non lue</span>');
    }
}
</script>

<%
    rs.close();
    ps.close();
    conn.close();
} catch (Exception e) {
    e.printStackTrace();
%>
<div class="alert alert-danger">
    <i class="fa fa-exclamation-triangle"></i> Erreur: <%= e.getMessage() %>
</div>
<% } %>
