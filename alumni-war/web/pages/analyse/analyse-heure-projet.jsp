


<%@page import="mg.mapping.TacheLibComplet"%>
<%@page import="affichage.PageRechercheGroupe"%>
<%@ page import="utilitaireAcade.UtilitaireAcade" %>
<%@ page import="com.google.gson.Gson" %>
<%
    try {

        TacheLibComplet lv = new TacheLibComplet();
        lv.setNomTable("tache_tous_heure");

        String listeCrt[] = {"daty", "projetlib"};
        String listeInt[] = {"daty"};

        String[] pourcentage = {};
        String somDefaut[] ={"duree","dureetachedouble","ecart"}; //sum

        String colDefaut[] =  {"daty"}; // colonne
        String[] colGrCol = {"projetlib"}; //ligne

        PageRechercheGroupe pr = new PageRechercheGroupe(lv, request, listeCrt, listeInt, 3, colGrCol, somDefaut, pourcentage, colDefaut.length, 0);

        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setLien((String) session.getValue("lien"));

        pr.getFormu().getChamp("projetlib").setLibelle("Projet");

        pr.getFormu().getChamp("daty1").setLibelle("Date min");
        pr.getFormu().getChamp("daty2").setLibelle("Date max");
        pr.getFormu().getChamp("daty1").setDefaut(UtilitaireAcade.dateDuJour());
        pr.getFormu().getChamp("daty2").setDefaut(UtilitaireAcade.dateDuJour());
        pr.setNpp(5000);

        pr.setApres("analyse/analyse-heure-projet.jsp");
        pr.creerObjetPageCroise(colDefaut, pr.getLien()+"?but="+pr.getApres());
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1>Consommation de temps des projets</h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=<%= pr.getApres()%>" method="post" name="formulaire" id="analyse">
            <%out.println(pr.getFormu().getHtmlEnsemble());%>
        </form>
        <div style="margin-bottom:8px; font-size:14px; font-style:italic;">
            Ligne 1 = Temps estimatif d&apos;&eacute;xecution en heures &nbsp;&nbsp;|&nbsp;&nbsp;
            Ligne 2 = Temps r&eacute;elle d&apos;&eacute;xecution en heures &nbsp;&nbsp;|&nbsp;&nbsp;
            Ligne 3 = &Eacute;cart d&apos;&eacute;xecution en heures
        </div>
        <div style="font-size:13px; font-style:italic; color:#555;">
            &Eacute;cart positive = termin&eacute;e plus t&ocirc;t que pr&eacute;vu / reste &nbsp;&nbsp;|&nbsp;&nbsp;
            &Eacute;cart n&eacute;gative = termin&eacute;e plus tard que pr&eacute;vu
            <br>
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