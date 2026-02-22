<%@page import="mg.mapping.TacheLibComplet"%>
<%@page import="affichage.PageRechercheGroupe"%>
<%@ page import="utilitaireAcade.UtilitaireAcade" %>
<%

    try {

        TacheLibComplet lv = new TacheLibComplet();
        lv.setNomTable("tache_debuter_etat");
        
        String listeCrt[] = {"projetlib", "responsablelib"};
        String listeInt[] = {};

        String[] pourcentage = {};
        String somDefaut[] ={"duree","tempsTravail","tempsReste"}; //sum
        
        String colDefaut[] =  {"responsablelib"}; // colonne
        String[] colGrCol = {"projetlib","id"}; //ligne
        
        PageRechercheGroupe pr = new PageRechercheGroupe(lv, request, listeCrt, listeInt, 3, colGrCol, somDefaut, pourcentage, colDefaut.length, 0);
        
        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setLien((String) session.getValue("lien"));
        
        pr.getFormu().getChamp("responsablelib").setLibelle("Responsable");
        pr.getFormu().getChamp("projetlib").setLibelle("Projet");
    
        pr.setApres("analyse/analyse-croisee-debut.jsp");
        pr.creerObjetPageCroise(colDefaut, pr.getLien()+"?but="+pr.getApres());
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1>Suivi des dur&eacute;es et de l&rsquo;&eacute;tat d&rsquo;avancement des t&acirc;ches en cours</h1>

    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=<%= pr.getApres()%>" method="post" name="formulaire" id="analyse">
            <%out.println(pr.getFormu().getHtmlEnsemble());%>
        </form>
        <div style="margin-bottom:8px; font-size:14px; font-style:italic;">
            Ligne 1 = Temps estimatif d&apos;&eacute;xecution en minutes &nbsp;&nbsp;|&nbsp;&nbsp;
            Ligne 2 = Dur&eacute;e r&eacute;elle d&apos;&eacute;xecution en minutes &nbsp;&nbsp;|&nbsp;&nbsp;
            Ligne 3 = Dur&eacute;e restant d&apos;&eacute;xecution en minutes
        </div>
        <div style="font-size:13px; font-style:italic; color:#555;">
            &Eacute;cart n&eacute;gative = en retard &nbsp;&nbsp;|&nbsp;&nbsp;
            &Eacute;cart positive = dans les temps
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