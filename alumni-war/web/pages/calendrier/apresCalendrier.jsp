<%@ page pageEncoding="UTF-8" %>
<%@ page import="bean.CalendrierScolaire" %>
<%@ page import="user.UserEJB" %>
<%@ page import="affichage.PageInsert" %>
<%@ page import="affichage.PageUpdate" %>
<%@ page import="java.sql.Timestamp" %>
<%
try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    String acte = request.getParameter("acte");
    String bute = request.getParameter("bute");
    String id = request.getParameter("id");
    
    int refuserInt = Integer.parseInt(u.getUser().getTuppleID());
    
    if ("insert".equals(acte)) {
        CalendrierScolaire cs = new CalendrierScolaire();
        PageInsert p = new PageInsert(cs, request);
        CalendrierScolaire f = (CalendrierScolaire) p.getObjectAvecValeur();
        
        // Initialiser les champs d'audit
        f.setCreated_by(refuserInt);
        f.setCreated_at(new Timestamp(System.currentTimeMillis()));
        
        CalendrierScolaire created = (CalendrierScolaire) u.createObject(f);
        if (created != null) {
            id = created.getTuppleID();
        }
%>
<script>document.location.replace("<%=lien%>?but=<%=bute%><%= id != null ? "&id=" + id : "" %>");</script>
<%
        return;
    }
    
    if ("update".equals(acte)) {
        CalendrierScolaire cs = new CalendrierScolaire();
        cs.setId(id);
        PageUpdate pu = new PageUpdate(cs, request, u);
        CalendrierScolaire f = (CalendrierScolaire) pu.getObjectAvecValeur();
        f.setId(id);
        u.updateObject(f);
%>
<script>document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=id%>");</script>
<%
        return;
    }
    
} catch (Exception e) {
    e.printStackTrace();
    String errorMsg = e.getMessage() != null ? e.getMessage().replace("'", "\\'") : "Erreur lors de l'opération";
%>
<script>
    alert('Erreur: <%= errorMsg %>');
    history.back();
</script>
<% } %>
