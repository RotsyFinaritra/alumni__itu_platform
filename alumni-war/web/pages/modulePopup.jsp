<%-- 
    Document   : modulePopup
    Description: Page simplifiée pour afficher du contenu dans une popup
    Created on : 24 févr. 2026
--%>
<%@page import="user.UserEJB"%>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String but = "index.jsp";
    String lien = "modulePopup.jsp";
    String lang = "";
    
    if (request.getParameter("lang") != null) {
        session.setAttribute("lang", (String) request.getParameter("lang"));
    }
    lang = (String) session.getAttribute("lang");
    
    if (session.getAttribute("lien") != null) {
        lien = (String) session.getAttribute("lien");
    }
   
    if ((request.getParameter("but") != null) && session.getAttribute("u") != null) {
        but = request.getParameter("but");
        session.setAttribute("lien", "modulePopup.jsp");
    } else {
%>
<script language="JavaScript">
    alert("Veuillez vous connecter pour acceder a ce contenu");
    window.close();
</script>
<% 
        return;
    }
    
    // Récupérer les paramètres de retour pour le popup
    String champReturn = request.getParameter("champReturn");
    String champUrl = request.getParameter("champUrl");
%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Popup - Alumni ITU</title>
    <meta content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" name="viewport">
    <script type="text/javascript">
        const _CONTEXT_PATH = '<%= request.getContextPath() %>';
        // Stub functions that may be called by generated HTML before js.jsp is loaded
        function checkbox() {}
        function synchro() {}
    </script>
    <jsp:include page='elements/css.jsp'/>
    <style>
        body {
            background: #f4f6f9;
            padding: 10px;
        }
        .content-wrapper {
            margin-left: 0 !important;
            background: transparent;
        }
        .card {
            margin-bottom: 0;
        }
    </style>
</head>
<body>
    <% try { %>
    <jsp:include page='<%=but%>'/>
    <% } catch (Exception e) {
        e.printStackTrace();
    %>
    <div class="alert alert-danger">
        <h4><i class="fas fa-ban"></i> Erreur</h4>
        <p><%= e.getMessage() != null ? e.getMessage() : "Erreur inconnue" %></p>
    </div>
    <script language="JavaScript">
        alert('Erreur: <%= e.getMessage() != null ? e.getMessage().replace("'", "\\'") : "Erreur inconnue" %>');
    </script>
    <% } %>
    
    <jsp:include page='elements/js.jsp'/>
    <script src="${pageContext.request.contextPath}/apjplugins/champcalcul.js" defer></script>      
    <script src="${pageContext.request.contextPath}/apjplugins/champdate.js" defer></script>      
    <script src="${pageContext.request.contextPath}/apjplugins/champautocomplete.js" defer></script>
</body>
</html>
