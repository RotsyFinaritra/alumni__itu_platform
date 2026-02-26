package bean;

import java.sql.Timestamp;

/**
 * Bean pour v_signalements_commentaires - signalements de commentaires avec jointures.
 */
public class SignalementCommentaire extends ClassMAPTable {

    // Champs de signalements
    private String id;
    private int idutilisateur;
    private String commentaire_id;
    private String idmotifsignalement;
    private String idstatutsignalement;
    private String description;
    private int traite_par;
    private Timestamp traite_at;
    private String decision;
    private Timestamp created_at;
    
    // Champs de jointure - signaleur
    private String signaleur_nom;
    private String signaleur_email;
    
    // Champs de jointure - motif
    private String motif_libelle;
    private String motif_code;
    private int motif_gravite;
    private String motif_couleur;
    private String motif_icon;
    
    // Champs de jointure - statut
    private String statut_libelle;
    private String statut_code;
    private String statut_couleur;
    
    // Champs de jointure - commentaire
    private String commentaire_contenu;
    private int commentaire_supprime;
    private Timestamp commentaire_date;
    private String commentaire_post_id;
    private String commentaire_auteur;
    
    // Champs de jointure - modérateur
    private String moderateur_nom;

    public SignalementCommentaire() {
        super.setNomTable("v_signalements_commentaires");
    }

    @Override
    public String getTuppleID() {
        return this.id;
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    // Getters et Setters
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public int getIdutilisateur() { return idutilisateur; }
    public void setIdutilisateur(int idutilisateur) { this.idutilisateur = idutilisateur; }

    public String getCommentaire_id() { return commentaire_id; }
    public void setCommentaire_id(String commentaire_id) { this.commentaire_id = commentaire_id; }

    public String getIdmotifsignalement() { return idmotifsignalement; }
    public void setIdmotifsignalement(String idmotifsignalement) { this.idmotifsignalement = idmotifsignalement; }

    public String getIdstatutsignalement() { return idstatutsignalement; }
    public void setIdstatutsignalement(String idstatutsignalement) { this.idstatutsignalement = idstatutsignalement; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public int getTraite_par() { return traite_par; }
    public void setTraite_par(int traite_par) { this.traite_par = traite_par; }

    public Timestamp getTraite_at() { return traite_at; }
    public void setTraite_at(Timestamp traite_at) { this.traite_at = traite_at; }

    public String getDecision() { return decision; }
    public void setDecision(String decision) { this.decision = decision; }

    public Timestamp getCreated_at() { return created_at; }
    public void setCreated_at(Timestamp created_at) { this.created_at = created_at; }

    public String getSignaleur_nom() { return signaleur_nom; }
    public void setSignaleur_nom(String signaleur_nom) { this.signaleur_nom = signaleur_nom; }

    public String getSignaleur_email() { return signaleur_email; }
    public void setSignaleur_email(String signaleur_email) { this.signaleur_email = signaleur_email; }

    public String getMotif_libelle() { return motif_libelle; }
    public void setMotif_libelle(String motif_libelle) { this.motif_libelle = motif_libelle; }

    public String getMotif_code() { return motif_code; }
    public void setMotif_code(String motif_code) { this.motif_code = motif_code; }

    public int getMotif_gravite() { return motif_gravite; }
    public void setMotif_gravite(int motif_gravite) { this.motif_gravite = motif_gravite; }

    public String getMotif_couleur() { return motif_couleur; }
    public void setMotif_couleur(String motif_couleur) { this.motif_couleur = motif_couleur; }

    public String getMotif_icon() { return motif_icon; }
    public void setMotif_icon(String motif_icon) { this.motif_icon = motif_icon; }

    public String getStatut_libelle() { return statut_libelle; }
    public void setStatut_libelle(String statut_libelle) { this.statut_libelle = statut_libelle; }

    public String getStatut_code() { return statut_code; }
    public void setStatut_code(String statut_code) { this.statut_code = statut_code; }

    public String getStatut_couleur() { return statut_couleur; }
    public void setStatut_couleur(String statut_couleur) { this.statut_couleur = statut_couleur; }

    public String getCommentaire_contenu() { return commentaire_contenu; }
    public void setCommentaire_contenu(String commentaire_contenu) { this.commentaire_contenu = commentaire_contenu; }

    public int getCommentaire_supprime() { return commentaire_supprime; }
    public void setCommentaire_supprime(int commentaire_supprime) { this.commentaire_supprime = commentaire_supprime; }

    public Timestamp getCommentaire_date() { return commentaire_date; }
    public void setCommentaire_date(Timestamp commentaire_date) { this.commentaire_date = commentaire_date; }

    public String getCommentaire_post_id() { return commentaire_post_id; }
    public void setCommentaire_post_id(String commentaire_post_id) { this.commentaire_post_id = commentaire_post_id; }

    public String getCommentaire_auteur() { return commentaire_auteur; }
    public void setCommentaire_auteur(String commentaire_auteur) { this.commentaire_auteur = commentaire_auteur; }

    public String getModerateur_nom() { return moderateur_nom; }
    public void setModerateur_nom(String moderateur_nom) { this.moderateur_nom = moderateur_nom; }
}
