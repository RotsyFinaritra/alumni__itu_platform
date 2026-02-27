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
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-flag"></i> D&eacute;tail du Signalement</h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=moderation/moderation-liste.jsp"><i class="fa fa-shield"></i> Mod&eacute;ration</a></li>
            <li><a href="<%=lien%>?but=moderation/signalement-liste.jsp&tab=<%=tabRetour%>"><i class="fa fa-flag"></i> Signalements</a></li>
            <li class="active">D&eacute;tail</li>
        </ol>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-6">
                <!-- Carte signalement -->
                <div class="box box-warning">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa fa-flag"></i> Signalement #<%= id %></h3>
                        <% if (estTraite) { %>
                        <span class="label label-success pull-right">TRAIT&Eacute;</span>
                        <% } else { %>
                        <span class="label label-warning pull-right">EN ATTENTE</span>
                        <% } %>
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
                            <% } %>
                        </table>
                    </div>
                </div>
            </div>
            
            <div class="col-md-6">
                <!-- Carte contenu signalé -->
                <div class="box <%= contenuSupprime ? "box-danger" : "box-primary" %>">
                    <div class="box-header with-border">
                        <h3 class="box-title">
                            <i class="fa <%= isPublication ? "fa-file-text" : "fa-comment" %>"></i> 
                            <%= isPublication ? "Publication" : "Commentaire" %> signal&eacute;<%= isPublication ? "e" : "" %>
                        </h3>
                        <% if (contenuSupprime) { %>
                        <span class="label label-danger pull-right">SUPPRIM&Eacute;<%= isPublication ? "E" : "" %></span>
                        <% } %>
                    </div>
                    <div class="box-body">
                        <table class="table table-bordered">
                            <tr><th width="35%">ID</th><td><%= targetId %></td></tr>
                            <% if (!isPublication && !commentairePostId.isEmpty()) { %>
                            <tr><th>ID Publication</th><td><%= commentairePostId %></td></tr>
                            <% } %>
                            <tr><th>Date</th><td><%= dateContenu %></td></tr>
                            <tr><th>Auteur</th><td><%= auteurSignale %></td></tr>
                            <tr><th>Contenu</th><td><div style="max-height:200px;overflow-y:auto;"><%= contenuSignale %></div></td></tr>
                        </table>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Actions -->
        <div class="row">
            <div class="col-md-12">
                <div class="box box-solid">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa fa-gavel"></i> Actions</h3>
                    </div>
                    <div class="box-body">
                        <a href="<%=lien%>?but=moderation/signalement-liste.jsp&tab=<%=tabRetour%>" class="btn btn-default">
                            <i class="fa fa-arrow-left"></i> Retour &agrave; la liste
                        </a>
                        
                        <% if (!estTraite) { %>
                            <% if (!contenuSupprime) { %>
                            <!-- Supprimer le contenu -->
                            <a href="<%=lien%>?but=moderation/signalement-action.jsp&action=<%= isPublication ? "supprimer_publication" : "supprimer_commentaire" %>&id=<%=id%>&<%= isPublication ? "post_id" : "commentaire_id" %>=<%=targetId%>&bute=moderation/signalement-fiche.jsp%26id=<%=id%>%26type=<%=type%>" 
                               class="btn btn-danger pull-right"
                               onclick="return confirm('&Ecirc;tes-vous s&ucirc;r de vouloir supprimer <%= isPublication ? "cette publication" : "ce commentaire" %> ?');">
                                <i class="fa fa-trash"></i> Supprimer <%= isPublication ? "la publication" : "le commentaire" %>
                            </a>
                            <% } %>
                            
                            <!-- Rejeter le signalement -->
                            <a href="<%=lien%>?but=moderation/signalement-action.jsp&action=rejeter&id=<%=id%>&bute=moderation/signalement-fiche.jsp%26id=<%=id%>%26type=<%=type%>" 
                               class="btn btn-warning pull-right" style="margin-right:10px;"
                               onclick="return confirm('Rejeter ce signalement ? Le contenu restera visible.');">
                                <i class="fa fa-times"></i> Rejeter le signalement
                            </a>
                        <% } else { %>
                        <span class="text-muted pull-right">Ce signalement a d&eacute;j&agrave; &eacute;t&eacute; trait&eacute;</span>
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
