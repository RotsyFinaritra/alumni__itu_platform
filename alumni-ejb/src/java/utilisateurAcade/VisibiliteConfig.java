package utilisateurAcade;

import bean.ClassMAPTable;

/**
 * Vue pivot de la table visibilite_utilisateur.
 * 
 * Mappe la vue v_visibilite_config qui transforme les lignes EAV
 * (idutilisateur, nomchamp, visible) en une ligne plate par utilisateur
 * avec une colonne par champ de visibilité.
 * 
 * Utilisé par PageUpdate dans visibilite.jsp pour l'édition APJ.
 * La sauvegarde reste via VisibiliteService (UPSERT sur la table EAV).
 * 
 * IMPORTANT : Tous les champs sont String pour compatibilité avec
 * CGenUtil.setValChamp() qui utilise la réflexion avec des paramètres String.
 */
public class VisibiliteConfig extends ClassMAPTable {

    private String idutilisateur;
    private String visimail;
    private String visiteluser;
    private String visiadruser;
    private String visiphoto;
    private String visiprenom;
    private String visinomuser;
    private String visiloginuser;
    private String visiidpromotion;

    public VisibiliteConfig() {
        super.setNomTable("v_visibilite_config");
    }

    // ------------------------------------------------------------------ //
    //  Contrat APJ ClassMAPTable                                          //
    // ------------------------------------------------------------------ //

    @Override
    public String getTuppleID() {
        return idutilisateur;
    }

    @Override
    public String getAttributIDName() {
        return "idutilisateur";
    }

    // ------------------------------------------------------------------ //
    //  Getters / Setters                                                  //
    // ------------------------------------------------------------------ //

    public String getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(String idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public String getVisimail() {
        return visimail;
    }

    public void setVisimail(String visimail) {
        this.visimail = visimail;
    }

    public String getVisiteluser() {
        return visiteluser;
    }

    public void setVisiteluser(String visiteluser) {
        this.visiteluser = visiteluser;
    }

    public String getVisiadruser() {
        return visiadruser;
    }

    public void setVisiadruser(String visiadruser) {
        this.visiadruser = visiadruser;
    }

    public String getVisiphoto() {
        return visiphoto;
    }

    public void setVisiphoto(String visiphoto) {
        this.visiphoto = visiphoto;
    }

    public String getVisiprenom() {
        return visiprenom;
    }

    public void setVisiprenom(String visiprenom) {
        this.visiprenom = visiprenom;
    }

    public String getVisinomuser() {
        return visinomuser;
    }

    public void setVisinomuser(String visinomuser) {
        this.visinomuser = visinomuser;
    }

    public String getVisiloginuser() {
        return visiloginuser;
    }

    public void setVisiloginuser(String visiloginuser) {
        this.visiloginuser = visiloginuser;
    }

    public String getVisiidpromotion() {
        return visiidpromotion;
    }

    public void setVisiidpromotion(String visiidpromotion) {
        this.visiidpromotion = visiidpromotion;
    }
}
