package bean;

/**
 * Bean pour autocomplete Promotion avec affichage id-libelle
 * Utilise la vue v_promotion_aff
 */
public class PromotionAff extends ClassMAPTable {
    private String id;
    private String libelle;
    private int annee;
    private String idoption;
    private String aff;

    public PromotionAff() {
        super.setNomTable("v_promotion_aff");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }
    public int getAnnee() { return annee; }
    public void setAnnee(int annee) { this.annee = annee; }
    public String getIdoption() { return idoption; }
    public void setIdoption(String idoption) { this.idoption = idoption; }
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
