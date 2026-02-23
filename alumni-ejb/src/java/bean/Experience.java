package bean;

import java.sql.Connection;
import java.sql.Date;

public class Experience extends ClassMAPTable {
    private String id;
    private int idutilisateur;
    private Date datedebut;
    private Date datefin;
    private String poste;
    private String iddomaine;
    private String identreprise;
    private String idtypeemploie;

    public Experience() {
        super.setNomTable("experience");
    }

    public String getId() { return id; }
    public void setId(String id) { this.id = id; }

    public int getIdutilisateur() { return idutilisateur; }
    public void setIdutilisateur(int idutilisateur) { this.idutilisateur = idutilisateur; }

    public Date getDatedebut() { return datedebut; }
    public void setDatedebut(Date datedebut) { this.datedebut = datedebut; }

    public Date getDatefin() { return datefin; }
    public void setDatefin(Date datefin) { this.datefin = datefin; }

    public String getPoste() { return poste; }
    public void setPoste(String poste) { this.poste = poste; }

    public String getIddomaine() { return iddomaine; }
    public void setIddomaine(String iddomaine) { this.iddomaine = iddomaine; }

    public String getIdentreprise() { return identreprise; }
    public void setIdentreprise(String identreprise) { this.identreprise = identreprise; }

    public String getIdtypeemploie() { return idtypeemploie; }
    public void setIdtypeemploie(String idtypeemploie) { this.idtypeemploie = idtypeemploie; }

    @Override
    public String getTuppleID() { return this.id; }

    @Override
    public String getAttributIDName() { return "id"; }

    public void construirePK(Connection c) throws Exception {
        super.setNomTable("experience");
        this.preparePk("EXP", "getseqexperience");
        this.setId(makePK(c));
    }
}
