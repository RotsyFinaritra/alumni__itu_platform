<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="affichage.PageInsert" %>
<%@ page import="affichage.Champ" %>
<%@ page import="affichage.Liste" %>
<%@ page import="bean.Signalement" %>
<%@ page import="bean.MotifSignalement" %>
<%@ page import="bean.Post" %>
<%@ page import="bean.Commentaire" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="user.UserEJB" %>
<%@ page import="utilisateurAcade.UtilisateurPg" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        
        String postId = request.getParameter("post_id");
        String commentaireId = request.getParameter("commentaire_id");
        boolean isCommentaire = (commentaireId != null && !commentaireId.isEmpty());
        
        if (!isCommentaire && (postId == null || postId.isEmpty())) {
            throw new Exception("Aucun contenu specifie");
        }
        
        // Variables communes
        String nomAuteur = "Utilisateur";
        String contenuApercu = "";
        String acte = "signaler";
        String titreSignalement = "Signaler une publication";
        String iconSignalement = "fa-newspaper-o";
        
        if (isCommentaire) {
            // Charger le commentaire
            Commentaire commCritere = new Commentaire();
            commCritere.setId(commentaireId);
            Object[] commResult = CGenUtil.rechercher(commCritere, null, null, "");
            if (commResult == null || commResult.length == 0) {
                throw new Exception("Commentaire introuvable");
            }
            Commentaire commentaire = (Commentaire) commResult[0];
            if (postId == null || postId.isEmpty()) postId = commentaire.getPost_id();
            
            UtilisateurPg auteurCritere = new UtilisateurPg();
            Object[] auteurResult = CGenUtil.rechercher(auteurCritere, null, null, " AND refuser = " + commentaire.getIdutilisateur());
            if (auteurResult != null && auteurResult.length > 0) {
                UtilisateurPg auteur = (UtilisateurPg) auteurResult[0];
                nomAuteur = ((auteur.getPrenom() != null ? auteur.getPrenom() + " " : "") + 
                            (auteur.getNomuser() != null ? auteur.getNomuser() : "")).trim();
            }
            contenuApercu = commentaire.getContenu() != null ? commentaire.getContenu() : "";
            acte = "signalerCommentaire";
            titreSignalement = "Signaler un commentaire";
            iconSignalement = "fa-comment";
        } else {
            // Charger la publication
            Post postCritere = new Post();
            postCritere.setId(postId);
            Object[] postResult = CGenUtil.rechercher(postCritere, null, null, " AND id = '" + postId + "'");
            if (postResult == null || postResult.length == 0) {
                throw new Exception("Publication introuvable");
            }
            Post post = (Post) postResult[0];
            
            UtilisateurPg auteurCritere = new UtilisateurPg();
            Object[] auteurResult = CGenUtil.rechercher(auteurCritere, null, null, " AND refuser = " + post.getIdutilisateur());
            if (auteurResult != null && auteurResult.length > 0) {
                UtilisateurPg auteur = (UtilisateurPg) auteurResult[0];
                nomAuteur = ((auteur.getPrenom() != null ? auteur.getPrenom() + " " : "") + 
                            (auteur.getNomuser() != null ? auteur.getNomuser() : "")).trim();
            }
            contenuApercu = post.getContenu() != null ? post.getContenu() : "";
        }
        
        // Nettoyer et tronquer le contenu
        contenuApercu = contenuApercu.replaceAll("<[^>]*>", "");
        if (contenuApercu.length() > 200) {
            contenuApercu = contenuApercu.substring(0, 200) + "...";
        }
        
        // --- Formulaire APJ ---
        Signalement sig = new Signalement();
        PageInsert pi = new PageInsert(sig, request, u);
        pi.setLien(lien);
        
        // Liste deroulante pour motif de signalement
        MotifSignalement motifObj = new MotifSignalement();
        Champ[] listes = new Champ[1];
        listes[0] = new Liste("idmotifsignalement", motifObj, "libelle", "id");
        pi.getFormu().changerEnChamp(listes);
        
        // Masquer les champs auto-geres
        Champ c;
        c = pi.getFormu().getChamp("id");                  if (c != null) c.setVisible(false);
        c = pi.getFormu().getChamp("idutilisateur");       if (c != null) c.setVisible(false);
        c = pi.getFormu().getChamp("post_id");             if (c != null) c.setVisible(false);
        c = pi.getFormu().getChamp("commentaire_id");      if (c != null) c.setVisible(false);
        c = pi.getFormu().getChamp("idstatutsignalement"); if (c != null) c.setVisible(false);
        c = pi.getFormu().getChamp("traite_par");          if (c != null) c.setVisible(false);
        c = pi.getFormu().getChamp("traite_at");           if (c != null) c.setVisible(false);
        c = pi.getFormu().getChamp("decision");            if (c != null) c.setVisible(false);
        c = pi.getFormu().getChamp("created_at");          if (c != null) c.setVisible(false);
        
        // Configurer les champs visibles
        c = pi.getFormu().getChamp("idmotifsignalement");
        if (c != null) { c.setLibelle("Motif du signalement *"); c.setAutre("required"); }
        
        c = pi.getFormu().getChamp("description");
        if (c != null) { c.setLibelle("Description (optionnel)"); }
        
        // Ordre d'affichage
        pi.getFormu().setOrdre(new String[]{"idmotifsignalement", "description"});
        
        pi.preparerDataFormu();
        pi.getFormu().makeHtmlInsertTabIndex();
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-flag text-danger"></i> <%= titreSignalement %></h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=publication/publication-liste.jsp"><i class="fa fa-newspaper-o"></i> Publications</a></li>
            <li><a href="<%=lien%>?but=publication/publication-fiche.jsp&id=<%=postId%>">Publication</a></li>
            <li class="active">Signaler</li>
        </ol>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-8 col-md-offset-2">
                
                <!-- Avertissement -->
                <div class="callout callout-warning">
                    <h4><i class="fa fa-exclamation-triangle"></i> Attention</h4>
                    <p>Les signalements abusifs peuvent entra&icirc;ner des sanctions. 
                    Veuillez signaler uniquement les contenus qui enfreignent les r&egrave;gles de la communaut&eacute;.</p>
                </div>
                
                <!-- Apercu du contenu signale -->
                <div class="box box-default">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa <%= iconSignalement %>"></i> Contenu signal&eacute;</h3>
                    </div>
                    <div class="box-body">
                        <p><strong><i class="fa fa-user"></i> <%= nomAuteur %></strong></p>
                        <blockquote style="font-size: 14px;"><%= contenuApercu %></blockquote>
                    </div>
                </div>
                
                <!-- Formulaire de signalement -->
                <div class="box box-danger">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa fa-flag"></i> Formulaire de signalement</h3>
                    </div>
                    <form method="post" action="<%=lien%>?but=publication/apresPublication.jsp">
                        <input type="hidden" name="acte" value="<%= acte %>">
                        <% if (isCommentaire) { %>
                        <input type="hidden" name="commentaire_id" value="<%= commentaireId %>">
                        <input type="hidden" name="bute" value="publication/publication-fiche.jsp&id=<%= postId %>">
                        <% } else { %>
                        <input type="hidden" name="post_id" value="<%= postId %>">
                        <input type="hidden" name="bute" value="publication/publication-fiche.jsp">
                        <% } %>
                        
                        <div class="box-body">
                            <%= pi.getFormu().getHtmlInsert() %>
                        </div>
                        <div class="box-footer">
                            <button type="submit" class="btn btn-danger" onclick="return confirm('Confirmez-vous ce signalement ?');">
                                <i class="fa fa-flag"></i> Envoyer le signalement
                            </button>
                            <a href="<%=lien%>?but=publication/publication-fiche.jsp&id=<%=postId%>" class="btn btn-default" style="margin-left: 10px;">
                                <i class="fa fa-arrow-left"></i> Annuler
                            </a>
                        </div>
                    </form>
                </div>
                
            </div>
        </div>
    </section>
</div>

<% } catch (Exception e) {
    e.printStackTrace();
%>
<script language="JavaScript">
    alert('<%= e.getMessage() != null ? e.getMessage().replace("'", "\\'") : "Une erreur est survenue" %>');
    history.back();
</script>
<% } %>
