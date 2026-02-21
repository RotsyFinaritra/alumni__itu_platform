<%--
    Author     : tokinaina_judicael
--%>

<%@page import="utilitaire.*"%>
<%@page import="affichage.*"%>
<%@page import="java.util.Calendar"%>
<%@ page import="bean.DonationLibCPL" %>

<%
    try{
        DonationLibCPL mvt = new DonationLibCPL();

        String listeCrt[] = {"id","daty","nom","idcategorielib", "idcategoriedonateurlib", "idprojetlib" };
        String listeInt[] = {"daty"};
        String[] pourcentage = {};
        String[] colGr = {"idcategoriedonateurlib"};
        String[] colGrCol = {"idcategorielib"};
        String somDefaut[] = {"montant"};

        PageRechercheGroupe pr = new PageRechercheGroupe(mvt, request, listeCrt, listeInt, 3, colGr, somDefaut, pourcentage, colGr.length , somDefaut.length);
        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setLien((String) session.getValue("lien"));
        pr.getFormu().getChamp("daty1").setDefaut(Utilitaire.getDebutAnnee(Utilitaire.getAnnee(Utilitaire.dateDuJour())));
        pr.getFormu().getChamp("daty2").setDefaut(utilitaire.Utilitaire.dateDuJour());
        pr.getFormu().getChamp("daty1").setLibelle("Date Min");
        pr.getFormu().getChamp("daty2").setLibelle("Date max");
        pr.getFormu().getChamp("idcategorielib").setLibelle("Cat&eacute;gorie");
        pr.getFormu().getChamp("idcategoriedonateurlib").setLibelle("Cat&eacute;gorie du donateur");
        pr.getFormu().getChamp("idprojetlib").setLibelle("Projet");
        pr.setNpp(500);
        pr.setApres("donation/donation-analyse.jsp");
        pr.creerObjetPageCroise(colGrCol,pr.getLien()+"?but=donation/donation-liste-all.jsp");
%>
<script>
    function changerDesignation() {
        document.analyse.submit();
    }
    // $(document).ready(function() {
    //     $('.box table tr').each(function() {
    //         $(this).find('td:last, th:last').hide();
    //     });
    // });
</script>
<div class="content-wrapper">
    <section class="content-header">
        <h1>Analyse des donations</h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=donation/donation-analyse.jsp" method="post" name="analyse" id="analyse">
            <%out.println(pr.getFormu().getHtmlEnsemble());%>
        </form>
        <!--        <ul>
                    <li>La premiere ligne correspond au quantite</li>
                    <li>La 2e ligne correspond au montant TTC total</li>
                </ul>-->
        <%
            String lienTableau[] = {};
            pr.getTableau().setLien(lienTableau);
            pr.getTableau().setColonneLien(somDefaut);%>
        <br>
        <%
            out.println(pr.getTableauRecap().getHtml());%>
        <br>
        <%
            out.println(pr.getTableau().getHtml());
            out.println(pr.getBasPage());
        %>
    </section>
</div>
<%
    }catch(Exception e){
        e.printStackTrace();
    }
%>