package profil;

import bean.CGenUtil;
import bean.Competence;
import bean.CompetenceUtilisateur;
import bean.Specialite;
import bean.UtilisateurSpecialite;
import utilitaire.UtilDB;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.HashSet;
import java.util.Set;

/**
 * Service de gestion des compétences et spécialités d'un utilisateur.
 *
 * Justification des JDBC directs :
 *   Les tables competence_utilisateur et utilisateur_specialite ont des PK composites.
 *   CGenUtil.supprimer() n'utilise que getTuppleID() (= idcompetence seul),
 *   ce qui supprimerait la compétence pour TOUS les utilisateurs.
 *   → DELETE WHERE idutilisateur = ? est forcément JDBC.
 *   Les INSERT restent via CGenUtil.save() (APJ).
 */
public class CompetenceProfilService {

    /**
     * Remplace toutes les compétences et spécialités de l'utilisateur.
     *
     * @param idutilisateur  PK numérique (refuser) de l'utilisateur
     * @param competences    tableau des idcompetence sélectionnés (peut être null)
     * @param specialites    tableau des idspecialite sélectionnés (peut être null)
     * @throws Exception en cas d'erreur SQL ou APJ
     */
    public static void sauvegarder(int idutilisateur, String[] competences, String[] specialites)
            throws Exception {

        // 1. Supprimer les anciennes associations (JDBC obligatoire — PK composite)
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = new UtilDB().GetConn();

            ps = conn.prepareStatement(
                "DELETE FROM competence_utilisateur WHERE idutilisateur = ?"
            );
            ps.setInt(1, idutilisateur);
            ps.executeUpdate();
            ps.close();

            ps = conn.prepareStatement(
                "DELETE FROM utilisateur_specialite WHERE idutilisateur = ?"
            );
            ps.setInt(1, idutilisateur);
            ps.executeUpdate();
            ps.close();
            ps = null;

        } finally {
            if (ps != null) try { ps.close(); } catch (Exception ignored) {}
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }

        // 2. Insérer les nouveaux choix via CGenUtil APJ
        if (competences != null) {
            for (String idComp : competences) {
                CompetenceUtilisateur cu = new CompetenceUtilisateur();
                cu.setIdcompetence(idComp);
                cu.setIdutilisateur(idutilisateur);
                CGenUtil.save(cu);
            }
        }

        if (specialites != null) {
            for (String idSpec : specialites) {
                UtilisateurSpecialite us = new UtilisateurSpecialite();
                us.setIdutilisateur(idutilisateur);
                us.setIdspecialite(idSpec);
                CGenUtil.save(us);
            }
        }
    }

    /**
     * Retourne tous les identifiants de compétences associés à un utilisateur.
     *
     * @param idutilisateur PK numérique de l'utilisateur
     * @return ensemble des idcompetence (jamais null)
     * @throws Exception en cas d'erreur APJ
     */
    public static Set<String> getCompetencesUtilisateur(int idutilisateur) throws Exception {
        CompetenceUtilisateur filtre = new CompetenceUtilisateur();
        filtre.setIdutilisateur(idutilisateur);
        Object[] result = CGenUtil.rechercher(filtre, null, null, "");
        Set<String> ids = new HashSet<String>();
        if (result != null) {
            for (Object o : result) {
                ids.add(((CompetenceUtilisateur) o).getIdcompetence());
            }
        }
        return ids;
    }

    /**
     * Retourne tous les identifiants de spécialités associés à un utilisateur.
     *
     * @param idutilisateur PK numérique de l'utilisateur
     * @return ensemble des idspecialite (jamais null)
     * @throws Exception en cas d'erreur APJ
     */
    public static Set<String> getSpecialitesUtilisateur(int idutilisateur) throws Exception {
        UtilisateurSpecialite filtre = new UtilisateurSpecialite();
        filtre.setIdutilisateur(idutilisateur);
        Object[] result = CGenUtil.rechercher(filtre, null, null, "");
        Set<String> ids = new HashSet<String>();
        if (result != null) {
            for (Object o : result) {
                ids.add(((UtilisateurSpecialite) o).getIdspecialite());
            }
        }
        return ids;
    }

    /**
     * Retourne toutes les compétences disponibles triées par libellé.
     *
     * @return tableau de Competence (peut être null si aucune)
     * @throws Exception en cas d'erreur APJ
     */
    public static Object[] getToutesCompetences() throws Exception {
        return CGenUtil.rechercher(new Competence(), null, null, " ORDER BY libelle");
    }

    /**
     * Retourne toutes les spécialités disponibles triées par libellé.
     *
     * @return tableau de Specialite (peut être null si aucune)
     * @throws Exception en cas d'erreur APJ
     */
    public static Object[] getToutesSpecialites() throws Exception {
        return CGenUtil.rechercher(new Specialite(), null, null, " ORDER BY libelle");
    }
}
