<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    if (u == null || lien == null) {
        response.sendRedirect("security-login.jsp");
        return;
    }
    String nomUser = u.getUser().getNomuser() != null ? u.getUser().getNomuser() : "Utilisateur";
%>

<div class="content-wrapper">
    <section class="content-header" style="position: relative;">
        <h1><i class="fa fa-search"></i> Recherche Alumni ITU</h1>
        <p class="text-muted">Recherchez des informations sur les anciens étudiants, leurs parcours, entreprises...</p>
        <a href="<%=lien%>?but=accueil.jsp" class="btn btn-default btn-sm" style="position: absolute; top: 15px; right: 15px; margin: 0;">
            <i class="fa fa-home"></i> Accueil
        </a>
    </section>
    
    <section class="content">
        <div class="chat-container">
            <!-- Zone de messages -->
            <div class="chat-messages" id="chatMessages">
                <div class="message bot-message">
                    <div class="message-avatar">
                        <i class="fa fa-search"></i>
                    </div>
                    <div class="message-content">
                        <p>Bonjour <%= nomUser %> ! 👋</p>
                        <p>Bienvenue dans la recherche Alumni ITU. Posez vos questions en langage naturel pour trouver des informations sur les anciens étudiants.</p>
                        <p><strong>Exemples de recherches :</strong></p>
                        <ul>
                            <li>Qui travaille chez <em>Orange</em> ?</li>
                            <li>Alumni de la promotion <em>2020</em></li>
                            <li>Domaine <em>informatique</em></li>
                            <li>Poste de <em>développeur</em></li>
                            <li>Compétence <em>Java</em></li>
                            <li>Statistiques</li>
                        </ul>
                    </div>
                </div>
            </div>
            
            <!-- Zone de saisie -->
            <div class="chat-input-container">
                <form id="chatForm" onsubmit="sendMessage(event)">
                    <div class="input-group">
                        <input type="text" id="questionInput" class="form-control chat-input" 
                               placeholder="Posez votre question sur les alumni..." autocomplete="off">
                        <span class="input-group-btn">
                            <button type="submit" class="btn btn-primary btn-send" id="sendBtn">
                                <i class="fa fa-paper-plane"></i>
                            </button>
                        </span>
                    </div>
                </form>
                <div class="chat-suggestions">
                    <button class="suggestion-btn" onclick="askQuestion('Qui travaille chez Orange ?')">
                        <i class="fa fa-building"></i> Entreprise
                    </button>
                    <button class="suggestion-btn" onclick="askQuestion('Alumni de la promotion 2020')">
                        <i class="fa fa-graduation-cap"></i> Promotion
                    </button>
                    <button class="suggestion-btn" onclick="askQuestion('Poste de développeur')">
                        <i class="fa fa-code"></i> Poste
                    </button>
                    <button class="suggestion-btn" onclick="askQuestion('Quels alumni travaillent à Antananarivo ?')">
                        <i class="fa fa-map-marker"></i> Ville
                    </button>
                    <button class="suggestion-btn" onclick="askQuestion('Statistiques')">
                        <i class="fa fa-bar-chart"></i> Stats
                    </button>
                </div>
            </div>
        </div>
    </section>
</div>

<style>
.chat-container {
    max-width: 900px;
    margin: 0 auto;
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 2px 20px rgba(0,0,0,0.1);
    display: flex;
    flex-direction: column;
    height: calc(100vh - 200px);
    min-height: 500px;
}

.chat-messages {
    flex: 1;
    overflow-y: auto;
    padding: 20px;
    background: #f8f9fa;
}

.message {
    display: flex;
    gap: 12px;
    margin-bottom: 20px;
    animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}

.message-avatar {
    width: 40px;
    height: 40px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    flex-shrink: 0;
    font-size: 18px;
}

.bot-message .message-avatar {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
}

.user-message .message-avatar {
    background: #0095f6;
    color: white;
}

.user-message {
    flex-direction: row-reverse;
}

.message-content {
    max-width: 75%;
    padding: 12px 16px;
    border-radius: 16px;
    line-height: 1.5;
}

.bot-message .message-content {
    background: white;
    border: 1px solid #e0e0e0;
    border-top-left-radius: 4px;
}

.user-message .message-content {
    background: #0095f6;
    color: white;
    border-top-right-radius: 4px;
}

.message-content p {
    margin: 0 0 8px 0;
}

.message-content p:last-child {
    margin-bottom: 0;
}

.message-content ul {
    margin: 8px 0;
    padding-left: 20px;
}

.message-content li {
    margin: 4px 0;
}

.chat-input-container {
    padding: 16px 20px;
    background: white;
    border-top: 1px solid #e0e0e0;
    border-radius: 0 0 12px 12px;
}

.chat-input {
    border-radius: 25px;
    padding: 12px 20px;
    border: 2px solid #e0e0e0;
    font-size: 15px;
    transition: border-color 0.2s;
}

.chat-input:focus {
    border-color: #0095f6;
    box-shadow: none;
}

.btn-send {
    border-radius: 50%;
    width: 46px;
    height: 46px;
    margin-left: 8px;
}

.chat-suggestions {
    display: flex;
    gap: 8px;
    margin-top: 12px;
    flex-wrap: wrap;
}

.suggestion-btn {
    background: #f0f2f5;
    border: none;
    padding: 8px 14px;
    border-radius: 20px;
    font-size: 13px;
    color: #65676b;
    cursor: pointer;
    transition: all 0.2s;
    display: flex;
    align-items: center;
    gap: 6px;
}

.suggestion-btn:hover {
    background: #e4e6e9;
    color: #050505;
}

.suggestion-btn i {
    font-size: 12px;
}

/* Loading animation */
.typing-indicator {
    display: flex;
    gap: 4px;
    padding: 12px 16px;
}

.typing-indicator span {
    width: 8px;
    height: 8px;
    background: #90949c;
    border-radius: 50%;
    animation: typing 1.4s infinite ease-in-out;
}

.typing-indicator span:nth-child(1) { animation-delay: 0s; }
.typing-indicator span:nth-child(2) { animation-delay: 0.2s; }
.typing-indicator span:nth-child(3) { animation-delay: 0.4s; }

@keyframes typing {
    0%, 60%, 100% { transform: translateY(0); }
    30% { transform: translateY(-8px); }
}

/* Scrollbar styling */
.chat-messages::-webkit-scrollbar {
    width: 6px;
}

.chat-messages::-webkit-scrollbar-track {
    background: transparent;
}

.chat-messages::-webkit-scrollbar-thumb {
    background: #c1c1c1;
    border-radius: 3px;
}

.chat-messages::-webkit-scrollbar-thumb:hover {
    background: #a8a8a8;
}
</style>

<script>
var chatMessages = document.getElementById('chatMessages');
var questionInput = document.getElementById('questionInput');
var sendBtn = document.getElementById('sendBtn');

function scrollToBottom() {
    chatMessages.scrollTop = chatMessages.scrollHeight;
}

function addMessage(content, isUser) {
    var messageDiv = document.createElement('div');
    messageDiv.className = 'message ' + (isUser ? 'user-message' : 'bot-message');
    
    var avatarHtml = isUser 
        ? '<div class="message-avatar"><i class="fa fa-user"></i></div>'
        : '<div class="message-avatar"><i class="fa fa-search"></i></div>';
    
    messageDiv.innerHTML = avatarHtml + '<div class="message-content">' + content + '</div>';
    chatMessages.appendChild(messageDiv);
    scrollToBottom();
}

function addTypingIndicator() {
    var typingDiv = document.createElement('div');
    typingDiv.className = 'message bot-message';
    typingDiv.id = 'typingIndicator';
    typingDiv.innerHTML = 
        '<div class="message-avatar"><i class="fa fa-search"></i></div>' +
        '<div class="message-content">' +
        '<div class="typing-indicator"><span></span><span></span><span></span></div>' +
        '</div>';
    chatMessages.appendChild(typingDiv);
    scrollToBottom();
}

function removeTypingIndicator() {
    var indicator = document.getElementById('typingIndicator');
    if (indicator) indicator.remove();
}

function sendMessage(event) {
    if (event) event.preventDefault();
    
    var question = questionInput.value.trim();
    if (!question) return;
    
    // Afficher le message utilisateur
    addMessage('<p>' + escapeHtml(question) + '</p>', true);
    questionInput.value = '';
    
    // Désactiver le bouton
    sendBtn.disabled = true;
    questionInput.disabled = true;
    
    // Afficher l'indicateur de frappe
    addTypingIndicator();
    
    // Envoyer la requête
    $.ajax({
        url: '<%= request.getContextPath() %>/alumni-chat',
        type: 'POST',
        data: { question: question },
        dataType: 'json',
        success: function(response) {
            removeTypingIndicator();
            sendBtn.disabled = false;
            questionInput.disabled = false;
            questionInput.focus();
            
            if (response.success) {
                addMessage(response.response, false);
            } else {
                addMessage('<p>Désolé, une erreur s\'est produite : ' + escapeHtml(response.error) + '</p>', false);
            }
        },
        error: function(xhr, status, error) {
            removeTypingIndicator();
            sendBtn.disabled = false;
            questionInput.disabled = false;
            questionInput.focus();
            
            addMessage('<p>Erreur de connexion. Veuillez réessayer.</p>', false);
        }
    });
}

function askQuestion(question) {
    questionInput.value = question;
    sendMessage();
}

function escapeHtml(text) {
    var div = document.createElement('div');
    div.textContent = text;
    return div.innerHTML;
}

// Focus sur l'input au chargement
questionInput.focus();

// Envoyer avec Enter
questionInput.addEventListener('keydown', function(e) {
    if (e.key === 'Enter' && !e.shiftKey) {
        e.preventDefault();
        sendMessage();
    }
});
</script>
