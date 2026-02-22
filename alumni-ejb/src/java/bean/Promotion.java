package bean;

import java.sql.Connection;

public class Promotion extends ClassMAPTable {
    private String id;
    private String libelle;
    private int annee;

    public Promotion() {
        super.setNomTable("promotion");
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

    public int getAnnee() {
        return annee;
    }

    public void setAnnee(int annee) {
        this.annee = annee;
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
        super.setNomTable("promotion");
        this.preparePk("PROMO", "getseqpromotion");
        this.setId(makePK(c));
    }
}
