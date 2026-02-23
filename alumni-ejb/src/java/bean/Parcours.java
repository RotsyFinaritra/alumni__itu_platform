package bean;

import java.sql.Connection;
import java.sql.Date;

public class Parcours extends ClassMAPTable {
    private String id;
    private Date datedebut;
    private Date datefin;
    private int idutilisateur;
    private String iddiplome;
    private String iddomaine;
    private String idecole;

    public Parcours() {
        super.setNomTable("parcours");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public Date getDatedebut() { return datedebut; }
    public void setDatedebut(Date datedebut) { this.datedebut = datedebut; }

    public Date getDatefin() { return datefin; }
    public void setDatefin(Date datefin) { this.datefin = datefin; }

    public int getIdutilisateur() { return idutilisateur; }
    public void setIdutilisateur(int idutilisateur) { this.idutilisateur = idutilisateur; }

    public String getIddiplome() { return iddiplome; }
    public void setIddiplome(String iddiplome) { this.iddiplome = iddiplome; }

    public String getIddomaine() { return iddomaine; }
    public void setIddomaine(String iddomaine) { this.iddomaine = iddomaine; }

    public String getIdecole() { return idecole; }
    public void setIdecole(String idecole) { this.idecole = idecole; }

    @Override
    public String getTuppleID() { return this.id; }

    @Override
    public String getAttributIDName() { return "id"; }

    public void construirePK(Connection c) throws Exception {
        super.setNomTable("parcours");
        this.preparePk("PARC", "getseqparcours");
        this.setId(makePK(c));
    }
}
