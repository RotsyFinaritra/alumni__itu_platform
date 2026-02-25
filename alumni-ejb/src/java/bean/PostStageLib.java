package bean;

import java.sql.Timestamp;

/**
 * Vue enrichie pour les offres de stage.
 * Utilisee par PageRecherche et PageConsulte (lecture seule).
 * Jointure : post_stage + posts + utilisateur_acade + statut_publication + visibilite_publication
 */
public class PostStageLib extends PostStage {

    // Champs additionnels venant des JOINs dans v_post_stage_cpl
    private String contenu;
    private String auteur_nom;
    private String statut_libelle;
    private String visibilite_libelle;
    private int nb_likes;
    private int nb_commentaires;
    private int nb_partages;
    private Timestamp created_at;
    private int epingle;
    private int supprime;
    private int idutilisateur;

    public PostStageLib() {
        super();
        super.setNomTable("v_post_stage_cpl");
    }

    public String getContenu() { return contenu; }
    public void setContenu(String contenu) { this.contenu = contenu; }

    public String getAuteur_nom() { return auteur_nom; }
    public void setAuteur_nom(String auteur_nom) { this.auteur_nom = auteur_nom; }

    public String getStatut_libelle() { return statut_libelle; }
    public void setStatut_libelle(String statut_libelle) { this.statut_libelle = statut_libelle; }

    public String getVisibilite_libelle() { return visibilite_libelle; }
    public void setVisibilite_libelle(String visibilite_libelle) { this.visibilite_libelle = visibilite_libelle; }

    public int getNb_likes() { return nb_likes; }
    public void setNb_likes(int nb_likes) { this.nb_likes = nb_likes; }

    public int getNb_commentaires() { return nb_commentaires; }
    public void setNb_commentaires(int nb_commentaires) { this.nb_commentaires = nb_commentaires; }

    public int getNb_partages() { return nb_partages; }
    public void setNb_partages(int nb_partages) { this.nb_partages = nb_partages; }

    public Timestamp getCreated_at() { return created_at; }
    public void setCreated_at(Timestamp created_at) { this.created_at = created_at; }

    public int getEpingle() { return epingle; }
    public void setEpingle(int epingle) { this.epingle = epingle; }

    public int getSupprime() { return supprime; }
    public void setSupprime(int supprime) { this.supprime = supprime; }

    public int getIdutilisateur() { return idutilisateur; }
    public void setIdutilisateur(int idutilisateur) { this.idutilisateur = idutilisateur; }
}
