package utilisateurAcade;

import bean.ClassMAPTable;

import java.sql.Date;

public class CapaciteJournaliere extends ClassMAPTable {
    private String idRessource;
    private String nomRessource;
    private String idRole;
    private Date daty;
    private double disponibiliteJour;
    private double capaciteMaximale;
    private double assigne;
    private double reste;

    public CapaciteJournaliere() {
        setNomTable("capaciteJournaliere");
    }

    @Override
    public String getTuppleID() {
        return idRessource;
    }

    @Override
    public String getAttributIDName() {
        return "idRessource";
    }

    public String getIdRessource() {
        return idRessource;
    }

    public void setIdRessource(String idRessource) {
        this.idRessource = idRessource;
    }

    public String getNomRessource() {
        return nomRessource;
    }

    public void setNomRessource(String nomRessource) {
        this.nomRessource = nomRessource;
    }

    public String getIdRole() {
        return idRole;
    }

    public void setIdRole(String idRole) {
        this.idRole = idRole;
    }

    public Date getDaty() {
        return daty;
    }

    public void setDaty(Date daty) {
        this.daty = daty;
    }

    public double getDisponibiliteJour() {
        return disponibiliteJour;
    }

    public void setDisponibiliteJour(double disponibiliteJour) {
        this.disponibiliteJour = disponibiliteJour;
    }

    public double getCapaciteMaximale() {
        return capaciteMaximale;
    }

    public void setCapaciteMaximale(double capaciteMaximale) {
        this.capaciteMaximale = capaciteMaximale;
    }

    public double getAssigne() {
        return assigne;
    }

    public void setAssigne(double assigne) {
        this.assigne = assigne;
    }

    public double getReste() { return reste; }

    public void setReste(double reste) { this.reste = reste; }
}
