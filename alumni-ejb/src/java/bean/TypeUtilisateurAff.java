package bean;

/**
 * Bean pour autocomplete TypeUtilisateur avec affichage id-libelle
 * Utilise la vue v_type_utilisateur_aff
 */
public class TypeUtilisateurAff extends ClassMAPTable {
    private String id;
    private String libelle;
    private String aff;

    public TypeUtilisateurAff() {
        super.setNomTable("v_type_utilisateur_aff");
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
