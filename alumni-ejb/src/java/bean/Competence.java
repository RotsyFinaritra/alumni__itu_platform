package bean;

import java.sql.Connection;

public class Competence extends ClassMAPTable {
    private String id;
    private String libelle;

    public Competence() {
        super.setNomTable("competence");
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
        super.setNomTable("competence");
        this.preparePk("COMP", "getseqcompetence");
        this.setId(makePK(c));
    }
}
