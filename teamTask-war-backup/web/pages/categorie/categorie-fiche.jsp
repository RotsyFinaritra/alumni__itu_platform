<%@page import="mg.mapping.annexe.Categorie"%>
<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="affichage.*" %>

<%
    try{
        Categorie categorie;
        categorie = new Categorie();
        PageConsulte pc = new PageConsulte(categorie, request, (user.UserEJB) session.getValue("u"));//ou avec argument liste Libelle si besoin
        pc.setTitre("Fiche cat&eacute;gorie");
        categorie = (Categorie) pc.getBase();
        String id=categorie.getId();
        String pageModif="categorie/categorie-saisie.jsp";
        pc.getChampByName("val").setLibelle("Valeur");
        pc.getChampByName("desce").setLibelle("D&eacute;scription");

%>

<div class="content-wrapper">
    <h1 class="box-title"><%=pc.getTitre()%></h1>
    <div class="row m-0">
        <div class="col-md-6 nopadding">
            <div class="box-fiche">
                <div class="box">
                    <div class="box-body">
                        <%
                            out.println(pc.getHtml());
                        %>
                        <br/>
                        <div class="box-footer" >
                            <a class="btn btn-secondary pull-right"  href="<%=(String) session.getValue("lien") + "?acte=update&classe=mg.mapping.annexe.Categorie&nomtable=categorie&but=categorie/categorie-saisie.jsp&id=" + id%>" style="margin-right: 10px">Modifier</a>
                            <a class="btn btn-danger"  href="<%=(String) session.getValue("lien") + "?but=apresTarif.jsp&acte=delete&classe=mg.mapping.annexe.Categorie&nomtable=categorie&bute=categorie/categorie-liste.jsp&id=" + id%>" style="margin-right: 10px">Supprimer</a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>


</div>

<%}
catch(Exception e){
    e.printStackTrace();
}
%>
