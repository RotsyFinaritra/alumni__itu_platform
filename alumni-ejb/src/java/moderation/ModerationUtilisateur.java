package moderation;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;

/**
 * Bean APJ pour la table moderation_utilisateur.
 * Gère les actions de modération (bannissement, suspension, levée).
 */
public class ModerationUtilisateur extends ClassMAPTable {
    private String id;
    private int idutilisateur;
    private int idmoderateur;
    private String type_action; // 'suspendu', 'banni', 'leve'
    private String motif;
    private Timestamp date_action;
    private Date date_expiration;

    public ModerationUtilisateur() {
        super.setNomTable("moderation_utilisateur");
    }

    // Getters et Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public int getIdutilisateur() { return idutilisateur; }
    public void setIdutilisateur(int idutilisateur) { this.idutilisateur = idutilisateur; }

    public int getIdmoderateur() { return idmoderateur; }
    public void setIdmoderateur(int idmoderateur) { this.idmoderateur = idmoderateur; }

    public String getType_action() { return type_action; }
    public void setType_action(String type_action) { this.type_action = type_action; }

    public String getMotif() { return motif; }
    public void setMotif(String motif) { this.motif = motif; }

    public Timestamp getDate_action() { return date_action; }
    public void setDate_action(Timestamp date_action) { this.date_action = date_action; }

    public Date getDate_expiration() { return date_expiration; }
    public void setDate_expiration(Date date_expiration) { this.date_expiration = date_expiration; }

    @Override
    public String getTuppleID() { return this.id; }

    @Override
    public String getAttributIDName() { return "id"; }

    /**
     * Construit la clé primaire selon le pattern APJ.
     */
    public void construirePK(Connection c) throws Exception {
        super.setNomTable("moderation_utilisateur");
        this.preparePk("MOD", "getseqmoderationutilisateur");
        this.setId(makePK(c));
    }

    /**
     * Bannit un utilisateur.
     * L'insertion dans moderation_utilisateur met automatiquement à jour
     * la vue utilisateur_statut (dernière action = statut actuel).
     */
    public static void bannir(Connection con, int idUtilisateur, int idModerateur, String motif, java.util.Date dateExpiration) throws Exception {
        ModerationUtilisateur m = new ModerationUtilisateur();
        m.construirePK(con);
        m.setIdutilisateur(idUtilisateur);
        m.setIdmoderateur(idModerateur);
        m.setType_action("banni");
        m.setMotif(motif);
        m.setDate_action(new Timestamp(System.currentTimeMillis()));
        // Convertir java.util.Date en java.sql.Date
        if (dateExpiration != null) {
            m.setDate_expiration(new Date(dateExpiration.getTime()));
        }
        m.insertToTable(con);
    }

    /**
     * Suspend temporairement un utilisateur.
     */
    public static void suspendre(Connection con, int idUtilisateur, int idModerateur, String motif, java.util.Date dateExpiration) throws Exception {
        ModerationUtilisateur m = new ModerationUtilisateur();
        m.construirePK(con);
        m.setIdutilisateur(idUtilisateur);
        m.setIdmoderateur(idModerateur);
        m.setType_action("suspendu");
        m.setMotif(motif);
        m.setDate_action(new Timestamp(System.currentTimeMillis()));
        // Convertir java.util.Date en java.sql.Date
        if (dateExpiration != null) {
            m.setDate_expiration(new Date(dateExpiration.getTime()));
        }
        m.insertToTable(con);
    }

    /**
     * Lève une sanction (débannissement).
     */
    public static void lever(Connection con, int idUtilisateur, int idModerateur, String motif) throws Exception {
        ModerationUtilisateur m = new ModerationUtilisateur();
        m.construirePK(con);
        m.setIdutilisateur(idUtilisateur);
        m.setIdmoderateur(idModerateur);
        m.setType_action("leve");
        m.setMotif(motif != null ? motif : "Sanction levée");
        m.setDate_action(new Timestamp(System.currentTimeMillis()));
        // date_expiration reste null pour levée
        m.insertToTable(con);
    }

    /**
     * Vérifie si un utilisateur est actuellement banni.
     */
    public static boolean estBanni(Connection con, int idUtilisateur) throws Exception {
        String sql = "SELECT statut FROM utilisateur_statut WHERE refuser = ?";
        PreparedStatement ps = con.prepareStatement(sql);
        ps.setInt(1, idUtilisateur);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            String statut = rs.getString("statut");
            return "banni".equalsIgnoreCase(statut) || "suspendu".equalsIgnoreCase(statut);
        }
        return false;
    }
}
