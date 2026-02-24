<%@ page pageEncoding="UTF-8" contentType="application/json; charset=UTF-8" %>
<%@ page import="bean.*" %>
<%@ page import="user.UserEJB" %>
<%@ page import="profil.PublicationService" %>
<%@ page import="org.json.JSONObject" %>

<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    JSONObject json = new JSONObject();
    
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        if (u == null || u.getUser() == null) {
            json.put("success", false);
            json.put("message", "Utilisateur non connecté");
            out.print(json.toString());
            return;
        }
        
        int idutilisateur = Integer.parseInt(u.getUser().getTuppleID());
        String postId = request.getParameter("postId");
        String contenu = request.getParameter("contenu");
        
        if (postId == null || postId.trim().isEmpty()) {
            json.put("success", false);
            json.put("message", "ID de publication manquant");
            out.print(json.toString());
            return;
        }
        
        if (contenu == null || contenu.trim().isEmpty()) {
            json.put("success", false);
            json.put("message", "Contenu du commentaire manquant");
            out.print(json.toString());
            return;
        }
        
        // Ajouter le commentaire
        Commentaire comm = PublicationService.addCommentaire(postId, idutilisateur, contenu);
        
        // Récupérer le nouveau nombre de commentaires
        Post post = new Post();
        post.setId(postId);
        Object[] posts = CGenUtil.rechercher(post, null, null, "");
        int nbCommentaires = 0;
        if (posts != null && posts.length > 0) {
            nbCommentaires = ((Post) posts[0]).getNb_commentaires();
        }
        
        // Info utilisateur
        UtilisateurAcade utilisateur = u.getUser();
        String photo = utilisateur.getPhoto();
        String avatarUrl = (photo != null && !photo.isEmpty()) 
            ? request.getContextPath() + "/uploads/" + photo 
            : request.getContextPath() + "/assets/img/default-avatar.png";
        
        json.put("success", true);
        json.put("contenu", contenu);
        json.put("auteur", utilisateur.getNomuser() + " " + utilisateur.getPrenom());
        json.put("avatar", avatarUrl);
        json.put("nbCommentaires", nbCommentaires);
        
    } catch (Exception e) {
        e.printStackTrace();
        json.put("success", false);
        json.put("message", "Erreur: " + e.getMessage());
    }
    
    out.print(json.toString());
%>
