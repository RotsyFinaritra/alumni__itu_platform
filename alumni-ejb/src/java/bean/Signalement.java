package bean;

import java.sql.Connection;
import java.sql.Timestamp;

public class Signalement extends ClassMAPTable {
    private String id;
    private int idutilisateur;
    private String post_id;
    private String commentaire_id;
    private String idmotifsignalement;
    private String idstatutsignalement;
    private String description;
    private int traite_par = -1;
    private Timestamp traite_at;
    private String decision;
    private Timestamp created_at;

    public Signalement() {
        super.setNomTable("signalements");
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
        super.setNomTable("signalements");
        this.preparePk("SIG", "getseqsignalements");
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

    public String getIdmotifsignalement() {
        return idmotifsignalement;
    }

    public void setIdmotifsignalement(String idmotifsignalement) {
        this.idmotifsignalement = idmotifsignalement;
    }

    public String getIdstatutsignalement() {
        return idstatutsignalement;
    }

    public void setIdstatutsignalement(String idstatutsignalement) {
        this.idstatutsignalement = idstatutsignalement;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getTraite_par() {
        return traite_par;
    }

    public void setTraite_par(int traite_par) {
        this.traite_par = traite_par;
    }

    public Timestamp getTraite_at() {
        return traite_at;
    }

    public void setTraite_at(Timestamp traite_at) {
        this.traite_at = traite_at;
    }

    public String getDecision() {
        return decision;
    }

    public void setDecision(String decision) {
        this.decision = decision;
    }

    public Timestamp getCreated_at() {
        return created_at;
    }

    public void setCreated_at(Timestamp created_at) {
        this.created_at = created_at;
    }
}
