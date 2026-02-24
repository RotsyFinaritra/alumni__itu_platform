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
            response.sendRedirect(lien + "?but=profil/mon-profil.jsp&refuser=" + refuser);
            return;
        }

        // Charger les param&egrave;tres de visibilit&eacute; actuels
        Map<String, Boolean> visibilite = VisibiliteService.getVisibilite(refuserInt);
%>
<style>
.minimal-wrapper {
    background: #f8f9fa;
    min-height: 100vh;
    padding: 40px 20px;
}
.minimal-container {
    max-width: 600px;
    margin: 0 auto;
}
.minimal-header {
    text-align: center;
    margin-bottom: 40px;
}
.minimal-header h1 {
    font-size: 28px;
    font-weight: 300;
    color: #2c3e50;
    margin: 0 0 10px 0;
    letter-spacing: -0.5px;
}
.minimal-header p {
    font-size: 14px;
    color: #95a5a6;
    margin: 0;
    font-weight: 400;
}
.minimal-card {
    background: white;
    border-radius: 8px;
    box-shadow: 0 1px 3px rgba(0,0,0,0.06);
    overflow: hidden;
    margin-bottom: 20px;
}
.minimal-card-body {
    padding: 30px;
}
.visibility-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 20px 0;
    border-bottom: 1px solid #ecf0f1;
}
.visibility-item:last-child {
    border-bottom: none;
    padding-bottom: 0;
}
.visibility-item:first-child {
    padding-top: 0;
}
.visibility-label {
    font-size: 15px;
    color: #2c3e50;
    font-weight: 400;
}
.switch-container {
    position: relative;
}
.switch {
    position: relative;
    display: inline-block;
    width: 48px;
    height: 26px;
}
.switch input {
    opacity: 0;
    width: 0;
    height: 0;
}
.slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: #cbd5e0;
    transition: .3s;
    border-radius: 26px;
}
.slider:before {
    position: absolute;
    content: "";
    height: 20px;
    width: 20px;
    left: 3px;
    bottom: 3px;
    background-color: white;
    transition: .3s;
    border-radius: 50%;
}
input:checked + .slider {
    background-color: #3498db;
}
input:checked + .slider:before {
    transform: translateX(22px);
}
.minimal-actions {
    display: flex;
    gap: 12px;
    justify-content: center;
    padding: 20px 0 0 0;
}
.btn-minimal {
    padding: 12px 28px;
    border: none;
    border-radius: 6px;
    font-size: 14px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    text-decoration: none;
    display: inline-block;
}
.btn-minimal-primary {
    background: #3498db;
    color: white;
}
.btn-minimal-primary:hover {
    background: #2980b9;
    color: white;
    transform: translateY(-1px);
    box-shadow: 0 4px 8px rgba(52,152,219,0.2);
}
.btn-minimal-secondary {
    background: #ecf0f1;
    color: #7f8c8d;
}
.btn-minimal-secondary:hover {
    background: #d5dbdb;
    color: #7f8c8d;
}
.minimal-info {
    background: #f8f9fa;
    border-left: 3px solid #3498db;
    padding: 15px 20px;
    margin-bottom: 30px;
    border-radius: 4px;
    font-size: 13px;
    color: #7f8c8d;
    line-height: 1.6;
}
</style>
<div class="content-wrapper minimal-wrapper">
    <div class="minimal-container">
        <div class="minimal-header">
            <h1>Gestion de la visibilité</h1>
            <p>Contrôlez qui peut voir vos informations</p>
        </div>

        <form action="<%= lien %>?but=profil/visibilite.jsp" method="post" id="formVisibilite">
            <div class="minimal-card">
                <div class="minimal-card-body">
                    <div class="minimal-info">
                        Les informations activées seront visibles par les autres membres de la plateforme.
                    </div>
                    
                    <% for (int i = 0; i < champsConfig.length; i++) {
                        String champ = champsConfig[i];
                        String label = labelsConfig[i];
                        Boolean isVis = visibilite.get(champ);
                        boolean checked = (isVis == null || isVis);
                    %>
                    <div class="visibility-item">
                        <label class="visibility-label" for="visi_<%= champ %>"><%= label %></label>
                        <div class="switch-container">
                            <label class="switch">
                                <input type="checkbox"
                                       name="visi_<%= champ %>"
                                       id="visi_<%= champ %>"
                                       <%= checked ? "checked" : "" %>>
                                <span class="slider"></span>
                            </label>
                        </div>
                    </div>
                    <% } %>
                </div>
            </div>

            <div class="minimal-actions">
                <button type="submit" class="btn-minimal btn-minimal-primary">
                    Enregistrer
                </button>
                <a href="<%= lien %>?but=profil/mon-profil.jsp" class="btn-minimal btn-minimal-secondary">
                    Retour
                </a>
            </div>
        </form>
    </div>
</div>
<%  } catch (Exception e) {
        e.printStackTrace();
    }
%>
