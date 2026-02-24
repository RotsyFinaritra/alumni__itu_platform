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
    
    // Exclure l'utilisateur connecté et les admins (rang < 1)
    pr.setAWhere(" AND refuser <> " + currentUser.getUser().getTuppleID());
    
    // Labels des champs de recherche (pas de liste déroulante pour idrole)
    
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
<style>
/* Liste en ligne - chaque utilisateur sur une ligne horizontale */
.moderation-grid {
    display: flex;
    flex-direction: column;
    gap: 15px;
    padding: 20px 0;
}
.user-card {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.08);
    overflow: hidden;
    transition: transform 0.2s, box-shadow 0.2s;
    display: flex;
    flex-direction: row;
    align-items: center;
}
.user-card:hover {
    transform: translateY(-2px);
    box-shadow: 0 8px 25px rgba(0,0,0,0.12);
}
.user-card-header {
    padding: 15px;
    display: flex;
    align-items: center;
    gap: 15px;
    border-right: 1px solid #eee;
    min-width: 300px;
}
.user-photo {
    width: 50px;
    height: 50px;
    border-radius: 50%;
    object-fit: cover;
    background: #e9ecef;
}
.user-info {
    flex: 1;
}
.user-name {
    font-size: 15px;
    font-weight: 600;
    color: #333;
    margin: 0 0 3px 0;
}
.user-email {
    font-size: 12px;
    color: #666;
    margin: 0;
}
.user-card-body {
    padding: 15px;
    display: flex;
    flex: 1;
    align-items: center;
    gap: 20px;
}
.user-meta {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    min-width: 180px;
}
.badge-role {
    padding: 4px 10px;
    border-radius: 15px;
    font-size: 12px;
    font-weight: 500;
}
.badge-admin {
    background: #3c8dbc;
    color: #fff;
}
.badge-user {
    background: #e9ecef;
    color: #333;
}
.badge-statut {
    padding: 4px 10px;
    border-radius: 15px;
    font-size: 12px;
    font-weight: 500;
}
.badge-actif {
    background: #d4edda;
    color: #155724;
}
.badge-banni {
    background: #f8d7da;
    color: #721c24;
}
.badge-suspendu {
    background: #fff3cd;
    color: #856404;
}
.user-details {
    font-size: 12px;
    color: #666;
    flex: 1;
    min-width: 150px;
}
.user-details p {
    margin: 3px 0;
}
.user-actions {
    display: flex;
    flex-wrap: nowrap;
    gap: 8px;
    padding-left: 15px;
    border-left: 1px solid #eee;
}
.btn-action {
    padding: 6px 12px;
    border-radius: 6px;
    font-size: 12px;
    font-weight: 500;
    border: none;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    gap: 5px;
    transition: all 0.2s;
    text-decoration: none;
}
.btn-ban {
    background: #dc3545;
    color: #fff;
}
.btn-ban:hover {
    background: #c82333;
    color: #fff;
}
.btn-unban {
    background: #28a745;
    color: #fff;
}
.btn-unban:hover {
    background: #218838;
    color: #fff;
}
.btn-promote {
    background: #9c27b0;
    color: #fff;
}
.btn-promote:hover {
    background: #7b1fa2;
    color: #fff;
}
.btn-demote {
    background: #6c757d;
    color: #fff;
}
.btn-demote:hover {
    background: #5a6268;
    color: #fff;
}
.btn-view {
    background: #17a2b8;
    color: #fff;
}
.btn-view:hover {
    background: #138496;
    color: #fff;
}
.search-section {
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    margin-bottom: 20px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.results-count {
    color: #666;
    margin-bottom: 15px;
    font-size: 14px;
}

/* Responsive: liste verticale sur petits écrans */
@media (max-width: 900px) {
    .user-card {
        flex-direction: column;
    }
    .user-card-header {
        border-right: none;
        border-bottom: 1px solid #eee;
        min-width: auto;
        width: 100%;
    }
    .user-card-body {
        flex-direction: column;
        align-items: flex-start;
    }
    .user-actions {
        border-left: none;
        border-top: 1px solid #eee;
        padding-left: 0;
        padding-top: 15px;
        flex-wrap: wrap;
    }
}

/* Modal styles */
.modal-overlay {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,0.5);
    z-index: 1000;
    align-items: center;
    justify-content: center;
}
.modal-overlay.active {
    display: flex;
}
.modal-content {
    background: #fff;
    border-radius: 12px;
    padding: 25px;
    max-width: 500px;
    width: 90%;
    max-height: 80vh;
    overflow-y: auto;
}
.modal-header {
    font-size: 18px;
    font-weight: 600;
    margin-bottom: 20px;
    padding-bottom: 15px;
    border-bottom: 1px solid #eee;
}
.modal-body label {
    display: block;
    margin-bottom: 5px;
    font-weight: 500;
}
.modal-body input, .modal-body textarea, .modal-body select {
    width: 100%;
    padding: 10px;
    border: 1px solid #ddd;
    border-radius: 6px;
    margin-bottom: 15px;
}
.modal-body textarea {
    min-height: 100px;
    resize: vertical;
}
.modal-footer {
    display: flex;
    gap: 10px;
    justify-content: flex-end;
    padding-top: 15px;
    border-top: 1px solid #eee;
}
</style>

<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-shield"></i> Modération des utilisateurs</h1>
    </section>
    <section class="content">
        <!-- Section de recherche -->
        <div class="search-section">
            <h4><i class="fa fa-search"></i> Rechercher des utilisateurs</h4>
            <%=pr.getFormu().getHtml()%>
        </div>
    
        <!-- Compteur de résultats -->
        <div class="results-count">
            <strong><%=(resultats != null ? resultats.length : 0)%></strong> utilisateur(s) trouvé(s)
        </div>
    
        <!-- Pagination -->
        <%=pr.getPagination()%>
    
        <!-- Grille d'utilisateurs -->
        <div class="moderation-grid">
        <% 
        if (resultats != null && resultats.length > 0) {
            for (int i = 0; i < resultats.length; i++) {
                UtilisateurModerationLibCPL u = (UtilisateurModerationLibCPL) resultats[i];
                String contextPath = request.getContextPath();
                String photoUrl = (u.getPhoto() != null && !u.getPhoto().isEmpty()) 
                    ? contextPath + "/assets/images/users/" + u.getPhoto() 
                    : contextPath + "/assets/images/users/default-avatar.png";
                String defaultPhoto = contextPath + "/assets/images/users/default-avatar.png";
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
                            <i class="fa fa-check"></i> Débannir
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
                            <i class="fa fa-arrow-down"></i> Rétrograder
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
            <p style="margin-top: 15px;">Aucun utilisateur trouvé</p>
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
