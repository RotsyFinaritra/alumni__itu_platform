<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="affichage.PageInsert" %>
<%@ page import="affichage.Champ" %>
<%@ page import="affichage.Liste" %>
<%@ page import="bean.Signalement" %>
<%@ page import="bean.MotifSignalement" %>
<%@ page import="bean.Post" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="user.UserEJB" %>
<%@ page import="utilisateurAcade.UtilisateurPg" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        int refuserInt = Integer.parseInt(u.getUser().getTuppleID());
        String postId = request.getParameter("post_id");
        
        if (postId == null || postId.isEmpty()) {
            throw new Exception("Aucune publication specifiee");
        }
        
        // Charger le post pour afficher un apercu
        Post postCritere = new Post();
        postCritere.setId(postId);
        Object[] postResult = CGenUtil.rechercher(postCritere, null, null, " AND id = '" + postId + "'");
        if (postResult == null || postResult.length == 0) {
            throw new Exception("Publication introuvable");
        }
        Post post = (Post) postResult[0];
        
        // Charger l'auteur de la publication
        String nomAuteur = "Utilisateur";
        UtilisateurPg auteurCritere = new UtilisateurPg();
        Object[] auteurResult = CGenUtil.rechercher(auteurCritere, null, null, " AND refuser = " + post.getIdutilisateur());
        if (auteurResult != null && auteurResult.length > 0) {
            UtilisateurPg auteur = (UtilisateurPg) auteurResult[0];
            nomAuteur = (auteur.getNomuser() != null ? auteur.getNomuser() : "") + " " + (auteur.getPrenom() != null ? auteur.getPrenom() : "");
        }
        
        // Contenu abrege
        String contenuApercu = post.getContenu() != null ? post.getContenu() : "";
        if (contenuApercu.length() > 200) {
            contenuApercu = contenuApercu.substring(0, 200) + "...";
        }
        // Nettoyer les tags HTML
        contenuApercu = contenuApercu.replaceAll("<[^>]*>", "");
        
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
        if (c != null) { c.setLibelle("Motif du signalement"); c.setAutre("required"); }
        
        c = pi.getFormu().getChamp("description");
        if (c != null) { c.setLibelle("Description (optionnel)"); c.setType("editor"); }
        
        // Ordre d'affichage
        pi.getFormu().setOrdre(new String[]{"idmotifsignalement", "description"});
        
        pi.preparerDataFormu();
        pi.getFormu().makeHtmlInsertTabIndex();
%>
<style>
.signal-container { max-width: 700px; margin: 0 auto; }
.signal-warning {
    background: #fff3cd; border: 1px solid #ffc107; border-radius: 8px;
    padding: 15px 20px; margin-bottom: 20px; color: #856404;
}
.signal-warning i { margin-right: 8px; }
.post-preview {
    background: #f8f9fa; border: 1px solid #dee2e6; border-radius: 8px;
    padding: 15px 20px; margin-bottom: 20px;
}
.post-preview .preview-author {
    font-weight: 600; color: #333; margin-bottom: 5px;
}
.post-preview .preview-content {
    color: #666; font-size: 14px; line-height: 1.5;
}
.signal-form .box { border-top: 3px solid #e74c3c; }
.signal-form .box-header { background: #fdf2f2; }
.signal-form .box-title { color: #c0392b; }
.btn-signal {
    background: #e74c3c; color: #fff; border: none;
    padding: 10px 30px; border-radius: 5px; font-size: 15px;
    cursor: pointer; transition: background 0.2s;
}
.btn-signal:hover { background: #c0392b; color: #fff; }
</style>

<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-flag" style="color:#e74c3c"></i> Signaler une publication</h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=publication/publication-liste.jsp"><i class="fa fa-newspaper-o"></i> Publications</a></li>
            <li><a href="<%=lien%>?but=publication/publication-fiche.jsp&id=<%=postId%>">Publication</a></li>
            <li class="active">Signaler</li>
        </ol>
    </section>
    <section class="content">
        <div class="signal-container">
            
            <!-- Avertissement -->
            <div class="signal-warning">
                <i class="fa fa-exclamation-triangle"></i>
                <strong>Attention :</strong> Les signalements abusifs peuvent entra&icirc;ner des sanctions. 
                Veuillez signaler uniquement les contenus qui enfreignent les r&egrave;gles de la communaut&eacute;.
            </div>
            
            <!-- Apercu de la publication -->
            <div class="post-preview">
                <div class="preview-author"><i class="fa fa-user"></i> <%= nomAuteur %></div>
                <div class="preview-content"><%= contenuApercu %></div>
            </div>
            
            <!-- Formulaire de signalement -->
            <div class="signal-form">
                <form method="post" action="<%=lien%>?but=publication/apresPublication.jsp">
                    <input type="hidden" name="acte" value="signaler">
                    <input type="hidden" name="post_id" value="<%=postId%>">
                    <input type="hidden" name="bute" value="publication/publication-fiche.jsp">
                    
                    <div class="box">
                        <div class="box-header with-border">
                            <h3 class="box-title"><i class="fa fa-flag"></i> Formulaire de signalement</h3>
                        </div>
                        <div class="box-body">
                            <%= pi.getFormu().getHtmlInsert() %>
                        </div>
                        <div class="box-footer">
                            <button type="submit" class="btn btn-signal" onclick="return confirm('Confirmez-vous le signalement de cette publication ?');">
                                <i class="fa fa-flag"></i> Envoyer le signalement
                            </button>
                            <a href="<%=lien%>?but=publication/publication-fiche.jsp&id=<%=postId%>" class="btn btn-default" style="margin-left: 10px;">
                                <i class="fa fa-times"></i> Annuler
                            </a>
                        </div>
                    </div>
                </form>
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
