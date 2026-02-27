package bean;

/**
 * Bean pour autocomplete Entreprise avec affichage id-libelle
 * Utilise la vue v_entreprise_aff
 */
public class EntrepriseAff extends ClassMAPTable {
    private String id;
    private String libelle;
    private String idville;
    private String description;
    private String aff;

    public EntrepriseAff() {
        super.setNomTable("v_entreprise_aff");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }
    public String getIdville() { return idville; }
    public void setIdville(String idville) { this.idville = idville; }
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    public String getAff() { return aff; }
    public void setAff(String aff) { this.aff = aff; }

    @Override
    public String getTuppleID() { return this.id; }
    @Override
    public String getAttributIDName() { return "id"; }

    @Override
    public String[] getMotCles() {
        return new String[]{"id", "libelle", "aff"};
    }

    @Override
    public String[] getValMotCles() {
        return new String[]{"aff"};
    }
}
