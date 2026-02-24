package moderation;

import bean.ClassMAPTable;

/**
 * Vue pour l'historique des actions de modération avec détails utilisateur/modérateur.
 */
public class ModerationHistoriqueLibCPL extends ClassMAPTable {
    private String id;
    private int idutilisateur;
    private String utilisateur_nom;
    private String utilisateur_prenom;
    private int idmoderateur;
    private String moderateur_nom;
    private String moderateur_prenom;
    private String type_action;
    private String motif;
    private String date_action;
    private String date_expiration;

    public ModerationHistoriqueLibCPL() {
        super.setNomTable("v_moderation_historique");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public int getIdutilisateur() { return idutilisateur; }
    public void setIdutilisateur(int idutilisateur) { this.idutilisateur = idutilisateur; }

    public String getUtilisateur_nom() { return utilisateur_nom; }
    public void setUtilisateur_nom(String utilisateur_nom) { this.utilisateur_nom = utilisateur_nom; }

    public String getUtilisateur_prenom() { return utilisateur_prenom; }
    public void setUtilisateur_prenom(String utilisateur_prenom) { this.utilisateur_prenom = utilisateur_prenom; }

    public int getIdmoderateur() { return idmoderateur; }
    public void setIdmoderateur(int idmoderateur) { this.idmoderateur = idmoderateur; }

    public String getModerateur_nom() { return moderateur_nom; }
    public void setModerateur_nom(String moderateur_nom) { this.moderateur_nom = moderateur_nom; }

    public String getModerateur_prenom() { return moderateur_prenom; }
    public void setModerateur_prenom(String moderateur_prenom) { this.moderateur_prenom = moderateur_prenom; }

    public String getType_action() { return type_action; }
    public void setType_action(String type_action) { this.type_action = type_action; }

    public String getMotif() { return motif; }
    public void setMotif(String motif) { this.motif = motif; }

    public String getDate_action() { return date_action; }
    public void setDate_action(String date_action) { this.date_action = date_action; }

    public String getDate_expiration() { return date_expiration; }
    public void setDate_expiration(String date_expiration) { this.date_expiration = date_expiration; }

    @Override
    public String getTuppleID() { return this.id; }

    @Override
    public String getAttributIDName() { return "id"; }
}
