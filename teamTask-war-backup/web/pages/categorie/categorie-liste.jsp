<%@page import="mg.mapping.annexe.Categorie"%>
<%@page import="user.UserEJB"%>
<%@page import="affichage.PageRecherche"%>

<%
    try {
        Categorie liste = new Categorie();

        UserEJB u = (user.UserEJB) session.getValue("u");

        String libEntete[] = {"id","val","desce"};
        String listeCrt[] = {"id","val","desce"};
        String listeInt[] = {};
        PageRecherche pr = new PageRecherche(liste, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setLien((String) session.getValue("lien"));


        pr.setApres("categorie/categorie-liste.jsp");
        //pr.setOrdre(" order by daty desc");
        String[] colSomme = null;
        pr.creerObjetPage(libEntete, colSomme);
%>

<%@page contentType="text/html"%>
<div class="content-wrapper">
    <section class="content-header">
        <h1>Liste des categories</h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=categorie/categorie-liste.jsp" method="post" name="prestation" id="prestation">
            <%
                out.println(pr.getFormu().getHtmlEnsemble());
            %>
            <div class="col-md-4"></div>
            <div class="col-md-4"></div>
        </form>
        <%  String lienTableau[] = {pr.getLien() + "?but=categorie/categorie-fiche.jsp"};
            String colonneLien[] = {"id"};
            pr.getTableau().setLien(lienTableau);
            pr.getTableau().setColonneLien(colonneLien);
            out.println(pr.getTableauRecap().getHtml());%>
        <br>
        <%
            String libEnteteAffiche[] = {"id","valeur","description"};
            pr.getTableau().setLibelleAffiche(libEnteteAffiche);
            out.println(pr.getTableau().getHtml());
            out.println(pr.getBasPage());
        %>
    </section>
</div>
<% } catch(Exception e) {
    e.printStackTrace();
} %>