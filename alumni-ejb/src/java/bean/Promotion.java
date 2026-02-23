package bean;

import java.sql.Connection;

public class Promotion extends ClassMAPTable {
    private String id;
    private String libelle;
    private int annee;
    private String idOption;

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

    public String getIdOption() {
        return idOption;
    }

    public void setIdOption(String idOption) {
        this.idOption = idOption;
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
        return new String[]{"id", "libelle"};
    }

    public void construirePK(Connection c) throws Exception {
        super.setNomTable("promotion");
        this.preparePk("PROMO", "getseqpromotion");
        this.setId(makePK(c));
    }
}
