<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*, utilitaire.*, java.sql.*, user.UserEJB, utilisateurAcade.UtilisateurAcade, java.util.*" %>
<%
try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    if (u == null || lien == null) {
        response.sendRedirect("security-login.jsp");
        return;
    }
    
    int refuserInt = u.getUser().getRefuser();
    
    // Charger tous les topics actifs
    Object[] allTopicsResult = CGenUtil.rechercher(new Topic(), null, null, " AND actif = 1 ORDER BY nom");
    
    // Charger les intérêts actuels de l'utilisateur
    Object[] userInteretsResult = CGenUtil.rechercher(new UtilisateurInteret(), null, null, " AND idutilisateur = " + refuserInt);
    Set<String> selectedTopicIds = new HashSet<String>();
    if (userInteretsResult != null) {
        for (Object obj : userInteretsResult) {
            UtilisateurInteret ui = (UtilisateurInteret) obj;
            selectedTopicIds.add(ui.getTopic_id());
        }
    }
%>

<div class="content-wrapper">
    <section class="content">
        <div class="interets-page">
            <div class="interets-container">
                <!-- Header -->
                <div class="interets-page-header">
                    <a href="<%= lien %>?but=profil/mon-profil-saisie.jsp" class="back-link">
                        <i class="fa fa-arrow-left"></i>
                    </a>
                    <div>
                        <h1><i class="fa fa-heart"></i> Mes centres d'int&eacute;r&ecirc;t</h1>
                        <p>Personnalisez votre fil d'actualit&eacute; en s&eacute;lectionnant les sujets qui vous int&eacute;ressent.</p>
                    </div>
                    <a href="<%= lien %>?but=accueil.jsp" class="btn btn-default btn-sm" style="position: absolute; right: 15px; margin: 0;">
                        <i class="fa fa-home"></i> Accueil
                    </a>
                </div>
                
                <!-- Topics Grid -->
                <div class="interets-grid-page">
                    <% if (allTopicsResult != null) {
                        for (Object topicObj : allTopicsResult) {
                            Topic topic = (Topic) topicObj;
                            boolean isSelected = selectedTopicIds.contains(topic.getId());
                    %>
                    <div class="interet-card-page <%= isSelected ? "selected" : "" %>"
                         data-topic-id="<%= topic.getId() %>"
                         onclick="toggleInteretPage(this)"
                         style="--card-color: <%= topic.getCouleur() != null ? topic.getCouleur() : "#6c757d" %>">
                        <div class="interet-icon-page">
                            <i class="fa <%= topic.getIcon() != null ? topic.getIcon() : "fa-tag" %>"></i>
                        </div>
                        <div class="interet-info-page">
                            <span class="interet-nom-page"><%= topic.getNom() %></span>
                            <% if (topic.getDescription() != null && !topic.getDescription().isEmpty()) { %>
                            <span class="interet-desc-page"><%= topic.getDescription() %></span>
                            <% } %>
                        </div>
                        <div class="interet-check-page"><i class="fa fa-check"></i></div>
                    </div>
                    <% }} %>
                </div>
                
                <!-- Footer Actions -->
                <div class="interets-actions-page">
                    <span class="interets-info-page"><span id="selectedCountPage"><%= selectedTopicIds.size() %></span> sujet(s) s&eacute;lectionn&eacute;(s)</span>
                    <button class="btn-save-page" onclick="saveInteretsPage()" id="btnSavePage">
                        <i class="fa fa-save"></i> Enregistrer
                    </button>
                </div>
            </div>
        </div>
    </section>
</div>

<style>
.interets-page {
    max-width: 700px;
    margin: 0 auto;
    padding: 20px;
}
.interets-container {
    background: #fff;
    border-radius: 12px;
    border: 1px solid #dbdbdb;
    overflow: hidden;
}
.interets-page-header {
    padding: 24px 28px;
    border-bottom: 1px solid #f0f0f0;
    display: flex;
    align-items: flex-start;
    gap: 16px;
}
.back-link {
    width: 36px;
    height: 36px;
    display: flex;
    align-items: center;
    justify-content: center;
    border-radius: 50%;
    color: #555;
    text-decoration: none;
    transition: all 0.15s;
    flex-shrink: 0;
    margin-top: 2px;
}
.back-link:hover { background: #f0f0f0; color: #333; text-decoration: none; }
.interets-page-header h1 {
    font-size: 20px;
    color: #1a1a2e;
    margin: 0 0 4px;
    font-weight: 700;
}
.interets-page-header h1 i { color: #e74c3c; margin-right: 6px; }
.interets-page-header p {
    color: #888;
    font-size: 13px;
    margin: 0;
}
.interets-grid-page {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 10px;
    padding: 20px 28px;
}
.interet-card-page {
    display: flex;
    align-items: center;
    gap: 12px;
    padding: 14px 16px;
    border-radius: 10px;
    border: 2px solid #e8e8e8;
    cursor: pointer;
    transition: all 0.2s;
    position: relative;
    background: #fafafa;
}
.interet-card-page:hover {
    border-color: var(--card-color, #6c757d);
    background: color-mix(in srgb, var(--card-color, #6c757d) 5%, white);
    transform: translateY(-1px);
}
.interet-card-page.selected {
    border-color: var(--card-color, #6c757d);
    background: color-mix(in srgb, var(--card-color, #6c757d) 10%, white);
}
.interet-icon-page {
    width: 40px;
    height: 40px;
    border-radius: 10px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 16px;
    color: var(--card-color, #6c757d);
    background: color-mix(in srgb, var(--card-color, #6c757d) 12%, white);
    flex-shrink: 0;
    transition: all 0.2s;
}
.interet-card-page.selected .interet-icon-page {
    background: var(--card-color, #6c757d);
    color: #fff;
}
.interet-info-page {
    flex: 1;
    display: flex;
    flex-direction: column;
    gap: 2px;
}
.interet-nom-page {
    font-size: 13px;
    font-weight: 600;
    color: #333;
}
.interet-desc-page {
    font-size: 11px;
    color: #999;
}
.interet-check-page {
    width: 22px;
    height: 22px;
    border-radius: 50%;
    border: 2px solid #ddd;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 10px;
    color: transparent;
    transition: all 0.2s;
    flex-shrink: 0;
}
.interet-card-page.selected .interet-check-page {
    background: var(--card-color, #6c757d);
    border-color: var(--card-color, #6c757d);
    color: #fff;
}
.interets-actions-page {
    padding: 16px 28px;
    border-top: 1px solid #f0f0f0;
    display: flex;
    align-items: center;
    justify-content: space-between;
    background: #fafafa;
}
.interets-info-page {
    font-size: 12px;
    color: #888;
    font-weight: 500;
}
.btn-save-page {
    padding: 10px 28px;
    border: none;
    border-radius: 8px;
    background: #0095f6;
    color: #fff;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.2s;
}
.btn-save-page:hover { background: #0081d6; }

/* Toast notification */
.toast-notif {
    position: fixed;
    bottom: 24px;
    right: 24px;
    padding: 12px 24px;
    background: #333;
    color: #fff;
    border-radius: 8px;
    font-size: 13px;
    z-index: 9999;
    animation: slideUp 0.3s, fadeOut 0.3s 2.2s forwards;
}
@keyframes slideUp { from { transform: translateY(20px); opacity: 0; } to { transform: translateY(0); opacity: 1; } }
@keyframes fadeOut { to { opacity: 0; transform: translateY(-10px); } }
</style>

<script>
function toggleInteretPage(card) {
    card.classList.toggle('selected');
    var count = document.querySelectorAll('.interet-card-page.selected').length;
    document.getElementById('selectedCountPage').textContent = count;
}

function saveInteretsPage() {
    var selectedCards = document.querySelectorAll('.interet-card-page.selected');
    var topicIds = [];
    selectedCards.forEach(function(card) {
        topicIds.push(card.getAttribute('data-topic-id'));
    });
    
    var xhr = new XMLHttpRequest();
    xhr.open('GET', '<%= lien %>?but=publication/apresInterets.jsp&acte=saveInterets&topics=' + topicIds.join(','), true);
    xhr.onreadystatechange = function() {
        if (xhr.readyState === 4 && xhr.status === 200) {
            // Rediriger vers l'accueil (fil de publications)
            window.location.href = '<%= lien %>?but=accueil.jsp';
        }
    };
    xhr.send();
}
</script>

<%
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
