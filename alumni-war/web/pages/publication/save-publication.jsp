<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*" %>
<%@ page import="user.UserEJB" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.UUID" %>

<%
    // Vérifier l'authentification
    UserEJB u = (UserEJB) session.getValue("u");
    if (u == null || u.getUser() == null) {
        response.sendRedirect("../login.jsp");
        return;
    }
    
    int idutilisateur = Integer.parseInt(u.getUser().getTuppleID());
    
    // Récupérer les paramètres du formulaire
    String idtypepublication = request.getParameter("idtypepublication");
    String idvisibilite = request.getParameter("idvisibilite");
    String contenu = request.getParameter("contenu");
    String epingleParam = request.getParameter("epingle");
    boolean epingle = "true".equals(epingleParam);
    
    // Validation
    if (idtypepublication == null || idtypepublication.trim().isEmpty()) {
        session.setAttribute("error", "Le type de publication est obligatoire");
        response.sendRedirect("../module.jsp?but=publication/publication-saisie.jsp&currentMenu=MENDYN100-3");
        return;
    }
    
    if (idvisibilite == null || idvisibilite.trim().isEmpty()) {
        session.setAttribute("error", "La visibilité est obligatoire");
        response.sendRedirect("../module.jsp?but=publication/publication-saisie.jsp&currentMenu=MENDYN100-3");
        return;
    }
    
    if (contenu == null || contenu.trim().isEmpty() || contenu.trim().length() < 10) {
        session.setAttribute("error", "Le contenu doit contenir au moins 10 caractères");
        response.sendRedirect("../module.jsp?but=publication/publication-saisie.jsp&currentMenu=MENDYN100-3");
        return;
    }
    
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        conn = new UtilDB().GetConn();
        
        // Récupérer l'ID du statut "Publié"
        String idStatutPublie = null;
        ps = conn.prepareStatement("SELECT id FROM statut_publication WHERE code = 'publie' LIMIT 1");
        rs = ps.executeQuery();
        if (rs.next()) {
            idStatutPublie = rs.getString("id");
        }
        rs.close();
        ps.close();
        
        if (idStatutPublie == null) {
            session.setAttribute("error", "Erreur de configuration : statut 'Publié' introuvable");
            response.sendRedirect("../module.jsp?but=publication/publication-saisie.jsp&currentMenu=MENDYN100-3");
            return;
        }
        
        // Générer un ID unique pour le post
        String postId = "POST" + UUID.randomUUID().toString().replace("-", "").substring(0, 10).toUpperCase();
        
        // Insérer le post
        String sql = "INSERT INTO posts (id, idutilisateur, idtypepublication, idstatutpublication, " +
                     "idvisibilite, contenu, epingle, supprime, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, false, NOW())";
        
        ps = conn.prepareStatement(sql);
        ps.setString(1, postId);
        ps.setInt(2, idutilisateur);
        ps.setString(3, idtypepublication);
        ps.setString(4, idStatutPublie);
        ps.setString(5, idvisibilite);
        ps.setString(6, contenu.trim());
        ps.setBoolean(7, epingle);
        
        int rowsAffected = ps.executeUpdate();
        
        if (rowsAffected > 0) {
            session.setAttribute("success", "Publication créée avec succès !");
            response.sendRedirect("../module.jsp?but=publication/mes-publications.jsp&currentMenu=MENDYN100-2");
        } else {
            session.setAttribute("error", "Erreur lors de la création de la publication");
            response.sendRedirect("../module.jsp?but=publication/publication-saisie.jsp&currentMenu=MENDYN100-3");
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        session.setAttribute("error", "Erreur technique : " + e.getMessage());
        response.sendRedirect("../module.jsp?but=publication/publication-saisie.jsp&currentMenu=MENDYN100-3");
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignored) {}
        if (ps != null) try { ps.close(); } catch (Exception ignored) {}
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
%>
