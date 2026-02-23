package bean;

public class CompetenceUtilisateur extends ClassMAPTable {
    private String idcompetence;
    private int idutilisateur;

    public CompetenceUtilisateur() {
        super.setNomTable("competence_utilisateur");
    }

    public String getIdcompetence() { return idcompetence; }
    public void setIdcompetence(String idcompetence) { this.idcompetence = idcompetence; }

    public int getIdutilisateur() { return idutilisateur; }
    public void setIdutilisateur(int idutilisateur) { this.idutilisateur = idutilisateur; }

    @Override
    public String getTuppleID() { return this.idcompetence; }

    @Override
    public String getAttributIDName() { return "idcompetence"; }

    // PK composite sans séquence — valeurs fournies directement à l'insertion
}
