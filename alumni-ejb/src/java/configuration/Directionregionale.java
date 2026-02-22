/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package configuration;

import bean.ClassMAPTable;
import java.sql.Connection;

/**
 *
 * @author GILEADA
 */
public class Directionregionale  extends ClassMAPTable{

    private String id;
    private String val;
    private String desce;
    private String dr_abreviation;
    private String numero_fixe;
    private String numero_mobile;
    private String dr_sigle;
    
    public Directionregionale(){
        super.setNomTable("sig_dr");
    }
    @Override
    public void construirePK(Connection c) throws Exception{
        super.setNomTable("sig_dr");
        this.preparePk("DR","getSeqDirectionRegionale");
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

    public String getDr_abreviation() {
        return dr_abreviation;
    }

    public void setDr_abreviation(String dr_abreviation) {
        this.dr_abreviation = dr_abreviation;
    }

    public String getNumero_fixe() {
        return numero_fixe;
    }

    public void setNumero_fixe(String numero_fixe) {
        this.numero_fixe = numero_fixe;
    }

    public String getNumero_mobile() {
        return numero_mobile;
    }

    public void setNumero_mobile(String numero_mobile) {
        this.numero_mobile = numero_mobile;
    }

    public String getDr_sigle() {
        return dr_sigle;
    }

    public void setDr_sigle(String dr_sigle) {
        this.dr_sigle = dr_sigle;
    }
    
}
