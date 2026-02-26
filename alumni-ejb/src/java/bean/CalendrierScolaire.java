package bean;

import java.sql.Connection;
import java.sql.Date;
import java.sql.Timestamp;

public class CalendrierScolaire extends ClassMAPTable {
    private String id;
    private String titre;
    private String description;
    private Date date_debut;
    private Date date_fin;
    private String heure_debut;
    private String heure_fin;
    private String couleur;
    private String idpromotion;
    private int created_by = -1;
    private Timestamp created_at;

    public CalendrierScolaire() {
        super.setNomTable("calendrier_scolaire");
    }

    @Override
    public String getTuppleID() {
        return this.id;
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        super.setNomTable("calendrier_scolaire");
        this.preparePk("CAL", "getseqcalendrierscolaire");
        this.setId(makePK(c));
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getTitre() { return titre; }
    public void setTitre(String titre) { this.titre = titre; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Date getDate_debut() { return date_debut; }
    public void setDate_debut(Date date_debut) { this.date_debut = date_debut; }

    public Date getDate_fin() { return date_fin; }
    public void setDate_fin(Date date_fin) { this.date_fin = date_fin; }

    public String getHeure_debut() { return heure_debut; }
    public void setHeure_debut(String heure_debut) { this.heure_debut = heure_debut; }

    public String getHeure_fin() { return heure_fin; }
    public void setHeure_fin(String heure_fin) { this.heure_fin = heure_fin; }

    public String getCouleur() { return couleur; }
    public void setCouleur(String couleur) { this.couleur = couleur; }

    public String getIdpromotion() { return idpromotion; }
    public void setIdpromotion(String idpromotion) { this.idpromotion = idpromotion; }

    public int getCreated_by() { return created_by; }
    public void setCreated_by(int created_by) { this.created_by = created_by; }

    public Timestamp getCreated_at() { return created_at; }
    public void setCreated_at(Timestamp created_at) { this.created_at = created_at; }
}
