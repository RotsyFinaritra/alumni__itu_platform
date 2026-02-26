<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.UserEJB" %>
<%@ page import="bean.*, utilitaire.*" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        if (u == null || lien == null) {
%><script>document.location.replace('index.jsp');</script><%
            return;
        }
        
        int refuserInt = u.getUser().getRefuser();
        String acte = request.getParameter("acte");
        String id = request.getParameter("id");
        String redirect = request.getParameter("redirect");
        String bute = "notification/notification-liste.jsp";
        
        if ("marquer_lu".equals(acte) && id != null) {
            Notification notifCritere = new Notification();
            notifCritere.setId(id);
            Object[] notifs = CGenUtil.rechercher(notifCritere, null, null, " AND idutilisateur = " + refuserInt);
            if (notifs != null && notifs.length > 0) {
                Notification n = (Notification) notifs[0];
                n.setVu(1);
                n.setLu_at(new java.sql.Timestamp(System.currentTimeMillis()));
                u.updateObject(n);
            }
        }
        else if ("marquer_non_lu".equals(acte) && id != null) {
            Notification notifCritere = new Notification();
            notifCritere.setId(id);
            Object[] notifs = CGenUtil.rechercher(notifCritere, null, null, " AND idutilisateur = " + refuserInt);
            if (notifs != null && notifs.length > 0) {
                Notification n = (Notification) notifs[0];
                n.setVu(0);
                n.setLu_at(null);
                u.updateObject(n);
            }
        }
        else if ("supprimer".equals(acte) && id != null) {
            Notification notifCritere = new Notification();
            notifCritere.setId(id);
            Object[] notifs = CGenUtil.rechercher(notifCritere, null, null, " AND idutilisateur = " + refuserInt);
            if (notifs != null && notifs.length > 0) {
                Notification n = (Notification) notifs[0];
                u.deleteObject(n);
            }
        }
        else if ("marquer_tout_lu".equals(acte)) {
            Notification notifCritere = new Notification();
            Object[] notifs = CGenUtil.rechercher(notifCritere, null, null, " AND idutilisateur = " + refuserInt + " AND vu = 0");
            if (notifs != null) {
                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
                for (Object obj : notifs) {
                    Notification n = (Notification) obj;
                    n.setVu(1);
                    n.setLu_at(now);
                    u.updateObject(n);
                }
            }
        }
        
        if (redirect != null && !redirect.isEmpty() && "marquer_lu".equals(acte)) {
%><script language="JavaScript">document.location.replace("<%=redirect%>");</script><%
        } else {
%><script language="JavaScript">document.location.replace("<%=lien%>?but=<%=bute%>");</script><%
        }

    } catch (Exception e) {
        e.printStackTrace();
%>
<script>
    alert('Erreur: <%= e.getMessage() != null ? e.getMessage().replace("'", "\\'") : "Une erreur est survenue" %>');
    history.back();
</script>
<% } %>
