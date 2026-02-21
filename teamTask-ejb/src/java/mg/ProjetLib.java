/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package mg;

import bean.ClassMAPTable;
import java.sql.Date;

/**
 *
 * @author john
 */
public class ProjetLib extends ClassMAPTable{
    private String id, code, designation, rn;
    private double pkdebut,pkfin,montantestimatif;
    private Date datedebut,datefin;
    private int nb_page_a_creer,nb_page_a_commiter,nb_page_a_debuger,a_tester,a_deployer,nb_page_total,nb_fonctionnalite;

    public ProjetLib() {
        setNomTable("projet_libcomplet");
    }

    public ProjetLib(String id, String code, String designation, String rn, double pkdebut, double pkfin, double montantestimatif, Date datedebut, Date datefin, int nb_page_a_creer, int nb_page_a_commiter, int nb_page_a_debuger, int a_tester, int a_deployer, int nb_page_total, int nb_fonctionnalite) {
        this.id = id;
        this.code = code;
        this.designation = designation;
        this.rn = rn;
        this.pkdebut = pkdebut;
        this.pkfin = pkfin;
        this.montantestimatif = montantestimatif;
        this.datedebut = datedebut;
        this.datefin = datefin;
        this.nb_page_a_creer = nb_page_a_creer;
        this.nb_page_a_commiter = nb_page_a_commiter;
        this.nb_page_a_debuger = nb_page_a_debuger;
        this.a_tester = a_tester;
        this.a_deployer = a_deployer;
        this.nb_page_total = nb_page_total;
        this.nb_fonctionnalite = nb_fonctionnalite;
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getDesignation() {
        return designation;
    }

    public void setDesignation(String designation) {
        this.designation = designation;
    }

    public String getRn() {
        return rn;
    }

    public void setRn(String rn) {
        this.rn = rn;
    }

    public double getPkdebut() {
        return pkdebut;
    }

    public void setPkdebut(double pkdebut) {
        this.pkdebut = pkdebut;
    }

    public double getPkfin() {
        return pkfin;
    }

    public void setPkfin(double pkfin) {
        this.pkfin = pkfin;
    }

    public double getMontantestimatif() {
        return montantestimatif;
    }

    public void setMontantestimatif(double montantestimatif) {
        this.montantestimatif = montantestimatif;
    }

    public Date getDatedebut() {
        return datedebut;
    }

    public void setDatedebut(Date datedebut) {
        this.datedebut = datedebut;
    }

    public Date getDatefin() {
        return datefin;
    }

    public void setDatefin(Date datefin) {
        this.datefin = datefin;
    }

    public int getNb_page_a_creer() {
        return nb_page_a_creer;
    }

    public void setNb_page_a_creer(int nb_page_a_creer) {
        this.nb_page_a_creer = nb_page_a_creer;
    }

    public int getNb_page_a_commiter() {
        return nb_page_a_commiter;
    }

    public void setNb_page_a_commiter(int nb_page_a_commiter) {
        this.nb_page_a_commiter = nb_page_a_commiter;
    }

    public int getNb_page_a_debuger() {
        return nb_page_a_debuger;
    }

    public void setNb_page_a_debuger(int nb_page_a_debuger) {
        this.nb_page_a_debuger = nb_page_a_debuger;
    }

    public int getA_tester() {
        return a_tester;
    }

    public void setA_tester(int a_tester) {
        this.a_tester = a_tester;
    }

    public int getA_deployer() {
        return a_deployer;
    }

    public void setA_deployer(int a_deployer) {
        this.a_deployer = a_deployer;
    }

    public int getNb_page_total() {
        return nb_page_total;
    }

    public void setNb_page_total(int nb_page_total) {
        this.nb_page_total = nb_page_total;
    }

    public int getNb_fonctionnalite() {
        return nb_fonctionnalite;
    }

    public void setNb_fonctionnalite(int nb_fonctionnalite) {
        this.nb_fonctionnalite = nb_fonctionnalite;
    }

    @Override
    public String getTuppleID() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }

    @Override
    public String getAttributIDName() {
        throw new UnsupportedOperationException("Not supported yet."); //To change body of generated methods, choose Tools | Templates.
    }
    
    
    
}
