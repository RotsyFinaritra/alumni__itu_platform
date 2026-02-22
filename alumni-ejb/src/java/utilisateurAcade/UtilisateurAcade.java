/*
 * Alumni ITU Platform - Classe utilisateur du projet Alumni
 */
package utilisateurAcade;

import bean.CGenUtil;
import utilisateur.Utilisateur;
import utilitaire.UtilDB;

import java.sql.Connection;

public class UtilisateurAcade extends Utilisateur {

    // Champs Alumni spécifiques
    private String prenom;
    private String etu;
    private String mail;
    private String photo;
    private String idtypeutilisateur;
    private String idpromotion;

    public UtilisateurAcade() {
        super.setNomTable("utilisateur");
    }

    // --- Champs Alumni ---

    public String getPrenom() {
        return prenom;
    }

    public void setPrenom(String prenom) {
        this.prenom = prenom;
    }

    public String getEtu() {
        return etu;
    }

    public void setEtu(String etu) {
        this.etu = etu;
    }

    public String getMail() {
        return mail;
    }

    public void setMail(String mail) {
        this.mail = mail;
    }

    public String getPhoto() {
        return photo;
    }

    public void setPhoto(String photo) {
        this.photo = photo;
    }

    public String getIdtypeutilisateur() {
        return idtypeutilisateur;
    }

    public void setIdtypeutilisateur(String idtypeutilisateur) {
        this.idtypeutilisateur = idtypeutilisateur;
    }

    public String getIdpromotion() {
        return idpromotion;
    }

    public void setIdpromotion(String idpromotion) {
        this.idpromotion = idpromotion;
    }

    // --- Identité APJ (PK = refuser hérité de Utilisateur) ---

    @Override
    public String getTuppleID() {
        return this.getRefuser();
    }

    @Override
    public String getAttributIDName() {
        return "refuser";
    }

    public void construirePK(Connection c) throws Exception {
        if (c == null) {
            c = new UtilDB().GetConn();
        }
        super.setNomTable("utilisateur");
        this.preparePk("", "getsequtilisateur");
        this.setRefuser(makePK(c));
    }

    public String[] getMotCles() {
        return new String[]{"refuser", "nomuser"};
    }

}
