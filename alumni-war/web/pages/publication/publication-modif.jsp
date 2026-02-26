<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.Post" %>
<%@ page import="bean.PostFichier" %>
<%@ page import="bean.TypePublication" %>
<%@ page import="bean.VisibilitePublication" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        if (u == null || lien == null) {
            response.sendRedirect("security-login.jsp");
            return;
        }

        int refuserInt = u.getUser().getRefuser();
        String postId = request.getParameter("id");

        if (postId == null || postId.isEmpty()) {
            throw new Exception("ID de publication manquant");
        }

        String bute = request.getParameter("bute");
        if (bute == null || bute.isEmpty()) bute = "accueil.jsp";

        // Charger le post
        Post post = new Post();
        post.setId(postId);
        Object[] postResult = CGenUtil.rechercher(post, null, null, "");
        if (postResult == null || postResult.length == 0) {
            throw new Exception("Publication introuvable");
        }
        post = (Post) postResult[0];

        // Vérifier propriétaire
        if (post.getIdutilisateur() != refuserInt) {
            throw new Exception("Vous n'&ecirc;tes pas autoris&eacute; &agrave; modifier cette publication");
        }

        // Charger les types de publication
        TypePublication[] typesPublication = (TypePublication[]) CGenUtil.rechercher(
            new TypePublication(), null, null, " AND actif = 1 ORDER BY ordre");

        // Charger les visibilités
        VisibilitePublication[] visibilites = (VisibilitePublication[]) CGenUtil.rechercher(
            new VisibilitePublication(), null, null, " AND actif = 1 ORDER BY ordre");

        // Fichiers joints existants
        PostFichier pfCritere = new PostFichier();
        pfCritere.setPost_id(postId);
        Object[] fichiers = null;
        try {
            fichiers = CGenUtil.rechercher(pfCritere, null, null, " AND post_id = '" + postId + "' ORDER BY ordre");
        } catch (Exception ex) {
            fichiers = new Object[0];
        }

        String photoUser = "assets/images/avatar-default.png";
        try {
            if (u.getUser().getPhoto() != null && !u.getUser().getPhoto().isEmpty()) {
                photoUser = "PhotoServlet?id=" + u.getUser().getTuppleID();
            }
        } catch (Exception ignored) {}
        String prenomUser = u.getUser().getNom();
%>
<div class="content-wrapper">
    <section class="content">
        <div class="feed-container">
            <div class="feed-main" style="max-width: 620px; margin: 0 auto;">
                
                <!-- Bouton retour -->
                <div style="margin-bottom: 15px;">
                    <a href="<%=lien%>?but=<%=bute%>&id=<%=postId%>" style="text-decoration:none; color:#555; font-size:13px;">
                        <i class="fa fa-arrow-left"></i> Retour
                    </a>
                </div>

                <!-- Formulaire de modification -->
                <div class="create-post-compact">
                    <form method="post" action="<%=lien%>?but=publication/apresPublication.jsp" id="formModifPost">
                        <input type="hidden" name="acte" value="update">
                        <input type="hidden" name="id" value="<%=postId%>">
                        <input type="hidden" name="bute" value="<%=bute%>">

                        <!-- Fichiers existants en haut -->
                        <% if (fichiers != null && fichiers.length > 0) { %>
                        <div class="file-drop-zone" style="cursor: default; padding: 12px;">
                            <div style="color: #555; font-size: 12px; margin-bottom: 8px; font-weight: 500;">
                                <i class="fa fa-paperclip"></i> Fichiers joints (<%= fichiers.length %>)
                            </div>
                            <div style="display: flex; flex-wrap: wrap; gap: 8px;">
                                <% for (int i = 0; i < fichiers.length; i++) {
                                    PostFichier pf = (PostFichier) fichiers[i];
                                    String mimeType = pf.getMime_type() != null ? pf.getMime_type() : "";
                                    boolean isImage = mimeType.startsWith("image/");
                                    String nomOriginal = pf.getNom_original() != null ? pf.getNom_original() : pf.getNom_fichier();
                                %>
                                <div class="fichier-mini">
                                    <% if (isImage) { %>
                                    <img src="PostFichierServlet?id=<%= pf.getId() %>&action=view" alt="<%= nomOriginal %>">
                                    <% } else { %>
                                    <div class="fichier-mini-icon">
                                        <i class="fa <%= mimeType.contains("pdf") ? "fa-file-pdf-o" : 
                                                        mimeType.contains("word") ? "fa-file-word-o" : 
                                                        "fa-file-o" %>"></i>
                                    </div>
                                    <% } %>
                                    <a href="PostFichierServlet?id=<%= pf.getId() %>&action=download" 
                                       class="fichier-mini-download" title="Télécharger <%= nomOriginal %>">
                                        <i class="fa fa-download"></i>
                                    </a>
                                </div>
                                <% } %>
                            </div>
                        </div>
                        <% } %>

                        <!-- Zone texte + avatar -->
                        <div class="create-bottom">
                            <img class="avatar-sm" src="<%= photoUser %>" alt="Photo">
                            <textarea name="contenu" class="create-input" placeholder="Modifier votre publication..." required rows="3" oninput="autoResizeModif(this)"><%= post.getContenu() != null ? post.getContenu() : "" %></textarea>
                        </div>

                        <!-- Options et bouton publier -->
                        <div class="modif-options">
                            <div class="modif-selects">
                                <select name="idtypepublication" class="modif-select">
                                    <% if (typesPublication != null) {
                                        for (TypePublication tp : typesPublication) { %>
                                    <option value="<%= tp.getId() %>" <%= tp.getId().equals(post.getIdtypepublication()) ? "selected" : "" %>>
                                        <%= tp.getLibelle() %>
                                    </option>
                                    <% } } %>
                                </select>
                                <select name="idvisibilite" class="modif-select">
                                    <% if (visibilites != null) {
                                        for (VisibilitePublication vp : visibilites) { %>
                                    <option value="<%= vp.getId() %>" <%= vp.getId().equals(post.getIdvisibilite()) ? "selected" : "" %>>
                                        <%= vp.getLibelle() %>
                                    </option>
                                    <% } } %>
                                </select>
                            </div>
                            <button type="submit" class="btn-save-modif">
                                <i class="fa fa-check"></i> Enregistrer
                            </button>
                        </div>
                    </form>
                </div>

            </div>
        </div>
    </section>
</div>

<style>
/* Réutilisation du style du formulaire d'ajout */
.create-post-compact {
    background: #fff;
    border: 1px solid #e0e0e0;
    border-radius: 12px;
    overflow: hidden;
}
.avatar-sm {
    width: 34px;
    height: 34px;
    border-radius: 50%;
    object-fit: cover;
    flex-shrink: 0;
}
.file-drop-zone {
    border-bottom: 1px solid #f0f0f0;
    background: #fafbfc;
}
.create-bottom {
    display: flex;
    align-items: flex-start;
    gap: 10px;
    padding: 14px;
}
.create-input {
    flex: 1;
    border: none;
    padding: 8px 0;
    font-size: 14px;
    background: transparent;
    outline: none;
    resize: none;
    min-height: 60px;
    max-height: 200px;
    overflow-y: auto;
    font-family: inherit;
    line-height: 1.5;
    color: #262626;
}
.create-input::placeholder {
    color: #b0b0b0;
}

/* Fichiers miniatures */
.fichier-mini {
    position: relative;
    width: 70px;
    height: 70px;
    border-radius: 8px;
    overflow: hidden;
    border: 1px solid #e0e0e0;
    background: #f5f5f5;
}
.fichier-mini img {
    width: 100%;
    height: 100%;
    object-fit: cover;
}
.fichier-mini-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    height: 100%;
    font-size: 24px;
    color: #999;
}
.fichier-mini-download {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    background: rgba(0,0,0,0.6);
    color: #fff;
    text-align: center;
    padding: 4px;
    font-size: 11px;
    opacity: 0;
    transition: opacity 0.2s;
}
.fichier-mini:hover .fichier-mini-download {
    opacity: 1;
}

/* Options de modification */
.modif-options {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 10px 14px;
    border-top: 1px solid #f0f0f0;
    background: #fafbfc;
}
.modif-selects {
    display: flex;
    gap: 8px;
    flex: 1;
}
.modif-select {
    flex: 1;
    padding: 6px 10px;
    border: 1px solid #e0e0e0;
    border-radius: 6px;
    font-size: 12px;
    background: #fff;
    color: #555;
    outline: none;
    transition: border-color 0.2s;
}
.modif-select:focus {
    border-color: #0095f6;
}
.btn-save-modif {
    background: #0095f6;
    color: #fff;
    border: none;
    border-radius: 6px;
    padding: 7px 16px;
    font-size: 13px;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.15s;
    white-space: nowrap;
}
.btn-save-modif:hover {
    background: #0081d6;
}
</style>

<script>
function autoResizeModif(textarea) {
    textarea.style.height = 'auto';
    textarea.style.height = Math.min(textarea.scrollHeight, 200) + 'px';
}
</script>

<%
    } catch (Exception e) {
        e.printStackTrace();
        String msgErr = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
%>
<script language="JavaScript">
    alert('Erreur : <%=msgErr.replace("'", "\\'")%>');
    history.back();
</script>
<% } %>
