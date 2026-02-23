package utilisateurAcade;

import bean.ClassMAPTable;
import java.sql.Date;

/**
 * Mapping APJ de la vue {@code utilisateur_statut}.
 *
 * Cette vue calcule le statut courant de chaque utilisateur en se basant
 * sur la dernière action de modération enregistrée dans
 * {@code moderation_utilisateur}.
 *
 * Valeurs possibles du champ {@code statut} :
 * <ul>
 *   <li>{@code "actif"}    – aucune sanction active</li>
 *   <li>{@code "suspendu"} – suspendu jusqu'à {@code date_expiration}</li>
 *   <li>{@code "banni"}    – banni définitivement ({@code date_expiration} est null)</li>
 * </ul>
 *
 * <b>Classe en lecture seule</b> – pas de {@code construirePK}.
 */
public class UtilisateurStatut extends ClassMAPTable {

    /** Référence de l'utilisateur (PK de la table utilisateur) */
    private int refuser;

    /** Login de l'utilisateur */
    private String loginuser;

    /** Nom complet de l'utilisateur */
    private String nomuser;

    /** Rôle de l'utilisateur */
    private String idrole;

    /**
     * Statut calculé par la vue :
     * {@code "actif"}, {@code "suspendu"} ou {@code "banni"}.
     */
    private String statut;

    /** Motif de la dernière action de modération (peut être null) */
    private String motif;

    /**
     * Date d'expiration de la suspension (null pour un bannissement permanent
     * ou si l'utilisateur est actif).
     */
    private Date date_expiration;

    /** Référence du modérateur ayant effectué la dernière action */
    private int idmoderateur;

    public UtilisateurStatut() {
        super.setNomTable("utilisateur_statut");
    }

    // ------------------------------------------------------------------ //
    //  Getters / Setters                                                   //
    // ------------------------------------------------------------------ //

    public int getRefuser() {
        return refuser;
    }

    public void setRefuser(int refuser) {
        this.refuser = refuser;
    }

    public String getLoginuser() {
        return loginuser;
    }

    public void setLoginuser(String loginuser) {
        this.loginuser = loginuser;
    }

    public String getNomuser() {
        return nomuser;
    }

    public void setNomuser(String nomuser) {
        this.nomuser = nomuser;
    }

    public String getIdrole() {
        return idrole;
    }

    public void setIdrole(String idrole) {
        this.idrole = idrole;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    public String getMotif() {
        return motif;
    }

    public void setMotif(String motif) {
        this.motif = motif;
    }

    public Date getDate_expiration() {
        return date_expiration;
    }

    public void setDate_expiration(Date date_expiration) {
        this.date_expiration = date_expiration;
    }

    public int getIdmoderateur() {
        return idmoderateur;
    }

    public void setIdmoderateur(int idmoderateur) {
        this.idmoderateur = idmoderateur;
    }

    // ------------------------------------------------------------------ //
    //  Contrat APJ ClassMAPTable                                           //
    // ------------------------------------------------------------------ //

    @Override
    public String getTuppleID() {
        return String.valueOf(this.refuser);
    }

    @Override
    public String getAttributIDName() {
        return "refuser";
    }

    // Pas de construirePK : vue SQL en lecture seule, aucune insertion possible.
}
