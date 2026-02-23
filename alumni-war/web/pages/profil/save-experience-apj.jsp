<%@ page import="bean.Experience, bean.CGenUtil" %>
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
                Experience exp = new Experience();
                exp.setValChamp(exp.getAttributIDName(), id);
                u.deleteObject(exp);
            }
%>
<script>window.location.href='<%= lien %>?but=profil/experience-saisie.jsp&refuser=<%= refuser %>';</script>
<%
            return;
        }

        if ("insertExperiences".equalsIgnoreCase(acte)) {
            String[] ids = request.getParameterValues("ids");
            if (ids != null) {
                for (String idx : ids) {
                    String poste          = request.getParameter("poste_"         + idx);
                    String iddomaine      = request.getParameter("iddomaine_"     + idx);
                    String identreprise   = request.getParameter("identreprise_"  + idx);
                    String idtypeemploie  = request.getParameter("idtypeemploie_" + idx);
                    String dateDebStr     = request.getParameter("datedebut_"     + idx);
                    String dateFinStr     = request.getParameter("datefin_"       + idx);

                    // Ignorer les lignes completement vides
                    boolean hasData = (poste         != null && !poste.trim().isEmpty())
                                   || (iddomaine     != null && !iddomaine.trim().isEmpty())
                                   || (identreprise  != null && !identreprise.trim().isEmpty())
                                   || (dateDebStr    != null && !dateDebStr.trim().isEmpty());
                    if (!hasData) continue;

                    Experience exp = new Experience();
                    exp.setIdutilisateur(refuserInt);
                    if (poste         != null && !poste.trim().isEmpty())        exp.setPoste(poste);
                    if (iddomaine     != null && !iddomaine.trim().isEmpty())    exp.setIddomaine(iddomaine);
                    if (identreprise  != null && !identreprise.trim().isEmpty()) exp.setIdentreprise(identreprise);
                    if (idtypeemploie != null && !idtypeemploie.trim().isEmpty()) exp.setIdtypeemploie(idtypeemploie);
                    if (dateDebStr    != null && !dateDebStr.trim().isEmpty()) {
                        try { exp.setDatedebut(Date.valueOf(dateDebStr)); } catch (Exception ignored) {}
                    }
                    if (dateFinStr != null && !dateFinStr.trim().isEmpty()) {
                        try { exp.setDatefin(Date.valueOf(dateFinStr)); } catch (Exception ignored) {}
                    }
                    CGenUtil.save(exp);
                }
            }
%>
<script>window.location.href='<%= lien %>?but=profil/experience-saisie.jsp&refuser=<%= refuser %>';</script>
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
window.location.href='<%= lien2 %>?but=profil/experience-saisie.jsp&refuser=<%= ref2 %>';</script>
<%
    }
%>
