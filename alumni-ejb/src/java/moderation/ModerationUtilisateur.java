package moderation;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.Date;

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
     * Génère un nouvel ID via la séquence PostgreSQL.
     */
    public static String genererNouvelId(Connection con) throws Exception {
        String sql = "SELECT getseqmoderationutilisateur()";
        PreparedStatement ps = con.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            return "MOD" + String.format("%010d", rs.getInt(1));
        }
        throw new Exception("Erreur lors de la génération de l'ID de modération");
    }

    /**
     * Bannit un utilisateur.
     * @param con Connexion BDD
     * @param idUtilisateur ID de l'utilisateur à bannir
     * @param idModerateur ID du modérateur effectuant l'action
     * @param motif Raison du bannissement
     * @param dateExpiration Date d'expiration (null = permanent)
     */
    public static void bannir(Connection con, int idUtilisateur, int idModerateur, String motif, Date dateExpiration) throws Exception {
        ModerationUtilisateur m = new ModerationUtilisateur();
        m.setId(genererNouvelId(con));
        m.setIdutilisateur(idUtilisateur);
        m.setIdmoderateur(idModerateur);
        m.setType_action("banni");
        m.setMotif(motif);
        m.setDate_expiration(dateExpiration);
        m.insertToTable(con);
    }

    /**
     * Suspend temporairement un utilisateur.
     */
    public static void suspendre(Connection con, int idUtilisateur, int idModerateur, String motif, Date dateExpiration) throws Exception {
        ModerationUtilisateur m = new ModerationUtilisateur();
        m.setId(genererNouvelId(con));
        m.setIdutilisateur(idUtilisateur);
        m.setIdmoderateur(idModerateur);
        m.setType_action("suspendu");
        m.setMotif(motif);
        m.setDate_expiration(dateExpiration);
        m.insertToTable(con);
    }

    /**
     * Lève une sanction (débannissement).
     */
    public static void lever(Connection con, int idUtilisateur, int idModerateur, String motif) throws Exception {
        ModerationUtilisateur m = new ModerationUtilisateur();
        m.setId(genererNouvelId(con));
        m.setIdutilisateur(idUtilisateur);
        m.setIdmoderateur(idModerateur);
        m.setType_action("leve");
        m.setMotif(motif != null ? motif : "Sanction levée");
        m.setDate_expiration(null);
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
