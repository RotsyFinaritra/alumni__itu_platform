<%@ page import="utilisateurAcade.UtilisateurAcade" %>
<%@ page import="utilisateurAcade.VisibiliteUtilisateur" %>
<%@ page import="affichage.PageConsulte" %>
<%@ page import="affichage.Champ" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="user.UserEJB" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%
    try {
        final UserEJB u = (UserEJB) session.getValue("u");
        final String lien = (String) session.getValue("lien");

        // Determine whose profile to display
        String refuserParam = request.getParameter("refuser");
        final String refuser = (refuserParam != null && !refuserParam.isEmpty())
                ? refuserParam : u.getUser().getTuppleID();
        boolean isOwnProfile = refuser.equals(u.getUser().getTuppleID());

        // Charger l'utilisateur directement via apresWhere (&eacute;vite upper(integer) sur
        // la colonne refuser INTEGER de PostgreSQL, incompatible avec makeWhere APJ)
        UtilisateurAcade filtreProfil = new UtilisateurAcade();
        Object[] profilResult = CGenUtil.rechercher(filtreProfil, null, null,
                " AND refuser = " + refuser);
        if (profilResult == null || profilResult.length == 0) {
            throw new Exception("Utilisateur introuvable (refuser=" + refuser + ")");
        }
        UtilisateurAcade utilisateur = (UtilisateurAcade) profilResult[0];

        // Initialiser PageConsulte manuellement pour acc&eacute;der aux helpers d'affichage
        // sans appeler getData() (qui passerait par makeWhere et upper(integer))
        PageConsulte pc = new PageConsulte();
        pc.setCritere(utilisateur);
        pc.setBase(utilisateur);
        pc.setReq(request);
        pc.setUtilisateur(u);
        pc.setLien(lien);
        pc.setTitre(isOwnProfile ? "Mon Profil" : "Profil &Eacute;tudiant");
        pc.makeChamp();

        // Libell&eacute;s des champs (null-safe : getChampByName retourne null si le champ n'existe pas)
        java.util.Map<String,String> libelles = new java.util.LinkedHashMap<String,String>();
        libelles.put("nomuser", "Nom");
        libelles.put("prenom", "Pr&eacute;nom");
        libelles.put("mail", "Email");
        libelles.put("teluser", "T&eacute;l&eacute;phone");
        libelles.put("adruser", "Adresse");
        libelles.put("loginuser", "Identifiant");
        libelles.put("idpromotion", "Promotion");
        libelles.put("idtypeutilisateur", "Type d'utilisateur");
        libelles.put("photo", "Photo de profil");
        for (java.util.Map.Entry<String,String> entry : libelles.entrySet()) {
            Champ c = pc.getChampByName(entry.getKey());
            if (c != null) { c.setLibelle(entry.getValue()); }
        }
        Champ champPhoto = pc.getChampByName("photo");
        if (champPhoto != null) { champPhoto.setPhoto(true); }

        // Masquer les champs techniques (null-safe)
        for (String hidden : new String[]{"pwduser", "idrole", "rang", "refuser", "etu", "interdit"}) {
            Champ c = pc.getChampByName(hidden);
            if (c != null) { c.setVisible(false); }
        }

        // Charger les pr&eacute;f&eacute;rences de visibilit&eacute; pour cet utilisateur
        // Utiliser awhere explicite pour &eacute;viter les filtres sur boolean (visible=false par d&eacute;faut)
        Object[] visiList = CGenUtil.rechercher(
            new VisibiliteUtilisateur(), null, null,
            " AND idutilisateur = " + refuser
        );
        Map<String, Boolean> visibilite = new HashMap<String, Boolean>();
        if (visiList != null) {
            for (Object o : visiList) {
                VisibiliteUtilisateur vv = (VisibiliteUtilisateur) o;
                visibilite.put(vv.getNomChamp(), vv.getVisible() == 1);
            }
        }

        // Si consultation par un tiers : appliquer les masques de visibilit&eacute;
        if (!isOwnProfile) {
            String[] champsControles = {"mail", "teluser", "adruser", "photo"};
            for (String champ : champsControles) {
                Boolean isVisible = visibilite.get(champ);
                if (Boolean.FALSE.equals(isVisible)) {
                    Champ champMask = pc.getChampByName(champ);
                    if (champMask != null) { champMask.setVisible(false); }
                }
            }
        }
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><%= pc.getTitre() %></h1>
    </section>
    <section class="content">

        <% if (isOwnProfile) { %>
        <div class="row">
            <div class="col-md-12">
                <a href="<%= lien %>?but=profil/mon-profil-saisie.jsp&acte=update&classe=utilisateurAcade.UtilisateurAcade&nomtable=utilisateur&refuser=<%= refuser %>"
                   class="btn btn-primary btn-sm pull-right" style="margin-bottom:10px;">
                    <i class="fa fa-pencil"></i> Modifier mon profil
                </a>
                <a href="<%= lien %>?but=profil/visibilite.jsp&refuser=<%= refuser %>"
                   class="btn btn-default btn-sm pull-right" style="margin-bottom:10px; margin-right:5px;">
                    <i class="fa fa-eye"></i> G&eacute;rer ma visibilit&eacute;
                </a>
            </div>
        </div>
        <% } %>

        <div class="row">
            <!-- Photo de profil -->
            <div class="col-md-3">
                <div class="box box-primary">
                    <div class="box-body box-profile">
                        <% String photo = utilisateur.getPhoto();
                           if (photo != null && !photo.isEmpty()) { %>
                        <img class="profile-user-img img-responsive img-circle"
                             src="<%= photo %>"
                             alt="Photo de profil">
                        <% } else { %>
                        <img class="profile-user-img img-responsive img-circle"
                             src="assets/img/user-placeholder.png"
                             alt="Photo de profil">
                        <% } %>
                        <h3 class="profile-username text-center">
                            <%= (utilisateur.getPrenom() != null ? utilisateur.getPrenom() : "") %>
                            <%= (utilisateur.getNomuser() != null ? utilisateur.getNomuser() : "") %>
                        </h3>
                        <% if (isOwnProfile) { %>
                        <p class="text-muted text-center">
                            <i class="fa fa-envelope"></i> <%= utilisateur.getMail() != null ? utilisateur.getMail() : "" %>
                        </p>
                        <% } else {
                            Boolean mailVisible = visibilite.get("mail");
                            if (mailVisible == null || mailVisible) { %>
                        <p class="text-muted text-center">
                            <i class="fa fa-envelope"></i> <%= utilisateur.getMail() != null ? utilisateur.getMail() : "" %>
                        </p>
                        <% } } %>
                    </div>
                </div>

                <!-- Visibilit&eacute; rapide (seulement pour son propre profil) -->
                <% if (isOwnProfile) { %>
                <div class="box box-default">
                    <div class="box-header with-border">
                        <h3 class="box-title"><i class="fa fa-eye"></i> Visibilit&eacute; rapide</h3>
                    </div>
                    <div class="box-body">
                        <% String[] champsVisiAffich = {"mail", "teluser", "adruser", "photo"};
                           String[] labelVisiAffich = {"Email", "T&eacute;l&eacute;phone", "Adresse", "Photo"};
                           for (int vi = 0; vi < champsVisiAffich.length; vi++) {
                               String champ = champsVisiAffich[vi];
                               Boolean isVis = visibilite.get(champ);
                               boolean checked = (isVis == null || isVis);
                        %>
                        <div class="clearfix" style="margin-bottom:8px;">
                            <span class="pull-left"><%= labelVisiAffich[vi] %></span>
                            <div class="pull-right">
                                <input type="checkbox" class="toggle-visibilite"
                                       data-refuser="<%= refuser %>"
                                       data-champ="<%= champ %>"
                                       <%= checked ? "checked" : "" %>
                                       data-lien="<%= lien %>">
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- Fiche PageConsulte APJ -->
            <div class="col-md-9">
                <div class="nav-tabs-custom">
                    <!-- Onglets Bootstrap -->
                    <ul class="nav nav-tabs" id="profil-tabs">
                        <li class="active"><a href="#tab-infos" data-toggle="tab"><i class="fa fa-user"></i> Informations</a></li>
                        <li><a href="#" class="tab-ajax" data-target="tab-parcours"
                               data-url="<%= request.getContextPath() %>/pages/profil/parcours-tab.jsp?refuser=<%= refuser %>">
                            <i class="fa fa-graduation-cap"></i> Parcours acad&eacute;mique</a></li>
                        <li><a href="#" class="tab-ajax" data-target="tab-experience"
                               data-url="<%= request.getContextPath() %>/pages/profil/experience-tab.jsp?refuser=<%= refuser %>">
                            <i class="fa fa-briefcase"></i> Exp&eacute;riences</a></li>
                        <li><a href="#" class="tab-ajax" data-target="tab-competence"
                               data-url="<%= request.getContextPath() %>/pages/profil/competence-tab.jsp?refuser=<%= refuser %>">
                            <i class="fa fa-star"></i> Comp&eacute;tences</a></li>
                        <li><a href="#" class="tab-ajax" data-target="tab-reseaux"
                               data-url="<%= request.getContextPath() %>/pages/profil/reseaux-tab.jsp?refuser=<%= refuser %>">
                            <i class="fa fa-share-alt"></i> R&eacute;seaux sociaux</a></li>
                    </ul>
                    <div class="tab-content">
                        <!-- Tab Informations — contenu PageConsulte APJ -->
                        <div class="tab-pane active" id="tab-infos">
                            <table class="table table-bordered">
                                <% Champ[] champs = pc.getListeChamp();
                                   if (champs != null) {
                                       for (Champ chp : champs) {
                                           if (!chp.getVisible()) continue;
                                           if (chp.isPhoto()) continue; // d&eacute;j&agrave; affich&eacute;e &agrave; gauche
                                %>
                                <tr>
                                    <th style="width:30%"><%= chp.getLibelle() %></th>
                                    <td>
                                        <% String val = chp.getValeur();
                                           if (isOwnProfile) {
                                               String[] champsVisi = {"mail","teluser","adruser"};
                                               boolean estChampVisi = false;
                                               for (String cv : champsVisi) if (cv.equals(chp.getNom())) estChampVisi = true;
                                               if (estChampVisi) {
                                                   Boolean isVis = visibilite.get(chp.getNom());
                                                   boolean isVisChecked = (isVis == null || isVis);
                                        %>
                                        <%= val != null ? val : "" %>
                                        <span class="pull-right">
                                            <i class="fa <%= isVisChecked ? "fa-eye text-success" : "fa-eye-slash text-muted" %> toggle-icon"
                                               style="cursor:pointer;"
                                               data-refuser="<%= refuser %>"
                                               data-champ="<%= chp.getNom() %>"
                                               data-visible="<%= isVisChecked %>"
                                               title="<%= isVisChecked ? "Visible par les autres" : "Masqu&eacute; des autres" %>">
                                            </i>
                                        </span>
                                        <% } else { %>
                                        <%= val != null ? val : "" %>
                                        <% } } else { %>
                                        <%= val != null ? val : "" %>
                                        <% } %>
                                    </td>
                                </tr>
                                <% }
                                   } else {
                                       out.println(pc.getHtml());
                                   }
                                %>
                            </table>
                        </div>
                        <!-- Tabs charg&eacute;s en AJAX -->
                        <div class="tab-pane" id="tab-parcours"><div class="text-center text-muted" style="padding:20px;"><i class="fa fa-spinner fa-spin"></i> Chargement...</div></div>
                        <div class="tab-pane" id="tab-experience"><div class="text-center text-muted" style="padding:20px;"><i class="fa fa-spinner fa-spin"></i> Chargement...</div></div>
                        <div class="tab-pane" id="tab-competence"><div class="text-center text-muted" style="padding:20px;"><i class="fa fa-spinner fa-spin"></i> Chargement...</div></div>
                        <div class="tab-pane" id="tab-reseaux"><div class="text-center text-muted" style="padding:20px;"><i class="fa fa-spinner fa-spin"></i> Chargement...</div></div>
                    </div>
                </div>
            </div>
        </div>

    </section>
</div>

<script>
(function() {
    var loadedTabs = {};
    var lien = '<%= lien %>';
    var refuser = '<%= refuser %>';
    var isOwnProfile = <%= isOwnProfile %>;

    // Chargement AJAX des onglets
    $(document).on('click', '.tab-ajax', function(e) {
        e.preventDefault();
        var $this = $(this);
        var targetId = $this.data('target');
        var url = $this.data('url');
        var $pane = $('#' + targetId);

        // Activer l'onglet
        $this.closest('li').siblings().removeClass('active');
        $this.closest('li').addClass('active');
        $('.tab-pane').removeClass('active');
        $pane.addClass('active');

        // Charger seulement si pas d&eacute;j&agrave; charg&eacute;
        if (!loadedTabs[targetId]) {
            $.get(url)
                .done(function(html) {
                    $pane.html(html);
                    loadedTabs[targetId] = true;
                })
                .fail(function() {
                    $pane.html('<div class="alert alert-danger">Erreur de chargement.</div>');
                });
        }
    });

    // Toggle visibilit&eacute; via ic&ocirc;nes
    $(document).on('click', '.toggle-icon', function() {
        var $icon = $(this);
        var champ = $icon.data('champ');
        var visible = $icon.data('visible');
        var nouvelleVisi = !visible;

        $.post(lien + '?but=profil/toggle-visibilite.jsp', {
            refuser: refuser,
            nomchamp: champ,
            visible: nouvelleVisi
        }, function(resp) {
            var res = $.parseJSON(resp);
            if (res.success) {
                $icon.data('visible', nouvelleVisi);
                if (nouvelleVisi) {
                    $icon.removeClass('fa-eye-slash text-muted').addClass('fa-eye text-success');
                    $icon.attr('title', 'Visible par les autres');
                } else {
                    $icon.removeClass('fa-eye text-success').addClass('fa-eye-slash text-muted');
                    $icon.attr('title', 'Masqu&eacute; des autres');
                }
                // Sync checkbox lat&eacute;rale
                $('input.toggle-visibilite[data-champ="' + champ + '"]').prop('checked', nouvelleVisi);
            }
        });
    });

    // Toggle visibilit&eacute; via checkboxes de la sidebar
    $(document).on('change', '.toggle-visibilite', function() {
        var $cb = $(this);
        var champ = $cb.data('champ');
        var visible = $cb.is(':checked');

        $.post(lien + '?but=profil/toggle-visibilite.jsp', {
            refuser: refuser,
            nomchamp: champ,
            visible: visible
        }, function(resp) {
            var res = $.parseJSON(resp);
            if (!res.success) {
                // Rollback
                $cb.prop('checked', !visible);
            } else {
                // Sync ic&ocirc;ne inline
                var $icon = $('.toggle-icon[data-champ="' + champ + '"]');
                $icon.data('visible', visible);
                if (visible) {
                    $icon.removeClass('fa-eye-slash text-muted').addClass('fa-eye text-success');
                } else {
                    $icon.removeClass('fa-eye text-success').addClass('fa-eye-slash text-muted');
                }
            }
        });
    });
})();
</script>

<%  } catch (Exception e) {
        e.printStackTrace();
    }
%>
