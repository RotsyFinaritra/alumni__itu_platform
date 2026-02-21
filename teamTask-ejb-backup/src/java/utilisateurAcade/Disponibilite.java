package utilisateurAcade;

import bean.ClassMAPTable;
import utilitaire.Utilitaire;

import java.sql.Connection;
import java.sql.Date;
import java.time.Duration;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;

public class Disponibilite extends ClassMAPTable {
    private String id;
    private Date daty;
    private double dureeMins; // tsy apotra am affichage

    public Disponibilite() {
        setNomTable("disponibilite");
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }


    public Date getDaty() {
        return daty;
    }

    public void setDaty(Date daty) {
        this.daty = daty;
    }

    public double getDureeMins() {
        return dureeMins;
    }

    public void setDureeMins(double dureeMins) {
        this.dureeMins = dureeMins;
    }

    public void construirePK(Connection c) throws Exception {
        this.preparePk("DISPO", "getSeqCreation_projet");
        this.setId(makePK(c));
    }
    @Override
    public String getTuppleID() {
        return id;
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }
}
