<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="affichage.PageUpdate" %>
<%@ page import="affichage.Champ" %>
<%@ page import="affichage.Liste" %>
<%@ page import="bean.Post" %>
<%@ page import="bean.PostStage" %>
<%@ page import="bean.VisibilitePublication" %>
<%@ page import="bean.Competence" %>
<%@ page import="bean.StageCompetence" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="java.util.HashSet" %>
<%@ page import="java.util.Set" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String postId = request.getParameter("id");

        // --- Section 1 : mise a jour du Post parent ---
        Post postModele = new Post();
        postModele.setNomTable("posts");
        PageUpdate puPost = new PageUpdate(postModele, request, u);
        puPost.setTitre("Modifier l'offre de stage");

        Champ c;
        c = puPost.getChampByName("post_id");        if (c != null) c.setVisible(false);
        c = puPost.getChampByName("idutilisateur");  if (c != null) c.setVisible(false);
        c = puPost.getChampByName("type");           if (c != null) c.setVisible(false);
        c = puPost.getChampByName("idstatutpublication"); if (c != null) c.setVisible(false);
        c = puPost.getChampByName("idgroupe");       if (c != null) c.setVisible(false);
        c = puPost.getChampByName("epingle");        if (c != null) c.setVisible(false);
        c = puPost.getChampByName("supprime");       if (c != null) c.setVisible(false);
        c = puPost.getChampByName("edited_at");      if (c != null) c.setVisible(false);
        c = puPost.getChampByName("created_at");     if (c != null) c.setVisible(false);

        Champ champContenu = puPost.getChampByName("contenu");
        if (champContenu != null) {
            champContenu.setLibelle("Description du stage");
            champContenu.setType("editor");
            champContenu.setObligatoire(true);
        }

        Champ champVisi = puPost.getChampByName("idvisibilite");
        if (champVisi != null) {
            champVisi.setLibelle("Visibilite");
            champVisi.setObligatoire(true);
            Liste listeVisi = new Liste(new VisibilitePublication(), u,
                    "idvisibilite", "libelle");
            champVisi.setListe(listeVisi);
        }

        // --- Section 2 : mise a jour du PostStage ---
        PostStage stageModele = new PostStage();
        PageUpdate puStage = new PageUpdate(stageModele, request, u);

        c = puStage.getChampByName("post_id");       if (c != null) c.setVisible(false);

        puStage.getChampByName("entreprise").setLibelle("Entreprise / Organisme");
        puStage.getChampByName("entreprise").setObligatoire(true);
        puStage.getChampByName("localisation").setLibelle("Localisation");
        puStage.getChampByName("duree").setLibelle("Duree (ex: 3 mois)");
        puStage.getChampByName("date_debut").setLibelle("Date de debut");
        puStage.getChampByName("date_fin").setLibelle("Date de fin");
        puStage.getChampByName("indemnite").setLibelle("Indemnite mensuelle");
        puStage.getChampByName("places_disponibles").setLibelle("Nombre de places");
        puStage.getChampByName("contact_email").setLibelle("Email de contact");
        puStage.getChampByName("contact_tel").setLibelle("Telephone");
        puStage.getChampByName("lien_candidature").setLibelle("Lien de candidature");

        Champ champConvention = puStage.getChampByName("convention_requise");
        if (champConvention != null) {
            champConvention.setLibelle("Convention requise");
            Liste listeConv = new Liste();
            listeConv.ajouterLigne("0", "Non");
            listeConv.ajouterLigne("1", "Oui");
            champConvention.setListe(listeConv);
        }

        Champ champNiveau = puStage.getChampByName("niveau_etude_requis");
        if (champNiveau != null) champNiveau.setLibelle("Niveau d etude requis");
        
        // Charger toutes les competences disponibles
        Competence compFiltre = new Competence();
        Object[] competences = CGenUtil.rechercher(compFiltre, null, null, " ORDER BY libelle");
        
        // Charger les competences deja associees a ce stage
        Set<String> selectedCompetences = new HashSet<>();
        StageCompetence scFiltre = new StageCompetence();
        scFiltre.setPost_id(postId);
        Object[] existingComps = CGenUtil.rechercher(scFiltre, null, null, " AND post_id = '" + postId + "'");
        if (existingComps != null) {
            for (Object o : existingComps) {
                StageCompetence sc = (StageCompetence) o;
                selectedCompetences.add(sc.getIdcompetence());
            }
        }
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-edit"></i> <%= puPost.getTitre() %></h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=carriere/carriere-accueil.jsp"><i class="fa fa-home"></i> Espace Carriere</a></li>
            <li><a href="<%=lien%>?but=carriere/stage-liste.jsp">Offres de stage</a></li>
            <li class="active">Modifier</li>
        </ol>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-1"></div>
            <div class="col-md-10">
                <form method="post" action="<%=lien%>">
                    <input type="hidden" name="but" value="apresCarriere.jsp">
                    <input type="hidden" name="acte" value="updateStage">
                    <input type="hidden" name="bute" value="carriere/stage-fiche.jsp">
                    <input type="hidden" name="id" value="<%=postId%>">

                    <!-- Section Post -->
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <h3 class="box-title">Publication</h3>
                        </div>
                        <div class="box-body">
                            <%= puPost.getHtml() %>
                        </div>
                    </div>

                    <!-- Section PostStage -->
                    <div class="box box-success">
                        <div class="box-header with-border">
                            <h3 class="box-title">Details du stage</h3>
                        </div>
                        <div class="box-body">
                            <%= puStage.getHtml() %>
                            
                            <!-- Selection multiple des competences -->
                            <div class="form-group">
                                <label>Competences requises</label>
                                <select name="competences[]" class="form-control select2" multiple="multiple" 
                                        data-placeholder="Selectionnez les competences" style="width: 100%;">
                                    <% if (competences != null) {
                                        for (Object o : competences) {
                                            Competence comp = (Competence) o;
                                            boolean isSelected = selectedCompetences.contains(comp.getId());
                                    %>
                                    <option value="<%= comp.getId() %>" <%= isSelected ? "selected" : "" %>><%= comp.getLibelle() %></option>
                                    <% }} %>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="box-footer">
                        <button type="submit" class="btn btn-warning">
                            <i class="fa fa-save"></i> Enregistrer les modifications
                        </button>
                        <a class="btn btn-info"
                           href="<%=lien%>?but=carriere/post-fichiers.jsp&postId=<%=postId%>&type=stage">
                            <i class="fa fa-file"></i> Gerer les fichiers
                        </a>
                        <a class="btn btn-default pull-right"
                           href="<%=lien%>?but=carriere/stage-fiche.jsp&id=<%=postId%>">
                            <i class="fa fa-times"></i> Annuler
                        </a>
                    </div>
                </form>
            </div>
        </div>
    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
        String msgErr = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
%>
<script language="JavaScript">alert('Erreur stage-modif : <%=msgErr.replace("'", "\\'")%>');</script>
<%
    }
%>
