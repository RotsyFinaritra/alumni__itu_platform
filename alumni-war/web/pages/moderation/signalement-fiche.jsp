<%@page contentType="text/html;charset=UTF-8" %>
<%@page import="bean.SignalementPublication" %>
<%@page import="bean.SignalementCommentaire" %>
<%@page import="bean.CGenUtil" %>
<%@page import="user.UserEJB" %>
<% try {
    // Vérifier que l'utilisateur est admin ou modérateur
    UserEJB currentUser = (UserEJB) session.getValue("u");
    String role = currentUser != null ? currentUser.getUser().getIdrole() : "";
    if (currentUser == null || (!"admin".equals(role) && !"moderateur".equals(role))) {
        out.println("<div class='alert alert-danger' style='margin:20px;'><i class='fa fa-exclamation-circle'></i> Acc&egrave;s r&eacute;serv&eacute; aux administrateurs et mod&eacute;rateurs.</div>");
        return;
    }
    
    String lien = (String) session.getValue("lien");
    String id = request.getParameter("id");
    String type = request.getParameter("type"); // "publication" ou "commentaire"
    
    // Variables communes
    String signaleurNom = "-";
    String signaleurEmail = "-";
    String motifLibelle = "-";
    String motifCouleur = "#000";
    String motifIcon = "fa-exclamation";
    int motifGravite = 0;
    String statutLibelle = "-";
    String statutCode = "";
    String statutCouleur = "#000";
    String description = "-";
    String moderateurNom = "-";
    String decision = "-";
    String createdAt = "-";
    String traiteAt = "-";
    boolean estTraite = false;
    
    // Variables spécifiques
    String contenuSignale = "-";
    String auteurSignale = "-";
    String dateContenu = "-";
    boolean contenuSupprime = false;
    String targetId = "";
    String commentairePostId = "";
    
    if ("publication".equals(type)) {
        // Charger signalement de publication
        SignalementPublication critere = new SignalementPublication();
        critere.setId(id);
        Object[] results = CGenUtil.rechercher(critere, null, null, "");
        if (results != null && results.length > 0) {
            SignalementPublication sig = (SignalementPublication) results[0];
            signaleurNom = sig.getSignaleur_nom() != null ? sig.getSignaleur_nom() : "-";
            signaleurEmail = sig.getSignaleur_email() != null ? sig.getSignaleur_email() : "-";
            motifLibelle = sig.getMotif_libelle() != null ? sig.getMotif_libelle() : "-";
            motifCouleur = sig.getMotif_couleur() != null ? sig.getMotif_couleur() : "#000";
            motifIcon = sig.getMotif_icon() != null ? sig.getMotif_icon() : "fa-exclamation";
            motifGravite = sig.getMotif_gravite();
            statutLibelle = sig.getStatut_libelle() != null ? sig.getStatut_libelle() : "-";
            statutCode = sig.getStatut_code() != null ? sig.getStatut_code() : "";
            statutCouleur = sig.getStatut_couleur() != null ? sig.getStatut_couleur() : "#000";
            description = sig.getDescription() != null ? sig.getDescription() : "-";
            moderateurNom = sig.getModerateur_nom() != null ? sig.getModerateur_nom() : "-";
            decision = sig.getDecision() != null ? sig.getDecision() : "-";
            createdAt = sig.getCreated_at() != null ? sig.getCreated_at().toString() : "-";
            traiteAt = sig.getTraite_at() != null ? sig.getTraite_at().toString() : "-";
            
            contenuSignale = sig.getPublication_contenu() != null ? sig.getPublication_contenu() : "-";
            auteurSignale = sig.getPublication_auteur() != null ? sig.getPublication_auteur() : "-";
            dateContenu = sig.getPublication_date() != null ? sig.getPublication_date().toString() : "-";
            contenuSupprime = sig.getPublication_supprime() == 1;
            targetId = sig.getPost_id();
        }
    } else {
        // Charger signalement de commentaire
        SignalementCommentaire critere = new SignalementCommentaire();
        critere.setId(id);
        Object[] results = CGenUtil.rechercher(critere, null, null, "");
        if (results != null && results.length > 0) {
            SignalementCommentaire sig = (SignalementCommentaire) results[0];
            signaleurNom = sig.getSignaleur_nom() != null ? sig.getSignaleur_nom() : "-";
            signaleurEmail = sig.getSignaleur_email() != null ? sig.getSignaleur_email() : "-";
            motifLibelle = sig.getMotif_libelle() != null ? sig.getMotif_libelle() : "-";
            motifCouleur = sig.getMotif_couleur() != null ? sig.getMotif_couleur() : "#000";
            motifIcon = sig.getMotif_icon() != null ? sig.getMotif_icon() : "fa-exclamation";
            motifGravite = sig.getMotif_gravite();
            statutLibelle = sig.getStatut_libelle() != null ? sig.getStatut_libelle() : "-";
            statutCode = sig.getStatut_code() != null ? sig.getStatut_code() : "";
            statutCouleur = sig.getStatut_couleur() != null ? sig.getStatut_couleur() : "#000";
            description = sig.getDescription() != null ? sig.getDescription() : "-";
            moderateurNom = sig.getModerateur_nom() != null ? sig.getModerateur_nom() : "-";
            decision = sig.getDecision() != null ? sig.getDecision() : "-";
            createdAt = sig.getCreated_at() != null ? sig.getCreated_at().toString() : "-";
            traiteAt = sig.getTraite_at() != null ? sig.getTraite_at().toString() : "-";
            
            contenuSignale = sig.getCommentaire_contenu() != null ? sig.getCommentaire_contenu() : "-";
            auteurSignale = sig.getCommentaire_auteur() != null ? sig.getCommentaire_auteur() : "-";
            dateContenu = sig.getCommentaire_date() != null ? sig.getCommentaire_date().toString() : "-";
            contenuSupprime = sig.getCommentaire_supprime() == 1;
            targetId = sig.getCommentaire_id();
            commentairePostId = sig.getCommentaire_post_id() != null ? sig.getCommentaire_post_id() : "";
        }
    }
    
    estTraite = "traite".equals(statutCode) || "rejete".equals(statutCode);
    boolean isPublication = "publication".equals(type);
    String tabRetour = isPublication ? "publications" : "commentaires";
%>

<style>
    .signalement-detail {
        background: #fff;
        border-radius: 12px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.08);
        overflow: hidden;
    }
    
    .detail-header {
        background: linear-gradient(135deg, #0095f6 0%, #00759c 100%);
        padding: 30px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        color: #fff;
    }
    
    .detail-header h2 {
        margin: 0;
        font-size: 24px;
        font-weight: 600;
        display: flex;
        align-items: center;
        gap: 12px;
    }
    
    .status-badge {
        padding: 8px 16px;
        border-radius: 20px;
        font-size: 12px;
        font-weight: 700;
        text-transform: uppercase;
        letter-spacing: 1px;
        background: rgba(255,255,255,0.25);
        backdrop-filter: blur(10px);
    }
    
    .detail-body {
        padding: 0;
    }
    
    .detail-section {
        padding: 24px 30px;
        border-bottom: 1px solid #f0f0f0;
    }
    
    .detail-section:last-child {
        border-bottom: none;
    }
    
    .section-title {
        font-size: 14px;
        font-weight: 700;
        color: #8e8e8e;
        text-transform: uppercase;
        letter-spacing: 0.5px;
        margin-bottom: 16px;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    
    .info-grid {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
        gap: 20px;
    }
    
    .info-item {
        display: flex;
        flex-direction: column;
        gap: 6px;
    }
    
    .info-label {
        font-size: 12px;
        font-weight: 600;
        color: #8e8e8e;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .info-value {
        font-size: 15px;
        color: #262626;
        font-weight: 500;
    }
    
    .motif-display {
        display: inline-flex;
        align-items: center;
        gap: 10px;
        padding: 10px 16px;
        background: #f8f9fa;
        border-radius: 8px;
        border-left: 4px solid;
    }
    
    .motif-icon {
        font-size: 18px;
    }
    
    .gravite-badge {
        padding: 4px 10px;
        border-radius: 12px;
        font-size: 10px;
        font-weight: 700;
        background: #ed4956;
        color: #fff;
        text-transform: uppercase;
        letter-spacing: 0.5px;
    }
    
    .content-box {
        background: #f8f9fc;
        border: 1px solid #e9ecef;
        border-radius: 8px;
        padding: 20px;
        margin-top: 12px;
    }
    
    .content-meta {
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
        gap: 16px;
        margin-bottom: 16px;
        padding-bottom: 16px;
        border-bottom: 1px solid #e0e0e0;
    }
    
    .content-text {
        background: #fff;
        padding: 16px;
        border-radius: 6px;
        max-height: 250px;
        overflow-y: auto;
        color: #262626;
        font-size: 14px;
        line-height: 1.6;
        border-left: 3px solid #0095f6;
    }
    
    .content-deleted {
        border-left-color: #ed4956;
        background: #fff5f5;
    }
    
    .action-bar {
        display: flex;
        gap: 12px;
        align-items: center;
        flex-wrap: wrap;
    }
    
    .btn-modern {
        padding: 11px 24px;
        border-radius: 8px;
        font-weight: 600;
        font-size: 14px;
        border: none;
        cursor: pointer;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 8px;
        transition: all 0.2s;
    }
    
    .btn-primary-modern {
        background: #0095f6;
        color: #fff;
    }
    
    .btn-primary-modern:hover {
        background: #0086e0;
        color: #fff;
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(0,149,246,0.25);
    }
    
    .btn-danger-modern {
        background: #ed4956;
        color: #fff;
    }
    
    .btn-danger-modern:hover {
        background: #d63447;
        color: #fff;
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(237,73,86,0.25);
    }
    
    .btn-outline-modern {
        background: transparent;
        color: #262626;
        border: 2px solid #e0e0e0;
    }
    
    .btn-outline-modern:hover {
        background: #f8f9fa;
        color: #262626;
        border-color: #bbb;
        text-decoration: none;
    }
    
    .treated-notice {
        display: inline-flex;
        align-items: center;
        gap: 8px;
        padding: 12px 20px;
        background: #d4edda;
        color: #155724;
        border-radius: 8px;
        font-weight: 600;
        font-size: 14px;
    }
    
    @media (max-width: 768px) {
        .detail-header {
            flex-direction: column;
            gap: 12px;
            align-items: flex-start;
            padding: 20px;
        }
        
        .detail-section {
            padding: 20px;
        }
        
        .info-grid {
            grid-template-columns: 1fr;
        }
        
        .content-meta {
            grid-template-columns: 1fr;
        }
        
        .action-bar {
            flex-direction: column;
            width: 100%;
        }
        
        .btn-modern {
            width: 100%;
            justify-content: center;
        }
    }
</style>

<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-flag"></i> D&eacute;tail du Signalement</h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=moderation/moderation-liste.jsp"><i class="fa fa-shield"></i> Mod&eacute;ration</a></li>
            <li><a href="<%=lien%>?but=moderation/signalement-liste.jsp&tab=<%=tabRetour%>"><i class="fa fa-flag"></i> Signalements</a></li>
            <li class="active">D&eacute;tail</li>
        </ol>
    </section>
    
    <section class="content" style="background: #fafafa; min-height: 500px;">
        <div class="signalement-detail">
            <!-- En-tête avec gradient -->
            <div class="detail-header">
                <h2>
                    <i class="fa fa-flag"></i>
                    Signalement #<%= id %>
                </h2>
                <% if (estTraite) { %>
                    <span class="status-badge">✓ Trait&eacute;</span>
                <% } else { %>
                    <span class="status-badge">⏳ En attente</span>
                <% } %>
            </div>
            
            <div class="detail-body">
                <!-- Informations du signalement -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="fa fa-info-circle"></i>
                        Informations du signalement
                    </div>
                    
                    <div class="info-grid">
                        <div class="info-item">
                            <div class="info-label">Date du signalement</div>
                            <div class="info-value"><%= createdAt %></div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-label">Statut actuel</div>
                            <div class="info-value">
                                <span style="color:<%= statutCouleur %>; font-weight: 700;"><%= statutLibelle %></span>
                            </div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-label">Signal&eacute; par</div>
                            <div class="info-value"><%= signaleurNom %></div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-label">Email du signaleur</div>
                            <div class="info-value"><%= signaleurEmail %></div>
                        </div>
                    </div>
                    <div class="box-body">
                        <table class="table table-bordered">
                            <tr><th width="35%">Date signalement</th><td><%= createdAt %></td></tr>
                            <tr><th>Signal&eacute; par</th><td><%= signaleurNom %></td></tr>
                            <tr><th>Email signaleur</th><td><%= signaleurEmail %></td></tr>
                            <tr>
                                <th>Motif</th>
                                <td>
                                    <span style="color:<%= motifCouleur %>">
                                        <i class="fa <%= motifIcon %>"></i>
                                        <%= motifLibelle %>
                                    </span>
                                </td>
                            </tr>
                            <tr><th>Statut</th><td><span style="color:<%= statutCouleur %>"><%= statutLibelle %></span></td></tr>
                            <tr><th>Description</th><td><%= description %></td></tr>
                            <% if (estTraite) { %>
                            <tr><th>Trait&eacute; par</th><td><%= moderateurNom %></td></tr>
                            <tr><th>Trait&eacute; le</th><td><%= traiteAt %></td></tr>
                            <tr><th>D&eacute;cision</th><td><%= decision %></td></tr>
                    
                    <div style="margin-top: 20px;">
                        <div class="info-label" style="margin-bottom: 8px;">Motif du signalement</div>
                        <div class="motif-display" style="border-left-color:<%= motifCouleur %>">
                            <i class="fa <%= motifIcon %> motif-icon" style="color:<%= motifCouleur %>"></i>
                            <span style="color:#262626; font-weight: 600;"><%= motifLibelle %></span>
                            <% if (motifGravite > 0) { %>
                                <span class="gravite-badge">Niveau <%= motifGravite %></span>
                            <% } %>
                        </div>
                    </div>
                    
                    <% if (description != null && !description.trim().isEmpty()) { %>
                    <div style="margin-top: 20px;">
                        <div class="info-label" style="margin-bottom: 8px;">Description</div>
                        <div class="info-value" style="line-height: 1.6;"><%= description %></div>
                    </div>
                    <% } %>
                </div>
                
                <!-- Contenu signalé -->
                <div class="detail-section" style="background: #fcfcfc;">
                    <div class="section-title">
                        <i class="fa <%= isPublication ? "fa-file-text" : "fa-comment" %>"></i>
                        <%= isPublication ? "Publication" : "Commentaire" %> signal&eacute;<%= isPublication ? "e" : "" %>
                        <% if (contenuSupprime) { %>
                            <span class="gravite-badge" style="margin-left: 10px;">Supprim&eacute;</span>
                        <% } %>
                    </div>
                    
                    <div class="content-box">
                        <div class="content-meta">
                            <div class="info-item">
                                <div class="info-label">ID <%= isPublication ? "Publication" : "Commentaire" %></div>
                                <div class="info-value"><%= targetId %></div>
                            </div>
                            
                            <% if (!isPublication && !commentairePostId.isEmpty()) { %>
                            <div class="info-item">
                                <div class="info-label">ID Publication li&eacute;e</div>
                                <div class="info-value"><%= commentairePostId %></div>
                            </div>
                            <% } %>
                            
                            <div class="info-item">
                                <div class="info-label">Date de publication</div>
                                <div class="info-value"><%= dateContenu %></div>
                            </div>
                            
                            <div class="info-item">
                                <div class="info-label">Auteur</div>
                                <div class="info-value"><%= auteurSignale %></div>
                            </div>
                        </div>
                        
                        <div class="info-label" style="margin-bottom: 8px;">Contenu</div>
                        <div class="content-text <%= contenuSupprime ? "content-deleted" : "" %>">
                            <%= contenuSignale %>
                        </div>
                    </div>
                </div>
                
                <!-- Historique modération (si traité) -->
                <% if (estTraite) { %>
                <div class="detail-section">
                    <div class="section-title">
                        <i class="fa fa-history"></i>
                        Historique de mod&eacute;ration
                    </div>
                    
                    <div class="info-grid">
                        <div class="info-item">
                            <div class="info-label">Mod&eacute;rateur</div>
                            <div class="info-value"><%= moderateurNom %></div>
                        </div>
                        
                        <div class="info-item">
                            <div class="info-label">Date de traitement</div>
                            <div class="info-value"><%= traiteAt %></div>
                        </div>
                        
                        <div class="info-item" style="grid-column: 1 / -1;">
                            <div class="info-label">D&eacute;cision</div>
                            <div class="info-value"><%= decision %></div>
                        </div>
                    </div>
                </div>
                <% } %>
                
                <!-- Actions de modération -->
                <div class="detail-section">
                    <div class="section-title">
                        <i class="fa fa-gavel"></i>
                        Actions de mod&eacute;ration
                    </div>
                    
                    <div class="action-bar">
                        <a href="<%=lien%>?but=moderation/signalement-liste.jsp&tab=<%=tabRetour%>" class="btn-modern btn-outline-modern">
                            <i class="fa fa-arrow-left"></i>
                            Retour
                        </a>
                        
                        <% if (!estTraite) { %>
                            <% if (!contenuSupprime) { %>
                            <a href="<%=lien%>?but=moderation/signalement-action.jsp&action=<%= isPublication ? "supprimer_publication" : "supprimer_commentaire" %>&id=<%=id%>&<%= isPublication ? "post_id" : "commentaire_id" %>=<%=targetId%>&bute=moderation/signalement-fiche.jsp%26id=<%=id%>%26type=<%=type%>" 
                               class="btn-modern btn-danger-modern"
                               onclick="return confirm('&Ecirc;tes-vous s&ucirc;r de vouloir supprimer <%= isPublication ? "cette publication" : "ce commentaire" %> ?');">
                                <i class="fa fa-trash"></i>
                                Supprimer le contenu
                            </a>
                            <% } %>
                            
                            <a href="<%=lien%>?but=moderation/signalement-action.jsp&action=rejeter&id=<%=id%>&bute=moderation/signalement-fiche.jsp%26id=<%=id%>%26type=<%=type%>" 
                               class="btn-modern btn-outline-modern"
                               onclick="return confirm('Rejeter ce signalement ? Le contenu restera visible.');">
                                <i class="fa fa-times"></i>
                                Rejeter le signalement
                            </a>
                        <% } else { %>
                            <div class="treated-notice">
                                <i class="fa fa-check-circle"></i>
                                Ce signalement a d&eacute;j&agrave; &eacute;t&eacute; trait&eacute;
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>
<% } catch (Exception e) {
    e.printStackTrace();
%>
<div class="alert alert-danger" style="margin:20px;">
    <i class="fa fa-exclamation-circle"></i> Erreur: <%=e.getMessage()%>
</div>
<% } %>
