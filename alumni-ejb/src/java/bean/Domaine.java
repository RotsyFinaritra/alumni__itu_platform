package bean;

import java.sql.Connection;

public class Domaine extends ClassMAPTable {
    private String id;
    private String libelle;
    private String idpere;

    public Domaine() {
        super.setNomTable("domaine");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }

    public String getIdpere() { return idpere; }
    public void setIdpere(String idpere) { this.idpere = idpere; }

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
        super.setNomTable("domaine");
        this.preparePk("DOM", "getseqdomaine");
        this.setId(makePK(c));
    }
}
