package bean;

import java.sql.Timestamp;

/**
 * Bean simplifié pour v_posts_admin - seulement les champs de base.
 */
public class PostAdmin extends ClassMAPTable {

    private String id;
    private int idutilisateur;
    private String contenu;
    private int supprime;
    private Timestamp created_at;
    
    // Champs de jointure
    private String nom_complet;
    private String type_libelle;
    private String statut_libelle;

    public PostAdmin() {
        super.setNomTable("v_posts_admin");
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

    public String getContenu() { return contenu; }
    public void setContenu(String contenu) { this.contenu = contenu; }

    public int getSupprime() { return supprime; }
    public void setSupprime(int supprime) { this.supprime = supprime; }

    public Timestamp getCreated_at() { return created_at; }
    public void setCreated_at(Timestamp created_at) { this.created_at = created_at; }

    public String getNom_complet() { return nom_complet; }
    public void setNom_complet(String nom_complet) { this.nom_complet = nom_complet; }

    public String getType_libelle() { return type_libelle; }
    public void setType_libelle(String type_libelle) { this.type_libelle = type_libelle; }

    public String getStatut_libelle() { return statut_libelle; }
    public void setStatut_libelle(String statut_libelle) { this.statut_libelle = statut_libelle; }
}
