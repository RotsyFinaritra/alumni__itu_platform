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
            // Suppression d'une competence individuelle
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
            // Retour a la page competence-saisie
            response.sendRedirect(lien + "?but=profil/competence-saisie.jsp&refuser=" + refuser);
            return;
        }

        if ("insertCompetences".equalsIgnoreCase(acte)) {
            // Insertion des competences cochees dans le PageInsertMultiple
            String[] ids = request.getParameterValues("ids");
            int nombreLigne = Integer.parseInt(request.getParameter("nombreLigne"));

            if (ids != null) {
                for (String idx : ids) {
                    String idcomp = request.getParameter("idcompetence_" + idx);
                    if (idcomp != null && !idcomp.trim().isEmpty()) {
                        // Verifier que la competence n'existe pas deja
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
            // Retour a la page competence-saisie
            response.sendRedirect(lien + "?but=profil/competence-saisie.jsp&refuser=" + refuser);
            return;
        }

        // Action inconnue -> retour au profil
        response.sendRedirect(lien + "?but=profil/mon-profil.jsp&refuser=" + refuser);

    } catch (Exception e) {
        e.printStackTrace();
        String lien = (String) session.getValue("lien");
        String refuser = request.getParameter("refuser");
        session.setAttribute("errorMessage", "Erreur : " + e.getMessage());
        response.sendRedirect(lien + "?but=profil/competence-saisie.jsp&refuser=" + refuser);
    }
%>
