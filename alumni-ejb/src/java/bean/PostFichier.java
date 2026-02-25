package bean;

import java.sql.Connection;
import java.sql.Timestamp;

public class PostFichier extends ClassMAPTable {
    private String id;
    private String post_id;
    private String idtypefichier;
    private String nom_fichier;
    private String nom_original;
    private String chemin;
    private Long taille_octets;
    private String mime_type;
    private int ordre;
    private Timestamp created_at;

    public PostFichier() {
        super.setNomTable("post_fichiers");
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
        super.setNomTable("post_fichiers");
        this.preparePk("PFIC", "getseqpostfichiers");
        this.setId(makePK(c));
    }

    // Getters et Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getPost_id() {
        return post_id;
    }

    public void setPost_id(String post_id) {
        this.post_id = post_id;
    }

    public String getIdtypefichier() {
        return idtypefichier;
    }

    public void setIdtypefichier(String idtypefichier) {
        this.idtypefichier = idtypefichier;
    }

    public String getNom_fichier() {
        return nom_fichier;
    }

    public void setNom_fichier(String nom_fichier) {
        this.nom_fichier = nom_fichier;
    }

    public String getNom_original() {
        return nom_original;
    }

    public void setNom_original(String nom_original) {
        this.nom_original = nom_original;
    }

    public String getChemin() {
        return chemin;
    }

    public void setChemin(String chemin) {
        this.chemin = chemin;
    }

    public Long getTaille_octets() {
        return taille_octets;
    }

    public void setTaille_octets(Long taille_octets) {
        this.taille_octets = taille_octets;
    }

    public String getMime_type() {
        return mime_type;
    }

    public void setMime_type(String mime_type) {
        this.mime_type = mime_type;
    }

    public int getOrdre() {
        return ordre;
    }

    public void setOrdre(int ordre) {
        this.ordre = ordre;
    }

    public Timestamp getCreated_at() {
        return created_at;
    }

    public void setCreated_at(Timestamp created_at) {
        this.created_at = created_at;
    }
}
