package bean;

import java.sql.Connection;

public class Pays extends ClassMAPTable {
    private String id;
    private String libelle;

    public Pays() {
        super.setNomTable("pays");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }

    @Override
    public String getTuppleID() { return this.id; }

    @Override
    public String getAttributIDName() { return "id"; }

    @Override
    public String[] getMotCles() {
        return new String[]{"id", "libelle"};
    }

    @Override
    public String[] getValMotCles() {
        return new String[]{"libelle"};
    }

    public void construirePK(Connection c) throws Exception {
        super.setNomTable("pays");
        this.preparePk("PAYS", "getseqpays");
        this.setId(makePK(c));
    }
}
