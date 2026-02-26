<%@page contentType="text/html;charset=UTF-8" %>
<%@page import="bean.Signalement" %>
<%@page import="bean.Post" %>
<%@page import="bean.Commentaire" %>
<%@page import="bean.CGenUtil" %>
<%@page import="user.UserEJB" %>
<%@page import="utilitaire.UtilDB" %>
<%@page import="java.sql.Connection" %>
<%@page import="java.sql.Timestamp" %>
<% 
String lien = (String) session.getValue("lien");
String redirectUrl = "moderation/signalement-liste.jsp&tab=publications";
String errorMsg = null;

try {
    UserEJB u = (UserEJB) session.getValue("u");
    String role = u != null ? u.getUser().getIdrole() : "";
    
    if (u == null || (!"admin".equals(role) && !"moderateur".equals(role))) {
        errorMsg = "Accès non autorisé";
    } else {
        String id = request.getParameter("id");                     // ID signalement
        String action = request.getParameter("action");             // supprimer_publication, supprimer_commentaire, rejeter
        String postId = request.getParameter("post_id");            // ID publication (si action sur publication)
        String commentaireId = request.getParameter("commentaire_id"); // ID commentaire (si action sur commentaire)
        String bute = request.getParameter("bute");                 // Page de retour
        
        if (id != null && action != null) {
            Connection c = new UtilDB().GetConn();
            try {
                // Charger le signalement
                Signalement sigCritere = new Signalement();
                sigCritere.setId(id);
                Object[] sigResults = CGenUtil.rechercher(sigCritere, null, null, "");
                
                if (sigResults != null && sigResults.length > 0) {
                    Signalement signalement = (Signalement) sigResults[0];
                    
                    String decision = "";
                    
                    if ("supprimer_publication".equals(action) && postId != null) {
                        // Supprimer la publication (soft delete)
                        Post postCritere = new Post();
                        postCritere.setId(postId);
                        Object[] postResults = CGenUtil.rechercher(postCritere, null, null, "");
                        
                        if (postResults != null && postResults.length > 0) {
                            Post post = (Post) postResults[0];
                            post.setIdstatutpublication("STAT00005"); // Statut "Supprimé"
                            post.setSupprime(1);
                            post.setDate_suppression(new Timestamp(System.currentTimeMillis()));
                            post.updateToTable(c);
                            decision = "Publication supprimée";
                        }
                        
                        // Marquer TOUS les signalements de cette publication comme traités
                        Signalement sigPubCritere = new Signalement();
                        sigPubCritere.setPost_id(postId);
                        Object[] allSigPub = CGenUtil.rechercher(sigPubCritere, null, null, "");
                        
                        if (allSigPub != null) {
                            Timestamp now = new Timestamp(System.currentTimeMillis());
                            int moderateurId = u.getUser().getRefuser();
                            for (Object obj : allSigPub) {
                                Signalement sig = (Signalement) obj;
                                // Ne traiter que les signalements non encore traités
                                if (!"SSIG00003".equals(sig.getIdstatutsignalement()) && !"SSIG00004".equals(sig.getIdstatutsignalement())) {
                                    sig.setIdstatutsignalement("SSIG00003"); // Traité
                                    sig.setTraite_par(moderateurId);
                                    sig.setTraite_at(now);
                                    sig.setDecision("Publication supprimée suite à signalement");
                                    sig.updateToTable(c);
                                }
                            }
                        }
                        
                    } else if ("supprimer_commentaire".equals(action) && commentaireId != null) {
                        // Supprimer le commentaire (soft delete)
                        Commentaire commCritere = new Commentaire();
                        commCritere.setId(commentaireId);
                        Object[] commResults = CGenUtil.rechercher(commCritere, null, null, "");
                        
                        if (commResults != null && commResults.length > 0) {
                            Commentaire comm = (Commentaire) commResults[0];
                            comm.setSupprime(1);
                            comm.updateToTable(c);
                            decision = "Commentaire supprimé";
                        }
                        
                        // Marquer TOUS les signalements de ce commentaire comme traités
                        Signalement sigCommCritere = new Signalement();
                        sigCommCritere.setCommentaire_id(commentaireId);
                        Object[] allSigComm = CGenUtil.rechercher(sigCommCritere, null, null, "");
                        
                        if (allSigComm != null) {
                            Timestamp now = new Timestamp(System.currentTimeMillis());
                            int moderateurId = u.getUser().getRefuser();
                            for (Object obj : allSigComm) {
                                Signalement sig = (Signalement) obj;
                                // Ne traiter que les signalements non encore traités
                                if (!"SSIG00003".equals(sig.getIdstatutsignalement()) && !"SSIG00004".equals(sig.getIdstatutsignalement())) {
                                    sig.setIdstatutsignalement("SSIG00003"); // Traité
                                    sig.setTraite_par(moderateurId);
                                    sig.setTraite_at(now);
                                    sig.setDecision("Commentaire supprimé suite à signalement");
                                    sig.updateToTable(c);
                                }
                            }
                        }
                        
                        redirectUrl = "moderation/signalement-liste.jsp&tab=commentaires";
                        
                    } else if ("rejeter".equals(action)) {
                        // Rejeter le signalement sans supprimer le contenu
                        signalement.setIdstatutsignalement("SSIG00004"); // Rejeté
                        signalement.setTraite_par(u.getUser().getRefuser());
                        signalement.setTraite_at(new Timestamp(System.currentTimeMillis()));
                        signalement.setDecision("Signalement rejeté - contenu conforme");
                        signalement.updateToTable(c);
                        
                        // Déterminer la page de retour selon le type de signalement
                        if (signalement.getCommentaire_id() != null && !signalement.getCommentaire_id().isEmpty()) {
                            redirectUrl = "moderation/signalement-liste.jsp&tab=commentaires";
                        }
                    }
                }
                
                // Définir URL de redirection si spécifiée
                if (bute != null && !bute.isEmpty()) {
                    redirectUrl = bute;
                }
                
            } finally {
                if (c != null) c.close();
            }
        }
    }
} catch (Exception e) {
    e.printStackTrace();
    errorMsg = e.getMessage();
}

if (errorMsg != null) {
%>
<div class="alert alert-danger" style="margin:20px;">
    <i class="fa fa-exclamation-circle"></i> Erreur: <%=errorMsg%>
</div>
<% } else { %>
<script>document.location.replace("<%=lien%>?but=<%=redirectUrl%>");</script>
<% } %>
