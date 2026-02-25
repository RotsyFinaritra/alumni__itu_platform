<%@page import="bean.CGenUtil"%>
<%@page import="bean.PostFichier"%>
<%@page import="utilitaire.UtilDB"%>
<%@page import="java.sql.Connection"%>
<%@page import="java.io.File"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    try {
        String lien = (String) session.getValue("lien");
        String idFichier = request.getParameter("idFichier");
        String postId = request.getParameter("postId");
        String typePost = request.getParameter("type");
        
        if (idFichier == null || idFichier.isEmpty()) {
            throw new Exception("idFichier requis");
        }
        
        Connection conn = new UtilDB().GetConn();
        try {
            conn.setAutoCommit(false);
            
            // Récupérer le fichier
            PostFichier critere = new PostFichier();
            Object[] fichiers = CGenUtil.rechercher(critere, null, null, conn, " AND id = '" + idFichier + "'");
            
            if (fichiers != null && fichiers.length > 0) {
                PostFichier pf = (PostFichier) fichiers[0];
                
                // Supprimer le fichier physique
                if (pf.getChemin() != null) {
                    File file = new File(pf.getChemin());
                    if (file.exists()) {
                        file.delete();
                    }
                }
                
                // Supprimer l'enregistrement
                pf.deleteToTable(conn);
            }
            
            conn.commit();
        } catch (Exception e) {
            conn.rollback();
            throw e;
        } finally {
            conn.close();
        }
%>
<script language="JavaScript">
    document.location.replace("<%=lien%>?but=carriere/post-fichiers.jsp&postId=<%=postId%>&type=<%=typePost%>");
</script>
<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<div class="alert alert-danger">
    Erreur : <%=e.getMessage()%>
</div>
<%
    }
%>
