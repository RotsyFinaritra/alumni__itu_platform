<%@ page import="bean.CompetenceUtilisateur, bean.CGenUtil" %>
<%@ page import="user.UserEJB" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.Connection, java.sql.PreparedStatement" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String refuser = request.getParameter("refuser");
        if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
        int refuserInt = Integer.parseInt(refuser);
        String acte = request.getParameter("acte");

        if ("delete".equalsIgnoreCase(acte)) {
            String idcompetence = request.getParameter("idcompetence");
            if (idcompetence != null && !idcompetence.isEmpty()) {
                Connection conn = null;
                PreparedStatement ps = null;
                try {
                    conn = new UtilDB().GetConn();
                    ps = conn.prepareStatement(
                        "DELETE FROM competence_utilisateur WHERE idcompetence = ? AND idutilisateur = ?"
                    );
                    ps.setString(1, idcompetence);
                    ps.setInt(2, refuserInt);
                    ps.executeUpdate();
                } finally {
                    if (ps != null) try { ps.close(); } catch (Exception ignored) {}
                    if (conn != null) try { conn.close(); } catch (Exception ignored) {}
                }
            }
%>
<script>window.location.href='<%= lien %>?but=profil/competence-saisie.jsp&refuser=<%= refuser %>';</script>
<%
            return;
        }

        if ("insertCompetences".equalsIgnoreCase(acte)) {
            String[] ids = request.getParameterValues("ids");

            if (ids != null) {
                for (String idx : ids) {
                    String idcomp = request.getParameter("idcompetence_" + idx);
                    if (idcomp != null && !idcomp.trim().isEmpty()) {
                        CompetenceUtilisateur check = new CompetenceUtilisateur();
                        check.setIdcompetence(idcomp);
                        check.setIdutilisateur(refuserInt);
                        Object[] existing = CGenUtil.rechercher(check, null, null,
                            " AND idcompetence = '" + idcomp + "' AND idutilisateur = " + refuserInt);
                        if (existing == null || existing.length == 0) {
                            CompetenceUtilisateur cu = new CompetenceUtilisateur();
                            cu.setIdcompetence(idcomp);
                            cu.setIdutilisateur(refuserInt);
                            CGenUtil.save(cu);
                        }
                    }
                }
            }
%>
<script>window.location.href='<%= lien %>?but=profil/competence-saisie.jsp&refuser=<%= refuser %>';</script>
<%
            return;
        }
%>
<script>window.location.href='<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= refuser %>';</script>
<%
    } catch (Exception e) {
        e.printStackTrace();
        String lien = (String) session.getValue("lien");
        String refuser = request.getParameter("refuser");
%>
<script>alert('Erreur: <%= e.getMessage() != null ? e.getMessage().replace("'", "\\\\'" ) : "erreur inconnue" %>'); window.location.href='<%= lien %>?but=profil/competence-saisie.jsp&refuser=<%= refuser %>';</script>
<%
    }
%>
