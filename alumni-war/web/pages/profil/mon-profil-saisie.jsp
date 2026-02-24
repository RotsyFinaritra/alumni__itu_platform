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

        // Liste déroulante pour Type de compte (changerEnChamp AVANT setLibelle)
        Liste[] listes = new Liste[1];
        listes[0] = new Liste("idtypeutilisateur", new TypeUtilisateur(), "libelle", "id");
        pi.getFormu().changerEnChamp(listes);

        // Vérifier si c'est un enseignant
        String typeUtilisateur = utilisateur.getIdtypeutilisateur();
        boolean isEnseignant = "TU0000003".equals(typeUtilisateur);

        // Autocomplete dynamique pour Promotion (seulement pour les non-enseignants)
        if (!isEnseignant) {
            pi.getFormu().getChamp("idpromotion").setPageAppelComplete("bean.Promotion", "id", "promotion");
        }

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

        // Masquer les champs techniques (null-safe)
        for (String hidden : new String[]{"pwduser", "idrole", "rang", "photo"}) {
            c = pi.getFormu().getChamp(hidden);
            if (c != null) c.setVisible(false);
        }
        
        // Pour les enseignants, masquer etu et promotion
        if (isEnseignant) {
            for (String champEnseignant : new String[]{"etu", "idpromotion"}) {
                c = pi.getFormu().getChamp(champEnseignant);
                if (c != null) c.setVisible(false);
            }
        } else {
            // Pour les étudiants, masquer seulement etu
            c = pi.getFormu().getChamp("etu");
            if (c != null) c.setVisible(false);
        }

        pi.preparerDataFormu();
    
%>
<style>
.profile-edit-layout {
    display: flex;
    gap: 30px;
    align-items: flex-start;
}
.photo-upload-section {
    flex: 0 0 250px;
    text-align: center;
    padding: 20px;
    background: #fff;
    border: 1px solid #dbdbdb;
    border-radius: 8px;
    position: sticky;
    top: 20px;
}
.photo-preview {
    width: 180px;
    height: 180px;
    object-fit: cover;
    border-radius: 50%;
    border: 3px solid #3c8dbc;
    margin: 0 auto 20px;
    display: block;
    box-shadow: 0 3px 10px rgba(0,0,0,0.15);
}
.photo-upload-btn {
    display: inline-block;
    padding: 10px 20px;
    background: #3c8dbc;
    color: white;
    border-radius: 4px;
    cursor: pointer;
    transition: all 0.3s;
    font-weight: 600;
    font-size: 14px;
}
.photo-upload-btn:hover {
    background: #2e7199;
    transform: translateY(-2px);
    box-shadow: 0 2px 8px rgba(0,0,0,0.2);
}
.photo-upload-input {
    display: none;
}
.form-section {
    flex: 1;
}
@media (max-width: 768px) {
    .profile-edit-layout {
        flex-direction: column;
    }
    .photo-upload-section {
        flex: 1 1 auto;
        width: 100%;
        position: relative;
    }
}
</style>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-pencil"></i> Modifier mon profil</h1>
    </section>
    <section class="content">
        <%-- Affichage des messages d'erreur/succès --%>
        <% String errorMessage = (String) session.getAttribute("errorMessage");
           String successMessage = (String) session.getAttribute("successMessage");
           if (errorMessage != null) {
               session.removeAttribute("errorMessage");
        %>
        <div class="alert alert-danger alert-dismissible">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="fa fa-exclamation-circle"></i> <strong>Erreur :</strong> <%= errorMessage %>
        </div>
        <% } if (successMessage != null) {
               session.removeAttribute("successMessage");
        %>
        <div class="alert alert-success alert-dismissible">
            <button type="button" class="close" data-dismiss="alert">&times;</button>
            <i class="fa fa-check-circle"></i> <%= successMessage %>
        </div>
        <% } %>
        <div class="row">
            <div class="col-md-12">
                <form action="<%= lien %>?but=profil/update-profil.jsp" method="post" name="sortie" id="formProfil" enctype="multipart/form-data">
                    <div class="profile-edit-layout">
                        <!-- Section photo à gauche -->
                        <div class="photo-upload-section">
                            <h4 style="margin-top: 0; margin-bottom: 20px; color: #333;">
                                <i class="fa fa-camera"></i> Photo de profil
                            </h4>
                            <% String photo = utilisateur.getPhoto();
                               if (photo != null && !photo.isEmpty()) {
                                   String photoFileName = photo;
                                   if (photo.contains("/")) {
                                       photoFileName = photo.substring(photo.lastIndexOf("/") + 1);
                                   }
                            %>
                            <img id="photoPreview" class="photo-preview"
                                 src="<%= request.getContextPath() %>/profile-photo?file=<%= photoFileName %>"
                                 alt="Photo actuelle">
                            <% } else { %>
                            <img id="photoPreview" class="photo-preview"
                                 src="<%= request.getContextPath() %>/assets/img/user-placeholder.svg"
                                 alt="Pas de photo">
                            <% } %>
                            
                            <label for="photoInput" class="photo-upload-btn">
                                <i class="fa fa-upload"></i> Choisir une photo
                            </label>
                            <input type="file" id="photoInput" name="photo" accept="image/*" class="photo-upload-input" style="display:none;">
                            <p class="help-block" style="margin-top: 15px; font-size: 12px; color: #666;">
                                JPG, PNG ou GIF<br>Max 5MB
                            </p>
                            <input type="hidden" name="photo_actuelle" value="<%= photo != null ? photo : "" %>">
                        </div>
                        
                        <!-- Formulaire à droite -->
                        <div class="form-section">
                            <div class="box box-primary">
                                <div class="box-header with-border" style="display:none;">
                                    <h3 class="box-title"><i class="fa fa-user"></i> Informations personnelles</h3>
                                </div>
                                <div class="box-body">
                                    <%
                                        pi.getFormu().makeHtmlInsertTabIndex();
                                        out.println(pi.getFormu().getHtmlInsert());
                                    %>
                                </div>
                                <div class="box-footer" style="display:none;">
                                    <input name="acte" type="hidden" value="update">
                                    <input name="bute" type="hidden" value="profil/mon-profil.jsp">
                                    <input name="classe" type="hidden" value="utilisateurAcade.UtilisateurAcade">
                                    <input name="nomtable" type="hidden" value="utilisateur">
                                    <input name="refuser" type="hidden" value="<%= refuser %>">
                                    <button type="submit" class="btn btn-primary btn-lg">
                                        <i class="fa fa-save"></i> Enregistrer les modifications
                                    </button>
                                    <a href="<%= lien %>?but=profil/mon-profil.jsp" class="btn btn-default btn-lg">
                                        <i class="fa fa-times"></i> Annuler
                                    </a>
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </section>
</div>

<script>
// Pr&eacute;visualisation de l'image s&eacute;lectionn&eacute;e
document.getElementById('photoInput').addEventListener('change', function(e) {
    var file = e.target.files[0];
    if (file) {
        // V&eacute;rifier que c'est bien une image
        if (!file.type.startsWith('image/')) {
            alert('Veuillez s\u00e9lectionner une image valide (JPG, PNG, GIF)');
            this.value = '';
            return;
        }
        
        // V&eacute;rifier la taille (max 5MB)
        if (file.size > 5 * 1024 * 1024) {
            alert('L\'image est trop grande. Taille maximum: 5MB');
            this.value = '';
            return;
        }
        
        // Afficher l'aper\u00e7u
        var reader = new FileReader();
        reader.onload = function(event) {
            document.getElementById('photoPreview').src = event.target.result;
        };
        reader.readAsDataURL(file);
    }
});

// Masquer uniquement le champ photo g&eacute;n&eacute;r&eacute; par APJ (pas le conteneur parent)
$(document).ready(function() {
    // Trouver tous les inputs photo sauf notre propre input
    $('.box-body input[name="photo"]').not('#photoInput').each(function() {
        // Masquer uniquement la ligne du formulaire (tr pour table ou form-group pour div)
        var $parent = $(this).closest('tr');
        if ($parent.length) {
            $parent.hide();
        } else {
            $(this).closest('.form-group').hide();
        }
    });
});
</script>

<%  } catch (Exception e) {
        e.printStackTrace();
    }
%>