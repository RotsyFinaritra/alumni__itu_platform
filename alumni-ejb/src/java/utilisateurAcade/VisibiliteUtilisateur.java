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

    /**
     * 1 = visible par les autres alumni, 0 = masqué.
     * APJ ne supporte pas le type boolean Java (javaToSql() n'a pas de mapping
     * pour boolean → Champ.type reste null → NPE dans makeWhere).
     * On utilise int (0/1) à la place, qui est correctement géré par APJ
     * (javaToSql → "Number", testNombre=true dans makeWhere → le champ est ignoré).
     */
    private int visible = 0;

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

    public int getVisible() {
        return visible;
    }

    public void setVisible(int visible) {
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
