package bean;

import java.sql.Connection;

public class ReseauxSociaux extends ClassMAPTable {
    private String id;
    private String libelle;
    private String icone;

    public ReseauxSociaux() {
        super.setNomTable("reseaux_sociaux");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }

    public String getIcone() { return icone; }
    public void setIcone(String icone) { this.icone = icone; }

    @Override
    public String getTuppleID() { return this.id; }

    @Override
    public String getAttributIDName() { return "id"; }

    public void construirePK(Connection c) throws Exception {
        super.setNomTable("reseaux_sociaux");
        this.preparePk("RSX", "getseqreseauxsociaux");
        this.setId(makePK(c));
    }
}
