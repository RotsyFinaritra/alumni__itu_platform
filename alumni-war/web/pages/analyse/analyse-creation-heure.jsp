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
<%@ page import="mg.mapping.etatglobal.AnalyseCreationHeure" %>

<%
    try {

        AnalyseCreationHeure op = new AnalyseCreationHeure();

        String listeCrt[] = {"idcplib","daty", "heure"};
        String listeInt[] = {"daty","heure"};
        String[] pourcentage = {};
        String somDefaut[] = {"nb_taches","somme_duree","nb_devs"};

        String[] colGr = {"idcplib"};
        String[] colGrCol = {"daty","heure"};

        PageRechercheGroupe pr = new PageRechercheGroupe(op, request, listeCrt, listeInt, 3, colGr, somDefaut, pourcentage, 3, 1);
        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setApres("analyse/analyse-creation-heure.jsp");
        pr.setLien((String) session.getValue("lien"));
        pr.getFormu().getChamp("idcplib").setLibelle("CP");
        pr.getFormu().getChamp("heure1").setLibelle("Heure min");
        pr.getFormu().getChamp("heure2").setLibelle("Heure max");
        pr.getFormu().getChamp("daty1").setLibelle("Date min");
        pr.getFormu().getChamp("daty2").setLibelle("Date max");
        pr.getFormu().getChamp("daty1").setDefaut(UtilitaireAcade.dateDuJour());
        pr.getFormu().getChamp("daty2").setDefaut(UtilitaireAcade.dateDuJour());
        pr.setNpp(100);

        pr.creerObjetPageCroise(colGrCol, pr.getLien() + "?but=analyse/analyse-creation-heure.jsp");
%>
<script>
    function changerDesignation() {
        document.heureahalyse.submit();
    }
</script>
<div class="content-wrapper">
    <section class="content-header">
        <h1>Analyse de cr&eacute;ation des t&acirc;ches par ressource par heure</h1>
    </section>
    <section class="content">

        <form action="<%=pr.getLien()%>" method="get" name="heureahalyse" id="heureahalyse">
            <input type="hidden" name="but" value="<%=pr.getApres()%>" />
            <%out.println(pr.getFormu().getHtmlEnsemble());%>
        </form>
        <div style="margin-bottom:8px; font-size:14px; font-style:italic;">
            Ligne 1 = Nombre de t&acirc;ches cr&eacute;&eacute; &nbsp;&nbsp;|&nbsp;&nbsp;
            Ligne 2 = Dur&eacute;e estimatif d&apos;&eacute;xecution en heures &nbsp;&nbsp;|&nbsp;&nbsp;
            Ligne 3 = Nombre de ressources utilis&eacute;
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

