<%@ page import="profil.CompetenceProfilService" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String refuser = request.getParameter("refuser");
        if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
        int refuserInt = Integer.parseInt(refuser);

        // Récupérer les sélections
        String[] selectedComps = request.getParameterValues("competences");
        String[] selectedSpecs = request.getParameterValues("specialites");
        
        // Sauvegarder
        CompetenceProfilService.sauvegarder(refuserInt, selectedComps, selectedSpecs);
        
        // Redirection vers le profil
        response.sendRedirect(lien + "?but=profil/mon-profil.jsp&refuser=" + refuser);
        
    } catch (Exception e) {
        e.printStackTrace();
        // En cas d'erreur, stocker en session et retourner au formulaire
        session.setAttribute("errorMessage", "Erreur lors de l'enregistrement : " + e.getMessage());
        String refuser = request.getParameter("refuser");
        if (refuser == null || refuser.isEmpty()) {
            UserEJB u = (UserEJB) session.getValue("u");
            refuser = u.getUser().getTuppleID();
        }
        String lien = (String) session.getValue("lien");
        response.sendRedirect(lien + "?but=profil/competence-saisie.jsp&refuser=" + refuser);
    }
%>
