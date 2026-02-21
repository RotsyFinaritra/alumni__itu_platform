package bean;

import java.sql.Connection;
import java.sql.Date;

public class HistoImport extends ClassMAPTable
{
    String id;
    Date daty;
    String refobject;

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

    public String getRefobject() {
        return refobject;
    }

    public void setRefobject(String refobject) {
        this.refobject = refobject;
    }

    @Override
    public String getTuppleID() {
        return this.getId();
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    public HistoImport() {
        setNomTable("HISTOIMPORT");
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        this.preparePk("HIM", "GETSEQHISTOIMPORT");
        this.setId(makePK(c));
    }
}
