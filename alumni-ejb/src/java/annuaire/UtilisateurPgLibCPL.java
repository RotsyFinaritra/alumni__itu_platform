
package annuaire;

import bean.ClassMAPTable;

public class UtilisateurPgLibCPL extends ClassMAPTable {
    private int refuser;
    private String loginuser;
    private String nomuser;
    private String prenom;
    private String mail;
    private String teluser;
    private String adruser;
    private String photo;
    private String idtypeutilisateur;
    private String idpromotion;
    private String promotion;
    private String typeutilisateur;
    private String competence;
    private String entreprise;
    private String idville;
    private String ville;
    private String idpays;
    private String pays;

    public UtilisateurPgLibCPL() {
        super.setNomTable("v_utilisateurpg_libcpl");
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
    public String getTeluser() { return teluser; }
    public void setTeluser(String teluser) { this.teluser = teluser; }
    public String getAdruser() { return adruser; }
    public void setAdruser(String adruser) { this.adruser = adruser; }
    public String getPhoto() { return photo; }
    public void setPhoto(String photo) { this.photo = photo; }
    public String getIdtypeutilisateur() { return idtypeutilisateur; }
    public void setIdtypeutilisateur(String idtypeutilisateur) { this.idtypeutilisateur = idtypeutilisateur; }
    public String getIdpromotion() { return idpromotion; }
    public void setIdpromotion(String idpromotion) { this.idpromotion = idpromotion; }
    public String getPromotion() { return promotion; }
    public void setPromotion(String promotion) { this.promotion = promotion; }
    public String getTypeutilisateur() { return typeutilisateur; }
    public void setTypeutilisateur(String typeutilisateur) { this.typeutilisateur = typeutilisateur; }
    public String getCompetence() { return competence; }
    public void setCompetence(String competence) { this.competence = competence; }
    public String getEntreprise() { return entreprise; }
    public void setEntreprise(String entreprise) { this.entreprise = entreprise; }
    public String getIdville() { return idville; }
    public void setIdville(String idville) { this.idville = idville; }
    public String getVille() { return ville; }
    public void setVille(String ville) { this.ville = ville; }
    public String getIdpays() { return idpays; }
    public void setIdpays(String idpays) { this.idpays = idpays; }
    public String getPays() { return pays; }
    public void setPays(String pays) { this.pays = pays; }

    @Override
    public String getTuppleID() { return String.valueOf(this.refuser); }
    @Override
    public String getAttributIDName() { return "refuser"; }
}
