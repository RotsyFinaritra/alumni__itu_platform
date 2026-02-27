package bean;

/**
 * Bean pour autocomplete Competence avec affichage id-libelle
 * Utilise la vue v_competence_aff
 */
public class CompetenceAff extends ClassMAPTable {
    private String id;
    private String libelle;
    private String aff;

    public CompetenceAff() {
        super.setNomTable("v_competence_aff");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }
    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }
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
