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
<%@ page import="mg.mapping.etatglobal.EtatTacheJournalierParRessource" %>

<%
    try {

        EtatTacheJournalierParRessource op = new EtatTacheJournalierParRessource();
        op.setNomTable("etat_tache_journalier_par_ressource");

        String listeCrt[] = {"daty","responsable", "nomUser"};
        String listeInt[] = {"daty"};
        String[] pourcentage = {};
        String somDefaut[] = {"nbTache","nbTacheTermine"};

        String[] colGr = {"nomUser"};
        String[] colGrCol = {"daty"};

        PageRechercheGroupe pr = new PageRechercheGroupe(op, request, listeCrt, listeInt, 3, colGr, somDefaut, pourcentage, 3, 1);
        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setApres("analyse/analyse-tache-global.jsp");
        pr.setLien((String) session.getValue("lien"));
        pr.getFormu().getChamp("nomUser").setLibelle("Ressource");
        pr.getFormu().getChamp("responsable").setLibelle("ID Ressource");
        pr.getFormu().getChamp("daty1").setLibelle("Date min");
        pr.getFormu().getChamp("daty2").setLibelle("Date max");
        pr.getFormu().getChamp("daty1").setDefaut(UtilitaireAcade.dateDuJour());
        pr.getFormu().getChamp("daty2").setDefaut(UtilitaireAcade.dateDuJour());
        pr.setNpp(100);

        pr.creerObjetPageCroise(colGrCol, pr.getLien() + "?but=analyse/analyse-tache-global.jsp");
%>
<script>
    function changerDesignation() {
        document.analyse.submit();
    }
</script>
<div class="content-wrapper">
    <section class="content-header">
        <h1>Analyse de nombre des t&acirc;ches assign&eacute;es et accomplies par ressource</h1>
    </section>
    <section class="content">

        <form action="<%=pr.getLien()%>" method="get" name="analyse" id="analyse">
            <input type="hidden" name="but" value="<%=pr.getApres()%>" />
            <%out.println(pr.getFormu().getHtmlEnsemble());%>
        </form>
        <div style="margin-bottom:8px; font-size:14px; font-style:italic;">
            Ligne 1 = Nombre de T&acirc;ches Attribu&eacute; &nbsp;&nbsp;|&nbsp;&nbsp; Ligne 2 = Nombre de T&acirc;ches Termin&eacute;
        </div>
        <div style="font-size:13px; font-style:italic; color:#555;">
            **Ne prend en compte que les t&acirc;ches attribu&eacute;es et termin&eacute;es le m&ecirc;me jour.
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

