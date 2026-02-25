package bean;

import java.sql.Timestamp;

public class PostActivite extends ClassMAPTable {
    private String post_id;
    private String titre;
    private String categorie;
    private String lieu;
    private String adresse;
    private Timestamp date_debut;
    private Timestamp date_fin;
    private double prix;
    private int nombre_places;
    private int places_restantes;
    private String contact_email;
    private String contact_tel;
    private String lien_inscription;
    private String lien_externe;

    public PostActivite() {
        super.setNomTable("post_activite");
    }

    @Override
    public String getTuppleID() {
        return this.post_id;
    }

    @Override
    public String getAttributIDName() {
        return "post_id";
    }

    // PAS de construirePK() car post_id est fourni depuis Post

    // Getters et Setters
    public String getPost_id() {
        return post_id;
    }

    public void setPost_id(String post_id) {
        this.post_id = post_id;
    }

    public String getTitre() {
        return titre;
    }

    public void setTitre(String titre) {
        this.titre = titre;
    }

    public String getCategorie() {
        return categorie;
    }

    public void setCategorie(String categorie) {
        this.categorie = categorie;
    }

    public String getLieu() {
        return lieu;
    }

    public void setLieu(String lieu) {
        this.lieu = lieu;
    }

    public String getAdresse() {
        return adresse;
    }

    public void setAdresse(String adresse) {
        this.adresse = adresse;
    }

    public Timestamp getDate_debut() {
        return date_debut;
    }

    public void setDate_debut(Timestamp date_debut) {
        this.date_debut = date_debut;
    }

    public Timestamp getDate_fin() {
        return date_fin;
    }

    public void setDate_fin(Timestamp date_fin) {
        this.date_fin = date_fin;
    }

    public double getPrix() {
        return prix;
    }

    public void setPrix(double prix) {
        this.prix = prix;
    }

    public int getNombre_places() {
        return nombre_places;
    }

    public void setNombre_places(int nombre_places) {
        this.nombre_places = nombre_places;
    }

    public int getPlaces_restantes() {
        return places_restantes;
    }

    public void setPlaces_restantes(int places_restantes) {
        this.places_restantes = places_restantes;
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

    public String getLien_inscription() {
        return lien_inscription;
    }

    public void setLien_inscription(String lien_inscription) {
        this.lien_inscription = lien_inscription;
    }

    public String getLien_externe() {
        return lien_externe;
    }

    public void setLien_externe(String lien_externe) {
        this.lien_externe = lien_externe;
    }
}
