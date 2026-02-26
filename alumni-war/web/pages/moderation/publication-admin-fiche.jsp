<%@page contentType="text/html;charset=UTF-8" %>
<%@page import="bean.PostAdmin" %>
<%@page import="bean.CGenUtil" %>
<%@page import="user.UserEJB" %>
<% try {
    // Vérifier que l'utilisateur est admin
    UserEJB currentUser = (UserEJB) session.getValue("u");
    if (currentUser == null || !"admin".equals(currentUser.getUser().getIdrole())) {
        out.println("<div class='alert alert-danger' style='margin:20px;'><i class='fa fa-exclamation-circle'></i> Acc&egrave;s r&eacute;serv&eacute; aux administrateurs.</div>");
        return;
    }
    
    String lien = (String) session.getValue("lien");
    String id = request.getParameter("id");
    
    // Charger le post pour affichage (vue)
    PostAdmin critereVue = new PostAdmin();
    critereVue.setId(id);
    PostAdmin postVue = null;
    Object[] resultsVue = CGenUtil.rechercher(critereVue, null, null, "");
    if (resultsVue != null && resultsVue.length > 0) {
        postVue = (PostAdmin) resultsVue[0];
    }
    
    if (postVue == null) {
        out.println("<div class='alert alert-warning' style='margin:20px;'>Publication non trouv&eacute;e.</div>");
        return;
    }
    
    boolean estSupprime = postVue.getSupprime() == 1;
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-file-text"></i> D&eacute;tail de la Publication</h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=moderation/moderation-liste.jsp"><i class="fa fa-shield"></i> Mod&eacute;ration</a></li>
            <li><a href="<%=lien%>?but=moderation/publication-admin-liste.jsp"><i class="fa fa-newspaper-o"></i> Publications</a></li>
            <li class="active">D&eacute;tail</li>
        </ol>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-8 col-md-offset-2">
                <div class="box <%= estSupprime ? "box-danger" : "box-primary" %>">
                    <div class="box-header with-border">
                        <h3 class="box-title">
                            <i class="fa fa-info-circle"></i> Publication #<%= id %>
                            <% if (estSupprime) { %>
                            <span class="label label-danger">SUPPRIM&Eacute;E</span>
                            <% } %>
                        </h3>
                    </div>
                    <div class="box-body">
                        <table class="table table-bordered">
                            <tr><th>ID</th><td><%= postVue.getId() %></td></tr>
                            <tr><th>Date</th><td><%= postVue.getCreated_at() %></td></tr>
                            <tr><th>Auteur</th><td><%= postVue.getNom_complet() != null ? postVue.getNom_complet() : "-" %></td></tr>
                            <tr><th>Type</th><td><%= postVue.getType_libelle() != null ? postVue.getType_libelle() : "-" %></td></tr>
                            <tr><th>Statut</th><td><%= postVue.getStatut_libelle() != null ? postVue.getStatut_libelle() : "-" %></td></tr>
                            <tr><th>Contenu</th><td><%= postVue.getContenu() != null ? postVue.getContenu() : "-" %></td></tr>
                            <tr><th>Supprim&eacute;</th><td><%= estSupprime ? "Oui" : "Non" %></td></tr>
                        </table>
                    </div>
                    <div class="box-footer">
                        <a href="<%=lien%>?but=moderation/publication-admin-liste.jsp" class="btn btn-default">
                            <i class="fa fa-arrow-left"></i> Retour &agrave; la liste
                        </a>
                        <% if (!estSupprime) { %>
                        <%-- Lien pour SUPPRIMER --%>
                        <a href="<%=lien%>?but=moderation/publication-action.jsp&action=supprimer&id=<%=id%>&bute=moderation/publication-admin-fiche.jsp%26id=<%=id%>" 
                           class="btn btn-danger pull-right"
                           onclick="return confirm('&Ecirc;tes-vous s&ucirc;r de vouloir supprimer cette publication ?');">
                            <i class="fa fa-trash"></i> Supprimer
                        </a>
                        <% } else { %>
                        <%-- Lien pour RESTAURER --%>
                        <a href="<%=lien%>?but=moderation/publication-action.jsp&action=restaurer&id=<%=id%>&bute=moderation/publication-admin-fiche.jsp%26id=<%=id%>" 
                           class="btn btn-success pull-right"
                           onclick="return confirm('Restaurer cette publication ?');">
                            <i class="fa fa-undo"></i> Restaurer
                        </a>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </section>
</div>
<% } catch (Exception e) {
    e.printStackTrace();
%>
<div class="alert alert-danger" style="margin:20px;">
    <i class="fa fa-exclamation-circle"></i> Erreur: <%=e.getMessage()%>
</div>
<% } %>
