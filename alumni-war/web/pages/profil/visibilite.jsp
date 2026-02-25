<%@ page import="user.UserEJB" %>
<%@ page import="profil.VisibiliteService" %>
<%@ page import="utilisateurAcade.VisibiliteConfig" %>
<%@ page import="affichage.PageUpdate" %>
<%@ page import="affichage.Liste" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<%
try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    String refuser = u.getUser().getTuppleID();

    // Correspondance : colonne vue → nomchamp dans la table EAV
    String[] viewCols = {"visimail", "visiteluser", "visiadruser", "visiphoto",
                         "visiprenom", "visinomuser", "visiloginuser", "visiidpromotion"};
    String[] dbChamps = {"mail", "teluser", "adruser", "photo",
                         "prenom", "nomuser", "loginuser", "idpromotion"};

    // ──────────────────────────────────────────────────────────────────
    //  POST : sauvegarde via VisibiliteService (UPSERT sur table EAV)
    // ──────────────────────────────────────────────────────────────────
    if ("POST".equals(request.getMethod())) {
        Map<String, Boolean> visibiliteMap = new HashMap<String, Boolean>();
        for (int i = 0; i < viewCols.length; i++) {
            String valeur = request.getParameter(viewCols[i]);
            visibiliteMap.put(dbChamps[i], "1".equals(valeur));
        }
        VisibiliteService.sauvegarderVisibilite(Integer.parseInt(refuser), dbChamps, visibiliteMap);
%>
<script>document.location.replace("<%= lien %>?but=profil/mon-profil.jsp&refuser=<%= refuser %>");</script>
<%
        return;
    }

    // ──────────────────────────────────────────────────────────────────
    //  GET : formulaire APJ PageUpdate sur la vue v_visibilite_config
    // ──────────────────────────────────────────────────────────────────
    VisibiliteConfig critere = new VisibiliteConfig();
    critere.setIdutilisateur(refuser);

    PageUpdate pu = new PageUpdate(critere, request, u);
    pu.setLien(lien);

    // Chaque champ visi* devient un select (Visible / Masqué)
    Liste[] listes = new Liste[viewCols.length];
    String[] optLabels = {"Visible", "Masqu\u00e9"};
    String[] optVals   = {"1", "0"};
    for (int i = 0; i < viewCols.length; i++) {
        Liste l = new Liste(viewCols[i]);
        l.makeListeString(optLabels, optVals);
        listes[i] = l;
    }
    pu.getFormu().changerEnChamp(listes);

    // Masquer l'ID utilisateur
    pu.getFormu().getChamp("idutilisateur").setVisible(false);

    // Labels lisibles
    pu.getFormu().getChamp("visimail").setLibelle("Email");
    pu.getFormu().getChamp("visiteluser").setLibelle("T&eacute;l&eacute;phone");
    pu.getFormu().getChamp("visiadruser").setLibelle("Adresse");
    pu.getFormu().getChamp("visiphoto").setLibelle("Photo de profil");
    pu.getFormu().getChamp("visiprenom").setLibelle("Pr&eacute;nom");
    pu.getFormu().getChamp("visinomuser").setLibelle("Nom");
    pu.getFormu().getChamp("visiloginuser").setLibelle("Identifiant");
    pu.getFormu().getChamp("visiidpromotion").setLibelle("Promotion");

    // Ordre d'affichage
    String[] ordre = {"visimail", "visiteluser", "visiadruser", "visiphoto",
                      "visiprenom", "visinomuser", "visiloginuser", "visiidpromotion"};
    pu.getFormu().setOrdre(ordre);

    // OBLIGATOIRE : préparer après toute configuration
    pu.preparerDataFormu();
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-eye"></i> Gestion de la visibilit&eacute;</h1>
    </section>
    <section class="content">
        <div class="box">
            <div class="box-header with-border">
                <p class="box-title">Contr&ocirc;lez quelles informations sont visibles par les autres membres</p>
            </div>
            <div class="box-body">
                <form action="<%= lien %>?but=profil/visibilite.jsp" method="post" data-parsley-validate>
                    <%= pu.getFormu().getHtmlInsert() %>
                    <div class="form-group">
                        <button type="submit" class="btn btn-success">
                            <i class="fa fa-save"></i> Enregistrer
                        </button>
                        <a href="<%= lien %>?but=profil/mon-profil.jsp" class="btn btn-default">
                            <i class="fa fa-arrow-left"></i> Retour au profil
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
%>
<script>alert('<%= e.getMessage() %>'); history.back();</script>
<% } %>
