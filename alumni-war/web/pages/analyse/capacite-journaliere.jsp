<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="affichage.PageRechercheGroupe"%>
<%@ page import="utilisateurAcade.CapaciteJournaliere" %>
<%@ page import="utilitaireAcade.UtilitaireAcade" %>
<%@ page import="utilitaire.Utilitaire" %>

<% try{ 
    CapaciteJournaliere o = new CapaciteJournaliere();
    o.setNomTable("capaciteJournaliereEstimation");
    String[] listeCrt = {"daty","nomRessource","idrole","idrole"};
    String[] listeInt = {"daty"};
    String[] pourcentage = {};
    String[] colGr = {"nomRessource"};
    String[] colGrCol = {"daty"};
    String[] somDefaut = {"disponibiliteJour","capaciteMaximale","assigne", "reste"};
    PageRechercheGroupe pr = new PageRechercheGroupe(o, request, listeCrt, listeInt, 4, colGr, somDefaut, pourcentage, colGr.length , somDefaut.length);
    pr.setUtilisateur((user.UserEJB) session.getValue("u"));
    pr.setLien((String) session.getValue("lien"));
    pr.setTitre("Capacit&eacute; Journali&egrave;re");
    pr.setApres("analyse/capacite-journaliere.jsp");
    pr.getFormu().getChamp("daty1").setLibelle("Date min");
    pr.getFormu().getChamp("daty2").setLibelle("Date max");
    pr.getFormu().getChamp("nomRessource").setLibelle("Nom Ressource");
    pr.getFormu().getChamp("idrole").setLibelle("Rôle");
    pr.getFormu().getChamp("idrole").setLibelle("Rôle");

    String annee1, mois1, day1, annee2, mois2, day2;
    annee1 = UtilitaireAcade.getAnnee(UtilitaireAcade.dateDuJour());
    mois1 = UtilitaireAcade.getMois(UtilitaireAcade.dateDuJour());
    day1 = UtilitaireAcade.getJour(UtilitaireAcade.dateDuJour());
    String datyVrai1 = mois1 + "/" + day1 + "/" + annee1;

    String aWhere = "";
    if (request.getParameter("daty1") == null) {
        aWhere += " and daty>=to_date('" + datyVrai1 + "','MM/DD/YYYY')";
        pr.getFormu().getChamp("daty1").setDefaut(Utilitaire.dateDuJour());
    }
    if (request.getParameter("daty2") == null) {
        aWhere += " and daty<=to_date('" + datyVrai1 + "','MM/DD/YYYY')";
        pr.getFormu().getChamp("daty2").setDefaut(Utilitaire.dateDuJour());
    }

    pr.setAWhere(aWhere);

    pr.setNpp(500);
    pr.creerObjetPageCroise(colGrCol,pr.getLien()+"?but=capacite-journaliere.jsp");
    String[] lienTableau = {};
    pr.getTableau().setLien(lienTableau);
    pr.getTableau().setColonneLien(somDefaut);
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1><%=pr.getTitre()%></h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=<%= pr.getApres() %>" method="post" name="analyse" id="analyse">
            <%
                out.println(pr.getFormu().getHtmlEnsemble());
            %>
        </form>
        <ul>
            <li>La premi&egrave;re ligne correspond &agrave; la dur&eacute;&eacute; estimatif de la disponibilit&eacute; du jour</li>
            <li>La deuxi&egrave;me ligne correspond &agrave; la dur&eacute;&eacute; r&eacute;elle de la disponibilit&eacute; du jour</li>
            <li>La troisième ligne correspond &agrave; la somme de la durée assignée</li>
            <li>La quatrième ligne correspond à la durée restante qui peut être allouée</li>
        </ul>
        <br>
        <%
            out.println(pr.getTableau().getHtml());
            out.println(pr.getBasPage());
        %>
    </section>
</div>

<% } catch (Exception e) {
  e.printStackTrace();
%>
<script language="JavaScript"> alert('<%=e.getMessage()%>');
    history.back();
</script>
<% }%>

