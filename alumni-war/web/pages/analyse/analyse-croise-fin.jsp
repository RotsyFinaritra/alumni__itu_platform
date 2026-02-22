<%@page import="mg.mapping.TacheLibComplet"%>
<%@page import="affichage.PageRechercheGroupe"%>
<%
    try {

        TacheLibComplet lv = new TacheLibComplet();
        lv.setNomTable("tache_fin");
        
        String listeCrt[] = {"datyfin", "projetlib", "responsablelib"};
        String listeInt[] = {"datyfin"};

        String[] pourcentage = {};
        String somDefaut[] ={"duree"}; //sum
        
        String colDefaut[] =  {"responsablelib"}; // colonne
        String[] colGrCol = {"projetlib", "datyfin"}; //ligne
        
        PageRechercheGroupe pr = new PageRechercheGroupe(lv, request, listeCrt, listeInt, 3, colGrCol, somDefaut, pourcentage, colDefaut.length, 0);
        
        pr.setUtilisateur((user.UserEJB) session.getValue("u"));
        pr.setLien((String) session.getValue("lien"));
        
        pr.getFormu().getChamp("responsablelib").setLibelle("Responsable");
        pr.getFormu().getChamp("projetlib").setLibelle("Projet");
        
        pr.getFormu().getChamp("datyfin1").setLibelle("Date Fin min");
        pr.getFormu().getChamp("datyfin2").setLibelle("Date Fin max");
       
    
        pr.setApres("analyse/analyse-croise-fin.jsp");
        pr.creerObjetPageCroise(colDefaut, pr.getLien()+"?but="+pr.getApres());
%>

<div class="content-wrapper">
    <section class="content-header">
        <h1>Analyse T�ches finalis�es</h1>
    </section>
    <section class="content">
        <form action="<%=pr.getLien()%>?but=<%= pr.getApres()%>" method="post" name="formulaire" id="analyse">
            <%out.println(pr.getFormu().getHtmlEnsemble());%>
        </form>
        <%
            out.println(pr.getTableauRecap().getHtml());%>
        <br>
        <%
            out.println(pr.getTableau().getHtml());
        %>
    </section>
</div>
        <script>
            $('#btnListe').click(function(){
               if(document.getElementById("fin2").value !== "" && document.getElementById("fin2").value.toLocaleString().includes(":") == false){
                   document.getElementById("fin2").value = document.getElementById("fin2").value+" 23:59:59";
               }
            });
            
            document.getElementById("fin2").value = document.getElementById("fin2").value.toLocaleString().split(' ')[0];
        </script>
<%
    } catch (Exception e) {
        e.printStackTrace();
    }
%>