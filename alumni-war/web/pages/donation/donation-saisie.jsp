<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>
<%@ page import="constanteAcade.ConstanteAcade" %>
<%
    try {
        Donation a = new Donation();
        PageInsert pi = new PageInsert(a, request, (user.UserEJB) session.getValue("u"));
        pi.setLien((String) session.getValue("lien"));
        Liste[] listes = new Liste[4];
        TypeObjet categ = new TypeObjet();
        categ.setNomTable("categorie");
        listes[0] = new Liste("idCategorie", categ, "val", "id");
        TypeObjet categDon = new TypeObjet();
        categDon.setNomTable("categorieDonateur");
        listes[1] = new Liste("idCategorieDonateur", categDon, "val", "id");
        TypeObjet projet = new TypeObjet();
        projet.setNomTable("projet");
        listes[2] = new Liste("idProjet", projet, "val", "id");

        TypeObjet recepteur = new TypeObjet();
        recepteur.setNomTable("recepteur");
        listes[3] = new Liste("idRecepteur", recepteur, "val", "id");
        pi.getFormu().changerEnChamp(listes);
        //Modification des affichages
        pi.getFormu().getChamp("daty").setLibelle("Date");
        pi.getFormu().getChamp("daty").setDefaut(Utilitaire.dateDuJour());
        pi.getFormu().getChamp("desce").setLibelle("Description");
        pi.getFormu().getChamp("idCategorie").setLibelle("Cat&eacute;gorie");
        pi.getFormu().getChamp("qte").setLibelle("Quantit&eacute;");
        pi.getFormu().getChamp("qte").setDefaut("1");
        pi.getFormu().getChamp("idCategorieDonateur").setLibelle("Cat&eacute;gorie du donateur");
        pi.getFormu().getChamp("idProjet").setLibelle("Projet");
        pi.getFormu().getChamp("idEntiteDonateur").setPageAppelComplete("bean.TypeObjet","id","entiteDonateur","","");
        pi.getFormu().getChamp("idRecepteur").setLibelle("R&eacute;cepteur");
        pi.getFormu().getChamp("numeroPiece").setLibelle("Num&eacute;ro de Pi&egrave;ce");
        pi.getFormu().getChamp("idEntiteDonateur").setLibelle("Entit&eacute;");
        pi.getFormu().getChamp("idRecepteur").setDefaut(ConstanteAcade.recepteurEntrepriseAnalamanga);
        pi.getFormu().getChamp("idEntiteDonateur").setDefaut(ConstanteAcade.entiteMada);
        //Variables de navigation
        String classe = "bean.Donation";
        String butApresPost = "donation/donation-saisie.jsp";
        String nomTable = "DONATION";
        String[] ordre = {"nom", "desce", "montant", "qte", "idCategorie", "idCategorieDonateur", "idProjet", "daty"};
        pi.getFormu().setOrdre(ordre);
        //Generer les affichages
        pi.preparerDataFormu();
        pi.getFormu().makeHtmlInsertTabIndex();
%>
<div class="content-wrapper">
    <h1 align="center">Saisie donation</h1>
    <form action="<%=pi.getLien()%>?but=apresTarif.jsp" method="post"  data-parsley-validate>
        <%
            out.println(pi.getFormu().getHtmlInsert());
        %>
        <input name="acte" type="hidden" id="nature" value="insert">
        <input name="bute" type="hidden" id="bute" value="<%= butApresPost %>">
        <input name="classe" type="hidden" id="classe" value="<%= classe %>">
        <input name="nomtable" type="hidden" id="nomtable" value="<%= nomTable %>">
    </form>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
    } %>

