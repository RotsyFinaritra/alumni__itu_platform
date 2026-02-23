package bean;

import java.sql.Connection;

public class Option extends ClassMAPTable {
    private String id;
    private String libelle;

    public Option() {
        super.setNomTable("option");
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
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
        super.setNomTable("option");
        this.preparePk("OP", "getseqoption");
        this.setId(makePK(c));
    }
}
