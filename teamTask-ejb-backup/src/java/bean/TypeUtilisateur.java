
package bean;

import java.sql.Connection;



public class TypeUtilisateur extends ClassMAPTable {
    private String id;
    private String val;
    private String desce; 
    private double tauxHoraire;
    private double tauxJournalier;
    private double tauxMensuel;

    public TypeUtilisateur() {
        super.setNomTable("type_utilisateur");
    }
    public String getId() {
        return id;
    }
 
    public void setId(String id) {
        this.id = id;
    }

    public String getVal() {
        return val;
    }
 
    public void setVal(String val) {
        this.val = val;
    }
 
    public String getDesce() {
        return desce;
    }
 
    public void setDesce(String desce) {
        this.desce = desce;
    }

    public double getTauxHoraire() {
        return tauxHoraire;
    }

    public void setTauxHoraire(double tauxHoraire) {
        this.tauxHoraire = tauxHoraire;
    }

    public double getTauxJournalier() {
        return tauxJournalier;
    }

    public void setTauxJournalier(double tauxJournalier) {
        this.tauxJournalier = tauxJournalier;
    }

    public double getTauxMensuel() {
        return tauxMensuel;
    }

    public void setTauxMensuel(double tauxMensuel) {
        this.tauxMensuel = tauxMensuel;
    }

    @Override
    public String getTuppleID() {
        return this.id;
    }

    @Override
    public String getAttributIDName() {
        return "id"  ; 
    }
     public void construirePK(Connection c) throws Exception {
        super.setNomTable("type_utilisateur");
        this.preparePk("TU", "SEQ_TYPE_UTILISATEUR");
        this.setId(makePK(c));
    }

} 