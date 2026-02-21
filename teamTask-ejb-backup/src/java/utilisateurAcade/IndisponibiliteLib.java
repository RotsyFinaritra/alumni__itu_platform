package utilisateurAcade;

public class IndisponibiliteLib extends Indisponibilite{

    private String idRessourceLib;
    private String etatLib;

    public IndisponibiliteLib() throws Exception
    {
        this.setNomTable("indisponibilitelib");
    }

    public String getIdRessourceLib() {
        return idRessourceLib;
    }

    public void setIdRessourceLib(String idRessourceLib) {
        this.idRessourceLib = idRessourceLib;
    }

    public String getEtatLib() {
        return etatLib;
    }

    public void setEtatLib(String etatLib) {
        this.etatLib = etatLib;
    }
}