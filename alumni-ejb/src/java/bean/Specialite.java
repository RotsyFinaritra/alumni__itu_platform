package bean;

import java.sql.Connection;

public class Specialite extends ClassMAPTable {
    private String id;
    private String libelle;

    public Specialite() {
        super.setNomTable("specialite");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }

    @Override
    public String getTuppleID() { return this.id; }

    @Override
    public String getAttributIDName() { return "id"; }

    public void construirePK(Connection c) throws Exception {
        super.setNomTable("specialite");
        this.preparePk("SPEC", "getseqspecialite");
        this.setId(makePK(c));
    }

    @Override
    public String[] getMotCles() {
        return new String[]{"id", "libelle"};
    }

    @Override
    public String[] getValMotCles() {
        return new String[]{"libelle"};
    }
}
