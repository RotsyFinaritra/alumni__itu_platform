<%@ page import="bean.Competence, bean.Specialite" %>
<%@ page import="profil.CompetenceProfilService" %>
<%@ page import="user.UserEJB" %>
<%@ page import="java.util.Set" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String refuser = request.getParameter("refuser");
        if (refuser == null || refuser.isEmpty()) refuser = u.getUser().getTuppleID();
        int refuserInt = Integer.parseInt(refuser);

        // Traitement du formulaire POST (enregistrement)
        if ("POST".equals(request.getMethod())) {
            String[] selectedComps = request.getParameterValues("competences");
            String[] selectedSpecs = request.getParameterValues("specialites");
            CompetenceProfilService.sauvegarder(refuserInt, selectedComps, selectedSpecs);
            response.sendRedirect(lien + "?but=profil/mon-profil.jsp&refuser=" + refuser);
            return;
        }

        // Chargement des donn&eacute;es pour affichage
        Object[] toutesComps = CompetenceProfilService.getToutesCompetences();
        Set<String> compActuelles = CompetenceProfilService.getCompetencesUtilisateur(refuserInt);
        Object[] toutesSpecs = CompetenceProfilService.getToutesSpecialites();
        Set<String> specActuelles = CompetenceProfilService.getSpecialitesUtilisateur(refuserInt);
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1>G&eacute;rer mes comp&eacute;tences et sp&eacute;cialit&eacute;s</h1>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-10 col-md-offset-1">
                <form action="<%= lien %>?but=profil/competence-saisie.jsp&refuser=<%= refuser %>"
                      method="post" id="formCompetences">
                    <div class="row">
                        <!-- Comp&eacute;tences -->
                        <div class="col-md-6">
                            <div class="box box-primary">
                                <div class="box-header with-border">
                                    <h3 class="box-title"><i class="fa fa-star"></i> Comp&eacute;tences</h3>
                                </div>
                                <div class="box-body">
                                    <% if (toutesComps != null) {
                                        for (Object o : toutesComps) {
                                            Competence comp = (Competence) o;
                                            boolean checked = compActuelles.contains(comp.getId());
                                    %>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox"
                                                   name="competences"
                                                   value="<%= comp.getId() %>"
                                                   <%= checked ? "checked" : "" %>>
                                            <%= comp.getLibelle() %>
                                        </label>
                                    </div>
                                    <% } } else { %>
                                    <p class="text-muted">Aucune comp&eacute;tence disponible.</p>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                        <!-- Sp&eacute;cialit&eacute;s -->
                        <div class="col-md-6">
                            <div class="box box-success">
                                <div class="box-header with-border">
                                    <h3 class="box-title"><i class="fa fa-tags"></i> Sp&eacute;cialit&eacute;s</h3>
                                </div>
                                <div class="box-body">
                                    <% if (toutesSpecs != null) {
                                        for (Object o : toutesSpecs) {
                                            Specialite spec = (Specialite) o;
                                            boolean checked = specActuelles.contains(spec.getId());
                                    %>
                                    <div class="checkbox">
                                        <label>
                                            <input type="checkbox"
                                                   name="specialites"
                                                   value="<%= spec.getId() %>"
                                                   <%= checked ? "checked" : "" %>>
                                            <%= spec.getLibelle() %>
                                        </label>
                                    </div>
                                    <% } } else { %>
                                    <p class="text-muted">Aucune sp&eacute;cialit&eacute; disponible.</p>
                                    <% } %>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12 text-center">
                            <button type="submit" class="btn btn-primary btn-lg">
                                <i class="fa fa-save"></i> Enregistrer mes choix
                            </button>
                            <a href="<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= refuser %>"
                               class="btn btn-default btn-lg">
                                <i class="fa fa-times"></i> Annuler
                            </a>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </section>
</div>
<%  } catch (Exception e) {
        e.printStackTrace();
    }
%>
