package bean;

import java.sql.Connection;

public class TypeEmploie extends ClassMAPTable {
    private String id;
    private String libelle;

    public TypeEmploie() {
        super.setNomTable("type_emploie");
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

    @Override
    public String[] getMotCles() {
        return new String[]{"id", "libelle"};
    }

    @Override
    public String[] getValMotCles() {
        return new String[]{"libelle"};
    }

    public void construirePK(Connection c) throws Exception {
        super.setNomTable("type_emploie");
        this.preparePk("TEMPL", "getseqtypeemploie");
        this.setId(makePK(c));
    }
}
