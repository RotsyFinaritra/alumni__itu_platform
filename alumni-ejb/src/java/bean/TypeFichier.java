package bean;

import java.sql.Connection;
import java.sql.Timestamp;

public class TypeFichier extends ClassMAPTable {
    private String id;
    private String libelle;
    private String code;
    private String icon;
    private String couleur;
    private String extensions_acceptees;
    private int taille_max_mo;
    private String description;
    private int actif;
    private int ordre;
    private Timestamp created_at;

    public TypeFichier() {
        super.setNomTable("type_fichier");
    }

    @Override
    public String getTuppleID() {
        return this.id;
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    public void construirePK(Connection c) throws Exception {
        super.setNomTable("type_fichier");
        this.preparePk("TFIC", "getseqtypefichier");
        this.setId(makePK(c));
    }

    // Getters et Setters
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

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public String getCouleur() {
        return couleur;
    }

    public void setCouleur(String couleur) {
        this.couleur = couleur;
    }

    public String getExtensions_acceptees() {
        return extensions_acceptees;
    }

    public void setExtensions_acceptees(String extensions_acceptees) {
        this.extensions_acceptees = extensions_acceptees;
    }

    public int getTaille_max_mo() {
        return taille_max_mo;
    }

    public void setTaille_max_mo(int taille_max_mo) {
        this.taille_max_mo = taille_max_mo;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getActif() {
        return actif;
    }

    public void setActif(int actif) {
        this.actif = actif;
    }

    public int getOrdre() {
        return ordre;
    }

    public void setOrdre(int ordre) {
        this.ordre = ordre;
    }

    public Timestamp getCreated_at() {
        return created_at;
    }

    public void setCreated_at(Timestamp created_at) {
        this.created_at = created_at;
    }
}
