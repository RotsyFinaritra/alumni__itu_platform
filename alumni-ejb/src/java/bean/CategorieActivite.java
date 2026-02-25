package bean;

import java.sql.Connection;

public class CategorieActivite extends ClassMAPTable {
    private String id;
    private String libelle;

    public CategorieActivite() {
        super.setNomTable("categorie_activite");
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
        super.setNomTable("categorie_activite");
        this.preparePk("CATACT", "getseqcategorieactivite");
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
