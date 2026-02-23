<%@ page import="user.UserEJB" %>
<%@ page import="profil.VisibiliteService" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");
        String refuser = u.getUser().getTuppleID(); // Toujours les param&egrave;tres du compte connect&eacute;
        int refuserInt = Integer.parseInt(refuser);

        // D&eacute;finition des champs configurables
        String[] champsConfig = {"mail", "teluser", "adruser", "photo", "prenom", "nomuser", "loginuser", "idpromotion"};
        String[] labelsConfig = {"Email", "T&eacute;l&eacute;phone", "Adresse", "Photo de profil", "Pr&eacute;nom", "Nom", "Identifiant", "Promotion"};

        // Traitement du formulaire POST
        if ("POST".equals(request.getMethod())) {
            Map<String, Boolean> visibiliteMap = new HashMap<String, Boolean>();
            for (String champ : champsConfig) {
                String valeur = request.getParameter("visi_" + champ);
                visibiliteMap.put(champ, "on".equals(valeur) || "true".equals(valeur));
            }
            VisibiliteService.sauvegarderVisibilite(refuserInt, champsConfig, visibiliteMap);
            response.sendRedirect(lien + "?but=profil/mon-profil.jsp");
            return;
        }

        // Charger les param&egrave;tres de visibilit&eacute; actuels
        Map<String, Boolean> visibilite = VisibiliteService.getVisibilite(refuserInt);
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-eye"></i> G&eacute;rer ma visibilit&eacute;</h1>
        <small>Choisissez quelles informations sont visibles par les autres membres</small>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-8 col-md-offset-2">
                <div class="box box-info">
                    <div class="box-header with-border">
                        <h3 class="box-title">Param&egrave;tres de confidentialit&eacute;</h3>
                    </div>
                    <form action="<%= lien %>?but=profil/visibilite.jsp" method="post" id="formVisibilite">
                        <div class="box-body">
                            <div class="alert alert-info">
                                <i class="fa fa-info-circle"></i>
                                Les informations <strong>coch&eacute;es</strong> seront visibles par les autres membres de la plateforme.
                                Les informations <strong>d&eacute;coch&eacute;es</strong> ne seront visibles que par vous.
                            </div>
                            <table class="table table-bordered table-hover">
                                <thead>
                                    <tr>
                                        <th>Information</th>
                                        <th class="text-center" style="width:120px;">Visible par les autres</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (int i = 0; i < champsConfig.length; i++) {
                                        String champ = champsConfig[i];
                                        String label = labelsConfig[i];
                                        Boolean isVis = visibilite.get(champ);
                                        boolean checked = (isVis == null || isVis); // par d&eacute;faut visible
                                    %>
                                    <tr>
                                        <td><strong><%= label %></strong></td>
                                        <td class="text-center">
                                            <input type="checkbox"
                                                   name="visi_<%= champ %>"
                                                   id="visi_<%= champ %>"
                                                   <%= checked ? "checked" : "" %>>
                                        </td>
                                    </tr>
                                    <% } %>
                                </tbody>
                            </table>
                        </div>
                        <div class="box-footer">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa fa-save"></i> Enregistrer mes pr&eacute;f&eacute;rences
                            </button>
                            <a href="<%= lien %>?but=profil/mon-profil.jsp" class="btn btn-default">
                                <i class="fa fa-arrow-left"></i> Retour au profil
                            </a>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </section>
</div>
<%  } catch (Exception e) {
        e.printStackTrace();
    }
%>
