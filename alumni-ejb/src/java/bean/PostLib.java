package bean;

import java.sql.Timestamp;

/**
 * Vue enrichie pour les publications (administration).
 * Utilisee par PageRecherche et PageConsulte (lecture seule).
 * Jointure : posts + utilisateur + type_publication + statut_publication + visibilite_publication + groupes
 */
public class PostLib extends Post {

    // Champs hérités redéclarés (nécessaire pour la réflexion du framework)
    private String id;
    private Timestamp created_at;
    private int supprime;
    private String contenu;
    private int idutilisateur;

    // Champs utilisateur
    private String nomuser;
    private String prenom;
    private String email_auteur;
    private String photo_auteur;
    private String nom_complet;
    
    // Type publication
    private String type_libelle;
    private String type_code;
    private String type_icon;
    private String type_couleur;
    
    // Statut publication
    private String statut_libelle;
    private String statut_code;
    private String statut_couleur;
    
    // Visibilité
    private String visibilite_libelle;
    private String visibilite_code;
    
    // Groupe
    private String groupe_nom;
    
    // Statistiques réelles (COUNT retourne bigint/Long en PostgreSQL)
    private long nb_likes_reel;
    private long nb_commentaires_reel;
    private long nb_partages_reel;
    private long nb_fichiers;
    private long nb_signalements;

    public PostLib() {
        super();
        super.setNomTable("v_posts_admin");
    }

    // Getters et Setters - Champs hérités redéclarés
    @Override
    public String getTuppleID() { return this.id; }
    
    @Override
    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public Timestamp getCreated_at() { return created_at; }
    public void setCreated_at(Timestamp created_at) { this.created_at = created_at; }

    public int getSupprime() { return supprime; }
    public void setSupprime(int supprime) { this.supprime = supprime; }

    public String getContenu() { return contenu; }
    public void setContenu(String contenu) { this.contenu = contenu; }

    public int getIdutilisateur() { return idutilisateur; }
    public void setIdutilisateur(int idutilisateur) { this.idutilisateur = idutilisateur; }

    // Getters et Setters - Utilisateur
    public String getNomuser() { return nomuser; }
    public void setNomuser(String nomuser) { this.nomuser = nomuser; }

    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }

    public String getEmail_auteur() { return email_auteur; }
    public void setEmail_auteur(String email_auteur) { this.email_auteur = email_auteur; }

    public String getPhoto_auteur() { return photo_auteur; }
    public void setPhoto_auteur(String photo_auteur) { this.photo_auteur = photo_auteur; }

    public String getNom_complet() { return nom_complet; }
    public void setNom_complet(String nom_complet) { this.nom_complet = nom_complet; }

    // Getters et Setters - Type publication
    public String getType_libelle() { return type_libelle; }
    public void setType_libelle(String type_libelle) { this.type_libelle = type_libelle; }

    public String getType_code() { return type_code; }
    public void setType_code(String type_code) { this.type_code = type_code; }

    public String getType_icon() { return type_icon; }
    public void setType_icon(String type_icon) { this.type_icon = type_icon; }

    public String getType_couleur() { return type_couleur; }
    public void setType_couleur(String type_couleur) { this.type_couleur = type_couleur; }

    // Getters et Setters - Statut publication
    public String getStatut_libelle() { return statut_libelle; }
    public void setStatut_libelle(String statut_libelle) { this.statut_libelle = statut_libelle; }

    public String getStatut_code() { return statut_code; }
    public void setStatut_code(String statut_code) { this.statut_code = statut_code; }

    public String getStatut_couleur() { return statut_couleur; }
    public void setStatut_couleur(String statut_couleur) { this.statut_couleur = statut_couleur; }

    // Getters et Setters - Visibilité
    public String getVisibilite_libelle() { return visibilite_libelle; }
    public void setVisibilite_libelle(String visibilite_libelle) { this.visibilite_libelle = visibilite_libelle; }

    public String getVisibilite_code() { return visibilite_code; }
    public void setVisibilite_code(String visibilite_code) { this.visibilite_code = visibilite_code; }

    // Getters et Setters - Groupe
    public String getGroupe_nom() { return groupe_nom; }
    public void setGroupe_nom(String groupe_nom) { this.groupe_nom = groupe_nom; }

    // Getters et Setters - Statistiques
    public long getNb_likes_reel() { return nb_likes_reel; }
    public void setNb_likes_reel(long nb_likes_reel) { this.nb_likes_reel = nb_likes_reel; }

    public long getNb_commentaires_reel() { return nb_commentaires_reel; }
    public void setNb_commentaires_reel(long nb_commentaires_reel) { this.nb_commentaires_reel = nb_commentaires_reel; }

    public long getNb_partages_reel() { return nb_partages_reel; }
    public void setNb_partages_reel(long nb_partages_reel) { this.nb_partages_reel = nb_partages_reel; }

    public long getNb_fichiers() { return nb_fichiers; }
    public void setNb_fichiers(long nb_fichiers) { this.nb_fichiers = nb_fichiers; }

    public long getNb_signalements() { return nb_signalements; }
    public void setNb_signalements(long nb_signalements) { this.nb_signalements = nb_signalements; }
}
