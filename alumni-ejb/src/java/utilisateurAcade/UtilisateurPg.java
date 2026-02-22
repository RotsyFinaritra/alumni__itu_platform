/*
 * Alumni ITU Platform - Mapping utilisateur (APJ auth + champs alumni)
 */
package utilisateurAcade;

import bean.ClassMAPTable;
import java.sql.Connection;

public class UtilisateurPg extends ClassMAPTable {

    // Colonnes APJ obligatoires
    private int refuser;
    private String loginuser;
    private String pwduser;
    private String idrole;
    private String nomuser;
    private String teluser;
    private String adruser;

    // Colonnes Alumni spécifiques
    private String prenom;
    private String etu;
    private String mail;
    private String photo;
    private String idtypeutilisateur;
    private String idpromotion;

    public UtilisateurPg() {
        super.setNomTable("utilisateur");
    }

    public UtilisateurPg(String loginuser, String pwduser, String idrole, String nomuser, String teluser) {
        this.setLoginuser(loginuser);
        this.setPwduser(pwduser);
        this.setIdrole(idrole);
        this.setNomuser(nomuser);
        this.setTeluser(teluser);
    }

    // --- Colonnes APJ ---

    public int getRefuser() { return refuser; }
    public void setRefuser(int refuser) { this.refuser = refuser; }

    public String getLoginuser() { return loginuser; }
    public void setLoginuser(String loginuser) { this.loginuser = loginuser; }

    public String getPwduser() { return pwduser; }
    public void setPwduser(String pwduser) { this.pwduser = pwduser; }

    public String getIdrole() { return idrole; }
    public String getIdRole() { return idrole; }
    public void setIdrole(String idrole) { this.idrole = idrole; }

    public String getNomuser() { return nomuser; }
    public void setNomuser(String nomuser) { this.nomuser = nomuser; }

    public String getTeluser() { return teluser; }
    public void setTeluser(String teluser) { this.teluser = teluser; }

    public String getAdruser() { return adruser; }
    public void setAdruser(String adruser) { this.adruser = adruser; }

    // --- Colonnes Alumni ---

    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }

    public String getEtu() { return etu; }
    public void setEtu(String etu) { this.etu = etu; }

    public String getMail() { return mail; }
    public void setMail(String mail) { this.mail = mail; }

    public String getPhoto() { return photo; }
    public void setPhoto(String photo) { this.photo = photo; }

    public String getIdtypeutilisateur() { return idtypeutilisateur; }
    public void setIdtypeutilisateur(String idtypeutilisateur) { this.idtypeutilisateur = idtypeutilisateur; }

    public String getIdpromotion() { return idpromotion; }
    public void setIdpromotion(String idpromotion) { this.idpromotion = idpromotion; }

    // --- APJ identity ---

    @Override
    public String getTuppleID() {
        return String.valueOf(this.refuser);
    }

    @Override
    public String getAttributIDName() {
        return "refuser";
    }

    public String getAttribuLoguser() { return "loginuser"; }
    public String getAttribumdp() { return "pwduser"; }

    public void construirePK(Connection c) throws Exception {
        super.setNomTable("utilisateur");
        this.preparePk("", "getsequtilisateur");
        this.setRefuser(Integer.valueOf(makePK(c)));
    }
}
