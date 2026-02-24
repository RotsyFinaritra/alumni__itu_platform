package bean;

import java.sql.Connection;

public class Ecole extends ClassMAPTable {
    private String id;
    private String libelle;

    public Ecole() {
        super.setNomTable("ecole");
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
        return new String[]{"id", "libelle"};
    }

    public void construirePK(Connection c) throws Exception {
        super.setNomTable("ecole");
        this.preparePk("ECOL", "getseqecole");
        this.setId(makePK(c));
    }
}
