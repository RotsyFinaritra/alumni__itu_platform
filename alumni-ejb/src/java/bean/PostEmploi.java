package bean;

import java.sql.Connection;
import java.sql.Date;

public class PostEmploi extends ClassMAPTable {
    private String post_id;
    private String identreprise;
    private String entreprise;
    private String localisation;
    private String poste;
    private String type_contrat;
    private double salaire_min;
    private double salaire_max;
    private String devise;
    private String experience_requise;
    private String niveau_etude_requis;
    private int teletravail_possible;
    private Date date_limite;
    private String contact_email;
    private String contact_tel;
    private String lien_candidature;

    public PostEmploi() {
        super.setNomTable("post_emploi");
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

    public String getPoste() {
        return poste;
    }

    public void setPoste(String poste) {
        this.poste = poste;
    }

    public String getType_contrat() {
        return type_contrat;
    }

    public void setType_contrat(String type_contrat) {
        this.type_contrat = type_contrat;
    }

    public double getSalaire_min() {
        return salaire_min;
    }

    public void setSalaire_min(double salaire_min) {
        this.salaire_min = salaire_min;
    }

    public double getSalaire_max() {
        return salaire_max;
    }

    public void setSalaire_max(double salaire_max) {
        this.salaire_max = salaire_max;
    }

    public String getDevise() {
        return devise;
    }

    public void setDevise(String devise) {
        this.devise = devise;
    }

    public String getExperience_requise() {
        return experience_requise;
    }

    public void setExperience_requise(String experience_requise) {
        this.experience_requise = experience_requise;
    }

    public String getNiveau_etude_requis() {
        return niveau_etude_requis;
    }

    public void setNiveau_etude_requis(String niveau_etude_requis) {
        this.niveau_etude_requis = niveau_etude_requis;
    }

    public int getTeletravail_possible() {
        return teletravail_possible;
    }

    public void setTeletravail_possible(int teletravail_possible) {
        this.teletravail_possible = teletravail_possible;
    }

    public Date getDate_limite() {
        return date_limite;
    }

    public void setDate_limite(Date date_limite) {
        this.date_limite = date_limite;
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
