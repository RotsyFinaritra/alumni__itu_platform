package bean;

public class UtilisateurSpecialite extends ClassMAPTable {
    private int idutilisateur;
    private String idspecialite;

    public UtilisateurSpecialite() {
        super.setNomTable("utilisateur_specialite");
    }

    public int getIdutilisateur() { return idutilisateur; }
    public void setIdutilisateur(int idutilisateur) { this.idutilisateur = idutilisateur; }

    public String getIdspecialite() { return idspecialite; }
    public void setIdspecialite(String idspecialite) { this.idspecialite = idspecialite; }

    @Override
    public String getTuppleID() { return String.valueOf(this.idutilisateur); }

    @Override
    public String getAttributIDName() { return "idutilisateur"; }

    // PK composite sans séquence — valeurs fournies directement à l'insertion
}
