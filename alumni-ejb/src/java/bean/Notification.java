package bean;

import java.sql.Connection;
import java.sql.Timestamp;

public class Notification extends ClassMAPTable {
    private String id;
    private Integer idutilisateur;
    private Integer emetteur_id;
    private String idtypenotification;
    private String post_id;
    private String commentaire_id;
    private String groupe_id;
    private String contenu;
    private String lien;
    private Boolean vu;
    private Timestamp lu_at;
    private Timestamp created_at;

    public Notification() {
        super.setNomTable("notifications");
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
        super.setNomTable("notifications");
        this.preparePk("NOTIF", "getseqnotifications");
        this.setId(makePK(c));
    }

    // Getters et Setters
    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public Integer getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(Integer idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public Integer getEmetteur_id() {
        return emetteur_id;
    }

    public void setEmetteur_id(Integer emetteur_id) {
        this.emetteur_id = emetteur_id;
    }

    public String getIdtypenotification() {
        return idtypenotification;
    }

    public void setIdtypenotification(String idtypenotification) {
        this.idtypenotification = idtypenotification;
    }

    public String getPost_id() {
        return post_id;
    }

    public void setPost_id(String post_id) {
        this.post_id = post_id;
    }

    public String getCommentaire_id() {
        return commentaire_id;
    }

    public void setCommentaire_id(String commentaire_id) {
        this.commentaire_id = commentaire_id;
    }

    public String getGroupe_id() {
        return groupe_id;
    }

    public void setGroupe_id(String groupe_id) {
        this.groupe_id = groupe_id;
    }

    public String getContenu() {
        return contenu;
    }

    public void setContenu(String contenu) {
        this.contenu = contenu;
    }

    public String getLien() {
        return lien;
    }

    public void setLien(String lien) {
        this.lien = lien;
    }

    public Boolean getVu() {
        return vu;
    }

    public void setVu(Boolean vu) {
        this.vu = vu;
    }

    public Timestamp getLu_at() {
        return lu_at;
    }

    public void setLu_at(Timestamp lu_at) {
        this.lu_at = lu_at;
    }

    public Timestamp getCreated_at() {
        return created_at;
    }

    public void setCreated_at(Timestamp created_at) {
        this.created_at = created_at;
    }
}
