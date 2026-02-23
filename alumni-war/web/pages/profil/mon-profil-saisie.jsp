<%@ page import="utilisateurAcade.UtilisateurAcade" %>
<%@ page import="bean.Promotion, bean.TypeUtilisateur, bean.CGenUtil" %>
<%@ page import="affichage.PageInsert, affichage.Liste" %>
<%@ page import="user.UserEJB" %>
<%
    try {
        final UserEJB u = (UserEJB) session.getValue("u");
        final String lien = (String) session.getValue("lien");

        // On modifie toujours son propre profil
        final String refuser = u.getUser().getTuppleID();

        // Charger les donn&eacute;es manuellement avec WHERE explicite
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

        // Libell&eacute;s (null-safe : getChamp peut retourner null)
        affichage.Champ c;
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

        // Listes d&eacute;roulantes pour les FK (APJ : changerEnChamp remplace les Champ par des Liste)
        Liste[] listes = new Liste[2];
        listes[0] = new Liste("idpromotion", new Promotion(), "libelle", "id");
        listes[1] = new Liste("idtypeutilisateur", new TypeUtilisateur(), "libelle", "id");
        pi.getFormu().changerEnChamp(listes);

        // Masquer les champs techniques (null-safe)
        for (String hidden : new String[]{"pwduser", "idrole", "rang", "etu", "photo"}) {
            c = pi.getFormu().getChamp(hidden);
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
                            <div class="">
                                <div class="box-body" style="">
                                    <%
                                        pi.getFormu().makeHtmlInsertTabIndex();
                                        out.println(pi.getFormu().getHtmlInsert());
                                    %>
                                </div>
                                <div class="box-footer" style="display: none;">
                                    <input name="acte" type="hidden" value="update">
                                    <input name="bute" type="hidden" value="profil/mon-profil.jsp">
                                    <input name="classe" type="hidden" value="utilisateurAcade.UtilisateurAcade">
                                    <input name="nomtable" type="hidden" value="utilisateur">
                                    <input name="refuser" type="hidden" value="<%= refuser %>">
                                    
                                </div>
                            </div>
                        </div>
                    </div>
                </form>
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

// Masquer le champ photo g&eacute;n&eacute;r&eacute; automatiquement par APJ
$(document).ready(function() {
    // Chercher et masquer tous les champs avec le nom "photo" dans le formulaire g&eacute;n&eacute;r&eacute;
    $('input[name="photo"]').not('#photoInput').closest('.form-group, tr, div').hide();
    $('label:contains("Photo")').not('.photo-upload-section label').closest('.form-group, tr, div').hide();
});
</script>

<%  } catch (Exception e) {
        e.printStackTrace();
    }
%>