<%@page import="mg.mapping.annexe.Categorie"%>
<%@page import="mg.mapping.annexe.TypeProduit"%>
<%@page import="affichage.Liste"%>
<%@page import="bean.TypeObjet"%>
<%@page import="affichage.PageInsert"%>
<%@page import="utilitaireAcade.UtilitaireAcade"%>
<%
    try{


        String autreparsley = "data-parsley-range='[8, 40]' required";
        Categorie cp = new Categorie();
        cp.setNomTable("CATEGORIE");
        PageInsert pi = new PageInsert(cp, request, (user.UserEJB) session.getValue("u"));
        pi.setLien((String) session.getValue("lien"));

        pi.getFormu().getChamp("val").setLibelle("Valeur");
        pi.getFormu().getChamp("desce").setLibelle("D&eacute;scription");

        pi.preparerDataFormu();


%>
<div class="content-wrapper">
    <% if(request.getParameter("acte") != null && request.getParameter("acte").equalsIgnoreCase("update")) { %>
    <h1 align="center">Modification Phase</h1>
    <% } else { %>
    <h1 align="center">Saisie Cat&eacute;gorie Projet</h1>
    <% } %>
    <form action="<%=pi.getLien()%>?but=apresTarif.jsp" method="post" name="sortie" id="sortie" data-parsley-validate>
        <%
            pi.getFormu().makeHtmlInsertTabIndex();
            out.println(pi.getFormu().getHtmlInsert());
        %>
        <input name="acte" type="hidden" id="acte" value="insert">
        <input name="bute" type="hidden" id="bute" value="categorie/categorie-fiche.jsp">
        <input name="classe" type="hidden" id="classe" value="mg.mapping.annexe.Categorie">
        <input name="nomtable" type="hidden" id="nomtable" value="CATEGORIE">
    </form>
</div>
<%
    }
    catch (Exception e){
        e.printStackTrace();
        throw new RuntimeException(e);
    }
%>