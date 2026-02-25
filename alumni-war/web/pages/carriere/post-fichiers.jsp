<%@page import="bean.CGenUtil"%>
<%@page import="bean.PostFichier"%>
<%@page import="bean.TypeFichier"%>
<%@page import="user.UserEJB"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        
        String postId = request.getParameter("postId");
        String typePost = request.getParameter("type"); // "emploi" ou "stage"
        String butRetour = "carriere/" + typePost + "-fiche.jsp";
        
        if (postId == null || postId.isEmpty()) {
            throw new Exception("postId requis");
        }
        
        // Charger les fichiers existants pour ce post
        PostFichier critere = new PostFichier();
        critere.setPost_id(postId);
        Object[] fichiers = CGenUtil.rechercher(critere, null, null, " AND post_id = '" + postId + "' ORDER BY ordre, created_at");
        
        // Charger les types de fichiers pour la liste déroulante
        TypeFichier tfCritere = new TypeFichier();
        Object[] typesFichiers = CGenUtil.rechercher(tfCritere, null, null, " ORDER BY libelle");
        
        // Dossier pour l'upload
        String dossier = "post_" + postId;
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1>
            <i class="fa fa-file"></i> Fichiers du post
        </h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carrière</a></li>
            <li><a href="<%=lien%>?but=<%=butRetour%>&id=<%=postId%>">Fiche</a></li>
            <li class="active">Fichiers</li>
        </ol>
    </section>
    
    <section class="content">
        <div class="row">
            <div class="col-md-2"></div>
            <div class="col-md-8">
                <!-- Liste des fichiers existants -->
                <div class="box box-info">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa fa-list"></i> Fichiers attachés</h3>
                    </div>
                    <div class="box-body">
                        <% if (fichiers != null && fichiers.length > 0) { %>
                        <table class="table table-striped table-hover">
                            <thead>
                                <tr>
                                    <th>Nom</th>
                                    <th>Type</th>
                                    <th>Taille</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Object obj : fichiers) {
                                    PostFichier pf = (PostFichier) obj;
                                    String taille = "";
                                    if (pf.getTaille_octets() != null) {
                                        long t = pf.getTaille_octets();
                                        if (t < 1024) taille = t + " o";
                                        else if (t < 1024*1024) taille = (t/1024) + " Ko";
                                        else taille = (t/(1024*1024)) + " Mo";
                                    }
                                %>
                                <tr>
                                    <td>
                                        <a href="<%=request.getContextPath()%>/PostFichierServlet?action=download&id=<%=pf.getId()%>" target="_blank">
                                            <i class="fa fa-download"></i> <%=pf.getNom_original()%>
                                        </a>
                                    </td>
                                    <td><%=pf.getMime_type() != null ? pf.getMime_type() : "-"%></td>
                                    <td><%=taille%></td>
                                    <td>
                                        <a class="btn btn-danger btn-sm" 
                                           href="<%=lien%>?but=carriere/delete-post-fichier.jsp&idFichier=<%=pf.getId()%>&postId=<%=postId%>&type=<%=typePost%>"
                                           onclick="return confirm('Supprimer ce fichier ?')">
                                            <i class="fa fa-trash"></i>
                                        </a>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                        <% } else { %>
                        <div class="alert alert-info">
                            <i class="fa fa-info-circle"></i> Aucun fichier attaché à ce post.
                        </div>
                        <% } %>
                    </div>
                </div>
                
                <!-- Formulaire d'upload -->
                <div class="box box-success">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa fa-upload"></i> Ajouter des fichiers</h3>
                    </div>
                    <form action="<%=request.getContextPath()%>/PostFichierServlet" method="post" enctype="multipart/form-data">
                        <div class="box-body">
                            <input type="hidden" name="action" value="upload">
                            <input type="hidden" name="postId" value="<%=postId%>">
                            <input type="hidden" name="type" value="<%=typePost%>">
                            <input type="hidden" name="dossier" value="<%=dossier%>">
                            
                            <div id="fichiersList">
                                <div class="row fichier-row" style="margin-bottom: 10px;">
                                    <div class="col-md-5">
                                        <select name="typeFichier1" class="form-control">
                                            <option value="">-- Type de fichier --</option>
                                            <% if (typesFichiers != null) {
                                                for (Object tf : typesFichiers) {
                                                    TypeFichier typeFichier = (TypeFichier) tf;
                                            %>
                                            <option value="<%=typeFichier.getId()%>"><%=typeFichier.getLibelle()%></option>
                                            <% }} %>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <input type="file" name="fichier1" class="form-control" required>
                                    </div>
                                    <div class="col-md-1">
                                        <button type="button" class="btn btn-danger btn-sm" onclick="removeFichierRow(this)" style="display:none;">
                                            <i class="fa fa-times"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            
                            <button type="button" class="btn btn-default" onclick="addFichierRow()">
                                <i class="fa fa-plus"></i> Ajouter un autre fichier
                            </button>
                        </div>
                        <div class="box-footer">
                            <button type="submit" class="btn btn-success">
                                <i class="fa fa-upload"></i> Envoyer les fichiers
                            </button>
                            <a href="<%=lien%>?but=<%=butRetour%>&id=<%=postId%>" class="btn btn-default">
                                <i class="fa fa-arrow-left"></i> Retour
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </section>
</div>

<script>
var fichierCount = 1;

function addFichierRow() {
    fichierCount++;
    var html = '<div class="row fichier-row" style="margin-bottom: 10px;">' +
        '<div class="col-md-5">' +
        '<select name="typeFichier' + fichierCount + '" class="form-control">' +
        '<option value="">-- Type de fichier --</option>' +
        <% if (typesFichiers != null) {
            for (Object tf : typesFichiers) {
                TypeFichier typeFichier = (TypeFichier) tf;
        %>
        '<option value="<%=typeFichier.getId()%>"><%=typeFichier.getLibelle()%></option>' +
        <% }} %>
        '</select>' +
        '</div>' +
        '<div class="col-md-6">' +
        '<input type="file" name="fichier' + fichierCount + '" class="form-control">' +
        '</div>' +
        '<div class="col-md-1">' +
        '<button type="button" class="btn btn-danger btn-sm" onclick="removeFichierRow(this)">' +
        '<i class="fa fa-times"></i>' +
        '</button>' +
        '</div>' +
        '</div>';
    document.getElementById('fichiersList').insertAdjacentHTML('beforeend', html);
}

function removeFichierRow(btn) {
    btn.closest('.fichier-row').remove();
}
</script>
<%
    } catch (Exception e) {
        e.printStackTrace();
%>
<div class="alert alert-danger">
    Erreur : <%=e.getMessage()%>
</div>
<%
    }
%>
