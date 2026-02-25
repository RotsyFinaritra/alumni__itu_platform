package bean;

import java.sql.Connection;
import java.sql.Date;

public class PostStage extends ClassMAPTable {
    private String post_id;
    private String identreprise;
    private String entreprise;
    private String localisation;
    private String duree;
    private Date date_debut;
    private Date date_fin;
    private double indemnite;
    private String niveau_etude_requis;
    private int convention_requise;
    private int places_disponibles;
    private String contact_email;
    private String contact_tel;
    private String lien_candidature;

    public PostStage() {
        super.setNomTable("post_stage");
    }

    @Override
    public String getTuppleID() {
        return this.post_id;
    }

    @Override
    public String getAttributIDName() {
        return "post_id";
    }

    @Override
    public void construirePK(Connection c) throws Exception {
        // post_id est fourni manuellement depuis Post, pas de sequence
    }

    // Getters et Setters
    public String getPost_id() {
        return post_id;
    }

    public void setPost_id(String post_id) {
        this.post_id = post_id;
    }

    public String getEntreprise() {
        return entreprise;
    }

    public void setEntreprise(String entreprise) {
        this.entreprise = entreprise;
    }

    public String getIdentreprise() {
        return identreprise;
    }

    public void setIdentreprise(String identreprise) {
        this.identreprise = identreprise;
    }

    public String getLocalisation() {
        return localisation;
    }

    public void setLocalisation(String localisation) {
        this.localisation = localisation;
    }

    public String getDuree() {
        return duree;
    }

    public void setDuree(String duree) {
        this.duree = duree;
    }

    public Date getDate_debut() {
        return date_debut;
    }

    public void setDate_debut(Date date_debut) {
        this.date_debut = date_debut;
    }

    public Date getDate_fin() {
        return date_fin;
    }

    public void setDate_fin(Date date_fin) {
        this.date_fin = date_fin;
    }

    public double getIndemnite() {
        return indemnite;
    }

    public void setIndemnite(double indemnite) {
        this.indemnite = indemnite;
    }

    public String getNiveau_etude_requis() {
        return niveau_etude_requis;
    }

    public void setNiveau_etude_requis(String niveau_etude_requis) {
        this.niveau_etude_requis = niveau_etude_requis;
    }

    public int getConvention_requise() {
        return convention_requise;
    }

    public void setConvention_requise(int convention_requise) {
        this.convention_requise = convention_requise;
    }

    public int getPlaces_disponibles() {
        return places_disponibles;
    }

    public void setPlaces_disponibles(int places_disponibles) {
        this.places_disponibles = places_disponibles;
    }

    public String getContact_email() {
        return contact_email;
    }

    public void setContact_email(String contact_email) {
        this.contact_email = contact_email;
    }

    public String getContact_tel() {
        return contact_tel;
    }

    public void setContact_tel(String contact_tel) {
        this.contact_tel = contact_tel;
    }

    public String getLien_candidature() {
        return lien_candidature;
    }

    public void setLien_candidature(String lien_candidature) {
        this.lien_candidature = lien_candidature;
    }
}
