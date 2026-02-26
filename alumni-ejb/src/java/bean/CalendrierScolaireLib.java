package bean;

/**
 * Classe Lib pour la vue calendrier_scolaire_cpl
 * Contient les champs calculés/joints (libellé de la promotion)
 */
public class CalendrierScolaireLib extends CalendrierScolaire {
    
    private String libpromotion;
    
    public CalendrierScolaireLib() {
        super();
        this.setNomTable("calendrier_scolaire_cpl");
    }
    
    // Getters/setters pour les champs additionnels de la vue
    public String getLibpromotion() {
        return libpromotion;
    }
    
    public void setLibpromotion(String libpromotion) {
        this.libpromotion = libpromotion;
    }
}
