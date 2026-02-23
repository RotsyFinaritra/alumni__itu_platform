package bean;

import java.sql.Connection;

public class ReseauUtilisateur extends ClassMAPTable {
    private String id;
    private String idreseauxsociaux;
    private int idutilisateur;

    public ReseauUtilisateur() {
        super.setNomTable("reseau_utilisateur");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getIdreseauxsociaux() { return idreseauxsociaux; }
    public void setIdreseauxsociaux(String idreseauxsociaux) { this.idreseauxsociaux = idreseauxsociaux; }

    public int getIdutilisateur() { return idutilisateur; }
    public void setIdutilisateur(int idutilisateur) { this.idutilisateur = idutilisateur; }

    @Override
    public String getTuppleID() { return this.id; }

    @Override
    public String getAttributIDName() { return "id"; }

    public void construirePK(Connection c) throws Exception {
        super.setNomTable("reseau_utilisateur");
        this.preparePk("RSTU", "getseqreseauutilisateur");
        this.setId(makePK(c));
    }
}
