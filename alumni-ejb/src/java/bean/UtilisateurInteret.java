package bean;

import java.sql.Connection;
import java.sql.Timestamp;

public class UtilisateurInteret extends ClassMAPTable {
    private String id;
    private int idutilisateur;
    private String topic_id;
    private Timestamp created_at;

    public UtilisateurInteret() {
        super.setNomTable("utilisateur_interets");
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
        super.setNomTable("utilisateur_interets");
        this.preparePk("UINT", "getsequtilisateurinterets");
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

    public String getTopic_id() {
        return topic_id;
    }

    public void setTopic_id(String topic_id) {
        this.topic_id = topic_id;
    }

    public Timestamp getCreated_at() {
        return created_at;
    }

    public void setCreated_at(Timestamp created_at) {
        this.created_at = created_at;
    }
}
