package utilisateurAcade;

import bean.ClassMAPTable;
import com.google.gson.Gson;
import constanteAcade.ConstanteAcade;
import utilitaire.Utilitaire;

import java.sql.Connection;
import java.sql.Date;
import java.time.Duration;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import historique.MapUtilisateur;
import user.UserEJBBean;
import utilitaire.ConstanteEtat;
import bean.CGenUtil;
import bean.ClassEtat;

public class Indisponibilite extends ClassEtat {
    private String id;
    private String idRessource;
    private Date daty;
    private String heureDebut;
    private String heureFin;
    private String argument;
    private double dureeMins;
    private int etat;

    @Override
    public Object validerObject(String u, Connection c) throws Exception {
        MapUtilisateur map = new  MapUtilisateur();
        map.setNomTable("utilisateurvue");
        MapUtilisateur[] mapUtilisateurs = (MapUtilisateur[]) CGenUtil.rechercher(map,null,null,c," and refuser="+u);
        map = mapUtilisateurs[0];
        System.out.println("heyy "+new Gson().toJson(map));
        if (map.getRang() < ConstanteAcade.RANG_POM) {
            throw new Exception("Seul les POM et la Direction peuvent valider la demande d'indisponibilité.");
        }
        setEtat(ConstanteEtat.getEtatValider());
        return super.validerObject(u, c);
    }

    public int getEtat() {
        return etat;
    }

    public void setEtat(int etat) {
        this.etat = etat;
    }

    public Indisponibilite() {
        setNomTable("indisponibilite");
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getIdRessource() {
        return idRessource;
    }

    public void setIdRessource(String idRessource) {
        this.idRessource = idRessource;
    }

    public Date getDaty() {
        return daty;
    }

    public void setDaty(Date daty) {
        this.daty = daty;
    }

    public String getHeureDebut() {
        return heureDebut;
    }

    public void setHeureDebut(String heureDebut) {
        this.heureDebut = heureDebut;
    }


    public String getHeureFin() {
        return heureFin;
    }

    public void setHeureFin(String heureFin) {
        if ("modif".equals(this.getMode()) && heureFin != null && heureDebut != null) {

            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm");

            LocalTime fin = LocalTime.parse(heureFin, formatter);
            LocalTime debut = LocalTime.parse(heureDebut, formatter);

            if (fin.isBefore(debut)) {
                throw new IllegalArgumentException(
                        "L'heure de fin ne peut pas être inférieure à l'heure de début"
                );
            }
        }

        this.heureFin = heureFin;
    }

    public String getArgument() {
        return argument;
    }

    public void setArgument(String argument) {
        this.argument = argument;
    }

    public double getDureeMins() {
        return dureeMins;
    }

    public void setDureeMins(double dureeMins) {
        this.dureeMins = dureeMins;
    }

    @Override
    public ClassMAPTable createObject(String u, Connection c) throws Exception {
        setDureeMins(getDureeIntervalle());

        MapUtilisateur map = (MapUtilisateur) new MapUtilisateur().getById(u, "utilisateur", c);
        if (map.getRang() >= ConstanteAcade.RANG_POM) {
            this.setEtat(ConstanteEtat.getEtatValider());
        } else {
            this.setEtat(ConstanteEtat.getEtatCreer());
        }
        return super.createObject(u, c);
    }

    public double getDureeIntervalle() {

        if (heureDebut == null || heureFin == null) {
            return 0;
        }

        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm");

        LocalTime debut = LocalTime.parse(heureDebut, formatter);
        LocalTime fin = LocalTime.parse(heureFin, formatter);

        long minutes = Duration.between(debut, fin).toMinutes();

        if (minutes < 0) {
            throw new IllegalArgumentException(
                    "L'heure de fin doit être supérieure à l'heure de début"
            );
        }

        return minutes;
    }

    @Override
    public String getTuppleID() {
        return id;
    }

    @Override
    public String getAttributIDName() {
        return "id";
    }

    public void construirePK(Connection c) throws Exception {
        this.preparePk("IND", "get_seq_indisponibilite");
        this.setId(makePK(c));
    }

}
