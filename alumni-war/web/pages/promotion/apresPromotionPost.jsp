<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*, utilitaire.*, java.sql.*, java.io.*, java.util.*, user.UserEJB" %>
<%@ page import="org.apache.commons.fileupload.*, org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.servlet.*" %>
<%
try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    if (u == null || lien == null) {
%><script>document.location.replace('index.jsp');</script><%
        return;
    }
    
    int refuserInt = u.getUser().getRefuser();
    String idrole = u.getUser().getIdrole() != null ? u.getUser().getIdrole() : "";
    boolean isAdmin = "admin".equalsIgnoreCase(idrole) || "enseignant".equalsIgnoreCase(idrole);
    
    String acte = request.getParameter("acte");
    String bute = request.getParameter("bute");
    if (bute == null || bute.isEmpty()) bute = "promotion/espace-promotion.jsp";
    
    // Conserver le paramètre promo dans la redirection
    String promoParam = request.getParameter("promo");
    if (promoParam != null && !promoParam.isEmpty() && !bute.contains("promo=")) {
        bute += (bute.contains("?") ? "&" : "?") + "promo=" + promoParam;
    }
    
    // === ÉPINGLER / DÉSÉPINGLER ===
    if ("epingler".equals(acte)) {
        String postId = request.getParameter("post_id");
        String epingle = request.getParameter("epingle");
        
        if (postId != null && epingle != null && isAdmin) {
            Connection conn = null;
            try {
                conn = new UtilDB().GetConn();
                Post post = new Post();
                Object[] postResult = CGenUtil.rechercher(post, null, null, " AND id = '" + postId + "'");
                if (postResult != null && postResult.length > 0) {
                    Post p = (Post) postResult[0];
                    p.setEpingle(Integer.parseInt(epingle));
                    p.updateToTable(conn);
                }
            } finally {
                if (conn != null) conn.close();
            }
        }
    }
    
%><script language="JavaScript">document.location.replace("<%=lien%>?but=<%=bute%>");</script><%
    
} catch (Exception e) {
    e.printStackTrace();
%>
<script language="JavaScript">
    alert('Erreur: <%=e.getMessage() != null ? e.getMessage().replace("'", "\\'") : "inconnue"%>');
    history.back();
</script>
<% } %>
