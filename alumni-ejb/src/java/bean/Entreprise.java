package bean;

import java.sql.Connection;

public class Entreprise extends ClassMAPTable {
    private String id;
    private String libelle;
    private String idville;
    private String description;

    public Entreprise() {
        super.setNomTable("entreprise");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }

    public String getIdville() { return idville; }
    public void setIdville(String idville) { this.idville = idville; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

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
        super.setNomTable("entreprise");
        this.preparePk("ENT", "getseqentreprise");
        this.setId(makePK(c));
    }
}
