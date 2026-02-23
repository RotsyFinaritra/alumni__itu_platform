package utilisateurAcade;

import bean.ClassMAPTable;
import java.sql.Connection;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * Mapping APJ de la table moderation_utilisateur.
 *
 * Cette table enregistre les actions de modération sur les comptes :
 * suspension temporaire, bannissement définitif, ou levée de sanction.
 *
 * La séquence PostgreSQL {@code seqmoderationutilisateur} et la fonction
 * {@code getseqmoderationutilisateur()} sont définies dans le script SQL
 * BDD/2026-02-22-Rotsy-2.sql.
 */
public class ModerationUtilisateur extends ClassMAPTable {

    /** Identifiant unique de l'action de modération (PK, ex : MOD000001) */
    private String id;

    /** Référence vers l'utilisateur concerné */
    private int idutilisateur;

    /** Référence vers le modérateur ayant effectué l'action */
    private int idmoderateur;

    /**
     * Type d'action :
     * <ul>
     *   <li>{@code "suspendu"} – suspension temporaire</li>
     *   <li>{@code "banni"}    – bannissement définitif</li>
     *   <li>{@code "leve"}     – levée de la sanction</li>
     * </ul>
     */
    private String type_action;

    /** Motif de la décision (texte libre, facultatif) */
    private String motif;

    /** Horodatage de l'action (valeur par défaut SQL : CURRENT_TIMESTAMP) */
    private Timestamp date_action;

    /**
     * Date d'expiration de la suspension.
     * {@code null} pour un bannissement permanent.
     */
    private Date date_expiration;

    public ModerationUtilisateur() {
        super.setNomTable("moderation_utilisateur");
    }

    // ------------------------------------------------------------------ //
    //  Getters / Setters                                                   //
    // ------------------------------------------------------------------ //

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public int getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(int idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public int getIdmoderateur() {
        return idmoderateur;
    }

    public void setIdmoderateur(int idmoderateur) {
        this.idmoderateur = idmoderateur;
    }

    public String getType_action() {
        return type_action;
    }

    public void setType_action(String type_action) {
        this.type_action = type_action;
    }

    public String getMotif() {
        return motif;
    }

    public void setMotif(String motif) {
        this.motif = motif;
    }

    public Timestamp getDate_action() {
        return date_action;
    }

    public void setDate_action(Timestamp date_action) {
        this.date_action = date_action;
    }

    public Date getDate_expiration() {
        return date_expiration;
    }

    public void setDate_expiration(Date date_expiration) {
        this.date_expiration = date_expiration;
    }

    // ------------------------------------------------------------------ //
    //  Contrat APJ ClassMAPTable                                           //
    // ------------------------------------------------------------------ //

    @Override
    public String getTuppleID() {
        return this.id;
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    /**
     * Génère la clé primaire en utilisant la séquence PostgreSQL
     * {@code seqmoderationutilisateur}.
     * Format généré : {@code MOD} + numéro séquence complété à 6 chiffres,
     * ex : {@code MOD000001}.
     */
    public void construirePK(Connection c) throws Exception {
        super.setNomTable("moderation_utilisateur");
        this.preparePk("MOD", "getseqmoderationutilisateur");
        this.setId(makePK(c));
    }
}
