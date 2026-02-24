package moderation;

import bean.ClassMAPTable;

/**
 * Mapping APJ de la vue v_utilisateur_moderation.
 * Utilisée pour afficher la liste des utilisateurs avec leur statut de modération.
 */
public class UtilisateurModerationLibCPL extends ClassMAPTable {
    private int refuser;
    private String loginuser;
    private String nomuser;
    private String prenom;
    private String mail;
    private String photo;
    private String idrole;
    private String role_libelle;
    private int role_rang;
    private String statut;
    private String dernier_motif;
    private String date_expiration;
    private String promotion;

    public UtilisateurModerationLibCPL() {
        super.setNomTable("v_utilisateur_moderation");
    }

    public int getRefuser() { return refuser; }
    public void setRefuser(int refuser) { this.refuser = refuser; }

    public String getLoginuser() { return loginuser; }
    public void setLoginuser(String loginuser) { this.loginuser = loginuser; }

    public String getNomuser() { return nomuser; }
    public void setNomuser(String nomuser) { this.nomuser = nomuser; }

    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }

    public String getMail() { return mail; }
    public void setMail(String mail) { this.mail = mail; }

    public String getPhoto() { return photo; }
    public void setPhoto(String photo) { this.photo = photo; }

    public String getIdrole() { return idrole; }
    public void setIdrole(String idrole) { this.idrole = idrole; }

    public String getRole_libelle() { return role_libelle; }
    public void setRole_libelle(String role_libelle) { this.role_libelle = role_libelle; }

    public int getRole_rang() { return role_rang; }
    public void setRole_rang(int role_rang) { this.role_rang = role_rang; }

    public String getStatut() { return statut; }
    public void setStatut(String statut) { this.statut = statut; }

    public String getDernier_motif() { return dernier_motif; }
    public void setDernier_motif(String dernier_motif) { this.dernier_motif = dernier_motif; }

    public String getDate_expiration() { return date_expiration; }
    public void setDate_expiration(String date_expiration) { this.date_expiration = date_expiration; }

    public String getPromotion() { return promotion; }
    public void setPromotion(String promotion) { this.promotion = promotion; }

    @Override
    public String getTuppleID() { return String.valueOf(this.refuser); }

    @Override
    public String getAttributIDName() { return "refuser"; }
}
