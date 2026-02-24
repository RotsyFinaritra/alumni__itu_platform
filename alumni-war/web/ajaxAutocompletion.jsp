<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="utilitaire.UtilDB" %>
<%
    // Autocomplete AJAX pour les formulaires
    String valeur = request.getParameter("valeur");
    String idchamp = request.getParameter("idchamp");
    String idsuggestion = request.getParameter("idsuggestion");
    String idliste = request.getParameter("idliste");
    String colonne = request.getParameter("colonne");
    String nomclasse = request.getParameter("nomclasse");
    
    if (valeur == null || valeur.trim().isEmpty()) {
        return;
    }
    
    // Mapping nomclasse vers table et colonnes
    String tableName = "";
    String idCol = "id";
    String libelleCol = "libelle";
    
    if (nomclasse != null) {
        if (nomclasse.contains("Entreprise")) {
            tableName = "entreprise";
            libelleCol = "libelle";
        } else if (nomclasse.contains("Domaine")) {
            tableName = "domaine";
        } else if (nomclasse.contains("TypeEmploie") || nomclasse.contains("TypeContrat")) {
            tableName = "type_emploie";
        } else if (nomclasse.contains("Diplome")) {
            tableName = "diplome";
        } else if (nomclasse.contains("Competence")) {
            tableName = "competence";
        } else if (nomclasse.contains("Ecole")) {
            tableName = "ecole";
        } else if (nomclasse.contains("Localisation") || nomclasse.contains("Ville")) {
            tableName = "ville";
            libelleCol = "libelle";
        }
    }
    
    if (tableName.isEmpty()) {
        return;
    }
    
    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();
        String sql = "SELECT " + idCol + ", " + libelleCol + " FROM " + tableName 
                   + " WHERE LOWER(" + libelleCol + ") LIKE LOWER(?) ORDER BY " + libelleCol + " LIMIT 10";
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, "%" + valeur + "%");
        ResultSet rs = ps.executeQuery();
%>
<select id="<%=idliste%>" class="form-control autocomplete-list" 
        onchange="selection('<%=idchamp%>')" 
        onkeypress="selectionEnter(event, '<%=idchamp%>')"
        size="5" style="position:absolute; z-index:1000; width:100%; max-height:200px;">
<%
        while (rs.next()) {
            String id = rs.getString(1);
            String label = rs.getString(2);
%>
    <option value="<%=id%>"><%=label%></option>
<%
        }
        rs.close();
        ps.close();
%>
</select>
<%
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (conn != null) try { conn.close(); } catch(Exception ex) {}
    }
%>