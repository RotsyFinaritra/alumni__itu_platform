package utilisateurAcade;

import bean.ClassMAPTable;

/**
 * Mapping APJ de la table visibilite_utilisateur.
 *
 * Cette table stocke la visibilité de chaque champ du profil d'un utilisateur
 * (ex : 'telephone', 'mail', 'entreprise', 'photo', ...).
 *
 * La clé primaire est composite (idutilisateur, nomchamp) : pas de séquence,
 * les valeurs sont fournies directement à l'insertion.
 */
public class VisibiliteUtilisateur extends ClassMAPTable {

    /** FK vers utilisateur.refuser */
    private int idutilisateur;

    /**
     * Nom du champ concerné : 'telephone', 'mail', 'entreprise', 'photo', ...
     * Correspond à la colonne SQL {@code nomchamp} de la table.
     */
    private String nomChamp;

    /** true = visible par les autres alumni, false = masqué */
    private boolean visible;

    public VisibiliteUtilisateur() {
        super.setNomTable("visibilite_utilisateur");
    }


    public int getIdutilisateur() {
        return idutilisateur;
    }

    public void setIdutilisateur(int idutilisateur) {
        this.idutilisateur = idutilisateur;
    }

    public String getNomChamp() {
        return nomChamp;
    }

    public void setNomChamp(String nomChamp) {
        this.nomChamp = nomChamp;
    }

    public boolean isVisible() {
        return visible;
    }

    public void setVisible(boolean visible) {
        this.visible = visible;
    }

    // ------------------------------------------------------------------ //
    //  Contrat APJ ClassMAPTable                                           //
    // ------------------------------------------------------------------ //

    /**
     * La PK composite (idutilisateur, champ) est représentée ici
     * par idutilisateur pour satisfaire le contrat APJ.
     */
    @Override
    public String getTuppleID() {
        return String.valueOf(this.idutilisateur);
    }

    @Override
    public String getAttributIDName() {
        return "idutilisateur";
    }

    // Pas de construirePK : PK composite sans séquence, valeurs fournies à l'insertion.
}
