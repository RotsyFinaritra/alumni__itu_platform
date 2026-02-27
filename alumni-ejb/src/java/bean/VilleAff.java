package bean;

/**
 * Bean pour autocomplete Ville avec affichage id-libelle
 * Utilise la vue v_ville_aff
 * Contient idpays pour le filtrage dépendant
 */
public class VilleAff extends ClassMAPTable {
    private String id;
    private String libelle;
    private String idpays;
    private String aff;

    public VilleAff() {
        super.setNomTable("v_ville_aff");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }
    public String getIdpays() { return idpays; }
    public void setIdpays(String idpays) { this.idpays = idpays; }
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
