<%@ page import="bean.UtilisateurSpecialite, bean.CGenUtil" %>
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
            String idspecialite = request.getParameter("idspecialite");
            if (idspecialite != null && !idspecialite.isEmpty()) {
                Connection conn = null;
                PreparedStatement ps = null;
                try {
                    conn = new UtilDB().GetConn();
                    ps = conn.prepareStatement(
                        "DELETE FROM utilisateur_specialite WHERE idspecialite = ? AND idutilisateur = ?"
                    );
                    ps.setString(1, idspecialite);
                    ps.setInt(2, refuserInt);
                    ps.executeUpdate();
                } finally {
                    if (ps != null) try { ps.close(); } catch (Exception ignored) {}
                    if (conn != null) try { conn.close(); } catch (Exception ignored) {}
                }
            }
%>
<script>window.location.href='<%= lien %>?but=profil/specialite-saisie.jsp&refuser=<%= refuser %>';</script>
<%
            return;
        }

        if ("insertSpecialites".equalsIgnoreCase(acte)) {
            String[] ids = request.getParameterValues("ids");

            if (ids != null) {
                for (String idx : ids) {
                    String idspec = request.getParameter("idspecialite_" + idx);
                    if (idspec != null && !idspec.trim().isEmpty()) {
                        UtilisateurSpecialite check = new UtilisateurSpecialite();
                        check.setIdspecialite(idspec);
                        check.setIdutilisateur(refuserInt);
                        Object[] existing = CGenUtil.rechercher(check, null, null,
                            " AND idspecialite = '" + idspec + "' AND idutilisateur = " + refuserInt);
                        if (existing == null || existing.length == 0) {
                            UtilisateurSpecialite us = new UtilisateurSpecialite();
                            us.setIdspecialite(idspec);
                            us.setIdutilisateur(refuserInt);
                            CGenUtil.save(us);
                        }
                    }
                }
            }
%>
<script>window.location.href='<%= lien %>?but=profil/specialite-saisie.jsp&refuser=<%= refuser %>';</script>
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
<script>alert('Erreur: <%= e.getMessage() != null ? e.getMessage().replace("'", "\\\\'" ) : "erreur inconnue" %>'); window.location.href='<%= lien %>?but=profil/specialite-saisie.jsp&refuser=<%= refuser %>';</script>
<%
    }
%>
