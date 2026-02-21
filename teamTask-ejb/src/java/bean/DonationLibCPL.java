package bean;

public class DonationLibCPL extends  Donation {
    String idcategorielib;
    String idcategoriedonateurlib;
    String idprojetlib;
    double total;
    String idEntiteDonateurLib;
    String idRecepteurLib;

    public double getTotal() {
        return total;
    }

    public void setTotal(double total) {
        this.total = total;
    }

    public String getIdcategorielib() {
        return idcategorielib;
    }

    public void setIdcategorielib(String idcategorielib) {
        this.idcategorielib = idcategorielib;
    }

    public String getIdcategoriedonateurlib() {
        return idcategoriedonateurlib;
    }

    public void setIdcategoriedonateurlib(String idcategoriedonateurlib) {
        this.idcategoriedonateurlib = idcategoriedonateurlib;
    }

    public String getIdprojetlib() {
        return idprojetlib;
    }

    public void setIdprojetlib(String idprojetlib) {
        this.idprojetlib = idprojetlib;
    }

    public DonationLibCPL() {
        setNomTable("donationlibcpl");
    }

    public String getIdEntiteDonateurLib() {
        return idEntiteDonateurLib;
    }

    public void setIdEntiteDonateurLib(String idEntiteDonateurLib) {
        this.idEntiteDonateurLib = idEntiteDonateurLib;
    }

    public String getIdRecepteurLib() {
        return idRecepteurLib;
    }

    public void setIdRecepteurLib(String idRecepteurLib) {
        this.idRecepteurLib = idRecepteurLib;
    }
}
