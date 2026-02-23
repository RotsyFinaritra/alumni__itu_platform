<%@ page import="bean.Parcours, bean.CGenUtil" %>
<%@ page import="user.UserEJB" %>
<%@ page import="java.sql.Date" %>
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
            if (ids != null) {
                for (String idx : ids) {
                    String iddiplome   = request.getParameter("iddiplome_"   + idx);
                    String idecole     = request.getParameter("idecole_"     + idx);
                    String iddomaine   = request.getParameter("iddomaine_"   + idx);
                    String dateDebStr  = request.getParameter("datedebut_"   + idx);
                    String dateFinStr  = request.getParameter("datefin_"     + idx);

                    // Ignorer les lignes completement vides
                    boolean hasData = (iddiplome != null && !iddiplome.trim().isEmpty())
                                   || (idecole    != null && !idecole.trim().isEmpty())
                                   || (iddomaine  != null && !iddomaine.trim().isEmpty())
                                   || (dateDebStr != null && !dateDebStr.trim().isEmpty());
                    if (!hasData) continue;

                    Parcours p = new Parcours();
                    p.setIdutilisateur(refuserInt);
                    if (iddiplome  != null && !iddiplome.trim().isEmpty())  p.setIddiplome(iddiplome);
                    if (idecole    != null && !idecole.trim().isEmpty())    p.setIdecole(idecole);
                    if (iddomaine  != null && !iddomaine.trim().isEmpty())  p.setIddomaine(iddomaine);
                    if (dateDebStr != null && !dateDebStr.trim().isEmpty()) {
                        try { p.setDatedebut(Date.valueOf(dateDebStr)); } catch (Exception ignored) {}
                    }
                    if (dateFinStr != null && !dateFinStr.trim().isEmpty()) {
                        try { p.setDatefin(Date.valueOf(dateFinStr)); } catch (Exception ignored) {}
                    }
                    CGenUtil.save(p);
                }
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
