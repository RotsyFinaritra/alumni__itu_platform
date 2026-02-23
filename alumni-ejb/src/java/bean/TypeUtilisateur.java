
package bean;

import java.sql.Connection;

public class TypeUtilisateur extends ClassMAPTable {
    private String id;
    private String libelle;

    public TypeUtilisateur() {
        super.setNomTable("type_utilisateur");
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getLibelle() {
        return libelle;
    }

    public void setLibelle(String libelle) {
        this.libelle = libelle;
    }

    @Override
    public String getTuppleID() {
        return this.id;
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    @Override
    public String[] getMotCles() {
        return new String[]{"id", "libelle"};
    }

    @Override
    public String[] getValMotCles() {
        return new String[]{"libelle"};
    }

    public void construirePK(Connection c) throws Exception {
        super.setNomTable("type_utilisateur");
        this.preparePk("TU", "getseqtypeutilisateur");
        this.setId(makePK(c));
    }
}
