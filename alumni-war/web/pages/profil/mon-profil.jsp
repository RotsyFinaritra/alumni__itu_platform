<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="utilisateurAcade.UtilisateurPg" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.ClassMAPTable" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="utilitaire.Utilitaire" %>

<!-- TEST: PAGE CHARGÉE -->
<h1 style="color: red; font-size: 48px; text-align: center; padding: 50px;">
    🎉 HELLO WORLD - PAGE PROFIL CHARGÉE ! 🎉
</h1>

<%
    out.println("<p style='color: blue; font-size: 24px; text-align: center;'>TEST: Code Java exécuté !</p>");
    
    UserEJB u = (user.UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    
    out.println("<p style='text-align: center;'>Session u = " + (u != null ? "OK" : "NULL") + "</p>");
    
    // Récupérer les informations de l'utilisateur connecté depuis la session
    MapUtilisateur userSession = u.getUser();
    
    // Récupérer les informations complètes depuis la base
    UtilisateurPg utilisateur = new UtilisateurPg();
    Connection c = null;
    String refuser = String.valueOf(userSession.getRefuser());
    
    try {
        c = new Utilitaire().GetConn();
        utilisateur.setValChamp("refuser", refuser);
        utilisateur.setNomTable("utilisateur");
        UtilisateurPg[] users = (UtilisateurPg[]) ClassMAPTable.getValCriterion(utilisateur, null, c);
        
        if (users != null && users.length > 0) {
            utilisateur = users[0];
        }
    } catch (Exception e) {
        e.printStackTrace();
        out.println("<!-- Erreur: " + e.getMessage() + " -->");
    } finally {
        if (c != null) try { c.close(); } catch (Exception e) {}
    }
    
    // Valeurs par défaut - utiliser les données de session si BDD échoue
    String nom = utilisateur.getNomuser() != null ? utilisateur.getNomuser() : 
                 (userSession.getNomuser() != null ? userSession.getNomuser() : "");
    String prenom = utilisateur.getPrenom() != null ? utilisateur.getPrenom() : "";
    String login = utilisateur.getLoginuser() != null ? utilisateur.getLoginuser() : 
                   (userSession.getLoginuser() != null ? userSession.getLoginuser() : "");
    String email = utilisateur.getMail() != null ? utilisateur.getMail() : "";
    String telephone = utilisateur.getTeluser() != null ? utilisateur.getTeluser() : 
                       (userSession.getTeluser() != null ? userSession.getTeluser() : "");
    String adresse = utilisateur.getAdruser() != null ? utilisateur.getAdruser() : 
                     (userSession.getAdruser() != null ? userSession.getAdruser() : "");
    String etu = utilisateur.getEtu() != null ? utilisateur.getEtu() : "";
    String photo = utilisateur.getPhoto() != null ? utilisateur.getPhoto() : "";
    
    // Photo par défaut si non définie
    if (photo == null || photo.trim().isEmpty()) {
        photo = request.getContextPath() + "/assets/img/default-avatar.png";
    }
%>

<link href="${pageContext.request.contextPath}/assets/css/profil.css" rel="stylesheet" type="text/css" />

<div class="content-wrapper">
    <div class="profil-container">
        <!-- En-tête du profil -->
        <div class="profil-header">
            <div class="profil-header-bg"></div>
            <div class="profil-header-content">
                <div class="profil-avatar-wrapper">
                    <div class="profil-avatar">
                        <img src="<%=photo%>" alt="Photo de profil" id="avatar-img" onerror="this.src='${pageContext.request.contextPath}/assets/img/default-avatar.png'">
                        <label for="upload-photo" class="avatar-edit-btn" title="Changer la photo">
                            <i class="fa fa-camera"></i>
                        </label>
                        <input type="file" id="upload-photo" accept="image/*" style="display: none;" onchange="previewPhoto(this)">
                    </div>
                </div>
                <div class="profil-info">
                    <h1 class="profil-name"><%=nom%> <%=prenom%></h1>
                    <p class="profil-login"><i class="fa fa-user"></i> @<%=login%></p>
                    <%if (!etu.isEmpty()) {%>
                    <p class="profil-etu"><i class="fa fa-id-card"></i> ETU <%=etu%></p>
                    <%}%>
                </div>
            </div>
        </div>

        <!-- Onglets -->
        <div class="profil-tabs">
            <button class="tab-btn active" onclick="switchTab(event, 'infos')">
                <i class="fa fa-info-circle"></i> Informations personnelles
            </button>
            <button class="tab-btn" onclick="switchTab(event, 'securite')">
                <i class="fa fa-lock"></i> Sécurité
            </button>
            <button class="tab-btn" onclick="switchTab(event, 'activite')">
                <i class="fa fa-history"></i> Activité
            </button>
        </div>

        <!-- Contenu des onglets -->
        <div class="profil-content">
            <!-- Onglet Informations personnelles -->
            <div id="infos" class="tab-content active">
                <form action="<%=lien%>?but=apresTarif.jsp" method="post" id="form-profil">
                    <input type="hidden" name="acte" value="update">
                    <input type="hidden" name="bute" value="profil/mon-profil.jsp">
                    <input type="hidden" name="classe" value="utilisateurAcade.UtilisateurPg">
                    <input type="hidden" name="nomtable" value="utilisateur">
                    <input type="hidden" name="refuser" value="<%=refuser%>">
                    
                    <div class="card-section">
                        <div class="section-header">
                            <h2><i class="fa fa-user-circle"></i> Identité</h2>
                            <button type="button" class="btn-edit" onclick="enableEdit()">
                                <i class="fa fa-edit"></i> Modifier
                            </button>
                        </div>
                        
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="nomuser"><i class="fa fa-user"></i> Nom</label>
                                <input type="text" id="nomuser" name="nomuser" value="<%=nom%>" class="form-control" disabled>
                            </div>
                            
                            <div class="form-group">
                                <label for="prenom"><i class="fa fa-user"></i> Prénom</label>
                                <input type="text" id="prenom" name="prenom" value="<%=prenom%>" class="form-control" disabled>
                            </div>
                            
                            <div class="form-group">
                                <label for="etu"><i class="fa fa-id-card"></i> Numéro ETU</label>
                                <input type="text" id="etu" name="etu" value="<%=etu%>" class="form-control" disabled>
                            </div>
                            
                            <div class="form-group">
                                <label for="loginuser"><i class="fa fa-at"></i> Login</label>
                                <input type="text" id="loginuser" name="loginuser" value="<%=login%>" class="form-control" disabled>
                            </div>
                        </div>
                    </div>

                    <div class="card-section">
                        <div class="section-header">
                            <h2><i class="fa fa-envelope"></i> Contact</h2>
                        </div>
                        
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="mail"><i class="fa fa-envelope"></i> Email</label>
                                <input type="email" id="mail" name="mail" value="<%=email%>" class="form-control" disabled>
                            </div>
                            
                            <div class="form-group">
                                <label for="teluser"><i class="fa fa-phone"></i> Téléphone</label>
                                <input type="tel" id="teluser" name="teluser" value="<%=telephone%>" class="form-control" disabled>
                            </div>
                            
                            <div class="form-group full-width">
                                <label for="adruser"><i class="fa fa-map-marker"></i> Adresse</label>
                                <textarea id="adruser" name="adruser" class="form-control" rows="3" disabled><%=adresse%></textarea>
                            </div>
                        </div>
                    </div>

                    <div class="form-actions" id="form-actions" style="display: none;">
                        <button type="button" class="btn btn-secondary" onclick="cancelEdit()">
                            <i class="fa fa-times"></i> Annuler
                        </button>
                        <button type="submit" class="btn btn-primary">
                            <i class="fa fa-save"></i> Enregistrer les modifications
                        </button>
                    </div>
                </form>
            </div>

            <!-- Onglet Sécurité -->
            <div id="securite" class="tab-content">
                <div class="card-section">
                    <div class="section-header">
                        <h2><i class="fa fa-key"></i> Changer le mot de passe</h2>
                    </div>
                    
                    <form action="<%=lien%>?but=profil/change-password.jsp" method="post" id="form-password">
                        <div class="form-grid">
                            <div class="form-group full-width">
                                <label for="old-password"><i class="fa fa-lock"></i> Mot de passe actuel</label>
                                <input type="password" id="old-password" name="old_password" class="form-control" required>
                            </div>
                            
                            <div class="form-group">
                                <label for="new-password"><i class="fa fa-lock"></i> Nouveau mot de passe</label>
                                <input type="password" id="new-password" name="pwduser" class="form-control" required minlength="6">
                                <small class="form-text">Au moins 6 caractères</small>
                            </div>
                            
                            <div class="form-group">
                                <label for="confirm-password"><i class="fa fa-lock"></i> Confirmer le mot de passe</label>
                                <input type="password" id="confirm-password" name="confirm_password" class="form-control" required>
                            </div>
                        </div>
                        
                        <div class="form-actions">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa fa-key"></i> Modifier le mot de passe
                            </button>
                        </div>
                    </form>
                </div>

                <div class="card-section">
                    <div class="section-header">
                        <h2><i class="fa fa-shield"></i> Sécurité du compte</h2>
                    </div>
                    
                    <div class="security-info">
                        <div class="security-item">
                            <div class="security-icon">
                                <i class="fa fa-check-circle" style="color: #28a745;"></i>
                            </div>
                            <div class="security-text">
                                <h4>Compte actif</h4>
                                <p>Votre compte est actif et sécurisé</p>
                            </div>
                        </div>
                        
                        <div class="security-item">
                            <div class="security-icon">
                                <i class="fa fa-clock-o" style="color: #ffc107;"></i>
                            </div>
                            <div class="security-text">
                                <h4>Dernière connexion</h4>
                                <p>Aujourd'hui</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Onglet Activité -->
            <div id="activite" class="tab-content">
                <div class="card-section">
                    <div class="section-header">
                        <h2><i class="fa fa-history"></i> Activités récentes</h2>
                    </div>
                    
                    <div class="activity-timeline">
                        <div class="activity-item">
                            <div class="activity-icon">
                                <i class="fa fa-sign-in"></i>
                            </div>
                            <div class="activity-content">
                                <h4>Connexion au système</h4>
                                <p class="activity-time"><i class="fa fa-clock-o"></i> Aujourd'hui</p>
                            </div>
                        </div>
                        
                        <div class="activity-item">
                            <div class="activity-icon">
                                <i class="fa fa-user-circle"></i>
                            </div>
                            <div class="activity-content">
                                <h4>Mise à jour du profil</h4>
                                <p class="activity-time"><i class="fa fa-clock-o"></i> Il y a 2 jours</p>
                            </div>
                        </div>
                        
                        <div class="activity-item">
                            <div class="activity-icon">
                                <i class="fa fa-key"></i>
                            </div>
                            <div class="activity-content">
                                <h4>Changement de mot de passe</h4>
                                <p class="activity-time"><i class="fa fa-clock-o"></i> Il y a 1 semaine</p>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card-section">
                    <div class="section-header">
                        <h2><i class="fa fa-bar-chart"></i> Statistiques</h2>
                    </div>
                    
                    <div class="stats-grid">
                        <div class="stat-card">
                            <div class="stat-icon">
                                <i class="fa fa-tasks"></i>
                            </div>
                            <div class="stat-info">
                                <h3>24</h3>
                                <p>Tâches complétées</p>
                            </div>
                        </div>
                        
                        <div class="stat-card">
                            <div class="stat-icon">
                                <i class="fa fa-folder"></i>
                            </div>
                            <div class="stat-info">
                                <h3>8</h3>
                                <p>Projets actifs</p>
                            </div>
                        </div>
                        
                        <div class="stat-card">
                            <div class="stat-icon">
                                <i class="fa fa-users"></i>
                            </div>
                            <div class="stat-info">
                                <h3>15</h3>
                                <p>Collaborations</p>
                            </div>
                        </div>
                        
                        <div class="stat-card">
                            <div class="stat-icon">
                                <i class="fa fa-trophy"></i>
                            </div>
                            <div class="stat-info">
                                <h3>92%</h3>
                                <p>Taux de réussite</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
// Gestion des onglets
function switchTab(event, tabId) {
    // Retirer la classe active de tous les boutons et contenus
    const tabBtns = document.querySelectorAll('.tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');
    
    tabBtns.forEach(btn => btn.classList.remove('active'));
    tabContents.forEach(content => content.classList.remove('active'));
    
    // Ajouter la classe active au bouton et contenu cliqués
    event.currentTarget.classList.add('active');
    document.getElementById(tabId).classList.add('active');
}

// Activer le mode édition
function enableEdit() {
    const inputs = document.querySelectorAll('#form-profil input:not([type="hidden"]), #form-profil textarea');
    inputs.forEach(input => {
        input.disabled = false;
        input.classList.add('editable');
    });
    
    document.getElementById('form-actions').style.display = 'flex';
    document.querySelector('.btn-edit').style.display = 'none';
}

// Annuler l'édition
function cancelEdit() {
    location.reload();
}

// Prévisualiser la photo
function previewPhoto(input) {
    if (input.files && input.files[0]) {
        const reader = new FileReader();
        reader.onload = function(e) {
            document.getElementById('avatar-img').src = e.target.result;
        };
        reader.readAsDataURL(input.files[0]);
    }
}

// Validation du formulaire de mot de passe
document.getElementById('form-password')?.addEventListener('submit', function(e) {
    const newPassword = document.getElementById('new-password').value;
    const confirmPassword = document.getElementById('confirm-password').value;
    
    if (newPassword !== confirmPassword) {
        e.preventDefault();
        alert('Les mots de passe ne correspondent pas !');
        return false;
    }
    
    if (newPassword.length < 6) {
        e.preventDefault();
        alert('Le mot de passe doit contenir au moins 6 caractères !');
        return false;
    }
});

// Animation au chargement
document.addEventListener('DOMContentLoaded', function() {
    const cards = document.querySelectorAll('.card-section');
    cards.forEach((card, index) => {
        setTimeout(() => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(20px)';
            setTimeout(() => {
                card.style.transition = 'all 0.5s ease';
                card.style.opacity = '1';
                card.style.transform = 'translateY(0)';
            }, 50);
        }, index * 100);
    });
});
</script>
