<%@ page import="user.*" %>
<%@ page import="bean.*" %>
<%@ page import="affichage.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        
        // Détection mode popup - si lien est null ou contient modulePopup
        boolean isPopup = lien == null || lien.contains("modulePopup");
        String champReturn = request.getParameter("champReturn");
        String champUrl = request.getParameter("champUrl");
        
        // Si lien est null, utiliser un lien par défaut
        if (lien == null) {
            lien = "modulePopup.jsp";
        }
        
        Entreprise a = new Entreprise();
        PageInsert pi = new PageInsert(a, request, u);
        pi.setLien(lien);

        // Configuration des libellés - avec null checks
        if (pi.getFormu().getChamp("libelle") != null) {
            pi.getFormu().getChamp("libelle").setLibelle("Nom de l'entreprise *");
        }
        if (pi.getFormu().getChamp("description") != null) {
            pi.getFormu().getChamp("description").setLibelle("Description");
        }
        if (pi.getFormu().getChamp("idville") != null) {
            pi.getFormu().getChamp("idville").setLibelle("Ville");
            pi.getFormu().getChamp("idville").setPageAppelComplete("bean.Ville", "id", "ville");
        }

        // Masquer l'ID (auto-généré)
        if (pi.getFormu().getChamp("id") != null) {
            pi.getFormu().getChamp("id").setVisible(false);
        }

        // Ordre des champs
        String[] ordre = {"libelle", "idville", "description"};
        pi.getFormu().setOrdre(ordre);

        // Variables de navigation
        String classe = "bean.Entreprise";
        String butApresPost = "carriere/entreprise-saisie.jsp";
        String nomTable = "ENTREPRISE";

        // Générer les affichages
        pi.preparerDataFormu();
        pi.getFormu().makeHtmlInsertTabIndex();
%>
<div class="<%= isPopup ? "" : "content-wrapper" %>">
    <% if (!isPopup) { %>
    <section class="content-header">
        <div class="container-fluid">
            <h1><i class="fa fa-building"></i> Ajouter une entreprise</h1>
        </div>
    </section>
    <% } %>
    <section class="content">
        <div class="<%= isPopup ? "" : "container-fluid" %>">
            <div class="card card-info">
                <div class="card-header">
                    <h3 class="card-title"><i class="fa fa-building"></i> 
                        <%= isPopup ? "Nouvelle entreprise" : "Informations de l'entreprise" %>
                    </h3>
                </div>
                <form action="<%=pi.getLien()%>?but=apresTarif.jsp" method="post" name="<%=nomTable%>" id="<%=nomTable%>" data-parsley-validate>
                    <div class="card-body">
                        <%
                            out.println(pi.getFormu().getHtmlInsert());
                        %>
                        <input name="acte" type="hidden" value="insert">
                        <input name="bute" type="hidden" value="<%= butApresPost %>">
                        <input name="classe" type="hidden" value="<%= classe %>">
                        <input name="nomtable" type="hidden" value="<%= nomTable %>">
                        <% if (isPopup && champReturn != null) { %>
                        <input name="champReturn" type="hidden" value="<%= champReturn %>">
                        <input name="champUrl" type="hidden" value="<%= champUrl %>">
                        <% } %>
                    </div>
                    <div class="card-footer">
                        <button type="submit" class="btn btn-info">
                            <i class="fa fa-floppy-o"></i> Enregistrer
                        </button>
                        <% if (isPopup) { %>
                        <button type="button" class="btn btn-secondary" onclick="window.close();">
                            <i class="fa fa-times"></i> Annuler
                        </button>
                        <% } %>
                    </div>
                </form>
            </div>
        </div>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<div class="alert alert-danger">
    Erreur : <%= e.getMessage() %>
</div>
<%
    }
%>
