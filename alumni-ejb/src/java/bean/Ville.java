package bean;

import java.sql.Connection;

public class Ville extends ClassMAPTable {
    private String id;
    private String libelle;
    private String idpays;

    public Ville() {
        super.setNomTable("ville");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }

    public String getIdpays() { return idpays; }
    public void setIdpays(String idpays) { this.idpays = idpays; }

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
        super.setNomTable("ville");
        this.preparePk("VILL", "getseqville");
        this.setId(makePK(c));
    }
}
