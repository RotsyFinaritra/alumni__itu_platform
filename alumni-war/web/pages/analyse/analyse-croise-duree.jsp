


<%@page import="mg.mapping.TacheLibComplet"%>
<%@page import="affichage.PageRechercheGroupe"%>
<%@ page import="utilitaireAcade.UtilitaireAcade" %>
<%@ page import="com.google.gson.Gson" %>
<%
    try {

        TacheLibComplet lv = new TacheLibComplet();
        lv.setNomTable("tache_fin_duree");
        
        String listeCrt[] = {"datydebut","datyfin", "projetlib", "responsablelib"};
        String listeInt[] = {"datydebut","datyfin"};

        String[] pourcentage = {};
        String somDefaut[] ={"duree","dureeTacheReel","ecart"}; //sum
        
        String colDefaut[] =  {"responsablelib"}; // colonne
        String[] colGrCol = {"projetlib","datyfin"}; //ligne
        
        PageRechercheGroupe pr = new PageRechercheGroupe(lv, request, listeCrt, listeInt, 3, colGrCol, somDefaut, pourcentage, colDefaut.length, 0);
        
        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setLien((String) session.getValue("lien"));
        
        pr.getFormu().getChamp("responsablelib").setLibelle("Responsable");
        pr.getFormu().getChamp("projetlib").setLibelle("Projet");
        
        pr.getFormu().getChamp("datyfin1").setLibelle("Date Fin min");
        pr.getFormu().getChamp("datyfin2").setLibelle("Date Fin max");
        pr.getFormu().getChamp("datyfin1").setDefaut(UtilitaireAcade.dateDuJour());
        pr.getFormu().getChamp("datyfin2").setDefaut(UtilitaireAcade.dateDuJour());

        pr.getFormu().getChamp("datydebut1").setLibelle("Date D&eacute;but min");
        pr.getFormu().getChamp("datydebut2").setLibelle("Date D&eacute;but max");
        pr.getFormu().getChamp("datydebut1").setDefaut(UtilitaireAcade.dateDuJour());
        pr.getFormu().getChamp("datydebut2").setDefaut(UtilitaireAcade.dateDuJour());
        pr.setNpp(5000);
    
        pr.setApres("analyse/analyse-croise-duree.jsp");
        pr.creerObjetPageCroise(colDefaut, pr.getLien()+"?but="+pr.getApres());
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1>Temps estimatif et effectifs d&apos;ex&eacute;cution des t&acirc;ches</h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=<%= pr.getApres()%>" method="post" name="formulaire" id="analyse">
            <%out.println(pr.getFormu().getHtmlEnsemble());%>
        </form>
        <div style="margin-bottom:8px; font-size:14px; font-style:italic;">
            Ligne 1 = Temps estimatif d&apos;&eacute;xecution en heures &nbsp;&nbsp;|&nbsp;&nbsp;
            Ligne 2 = Temps r&eacute;elle d&apos;&eacute;xecution en heures &nbsp;&nbsp;|&nbsp;&nbsp;
            Ligne 3 = &Eacute;cart d&apos;&eacute;xecution en minutes
        </div>
        <div style="font-size:13px; font-style:italic; color:#555;">
            &Eacute;cart n&eacute;gative = t&acirc;che termin&eacute;e plus t&ocirc;t que pr&eacute;vu &nbsp;&nbsp;|&nbsp;&nbsp;
            &Eacute;cart positive = t&acirc;che termin&eacute;e plus tard que pr&eacute;vu
            <br>
            **Prend en compte les t&acirc;ches attribu&eacute;es et termin&eacute;es &agrave; des jours diff&eacute;rents
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