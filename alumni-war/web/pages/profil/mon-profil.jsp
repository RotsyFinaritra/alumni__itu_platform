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
        for (String hidden : new String[]{"pwduser", "idrole", "rang", "refuser", "interdit"}) {
            Champ c = pc.getChampByName(hidden);
            if (c != null) { c.setVisible(false); }
        }
        
        // Pour les enseignants (TU0000003), masquer etu et promotion
        String typeUtilisateur = utilisateur.getIdtypeutilisateur();
        boolean isEnseignant = "TU0000003".equals(typeUtilisateur);
        if (isEnseignant) {
            for (String champEtu : new String[]{"etu", "idpromotion"}) {
                Champ c = pc.getChampByName(champEtu);
                if (c != null) { c.setVisible(false); }
            }
        } else {
            // Pour les étudiants, masquer seulement etu dans l'affichage
            Champ champEtu = pc.getChampByName("etu");
            if (champEtu != null) { champEtu.setVisible(false); }
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
<style>
.instagram-profile {
    background: #fff;
    border: 1px solid #dbdbdb;
    border-radius: 3px;
    padding: 30px;
    margin-bottom: 20px;
}
.instagram-header {
    display: flex;
    align-items: center;
    margin-bottom: 30px;
}
.instagram-avatar {
    margin-right: 30px;
}
.instagram-avatar img {
    width: 150px;
    height: 150px;
    border-radius: 50%;
    object-fit: cover;
    border: 1px solid #dbdbdb;
}
.instagram-info {
    flex: 1;
}
.instagram-username {
    font-size: 28px;
    font-weight: 300;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 15px;
}
.instagram-stats {
    display: flex;
    gap: 40px;
    margin-bottom: 20px;
    font-size: 16px;
}
.instagram-stat-item {
    display: flex;
    gap: 5px;
}
.instagram-stat-item span:first-child {
    font-weight: 600;
}
.instagram-bio {
    font-size: 16px;
    line-height: 1.5;
}
.instagram-bio strong {
    font-weight: 600;
    display: block;
    margin-bottom: 5px;
}
.instagram-btn {
    padding: 5px 15px;
    border: 1px solid #dbdbdb;
    background: #fff;
    border-radius: 4px;
    font-weight: 600;
    font-size: 14px;
    cursor: pointer;
    transition: all 0.2s;
}
.instagram-btn:hover {
    background: #f0f0f0;
}
.instagram-btn-primary {
    background: #0095f6;
    color: white;
    border: none;
}
.instagram-btn-primary:hover {
    background: #1877f2;
    color: white;
}
.instagram-tabs {
    border-top: 1px solid #dbdbdb;
    display: flex;
    justify-content: center;
    gap: 60px;
}
.instagram-tab {
    padding: 20px 0;
    cursor: pointer;
    font-weight: 600;
    font-size: 12px;
    letter-spacing: 1px;
    text-transform: uppercase;
    color: #8e8e8e;
    border-top: 1px solid transparent;
    margin-top: -1px;
    transition: all 0.2s;
}
.instagram-tab:hover {
    color: #262626;
}
.instagram-tab.active {
    color: #262626;
    border-top-color: #262626;
}
.instagram-content {
    padding: 0;
}
.info-grid {
    display: grid;
    grid-template-columns: 150px 1fr;
    gap: 15px;
    font-size: 16px;
}
.info-grid-label {
    font-weight: 600;
    color: #262626;
}
.info-grid-value {
    color: #262626;
}
.visibility-badge {
    display: inline-block;
    margin-left: 10px;
    font-size: 12px;
    padding: 2px 8px;
    border-radius: 3px;
    background: #e3f2fd;
    color: #1976d2;
}
.visibility-badge.hidden {
    background: #f5f5f5;
    color: #999;
}
</style>

<div class="content-wrapper">
    <section class="content" style="padding-top: 20px;">
        <div class="container-fluid">
            <!-- Messages de feedback -->
            <% String successMessage = (String) session.getAttribute("successMessage");
               if (successMessage != null) {
                   session.removeAttribute("successMessage");
            %>
            <div class="alert alert-success alert-dismissible">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <i class="fa fa-check"></i> <%= successMessage %>
            </div>
            <% } %>
            
            <% String errorMessage = (String) session.getAttribute("errorMessage");
               if (errorMessage != null) {
                   session.removeAttribute("errorMessage");
            %>
            <div class="alert alert-danger alert-dismissible">
                <button type="button" class="close" data-dismiss="alert">&times;</button>
                <i class="fa fa-times"></i> <%= errorMessage %>
            </div>
            <% } %>
            
            <div class="instagram-profile">
                <!-- En-tête style Instagram -->
                <div class="instagram-header">
                    <div class="instagram-avatar">
                        <% String photo = utilisateur.getPhoto();
                           if (photo != null && !photo.isEmpty()) {
                               String photoFileName = photo;
                               if (photo.contains("/")) {
                                   photoFileName = photo.substring(photo.lastIndexOf("/") + 1);
                               }
                        %>
                        <img src="<%= request.getContextPath() %>/profile-photo?file=<%= photoFileName %>"
                             alt="Photo de profil">
                        <% } else { %>
                        <img src="<%= request.getContextPath() %>/assets/img/user-placeholder.svg"
                             alt="Photo de profil">
                        <% } %>
                    </div>
                    <div class="instagram-info">
                        <div class="instagram-username">
                            <%= utilisateur.getLoginuser() != null ? utilisateur.getLoginuser() : "" %>
                            <% if (isOwnProfile) { %>
                            <a href="<%= lien %>?but=profil/mon-profil-saisie.jsp&acte=update&classe=utilisateurAcade.UtilisateurAcade&nomtable=utilisateur&refuser=<%= refuser %>"
                               class="instagram-btn">
                                <i class="fa fa-pencil"></i> Modifier le profil
                            </a>
                            <a href="<%= lien %>?but=profil/visibilite.jsp&refuser=<%= refuser %>"
                               class="instagram-btn">
                                <i class="fa fa-cog"></i>
                            </a>
                            <% } %>
                        </div>
                        <div class="instagram-stats">
                            <div class="instagram-stat-item">
                                <span>0</span>
                                <span>publications</span>
                            </div>
                            <div class="instagram-stat-item">
                                <span>0</span>
                                <span>abonn&eacute;s</span>
                            </div>
                            <div class="instagram-stat-item">
                                <span>0</span>
                                <span>abonnements</span>
                            </div>
                        </div>
                        <div class="instagram-bio">
                            <strong><%= (utilisateur.getPrenom() != null ? utilisateur.getPrenom() : "") %>
                                <%= (utilisateur.getNomuser() != null ? utilisateur.getNomuser() : "") %>
                            </strong>
                            <% if (isOwnProfile || visibilite.get("mail") == null || visibilite.get("mail")) { %>
                            <div><i class="fa fa-envelope"></i> <%= utilisateur.getMail() != null ? utilisateur.getMail() : "" %></div>
                            <% } %>
                            <% if (isOwnProfile || visibilite.get("teluser") == null || visibilite.get("teluser")) { %>
                            <div><i class="fa fa-phone"></i> <%= utilisateur.getTeluser() != null ? utilisateur.getTeluser() : "" %></div>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- Onglets -->
                <div class="instagram-tabs">
                    <div class="instagram-tab active" data-tab="infos">
                        <i class="fa fa-th"></i> Informations
                    </div>
                    <div class="instagram-tab" data-tab="parcours">
                        <i class="fa fa-graduation-cap"></i> Parcours
                    </div>
                    <div class="instagram-tab" data-tab="experience">
                        <i class="fa fa-briefcase"></i> Exp&eacute;riences
                    </div>
                    <div class="instagram-tab" data-tab="competence">
                        <i class="fa fa-star"></i> Comp&eacute;tences
                    </div>
                    <div class="instagram-tab" data-tab="reseaux">
                        <i class="fa fa-share-alt"></i> R&eacute;seaux
                    </div>
                </div>
            </div>

            <!-- Contenu des onglets -->
            <div class="instagram-profile">
                <div class="instagram-content">
                    <div class="tab-content-item active" id="tab-infos">
                        <div class="info-grid">
                            <% Champ[] champs = pc.getListeChamp();
                               if (champs != null) {
                                   for (Champ chp : champs) {
                                       if (!chp.getVisible()) continue;
                                       if (chp.isPhoto()) continue;
                                       String val = chp.getValeur();
                            %>
                            <div class="info-grid-label"><%= chp.getLibelle() %></div>
                            <div class="info-grid-value">
                                <%= val != null ? val : "" %>
                                <% if (isOwnProfile) {
                                    String[] champsVisi = {"mail","teluser","adruser"};
                                    boolean estChampVisi = false;
                                    for (String cv : champsVisi) if (cv.equals(chp.getNom())) estChampVisi = true;
                                    if (estChampVisi) {
                                        Boolean isVis = visibilite.get(chp.getNom());
                                        boolean isVisChecked = (isVis == null || isVis);
                                %>
                                <i class="fa <%= isVisChecked ? "fa-eye" : "fa-eye-slash" %> toggle-icon"
                                   style="cursor:pointer; margin-left: 10px; color: <%= isVisChecked ? "#0095f6" : "#999" %>;"
                                   data-refuser="<%= refuser %>"
                                   data-champ="<%= chp.getNom() %>"
                                   data-visible="<%= isVisChecked %>"
                                   title="<%= isVisChecked ? "Visible par les autres" : "Masqué" %>">
                                </i>
                                <% } } %>
                            </div>
                            <% }
                               }
                            %>
                        </div>
                    </div>
                    <div class="tab-content-item" id="tab-parcours" style="display:none;">
                        <div class="text-center text-muted"><i class="fa fa-spinner fa-spin"></i> Chargement...</div>
                    </div>
                    <div class="tab-content-item" id="tab-experience" style="display:none;">
                        <div class="text-center text-muted"><i class="fa fa-spinner fa-spin"></i> Chargement...</div>
                    </div>
                    <div class="tab-content-item" id="tab-competence" style="display:none;">
                        <div class="text-center text-muted"><i class="fa fa-spinner fa-spin"></i> Chargement...</div>
                    </div>
                    <div class="tab-content-item" id="tab-reseaux" style="display:none;">
                        <div class="text-center text-muted"><i class="fa fa-spinner fa-spin"></i> Chargement...</div>
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
    
    var tabUrls = {
        'parcours': '<%= request.getContextPath() %>/pages/profil/parcours-tab.jsp?refuser=<%= refuser %>',
        'experience': '<%= request.getContextPath() %>/pages/profil/experience-tab.jsp?refuser=<%= refuser %>',
        'competence': '<%= request.getContextPath() %>/pages/profil/competence-tab.jsp?refuser=<%= refuser %>',
        'reseaux': '<%= request.getContextPath() %>/pages/profil/reseaux-tab.jsp?refuser=<%= refuser %>'
    };

    // Gestion des onglets
    $('.instagram-tab').click(function() {
        var tabName = $(this).data('tab');
        
        // Activer l'onglet
        $('.instagram-tab').removeClass('active');
        $(this).addClass('active');
        
        // Afficher le contenu
        $('.tab-content-item').hide().removeClass('active');
        $('#tab-' + tabName).show().addClass('active');
        
        // Charger le contenu AJAX si nécessaire
        if (tabUrls[tabName] && !loadedTabs[tabName]) {
            $.get(tabUrls[tabName])
                .done(function(html) {
                    $('#tab-' + tabName).html(html);
                    loadedTabs[tabName] = true;
                })
                .fail(function() {
                    $('#tab-' + tabName).html('<div class="alert alert-danger">Erreur de chargement.</div>');
                });
        }
    });

    // Toggle visibilité
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
                    $icon.removeClass('fa-eye-slash').addClass('fa-eye');
                    $icon.css('color', '#0095f6');
                    $icon.attr('title', 'Visible par les autres');
                } else {
                    $icon.removeClass('fa-eye').addClass('fa-eye-slash');
                    $icon.css('color', '#999');
                    $icon.attr('title', 'Masqué');
                }
            }
        });
    });
})();
</script>

            <!-- Ancien contenu conservé pour compatibilité -->
            <div class="col-md-9" style="display:none;">
                <div class="nav-tabs-custom">
                    <!-- Onglets Bootstrap -->
                    <ul class="nav nav-tabs" id="profil-tabs">
                        <li class="active"><a href="#tab-infos-old" data-toggle="tab"><i class="fa fa-user"></i> Informations</a></li>
                    </ul>
                    <div class="tab-content">
                        <div class="tab-pane active" id="tab-infos-old">
                            <table class="table table-bordered">
                                <% Champ[] champsOld = pc.getListeChamp();
                                   if (champsOld != null) {
                                       for (Champ chp : champsOld) {
                                           if (!chp.getVisible()) continue;
                                           if (chp.isPhoto()) continue;
                                %>
                                <tr>
                                    <th style="width:30%"><%= chp.getLibelle() %></th>
                                    <td>
                                        <% String val = chp.getValeur();
                                           out.print(val != null ? val : "");
                                        %>
                                    </td>
                                </tr>
                                <% }
                                   }
                                %>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            </div>
        </div>
    </section>
</div>

<%  } catch (Exception e) {
        e.printStackTrace();
    }
%>