package bean;

import java.sql.Connection;
import java.sql.Timestamp;

public class GroupeMembre extends ClassMAPTable {
    private String id;
    private int idutilisateur;
    private String idgroupe;
    private String idrole;
    private String statut;
    private Timestamp joined_at;

    public GroupeMembre() {
        super.setNomTable("groupe_membres");
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
        super.setNomTable("groupe_membres");
        this.preparePk("GMBR", "getseqgroupemembres");
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

    public String getIdrole() {
        return idrole;
    }

    public void setIdrole(String idrole) {
        this.idrole = idrole;
    }

    public String getStatut() {
        return statut;
    }

    public void setStatut(String statut) {
        this.statut = statut;
    }

    public Timestamp getJoined_at() {
        return joined_at;
    }

    public void setJoined_at(Timestamp joined_at) {
        this.joined_at = joined_at;
    }
}
