<%-- 
    Document   : analyse-croise
    Created on : 11 mai 2021, 11:05:18
    Author     : nyamp
--%>


<%@page import="mg.mapping.TacheDureeCombineProfile"%>
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

        TacheDureeCombineProfile op = new TacheDureeCombineProfile();
        op.setNomTable("tache_duree_combine_profile");

        String listeCrt[] = {"daty", "projetlib", "responsablelib","idrole","descrole"};
        String listeInt[] = {"daty"};
        String[] pourcentage = {};
        String somDefaut[] = {"duree","dureeExecute","dureeReste"};

        String[] colGr = {"projetlib", "daty"};
        String[] colGrCol = {"responsablelib"};

        PageRechercheGroupe pr = new PageRechercheGroupe(op, request, listeCrt, listeInt, 3, colGr, somDefaut, pourcentage, 3, 1);
        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setApres("analyse/analyse-croise.jsp");
        pr.setLien((String) session.getValue("lien"));
        pr.getFormu().getChamp("responsablelib").setLibelle("Responsable");
        pr.getFormu().getChamp("projetlib").setLibelle("Projet");
        pr.getFormu().getChamp("idrole").setLibelle("Id R&ocirc;le");
        pr.getFormu().getChamp("descrole").setLibelle("R&ocirc;le");
        pr.getFormu().getChamp("daty1").setLibelle("Date min");
        pr.getFormu().getChamp("daty2").setLibelle("Date max");
        pr.getFormu().getChamp("daty1").setDefaut(UtilitaireAcade.dateDuJour());
        pr.getFormu().getChamp("daty2").setDefaut(UtilitaireAcade.dateDuJour());
        pr.setNpp(100);

        pr.creerObjetPageCroise(colGrCol, pr.getLien() + "?but=analyse/analyse-croise.jsp");
%>
<script>
    function changerDesignation() {
        document.analyse.submit();
    }
</script>
<div class="content-wrapper">
    <section class="content-header">
        <h1>Temps estimatif d&apos;ex&eacute;cution des t&acirc;ches par ressource et par projet</h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>" method="get" name="analyse" id="analyse">
            <input type="hidden" name="but" value="<%=pr.getApres()%>" />
            <%out.println(pr.getFormu().getHtmlEnsemble());%>
        </form>
        <div style="margin-bottom:8px; font-size:14px; font-style:italic;">
            Ligne 1 = Temps allou&eacute; en heures &nbsp;&nbsp;|&nbsp;&nbsp;
            Ligne 2 = Temps d&apos;&eacute;xecution allou&eacute; en heures &nbsp;&nbsp;|&nbsp;&nbsp;
            Ligne 3 = Temps restant allou&eacute; en heures
        </div>
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

