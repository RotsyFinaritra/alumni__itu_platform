<%@ page import="user.UserEJB" %>
<%@ page import="profil.VisibiliteService" %>
<%@ page contentType="application/json;charset=UTF-8" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String refuserParam = request.getParameter("refuser");
        String nomchamp = request.getParameter("nomchamp");
        String visibleParam = request.getParameter("visible");

        // S&eacute;curit&eacute; : seul l'utilisateur peut modifier sa propre visibilit&eacute;
        if (refuserParam == null || !refuserParam.equals(u.getUser().getTuppleID())) {
            out.print("{\"success\":false,\"message\":\"Acc&egrave;s non autoris&eacute;\"}");
            return;
        }
        if (nomchamp == null || nomchamp.isEmpty()) {
            out.print("{\"success\":false,\"message\":\"Champ manquant\"}");
            return;
        }

        int refuserInt = Integer.parseInt(refuserParam);
        boolean isVisible = "true".equals(visibleParam);

        VisibiliteService.toggleVisibilite(refuserInt, nomchamp, isVisible);

        out.print("{\"success\":true,\"champ\":\"" + nomchamp + "\",\"visible\":" + isVisible + "}");

    } catch (Exception e) {
        e.printStackTrace();
        String msg = e.getMessage() != null ? e.getMessage().replace("\"","'") : "Erreur inconnue";
        out.print("{\"success\":false,\"message\":\"" + msg + "\"}");
    }
%>
