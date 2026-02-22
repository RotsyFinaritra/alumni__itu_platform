<%--
    Document   : analyse-croise
    Created on : 11 mai 2021, 11:05:18
    Author     : nyamp
--%>


<%@ page import="user.*" %>
<%@page import="affichage.Liste"%>
<%@ page import="bean.*" %>
<%@page import="bean.TypeObjet"%>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>

<%@ page import="affichage.*" %>
<%@ page contentType="text/html; charset=iso-8859-1" language="java" import="java.sql.*" errorPage="" %>
<%@ page import="mg.mapping.DecomptePage" %>

<%
    try {

        DecomptePage op = new DecomptePage();
        op.setNomTable("decomptepage");

        String listeCrt[] = {"idProjetLib", "idModuleLib"};
        String listeInt[] = {""};
        String[] pourcentage = {};
        String somDefaut[] = {"nb"};

        String[] colGr = {"idProjetLib", "idModuleLib"};
        String[] colGrCol = {"idTypePageLib"};

        PageRechercheGroupe pr = new PageRechercheGroupe(op, request, listeCrt, listeInt, 3, colGr, somDefaut, pourcentage, 3, 1);
        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setApres("analyse/analyse-decompte-page.jsp");
        pr.setLien((String) session.getValue("lien"));
        pr.getFormu().getChamp("idProjetLib").setLibelle("Projet");
        pr.getFormu().getChamp("idModuleLib").setLibelle("Module");
        pr.setNpp(200);

        pr.creerObjetPageCroise(colGrCol, pr.getLien() + "?but=analyse/analyse-decompte-page.jsp");
%>
<script>
    function changerDesignation() {
        document.analyse.submit();
    }
</script>
<div class="content-wrapper">
    <section class="content-header">
        <h1>Analyse Decompte Page</h1>
    </section>
    <section class="content">

        <form action="<%=pr.getLien()%>" method="get" name="analyse" id="analyse">
            <input type="hidden" name="but" value="<%=pr.getApres()%>" />
            <%out.println(pr.getFormu().getHtmlEnsemble());%>
        </form>
        <div style="margin-bottom:8px; font-size:14px; font-style:italic;">
            Colonne 1: Projet Colonne 2 : Module
        </div>
        <%

            /*String lienTableau[] = {pr.getLien() + "?but=tache/tache-fiche.jsp", pr.getLien() + "?but=tache/tache-mere.jsp"};
            String colonneLien[] = {"id", "idmere"};
            String varColonneLien[] = {"id", "id"};
            pr.getTableau().setLien(lienTableau);
            pr.getTableau().setLien(lienTableau);
            pr.getTableau().setColonneLien(colonneLien);*/
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

