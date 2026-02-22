<%-- 
    Document   : analyse-croise
    Created on : 11 mai 2021, 11:05:18
    Author     : nyamp
--%>


<%@page import="mg.mapping.TacheLibComplet"%>
<%@ page import="user.*" %>
<%@page import="affichage.Liste"%>
<%@ page import="bean.*" %>
<%@page import="bean.TypeObjet"%>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>

<%@ page import="affichage.*" %>
<%@ page contentType="text/html; charset=iso-8859-1" language="java" import="java.sql.*" errorPage="" %>

<%
    try {

        TacheLibComplet op = new TacheLibComplet();
        op.setNomTable("tache_libcomplet");

        String listeCrt[] = {"daty", "projetlib", "responsablelib"};
        String listeInt[] = {"daty"};
        String[] pourcentage = {};
        String somDefaut[] = {"duree"};

        String[] colGr = {"projetlib"};
        String[] colGrCol = {"responsablelib"};

        PageRechercheGroupe pr = new PageRechercheGroupe(op, request, listeCrt, listeInt, 3, colGr, somDefaut, pourcentage, 3, 1);
        pr.setNpp(50);
        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setApres("analyse/analyse-croise.jsp");
        pr.setLien((String) session.getValue("lien"));
        pr.getFormu().getChamp("responsablelib").setLibelle("Responsable");
        pr.getFormu().getChamp("projetlib").setLibelle("Projet");
        pr.getFormu().getChamp("daty1").setLibelle("Date min");
        pr.getFormu().getChamp("daty2").setLibelle("Date max");
        pr.getFormu().getChamp("daty1").setDefaut(UtilitaireAcade.dateDuJour());
        pr.getFormu().getChamp("daty2").setDefaut(UtilitaireAcade.dateDuJour());

        pr.creerObjetPageCroise(colGrCol, pr.getLien() + "?but=analyse/analyse-croise.jsp");
%>
<script>
    function changerDesignation() {
        document.analyse.submit();
    }
</script>
<div class="content-wrapper">
    <section class="content-header">
        <h1>Analyse croiser</h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>" method="get" name="analyse" id="analyse">
            <input type="hidden" name="but" value="<%=pr.getApres()%>" />
            <%out.println(pr.getFormu().getHtmlEnsemble());%>
        </form>
        <%

            String lienTableau[] = {pr.getLien() + "?but=tache/tache-fiche.jsp", pr.getLien() + "?but=tache/tache-mere.jsp"};
            String colonneLien[] = {"id", "idmere"};
            String varColonneLien[] = {"id", "id"};
            pr.getTableau().setLien(lienTableau);
            pr.getTableau().setLien(lienTableau);
            pr.getTableau().setColonneLien(colonneLien);
        %>
        <br>
        <%
//            out.println(pr.getTableau().getHtml());
//            out.println(pr.getBasPage());
//            out.println(pr.getInsertLienModal());
            out.println(pr.getTableauRecap().getHtml());
            out.println(pr.getTableau().getHtml());
        %>
    </section>
</div>
<%
} catch (Exception e) {
    e.printStackTrace();
%>
<script language="JavaScript">
    alert('<%=e.getMessage()%>');
    history.back();</script>
    <% }%>

