


<%@page import="mg.mapping.TacheMereLibCompletIsa"%>
<%@page import="affichage.PageRechercheGroupe"%>
<%@ page import="utilitaireAcade.UtilitaireAcade" %>
<%@ page import="com.google.gson.Gson" %>
<%
    try {

        TacheMereLibCompletIsa lv = new TacheMereLibCompletIsa();
        lv.setNomTable("tachemere_libcomplet2_isa");

        String listeCrt[] = {"datedemande","datedebut", "projetlib","valfonctionnalite"};
        String listeInt[] = {"datedemande","datedebut"};

        String[] pourcentage = {};
        String somDefaut[] ={"isa"}; //sum

        String colDefaut[] =  {"datedemande"}; // colonne
        String[] colGrCol = {"valfonctionnalite","designation"}; //ligne

        PageRechercheGroupe pr = new PageRechercheGroupe(lv, request, listeCrt, listeInt, 3, colGrCol, somDefaut, pourcentage, colDefaut.length, 0);

        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setLien((String) session.getValue("lien"));

        pr.getFormu().getChamp("projetlib").setLibelle("Projet");

        pr.getFormu().getChamp("datedemande1").setLibelle("Date fin min");
        pr.getFormu().getChamp("datedemande2").setLibelle("Date fin max");
        pr.getFormu().getChamp("datedemande1").setDefaut(UtilitaireAcade.dateDuJour());
        pr.getFormu().getChamp("datedemande2").setDefaut(UtilitaireAcade.dateDuJour());

        pr.getFormu().getChamp("datedebut1").setLibelle("Date d&eacute;but min");
        pr.getFormu().getChamp("datedebut2").setLibelle("Date d&eacute;but max");
        pr.getFormu().getChamp("datedebut1").setDefaut(UtilitaireAcade.dateDuJour());
        pr.getFormu().getChamp("datedebut2").setDefaut(UtilitaireAcade.dateDuJour());
        pr.getFormu().getChamp("valfonctionnalite").setLibelle("Fonctionnalit&eacute;");
        pr.setNpp(5000);

        pr.setApres("analyse/analyse-planning-projet.jsp");
        pr.creerObjetPageCroise(colDefaut, pr.getLien()+"?but="+pr.getApres());
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1>Planning des Projets</h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=<%= pr.getApres()%>" method="post" name="formulaire" id="analyse">
            <%out.println(pr.getFormu().getHtmlEnsemble());%>
        </form>
        <div style="margin-bottom:8px; font-size:14px; font-style:italic;">
            Ligne 1 = Indication de la terminaison de la t&acirc;che
        </div>
        <%
            out.println(pr.getTableauRecap().getHtml());%>
        <br>
        <%
            out.println(pr.getTableau().getHtml());
        %>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>