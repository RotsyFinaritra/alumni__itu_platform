package promesse;

import bean.ClassMAPTable;

import java.sql.Connection;
import java.sql.Date;

public class Promesse extends ClassMAPTable {
    private String id;
    private Date daty;
    private String idCategorieDonateur;
    private String idEntiteDonateur;
    private String idRecepteur;
    private String idProjet;
    private String description;
    private String materiel;
    private int qte;
    private double montant;
    private String idDevise;
    private double tauxDeChange;
    private double montantMga;

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("PROM", "getseqpromesse");
        this.setId(makePK(c));
    }

    public Promesse() {
        setNomTable("PROMESSE");
    }

    @Override
    public boolean getEstIndexable() {
        return true;
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

    public String getIdCategorieDonateur() {
        return idCategorieDonateur;
    }

    public void setIdCategorieDonateur(String idCategorieDonateur) {
        this.idCategorieDonateur = idCategorieDonateur;
    }

    public String getIdEntiteDonateur() {
        return idEntiteDonateur;
    }

    public void setIdEntiteDonateur(String idEntiteDonateur) {
        this.idEntiteDonateur = idEntiteDonateur;
    }

    public String getIdRecepteur() {
        return idRecepteur;
    }

    public void setIdRecepteur(String idRecepteur) {
        this.idRecepteur = idRecepteur;
    }

    public String getIdProjet() {
        return idProjet;
    }

    public void setIdProjet(String idProjet) {
        this.idProjet = idProjet;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getMateriel() {
        return materiel;
    }

    public void setMateriel(String materiel) {
        this.materiel = materiel;
    }

    public int getQte() {
        return qte;
    }

    public void setQte(int qte) {
        this.qte = qte;
    }

    public double getMontant() {
        return montant;
    }

    public void setMontant(double montant) {
        this.montant = montant;
    }

    public String getIdDevise() {
        return idDevise;
    }

    public void setIdDevise(String idDevise) {
        this.idDevise = idDevise;
    }

    public double getTauxDeChange() {
        return tauxDeChange;
    }

    public void setTauxDeChange(double tauxDeChange) {
        this.tauxDeChange = tauxDeChange;
    }

    public double getMontantMga() {
        return montantMga;
    }

    public void setMontantMga(double montantMga) {
        this.montantMga = montantMga;
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
