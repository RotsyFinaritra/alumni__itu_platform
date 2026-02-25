<%-- 
    Document   : apresPopup
    Description: Ferme le popup et retourne les valeurs à la fenêtre parente
    Created on : 24 févr. 2026
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Récupérer les paramètres
    String champReturn = request.getParameter("champReturn"); // ex: "identreprise;identrepriselibelle"
    String champUrl = request.getParameter("champUrl");       // ex: "id;libelle"
    String id = request.getParameter("id");
    String valeur = request.getParameter("valeur");
    
    // Valeurs à retourner
    String[] champReturns = champReturn != null ? champReturn.split(";") : new String[0];
    String[] champUrls = champUrl != null ? champUrl.split(";") : new String[0];
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Fermeture Popup</title>
</head>
<body>
<script language="JavaScript">
    try {
        // Récupérer les champs de retour et les valeurs
        var champReturns = "<%= champReturn != null ? champReturn : "" %>".split(";");
        var champUrls = "<%= champUrl != null ? champUrl : "" %>".split(";");
        
        // Valeurs à mettre dans les champs
        var valeurs = {};
        <% 
        if (champUrls.length > 0 && champReturns.length > 0) {
            for (int i = 0; i < champUrls.length && i < champReturns.length; i++) {
                String champUrlName = champUrls[i].trim();
                String val = request.getParameter(champUrlName);
                if (val == null) val = "";
        %>
        valeurs["<%= champReturns[i].trim() %>"] = "<%= val %>";
        <%
            }
        }
        %>
        
        // Affecter les valeurs aux champs de la fenêtre parente
        if (window.opener && !window.opener.closed) {
            for (var champ in valeurs) {
                var elem = window.opener.document.getElementById(champ);
                if (elem) {
                    elem.value = valeurs[champ];
                }
            }
        }
        
        // Fermer la popup
        window.close();
    } catch (e) {
        alert("Erreur lors du retour des valeurs: " + e.message);
        window.close();
    }
</script>
<p>Fermeture de la fenêtre...</p>
</body>
</html>
