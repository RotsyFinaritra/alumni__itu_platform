<%@page import="affichage.PageRecherche"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="bean.DonationLibCPL" %>
<%@ page import="utilitaire.Utilitaire" %>

<% try{
    DonationLibCPL t = new DonationLibCPL();
    t.setNomTable("donationlibcpl_mobilemoney");
    String listeCrt[] = {"id", "daty","nom","desce" ,"idEntiteDonateurLib", "idcategoriedonateurlib","idcategorielib", "idprojetlib"};
    String listeInt[] = {"daty"};
    String libEntete[] = {"daty", "nom","desce","idEntiteDonateurLib","idcategorielib" , "idcategoriedonateurlib","idprojetlib", "QteLettre", "montant"};
    PageRecherche pr = new PageRecherche(t, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Liste des dons num&eacute;raires - Entreprise");
    pr.setUtilisateur((user.UserEJB) session.getValue("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("donation/donation-liste.jsp");
    pr.getFormu().getChamp("id").setLibelle("Id");
    pr.getFormu().getChamp("daty1").setLibelle("Date Min");
    pr.getFormu().getChamp("daty2").setLibelle("Date Max");
    pr.getFormu().getChamp("daty1").setDefaut(Utilitaire.getDebutAnnee(Utilitaire.getAnnee(Utilitaire.dateDuJour())));
    pr.getFormu().getChamp("daty2").setDefaut(Utilitaire.dateDuJour());
    pr.getFormu().getChamp("desce").setLibelle("Description");
    pr.getFormu().getChamp("idcategoriedonateurlib").setLibelle("Cat&eacute;gorie donateur");
    pr.getFormu().getChamp("idCategorielib").setLibelle("Cat&eacute;gorie");
    pr.getFormu().getChamp("idprojetlib").setLibelle("Projet");
    pr.setNpp(50);
    String[] colSomme = {"montant"};
    pr.creerObjetPage(libEntete, colSomme);

    //Definition des lienTableau et des colonnes de lien
    String lienTableau[] = {};
    String colonneLien[] = {};
    String[] attributLien = {};
    pr.getTableau().setLien(lienTableau);
    pr.getTableau().setAttLien(attributLien);
    pr.getTableau().setColonneLien(colonneLien);
    String libEnteteAffiche[] = {"Date", "Donateur","Description","Entit&eacute; donateur","Cat&eacute;gorie" , "Cat&eacute;gorie donateur","Cadre", "Quantit&eacute;", "Montant"};
    pr.getTableau().setLibelleAffiche(libEnteteAffiche);
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1><%= pr.getTitre() %></h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=<%= pr.getApres() %>" method="post">
            <%
                out.println(pr.getFormu().getHtmlEnsemble());
            %>
        </form>
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



