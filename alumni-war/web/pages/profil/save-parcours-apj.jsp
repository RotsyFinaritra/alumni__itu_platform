<%@ page import="bean.Parcours, bean.CGenUtil" %>
<%@ page import="affichage.PageInsertMultiple" %>
<%@ page import="bean.ClassMAPTable" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String refuser = request.getParameter("refuser");
        if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
        int refuserInt = Integer.parseInt(refuser);
        String acte = request.getParameter("acte");

        if ("delete".equalsIgnoreCase(acte)) {
            String id = request.getParameter("id");
            if (id != null && !id.isEmpty()) {
                Parcours p = new Parcours();
                p.setValChamp(p.getAttributIDName(), id);
                u.deleteObject(p);
            }
%>
<script>window.location.href='<%= lien %>?but=profil/parcours-saisie.jsp&refuser=<%= refuser %>';</script>
<%
            return;
        }

        if ("insertParcours".equalsIgnoreCase(acte)) {
            String[] ids = request.getParameterValues("ids");
            int nbLine = Integer.parseInt(request.getParameter("nombreLigne"));
            if (ids != null && ids.length > 0) {
                Parcours fille = new Parcours();
                PageInsertMultiple pi = new PageInsertMultiple(fille, request, nbLine, ids);
                ClassMAPTable[] cfille = pi.getObjectFilleAvecValeur();
                // Forcer idutilisateur sur chaque ligne (securite)
                for (ClassMAPTable f : cfille) {
                    ((Parcours) f).setIdutilisateur(refuserInt);
                }
                u.createObjectMultiple(cfille);
            }
%>
<script>window.location.href='<%= lien %>?but=profil/parcours-saisie.jsp&refuser=<%= refuser %>';</script>
<%
            return;
        }
%>
<script>window.location.href='<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= refuser %>';</script>
<%
    } catch (Exception e) {
        e.printStackTrace();
        String lien2 = (String) session.getValue("lien");
        String ref2  = request.getParameter("refuser");
%>
<script>alert('Erreur: <%= e.getMessage() != null ? e.getMessage().replace("'","") : "inconnue" %>');
window.location.href='<%= lien2 %>?but=profil/parcours-saisie.jsp&refuser=<%= ref2 %>';</script>
<%
    }
%>
