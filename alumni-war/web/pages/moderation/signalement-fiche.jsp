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
    .fiche-card {
        background: #fff;
        border-radius: 8px;
        box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        margin-bottom: 20px;
    }
    
    .fiche-card-header {
        padding: 15px 20px;
        border-bottom: 1px solid #eee;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    
    .fiche-card-header h3 {
        margin: 0;
        font-size: 16px;
        font-weight: 600;
        color: #333;
    }
    
    .fiche-card-body {
        padding: 20px;
    }
    
    .status-pill {
        padding: 5px 12px;
        border-radius: 15px;
        font-size: 12px;
        font-weight: 600;
    }
    
    .status-pending { background: #fff3cd; color: #856404; }
    .status-done { background: #d4edda; color: #155724; }
    .status-deleted { background: #f8d7da; color: #721c24; }
    
    .info-row {
        display: flex;
        padding: 10px 0;
        border-bottom: 1px solid #f5f5f5;
    }
    
    .info-row:last-child { border-bottom: none; }
    
    .info-row .label {
        width: 140px;
        font-size: 13px;
        color: #666;
        flex-shrink: 0;
    }
    
    .info-row .value {
        font-size: 14px;
        color: #333;
        flex: 1;
    }
    
    .motif-tag {
        display: inline-flex;
        align-items: center;
        gap: 6px;
        padding: 6px 12px;
        background: #f8f9fa;
        border-radius: 4px;
        font-weight: 500;
    }
    
    .content-preview {
        background: #f8f9fa;
        border-radius: 6px;
        padding: 15px;
        font-size: 14px;
        line-height: 1.6;
        max-height: 200px;
        overflow-y: auto;
    }
    
    .content-preview.deleted {
        background: #fff5f5;
        border-left: 3px solid #dc3545;
    }
    
    .action-buttons {
        display: flex;
        gap: 10px;
        flex-wrap: wrap;
    }
    
    .btn-action {
        padding: 10px 20px;
        border-radius: 6px;
        font-weight: 500;
        font-size: 14px;
        text-decoration: none;
        display: inline-flex;
        align-items: center;
        gap: 6px;
        border: none;
        cursor: pointer;
    }
    
    .btn-back { background: #f0f0f0; color: #333; }
    .btn-back:hover { background: #e0e0e0; color: #333; text-decoration: none; }
    
    .btn-delete { background: #dc3545; color: #fff; }
    .btn-delete:hover { background: #c82333; color: #fff; text-decoration: none; }
    
    .btn-reject { background: #6c757d; color: #fff; }
    .btn-reject:hover { background: #5a6268; color: #fff; text-decoration: none; }
</style>

<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-flag"></i> Signalement #<%= id %></h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=moderation/moderation-liste.jsp"><i class="fa fa-shield"></i> Mod&eacute;ration</a></li>
            <li><a href="<%=lien%>?but=moderation/signalement-liste.jsp&tab=<%=tabRetour%>"><i class="fa fa-flag"></i> Signalements</a></li>
            <li class="active">D&eacute;tail</li>
        </ol>
    </section>
    
    <section class="content">
        <div class="row">
        <div class="col-md-8 col-md-offset-2">
            
            <!-- Carte: Informations générales -->
            <div class="fiche-card">
                <div class="fiche-card-header">
                    <h3><i class="fa fa-info-circle"></i> Informations</h3>
                    <% if (estTraite) { %>
                        <span class="status-pill status-done"><i class="fa fa-check"></i> Trait&eacute;</span>
                    <% } else { %>
                        <span class="status-pill status-pending"><i class="fa fa-clock-o"></i> En attente</span>
                    <% } %>
                </div>
                <div class="fiche-card-body">
                    <div class="info-row">
                        <span class="label">Date</span>
                        <span class="value"><%= createdAt %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">Signal&eacute; par</span>
                        <span class="value"><%= signaleurNom %> (<%= signaleurEmail %>)</span>
                    </div>
                    <div class="info-row">
                        <span class="label">Motif</span>
                        <span class="value">
                            <span class="motif-tag" style="border-left: 3px solid <%= motifCouleur %>;">
                                <i class="fa <%= motifIcon %>" style="color:<%= motifCouleur %>"></i>
                                <%= motifLibelle %>
                            </span>
                        </span>
                    </div>
                    <% if (description != null && !"-".equals(description) && !description.trim().isEmpty()) { %>
                    <div class="info-row">
                        <span class="label">Description</span>
                        <span class="value"><%= description %></span>
                    </div>
                    <% } %>
                </div>
            </div>
            
            <!-- Carte: Contenu signalé -->
            <div class="fiche-card">
                <div class="fiche-card-header">
                    <h3><i class="fa <%= isPublication ? "fa-file-text" : "fa-comment" %>"></i> <%= isPublication ? "Publication" : "Commentaire" %> signal&eacute;<%= isPublication ? "e" : "" %></h3>
                    <% if (contenuSupprime) { %>
                        <span class="status-pill status-deleted"><i class="fa fa-trash"></i> Supprim&eacute;</span>
                    <% } %>
                </div>
                <div class="fiche-card-body">
                    <div class="info-row">
                        <span class="label">Auteur</span>
                        <span class="value"><%= auteurSignale %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">Date</span>
                        <span class="value"><%= dateContenu %></span>
                    </div>
                    <div style="margin-top: 15px;">
                        <div class="content-preview <%= contenuSupprime ? "deleted" : "" %>">
                            <%= contenuSignale %>
                        </div>
                    </div>
                </div>
            </div>
            
            <% if (estTraite) { %>
            <!-- Carte: Décision -->
            <div class="fiche-card">
                <div class="fiche-card-header">
                    <h3><i class="fa fa-gavel"></i> D&eacute;cision</h3>
                </div>
                <div class="fiche-card-body">
                    <div class="info-row">
                        <span class="label">Mod&eacute;rateur</span>
                        <span class="value"><%= moderateurNom %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">Date</span>
                        <span class="value"><%= traiteAt %></span>
                    </div>
                    <div class="info-row">
                        <span class="label">D&eacute;cision</span>
                        <span class="value"><%= decision %></span>
                    </div>
                </div>
            </div>
            <% } %>
            
            <!-- Carte: Actions -->
            <div class="fiche-card">
                <div class="fiche-card-body">
                    <div class="action-buttons">
                        <a href="<%=lien%>?but=moderation/signalement-liste.jsp&tab=<%=tabRetour%>" class="btn-action btn-back">
                            <i class="fa fa-arrow-left"></i> Retour
                        </a>
                        
                        <% if (!estTraite) { %>
                            <% if (!contenuSupprime) { %>
                            <a href="<%=lien%>?but=moderation/signalement-action.jsp&action=<%= isPublication ? "supprimer_publication" : "supprimer_commentaire" %>&id=<%=id%>&<%= isPublication ? "post_id" : "commentaire_id" %>=<%=targetId%>&bute=moderation/signalement-fiche.jsp%26id=<%=id%>%26type=<%=type%>" 
                               class="btn-action btn-delete"
                               onclick="return confirm('Supprimer <%= isPublication ? "cette publication" : "ce commentaire" %> ?');">
                                <i class="fa fa-trash"></i> Supprimer le contenu
                            </a>
                            <% } %>
                            
                            <a href="<%=lien%>?but=moderation/signalement-action.jsp&action=rejeter&id=<%=id%>&bute=moderation/signalement-fiche.jsp%26id=<%=id%>%26type=<%=type%>" 
                               class="btn-action btn-reject"
                               onclick="return confirm('Rejeter ce signalement ?');">
                                <i class="fa fa-times"></i> Rejeter
                            </a>
                        <% } %>
                    </div>
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
