package bean;

import java.sql.Connection;
import java.sql.Timestamp;

public class Post extends ClassMAPTable {
    private String id;
    private int idutilisateur;
    private String idgroupe;
    private String idtypepublication;
    private String idstatutpublication;
    private String idvisibilite;
    private String contenu;
    private int epingle;
    private int supprime;
    private Timestamp date_suppression;
    private int nb_likes;
    private int nb_commentaires;
    private int nb_partages;
    private Timestamp created_at;
    private Timestamp edited_at;
    private int edited_by;

    public Post() {
        super.setNomTable("posts");
    }

    @Override
    public String getTuppleID() {
        return this.id;
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    public void construirePK(Connection c) throws Exception {
        super.setNomTable("posts");
        this.preparePk("POST", "getseqposts");
        this.setId(makePK(c));
    }

    // Getters et Setters
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

    public String getIdgroupe() {
        return idgroupe;
    }

    public void setIdgroupe(String idgroupe) {
        this.idgroupe = idgroupe;
    }

    public String getIdtypepublication() {
        return idtypepublication;
    }

    public void setIdtypepublication(String idtypepublication) {
        this.idtypepublication = idtypepublication;
    }

    public String getIdstatutpublication() {
        return idstatutpublication;
    }

    public void setIdstatutpublication(String idstatutpublication) {
        this.idstatutpublication = idstatutpublication;
    }

    public String getIdvisibilite() {
        return idvisibilite;
    }

    public void setIdvisibilite(String idvisibilite) {
        this.idvisibilite = idvisibilite;
    }

    public String getContenu() {
        return contenu;
    }

    public void setContenu(String contenu) {
        this.contenu = contenu;
    }

    public int getEpingle() {
        return epingle;
    }

    public void setEpingle(int epingle) {
        this.epingle = epingle;
    }

    public int getSupprime() {
        return supprime;
    }

    public void setSupprime(int supprime) {
        this.supprime = supprime;
    }

    public Timestamp getDate_suppression() {
        return date_suppression;
    }

    public void setDate_suppression(Timestamp date_suppression) {
        this.date_suppression = date_suppression;
    }

    public int getNb_likes() {
        return nb_likes;
    }

    public void setNb_likes(int nb_likes) {
        this.nb_likes = nb_likes;
    }

    public int getNb_commentaires() {
        return nb_commentaires;
    }

    public void setNb_commentaires(int nb_commentaires) {
        this.nb_commentaires = nb_commentaires;
    }

    public int getNb_partages() {
        return nb_partages;
    }

    public void setNb_partages(int nb_partages) {
        this.nb_partages = nb_partages;
    }

    public Timestamp getCreated_at() {
        return created_at;
    }

    public void setCreated_at(Timestamp created_at) {
        this.created_at = created_at;
    }

    public Timestamp getEdited_at() {
        return edited_at;
    }

    public void setEdited_at(Timestamp edited_at) {
        this.edited_at = edited_at;
    }

    public int getEdited_by() {
        return edited_by;
    }

    public void setEdited_by(int edited_by) {
        this.edited_by = edited_by;
    }
}
