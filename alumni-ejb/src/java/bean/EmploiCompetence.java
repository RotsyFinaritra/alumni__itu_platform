package bean;

/**
 * Bean pour la table emploi_competence (association many-to-many).
 * Permet d'associer plusieurs compétences à une offre d'emploi.
 */
public class EmploiCompetence extends ClassMAPTable {
    private String post_id;
    private String idcompetence;

    public EmploiCompetence() {
        super.setNomTable("emploi_competence");
    }

    // Getters et Setters
    public String getPost_id() {
        return post_id;
    }

    public void setPost_id(String post_id) {
        this.post_id = post_id;
    }

    public String getIdcompetence() {
        return idcompetence;
    }

    public void setIdcompetence(String idcompetence) {
        this.idcompetence = idcompetence;
    }

    @Override
    public String getTuppleID() {
        return this.post_id;
    }

    @Override
    public String getAttributIDName() {
        return "post_id";
    }

    @Override
    public String[] getMotCles() {
        return new String[]{"post_id", "idcompetence"};
    }

    @Override
    public String[] getValMotCles() {
        return new String[]{"post_id", "idcompetence"};
    }

    // PK composite sans séquence - valeurs fournies directement à l'insertion
}
