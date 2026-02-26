/*
 * Alumni ITU Platform - Mapping utilisateur (APJ auth + champs alumni)
 */
package utilisateurAcade;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import utilitaire.UtilDB;

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

    public static String getIdRoleEquivalent(String idtypeutilisateur) {
        if (idtypeutilisateur == null) return "alumni";
        switch (idtypeutilisateur.trim()) {
            case "TU0000002": return "etudiant";
            case "TU0000003": return "enseignant";
            case "TU0000001":
            default:           return "alumni";
        }
    }

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

    /**
     * Met a jour le profil utilisateur en base.
     * Utilise un PreparedStatement avec setInt pour le WHERE refuser (PK integer),
     * car le framework APJ updateToTable utilise setString pour le PK,
     * ce qui est incompatible avec une colonne SERIAL/integer en PostgreSQL.
     */
    public void updateProfil() throws Exception {
        String sql = "UPDATE utilisateur SET nomuser=?, prenom=?, mail=?, teluser=?, "
                   + "adruser=?, loginuser=?, idpromotion=?, idtypeutilisateur=?, photo=? "
                   + "WHERE refuser=?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = new UtilDB().GetConn();
            ps = conn.prepareStatement(sql);
            ps.setString(1, this.nomuser);
            ps.setString(2, this.prenom);
            ps.setString(3, this.mail);
            ps.setString(4, this.teluser);
            ps.setString(5, this.adruser);
            ps.setString(6, this.loginuser);
            // idpromotion peut être null pour les enseignants
            if (this.idpromotion != null && !this.idpromotion.trim().isEmpty()) {
                ps.setString(7, this.idpromotion);
            } else {
                ps.setNull(7, java.sql.Types.VARCHAR);
            }
            ps.setString(8, this.idtypeutilisateur);
            ps.setString(9, this.photo);
            ps.setInt(10, this.refuser);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                throw new Exception("Aucune ligne modifiee, refuser=" + this.refuser + " introuvable");
            }
        } finally {
            if (ps != null) try { ps.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }

    /**
     * Change le rôle d'un utilisateur.
     * @param refuserCible ID de l'utilisateur cible
     * @param nouveauRole Nouveau rôle ('admin', 'utilisateur')
     * @param con Connection BDD
     */
    public static void changerRole(int refuserCible, String nouveauRole, Connection con) throws Exception {
        String sql = "UPDATE utilisateur SET idrole = ? WHERE refuser = ?";
        PreparedStatement ps = null;
        try {
            ps = con.prepareStatement(sql);
            ps.setString(1, nouveauRole);
            ps.setInt(2, refuserCible);
            int rows = ps.executeUpdate();
            if (rows == 0) {
                throw new Exception("Utilisateur introuvable (refuser=" + refuserCible + ")");
            }
        } finally {
            if (ps != null) try { ps.close(); } catch (Exception e) {}
        }
    }

    /**
     * Promouvoir un utilisateur en admin.
     */
    public static void promouvoir(int refuserCible, Connection con) throws Exception {
        changerRole(refuserCible, "admin", con);
    }

    /**
     * Rétrograder un admin vers le rôle correspondant à son type d'utilisateur.
     * - TU0000001 (Alumni) → 'alumni'
     * - TU0000002 (Étudiant) → 'etudiant'
     * - TU0000003 (Enseignant) → 'enseignant'
     */
    public static void retrograder(int refuserCible, Connection con) throws Exception {
        // Récupérer l'utilisateur via CGenUtil avec apresWhere explicite et connexion
        Object[] resultats = bean.CGenUtil.rechercher(new UtilisateurPg(), null, null, con, " and refuser=" + refuserCible);

        if (resultats == null || resultats.length == 0) {
            throw new Exception("Utilisateur introuvable (refuser=" + refuserCible + ")");
        }

        UtilisateurPg utilisateur = (UtilisateurPg) resultats[0];

        // Déterminer le rôle approprié basé sur le type d'utilisateur
        String nouveauRole = getIdRoleEquivalent(utilisateur.getIdtypeutilisateur());

        // Appliquer le nouveau rôle
        changerRole(refuserCible, nouveauRole, con);
    }
}
