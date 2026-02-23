package profil;

import bean.CGenUtil;
import utilisateurAcade.VisibiliteUtilisateur;
import utilitaire.UtilDB;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.HashMap;
import java.util.Map;

/**
 * Service de gestion de la visibilité des champs du profil utilisateur.
 *
 * Justification des JDBC directs :
 *   La table visibilite_utilisateur a une PK composite (idutilisateur, nomchamp)
 *   et nécessite des opérations UPSERT (INSERT ON CONFLICT DO UPDATE).
 *   CGenUtil.inserer() ne gère pas ON CONFLICT, donc JDBC est obligatoire ici.
 */
public class VisibiliteService {

    private static final String UPSERT_SQL =
        "INSERT INTO visibilite_utilisateur (idutilisateur, nomchamp, visible) " +
        "VALUES (?, ?, ?) " +
        "ON CONFLICT (idutilisateur, nomchamp) DO UPDATE SET visible = EXCLUDED.visible";

    /**
     * Bascule la visibilité d'un seul champ pour un utilisateur (toggle AJAX).
     *
     * @param idutilisateur PK numérique de l'utilisateur
     * @param nomchamp      nom du champ (ex : "mail", "photo")
     * @param visible       nouvelle valeur de visibilité
     * @throws Exception en cas d'erreur SQL
     */
    public static void toggleVisibilite(int idutilisateur, String nomchamp, boolean visible)
            throws Exception {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = new UtilDB().GetConn();
            ps = conn.prepareStatement(UPSERT_SQL);
            ps.setInt(1, idutilisateur);
            ps.setString(2, nomchamp);
            ps.setInt(3, visible ? 1 : 0);
            ps.executeUpdate();
        } finally {
            if (ps != null) try { ps.close(); } catch (Exception ignored) {}
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }
    }

    /**
     * Sauvegarde en masse les paramètres de visibilité (page de confidentialité).
     *
     * @param idutilisateur PK numérique de l'utilisateur
     * @param champsConfig  liste des noms de champs configurables
     * @param visibiliteMap map nomchamp → visible
     * @throws Exception en cas d'erreur SQL
     */
    public static void sauvegarderVisibilite(int idutilisateur, String[] champsConfig,
                                              Map<String, Boolean> visibiliteMap)
            throws Exception {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = new UtilDB().GetConn();
            for (String champ : champsConfig) {
                boolean isVisible = Boolean.TRUE.equals(visibiliteMap.get(champ));
                ps = conn.prepareStatement(UPSERT_SQL);
                ps.setInt(1, idutilisateur);
                ps.setString(2, champ);
                ps.setInt(3, isVisible ? 1 : 0);
                ps.executeUpdate();
                ps.close();
                ps = null;
            }
        } finally {
            if (ps != null) try { ps.close(); } catch (Exception ignored) {}
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }
    }

    /**
     * Charge les préférences de visibilité d'un utilisateur.
     * Utilise awhere explicite pour éviter que CGenUtil filtre sur visible=false.
     *
     * @param idutilisateur PK numérique de l'utilisateur
     * @return map nomchamp → visible (jamais null)
     * @throws Exception en cas d'erreur APJ
     */
    public static Map<String, Boolean> getVisibilite(int idutilisateur) throws Exception {
        Object[] visiList = CGenUtil.rechercher(
            new VisibiliteUtilisateur(), null, null,
            " AND idutilisateur = " + idutilisateur
        );
        Map<String, Boolean> map = new HashMap<String, Boolean>();
        if (visiList != null) {
            for (Object o : visiList) {
                VisibiliteUtilisateur vv = (VisibiliteUtilisateur) o;
                map.put(vv.getNomChamp(), vv.getVisible() == 1);
            }
        }
        return map;
    }
}
