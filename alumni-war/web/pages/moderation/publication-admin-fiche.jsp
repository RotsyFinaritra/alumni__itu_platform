<%@page contentType="text/html;charset=UTF-8" %>
<%@page import="bean.PostAdmin" %>
<%@page import="bean.Post" %>
<%@page import="bean.CGenUtil" %>
<%@page import="user.UserEJB" %>
<%@page import="java.text.SimpleDateFormat" %>
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
    
    // Charger le post réel pour update (table posts)
    Post critere = new Post();
    critere.setId(id);
    Post post = null;
    Object[] results = CGenUtil.rechercher(critere, null, null, "");
    if (results != null && results.length > 0) {
        post = (Post) results[0];
    }
    
    if (post == null || postVue == null) {
        out.println("<div class='alert alert-warning' style='margin:20px;'>Publication non trouv&eacute;e.</div>");
        return;
    }
    
    boolean estSupprime = post.getSupprime() == 1;
    String dateNow = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date());
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
                        <%-- Formulaire pour SUPPRIMER --%>
                        <form action="<%=lien%>?but=apresTarif.jsp" method="post" style="display:inline;" class="pull-right"
                              onsubmit="return confirm('&Ecirc;tes-vous s&ucirc;r de vouloir supprimer cette publication ?');">
                            <input type="hidden" name="acte" value="update">
                            <input type="hidden" name="classe" value="bean.Post">
                            <input type="hidden" name="nomtable" value="posts">
                            <input type="hidden" name="bute" value="moderation/publication-admin-fiche.jsp">
                            <%-- Tous les champs du bean Post --%>
                            <input type="hidden" name="id" value="<%= post.getId() %>">
                            <input type="hidden" name="idutilisateur" value="<%= post.getIdutilisateur() %>">
                            <input type="hidden" name="idgroupe" value="<%= post.getIdgroupe() != null ? post.getIdgroupe() : "" %>">
                            <input type="hidden" name="idtypepublication" value="<%= post.getIdtypepublication() %>">
                            <%-- Changer statut vers STAT00005 (Supprimé) --%>
                            <input type="hidden" name="idstatutpublication" value="STAT00005">
                            <input type="hidden" name="idvisibilite" value="<%= post.getIdvisibilite() != null ? post.getIdvisibilite() : "" %>">
                            <input type="hidden" name="contenu" value="<%= post.getContenu() != null ? post.getContenu().replace("\"", "&quot;") : "" %>">
                            <input type="hidden" name="epingle" value="<%= post.getEpingle() %>">
                            <%-- Marquer comme supprimé --%>
                            <input type="hidden" name="supprime" value="1">
                            <input type="hidden" name="date_suppression" value="<%= dateNow %>">
                            <input type="hidden" name="nb_likes" value="<%= post.getNb_likes() %>">
                            <input type="hidden" name="nb_commentaires" value="<%= post.getNb_commentaires() %>">
                            <input type="hidden" name="nb_partages" value="<%= post.getNb_partages() %>">
                            <input type="hidden" name="created_at" value="<%= post.getCreated_at() != null ? post.getCreated_at().toString() : "" %>">
                            <input type="hidden" name="edited_at" value="<%= post.getEdited_at() != null ? post.getEdited_at().toString() : "" %>">
                            <input type="hidden" name="edited_by" value="<%= post.getEdited_by() %>">
                            <button type="submit" class="btn btn-danger">
                                <i class="fa fa-trash"></i> Supprimer
                            </button>
                        </form>
                        <% } else { %>
                        <%-- Formulaire pour RESTAURER --%>
                        <form action="<%=lien%>?but=apresTarif.jsp" method="post" style="display:inline;" class="pull-right"
                              onsubmit="return confirm('Restaurer cette publication ?');">
                            <input type="hidden" name="acte" value="update">
                            <input type="hidden" name="classe" value="bean.Post">
                            <input type="hidden" name="nomtable" value="posts">
                            <input type="hidden" name="bute" value="moderation/publication-admin-fiche.jsp">
                            <%-- Tous les champs du bean Post --%>
                            <input type="hidden" name="id" value="<%= post.getId() %>">
                            <input type="hidden" name="idutilisateur" value="<%= post.getIdutilisateur() %>">
                            <input type="hidden" name="idgroupe" value="<%= post.getIdgroupe() != null ? post.getIdgroupe() : "" %>">
                            <input type="hidden" name="idtypepublication" value="<%= post.getIdtypepublication() %>">
                            <%-- Changer statut vers STAT00002 (Publié) --%>
                            <input type="hidden" name="idstatutpublication" value="STAT00002">
                            <input type="hidden" name="idvisibilite" value="<%= post.getIdvisibilite() != null ? post.getIdvisibilite() : "" %>">
                            <input type="hidden" name="contenu" value="<%= post.getContenu() != null ? post.getContenu().replace("\"", "&quot;") : "" %>">
                            <input type="hidden" name="epingle" value="<%= post.getEpingle() %>">
                            <%-- Restaurer --%>
                            <input type="hidden" name="supprime" value="0">
                            <input type="hidden" name="date_suppression" value="">
                            <input type="hidden" name="nb_likes" value="<%= post.getNb_likes() %>">
                            <input type="hidden" name="nb_commentaires" value="<%= post.getNb_commentaires() %>">
                            <input type="hidden" name="nb_partages" value="<%= post.getNb_partages() %>">
                            <input type="hidden" name="created_at" value="<%= post.getCreated_at() != null ? post.getCreated_at().toString() : "" %>">
                            <input type="hidden" name="edited_at" value="<%= post.getEdited_at() != null ? post.getEdited_at().toString() : "" %>">
                            <input type="hidden" name="edited_by" value="<%= post.getEdited_by() %>">
                            <button type="submit" class="btn btn-success">
                                <i class="fa fa-undo"></i> Restaurer
                            </button>
                        </form>
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
