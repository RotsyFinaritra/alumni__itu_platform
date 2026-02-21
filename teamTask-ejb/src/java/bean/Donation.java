package bean;

import java.sql.Connection;
import java.sql.Date;

public class Donation extends ClassMAPTable
{
    String id;
    Date daty;
    String nom;
    double montant;
    String desce;
    String idCategorie;
    double qte;
    String idCategorieDonateur;
    String idProjet;
    String idRecepteur;
    String numeroPiece;
    String idEntiteDonateur;

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

    public String getNom() {
        return nom;
    }

    public void setNom(String nom) {
        this.nom = nom;
    }

    public double getMontant() {
        return montant;
    }

    public void setMontant(double montant) {
        this.montant = montant;
    }

    public String getDesce() {
        return desce;
    }

    public void setDesce(String desce) {
        this.desce = desce;
    }

    public String getIdCategorie() {
        return idCategorie;
    }

    public void setIdCategorie(String idCategorie) {
        this.idCategorie = idCategorie;
    }

    public double getQte() {
        return qte;
    }

    public void setQte(double qte) {
        this.qte = qte;
    }

    public String getIdCategorieDonateur() {
        return idCategorieDonateur;
    }

    public void setIdCategorieDonateur(String idCategorieDonateur) {
        this.idCategorieDonateur = idCategorieDonateur;
    }

    public String getIdProjet() {
        return idProjet;
    }

    public void setIdProjet(String idProjet) {
        this.idProjet = idProjet;
    }

    public String getQteLettre() {
        if (getIdCategorie()!=null && (getIdCategorie().equalsIgnoreCase("CAT0003") || getIdCategorie().equalsIgnoreCase("CAT0002"))) return " ";
        else return String.valueOf(getQte());
    }

    public String getIdRecepteur() {
        return idRecepteur;
    }

    public void setIdRecepteur(String idRecepteur) {
        this.idRecepteur = idRecepteur;
    }

    public String getNumeroPiece() {
        return numeroPiece;
    }

    public void setNumeroPiece(String numeroPiece) {
        this.numeroPiece = numeroPiece;
    }

    public String getIdEntiteDonateur() {
        return idEntiteDonateur;
    }

    public void setIdEntiteDonateur(String idEntiteDonateur) {
        this.idEntiteDonateur = idEntiteDonateur;
    }



    @Override
    public String getTuppleID() {
        return getId();
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("DON", "GETSEQUDONATION");
        this.setId(makePK(c));
    }

    public Donation() {
        setNomTable("DONATION");
    }

    @Override
    public boolean getEstIndexable() {
        return true;
    }

    @Override
    public String rajoutRemarque(Connection c) throws Exception {
        return getNom() + " " + getDesce();
    }
}
