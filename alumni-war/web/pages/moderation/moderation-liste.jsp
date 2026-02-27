<%@page import="affichage.PageRecherche"%>
<%@page import="affichage.Liste"%>
<%@page import="moderation.UtilisateurModerationLibCPL"%>
<%@page import="bean.CGenUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% 
try {
    // Vérifier que l'utilisateur est admin (idrole='admin')
    user.UserEJB currentUser = (user.UserEJB) session.getValue("u");
    if (currentUser == null || !"admin".equals(currentUser.getUser().getIdrole())) {
        out.println("<div class='alert alert-danger'>Accès réservé aux administrateurs.</div>");
        return;
    }
    
    // Afficher les messages de confirmation
    String message = (String) session.getAttribute("moderationMessage");
    String alertType = (String) session.getAttribute("moderationAlertType");
    if (message != null) {
        session.removeAttribute("moderationMessage");
        session.removeAttribute("moderationAlertType");
        out.println("<div class='alert alert-" + (alertType != null ? alertType : "info") + "' style='margin-bottom:20px;'>" + message + "</div>");
    }
    
    UtilisateurModerationLibCPL filtre = new UtilisateurModerationLibCPL();
    
    // Récupérer le filtre de statut depuis l'URL
    String statutFilter = request.getParameter("statutFilter");
    if (statutFilter == null) statutFilter = "tous";
    
    // Champs de critères
    String listeCrt[] = {"nomuser", "prenom", "mail", "idrole", "statut"};
    String listeInt[] = {};
    // Colonnes affichées
    String libEntete[] = {"photo", "nomuser", "prenom", "mail", "role_libelle", "statut", "dernier_motif", "date_expiration"};
    
    PageRecherche pr = new PageRecherche(filtre, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Modération des utilisateurs");
    pr.setUtilisateur(currentUser);
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("moderation/moderation-liste.jsp");
    pr.setNpp(20);
    
    // Construire le WHERE clause selon le filtre
    String whereClause = " AND refuser <> " + currentUser.getUser().getTuppleID();
    if ("banni".equals(statutFilter)) {
        whereClause += " AND statut = 'banni'";
    } else if ("actif".equals(statutFilter)) {
        whereClause += " AND (statut IS NULL OR statut = 'actif')";
    }
    // "tous" n'ajoute pas de filtre supplémentaire
    pr.setAWhere(whereClause);
    
    // Labels des champs de recherche
    pr.getFormu().getChamp("nomuser").setLibelle("Nom");
    pr.getFormu().getChamp("prenom").setLibelle("Pr&eacute;nom");
    pr.getFormu().getChamp("mail").setLibelle("Email");
    pr.getFormu().getChamp("idrole").setLibelle("R&ocirc;le");
    pr.getFormu().getChamp("statut").setLibelle("Statut");
    
    String[] colSomme = null;
    pr.creerObjetPage(libEntete, colSomme);
    
    // Récupérer les résultats
    Object[] resultats = pr.getListe();
    String lien = (String) session.getValue("lien");
%>
<link href="${pageContext.request.contextPath}/assets/css/moderation-liste.css" rel="stylesheet" type="text/css" />

<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-shield"></i> Mod&eacute;ration des utilisateurs</h1>
    </section>
    <section class="content">
        <!-- Onglets de filtrage par statut -->
        <div class="filter-tabs" style="margin-bottom: 20px;">
            <a href="<%=lien%>?but=moderation/moderation-liste.jsp&statutFilter=tous" 
               class="btn <%= "tous".equals(statutFilter) ? "btn-primary" : "btn-default" %>">
                <i class="fa fa-users"></i> Tous
            </a>
            <a href="<%=lien%>?but=moderation/moderation-liste.jsp&statutFilter=actif" 
               class="btn <%= "actif".equals(statutFilter) ? "btn-success" : "btn-default" %>">
                <i class="fa fa-check-circle"></i> Actifs
            </a>
            <a href="<%=lien%>?but=moderation/moderation-liste.jsp&statutFilter=banni" 
               class="btn <%= "banni".equals(statutFilter) ? "btn-danger" : "btn-default" %>">
                <i class="fa fa-ban"></i> Bannis
            </a>
        </div>
        
        <!-- Section de recherche APJ -->
        <div class="search-section">
            <h4><i class="fa fa-search"></i> Rechercher des utilisateurs</h4>
            <form action="<%=pr.getLien()%>?but=moderation/moderation-liste.jsp" method="post">
                <%=pr.getFormu().getHtmlEnsemble()%>
            </form>
        </div>
    
        <!-- Compteur de résultats -->
        <div class="results-count">
            <strong><%=(resultats != null ? resultats.length : 0)%></strong> utilisateur(s) trouv&eacute;(s)
        </div>
    
        <!-- Pagination APJ -->
        <%=pr.getPagination()%>
    
        <!-- Grille d'utilisateurs (rendu custom cards) -->
        <div class="moderation-grid">
        <% 
        if (resultats != null && resultats.length > 0) {
            for (int i = 0; i < resultats.length; i++) {
                UtilisateurModerationLibCPL u = (UtilisateurModerationLibCPL) resultats[i];
                String contextPath = request.getContextPath();
                String photoUrl = (u.getPhoto() != null && !u.getPhoto().isEmpty()) 
                    ? contextPath + "/profile-photo?file=" + u.getPhoto() 
                    : contextPath + "/assets/img/user-placeholder.svg";
                String defaultPhoto = contextPath + "/assets/img/user-placeholder.svg";
                String statut = (u.getStatut() != null) ? u.getStatut() : "actif";
                String badgeStatut = "badge-actif";
                if ("banni".equalsIgnoreCase(statut)) badgeStatut = "badge-banni";
                else if ("suspendu".equalsIgnoreCase(statut)) badgeStatut = "badge-suspendu";
                
                String badgeRole = "badge-user";
                if (u.getRole_rang() == 1) badgeRole = "badge-admin";
                
                boolean estBanni = "banni".equalsIgnoreCase(statut);
                boolean estAdmin = (u.getRole_rang() == 1);
        %>
        <div class="user-card" data-refuser="<%=u.getRefuser()%>">
            <div class="user-card-header">
                <img src="<%=photoUrl%>" alt="Photo" class="user-photo" onerror="this.onerror=null; this.src='<%=defaultPhoto%>';">
                <div class="user-info">
                    <h5 class="user-name"><%=u.getNomuser()%> <%=u.getPrenom()%></h5>
                    <p class="user-email"><%=u.getMail()%></p>
                </div>
            </div>
            <div class="user-card-body">
                <div class="user-meta">
                    <span class="badge-role <%=badgeRole%>"><%=u.getRole_libelle()%></span>
                    <span class="badge-statut <%=badgeStatut%>"><%=statut%></span>
                </div>
                
                <% if (u.getDernier_motif() != null && !u.getDernier_motif().isEmpty()) { %>
                <div class="user-details">
                    <p><strong>Motif:</strong> <%=u.getDernier_motif()%></p>
                    <% if (u.getDate_expiration() != null && !u.getDate_expiration().isEmpty()) { %>
                    <p><strong>Expiration:</strong> <%=u.getDate_expiration()%></p>
                    <% } %>
                </div>
                <% } %>
                
                <div class="user-actions">
                    <!-- Voir profil -->
                    <a href="<%=lien%>?but=profil/mon-profil.jsp&refuser=<%=u.getRefuser()%>" class="btn-action btn-view">
                        <i class="fa fa-eye"></i> Voir
                    </a>
                    
                    <% if (!estBanni) { %>
                    <!-- Bannir -->
                    <button class="btn-action btn-ban" onclick="openBanModal(<%=u.getRefuser()%>, '<%=u.getNomuser()%> <%=u.getPrenom()%>')">
                        <i class="fa fa-ban"></i> Bannir
                    </button>
                    <% } else { %>
                    <!-- Débannir -->
                    <form action="<%=request.getContextPath()%>/pages/moderation/moderation-action.jsp" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="unban">
                        <input type="hidden" name="refuser" value="<%=u.getRefuser()%>">
                        <button type="submit" class="btn-action btn-unban">
                            <i class="fa fa-check"></i> D&eacute;bannir
                        </button>
                    </form>
                    <% } %>
                    
                    <% if (!estAdmin) { %>
                    <!-- Promouvoir admin -->
                    <form action="<%=request.getContextPath()%>/pages/moderation/moderation-action.jsp" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="promote">
                        <input type="hidden" name="refuser" value="<%=u.getRefuser()%>">
                        <button type="submit" class="btn-action btn-promote">
                            <i class="fa fa-arrow-up"></i> Promouvoir
                        </button>
                    </form>
                    <% } else if (u.getRole_rang() == 1 && "admin".equals(currentUser.getUser().getIdrole())) { %>
                    <!-- Rétrograder (seulement admin peut rétrograder un admin) -->
                    <form action="<%=request.getContextPath()%>/pages/moderation/moderation-action.jsp" method="post" style="display:inline;">
                        <input type="hidden" name="action" value="demote">
                        <input type="hidden" name="refuser" value="<%=u.getRefuser()%>">
                        <button type="submit" class="btn-action btn-demote">
                            <i class="fa fa-arrow-down"></i> R&eacute;trograder
                        </button>
                    </form>
                    <% } %>
                </div>
            </div>
        </div>
        <% 
            }
        } else { 
        %>
        <div style="grid-column: 1/-1; text-align: center; padding: 40px; color: #666;">
            <i class="fa fa-users" style="font-size: 48px; color: #ddd;"></i>
            <p style="margin-top: 15px;">Aucun utilisateur trouv&eacute;</p>
        </div>
        <% } %>
    </div>
    
        <!-- Pagination bas -->
        <%=pr.getPagination()%>
    </section>
</div>

<!-- Modal Bannissement -->
<div id="banModal" class="modal-overlay">
    <div class="modal-content">
        <div class="modal-header">
            <i class="fa fa-ban" style="color:#dc3545;"></i> Bannir l'utilisateur
        </div>
        <form action="<%=request.getContextPath()%>/pages/moderation/moderation-action.jsp" method="post">
            <input type="hidden" name="action" value="ban">
            <input type="hidden" name="refuser" id="banRefuser">
            <div class="modal-body">
                <p id="banUserName" style="font-weight: 500; margin-bottom: 15px;"></p>
                
                <label for="banType">Type de bannissement</label>
                <select name="type" id="banType" onchange="toggleExpirationField()">
                    <option value="permanent">Permanent</option>
                    <option value="temporaire">Temporaire</option>
                </select>
                
                <div id="expirationField" style="display:none;">
                    <label for="dateExpiration">Date d'expiration</label>
                    <input type="date" name="dateExpiration" id="dateExpiration">
                </div>
                
                <label for="motif">Motif du bannissement *</label>
                <textarea name="motif" id="motif" required placeholder="Expliquez la raison du bannissement..."></textarea>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn-action" style="background:#e9ecef;color:#333;" onclick="closeBanModal()">Annuler</button>
                <button type="submit" class="btn-action btn-ban">Confirmer le bannissement</button>
            </div>
        </form>
    </div>
</div>

<script>
function openBanModal(refuser, userName) {
    document.getElementById('banRefuser').value = refuser;
    document.getElementById('banUserName').textContent = userName;
    document.getElementById('banModal').classList.add('active');
}

function closeBanModal() {
    document.getElementById('banModal').classList.remove('active');
    document.getElementById('motif').value = '';
    document.getElementById('banType').value = 'permanent';
    document.getElementById('expirationField').style.display = 'none';
}

function toggleExpirationField() {
    var type = document.getElementById('banType').value;
    document.getElementById('expirationField').style.display = (type === 'temporaire') ? 'block' : 'none';
}

// Fermer le modal en cliquant à l'extérieur
document.getElementById('banModal').addEventListener('click', function(e) {
    if (e.target === this) closeBanModal();
});
</script>

<% 
} catch(Exception e) {
    out.println("<div class='alert alert-danger'>");
    out.println("<strong>Erreur:</strong> " + e.getMessage());
    out.println("</div>");
    e.printStackTrace();
}
%>
