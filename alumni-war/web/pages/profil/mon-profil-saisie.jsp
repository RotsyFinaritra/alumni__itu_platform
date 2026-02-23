<%@ page import="utilisateurAcade.UtilisateurAcade" %>
<%@ page import="bean.Promotion, bean.TypeUtilisateur, bean.CGenUtil" %>
<%@ page import="affichage.PageInsert, affichage.Liste , affichage.Champ" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        final UserEJB u = (UserEJB) session.getValue("u");
        final String lien = (String) session.getValue("lien");

        // On modifie toujours son propre profil
        final String refuser = u.getUser().getTuppleID();

        // Charger les données manuellement avec WHERE explicite
        // (contourne makeWhere/upper(integer) sur la colonne refuser INTEGER)
        UtilisateurAcade filtre = new UtilisateurAcade();
        Object[] result = CGenUtil.rechercher(filtre, null, null, " AND refuser = " + refuser);
        if (result == null || result.length == 0) {
            throw new Exception("Utilisateur introuvable (refuser=" + refuser + ")");
        }
        UtilisateurAcade utilisateur = (UtilisateurAcade) result[0];

        // Initialiser PageInsert manuellement (sans le constructeur 3-args
        // qui appelle getData() -> rechercher -> makeWhere -> upper(integer))
        PageInsert pi = new PageInsert();
        pi.setUtilisateur(u);
        pi.setReq(request);
        pi.setLien(lien);
        pi.setBase(utilisateur);
        pi.makeFormulaireUpt();

        // Libellés (null-safe : getChamp peut retourner null)
        Champ c;
        String[][] labels = {
            {"nomuser","Nom"}, {"prenom","Pr&eacute;nom"}, {"mail","Email"},
            {"teluser","T&eacute;l&eacute;phone"}, {"adruser","Adresse"},
            {"loginuser","Identifiant"}, {"photo","URL Photo de profil"},
            {"idpromotion","Promotion"}, {"idtypeutilisateur","Type de compte"}
        };
        for (String[] lb : labels) {
            c = pi.getFormu().getChamp(lb[0]);
            if (c != null) c.setLibelle(lb[1]);
        }
        // Active le champ fichier pour la photo
        c = pi.getFormu().getChamp("photo");
        if (c != null) c.setPhoto(true);

        // NE PAS utiliser changerEnChamp pour les champs qu'on veut en recherche
        // On va plutôt configurer les champs un par un avec setPageAppelComplete
        
        // Configuration du champ Promotion avec recherche
        c = pi.getFormu().getChamp("idpromotion");
        if (c != null) {
            c.setPageAppelComplete("bean.Promotion", "id", "promotion");
        }
        
        // Configuration du champ Type de compte avec recherche
        c = pi.getFormu().getChamp("idtypeutilisateur");
        if (c != null) {
            c.setPageAppelComplete("bean.TypeUtilisateur", "id", "type_utilisateur");
        }

        // Masquer les champs techniques (null-safe)
        for (String hidden : new String[]{"pwduser", "idrole", "rang", "etu"}) {
            c = pi.getFormu().getChamp(hidden);
            if (c != null) c.setVisible(false);
        }

        pi.preparerDataFormu();
    
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1>Modifier mon profil</h1>
    </section>
    <section class="content">
        <div class="row">
            <div class="col-md-8 col-md-offset-2">
                <div class="box box-primary">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa fa-user"></i> Informations personnelles</h3>
                    </div>
                    <form action="<%= lien %>?but=apresTarif.jsp" method="post" name="sortie" id="formProfil" enctype="multipart/form-data">
                        <div class="box-body">
                            <%
                                pi.getFormu().makeHtmlInsertTabIndex();
                                out.println(pi.getFormu().getHtmlInsert());
                            %>
                        </div>
                        <div class="box-footer">
                            <input name="acte" type="hidden" value="update">
                            <input name="bute" type="hidden" value="profil/mon-profil.jsp">
                            <input name="classe" type="hidden" value="utilisateurAcade.UtilisateurAcade">
                            <input name="nomtable" type="hidden" value="utilisateur">
                            <input name="refuser" type="hidden" value="<%= refuser %>">
                            <button type="submit" class="btn btn-primary">
                                <i class="fa fa-save"></i> Enregistrer
                            </button>
                            <a href="<%= lien %>?but=profil/mon-profil.jsp" class="btn btn-default">
                                <i class="fa fa-times"></i> Annuler
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