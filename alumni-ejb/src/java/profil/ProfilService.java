package profil;

import bean.CGenUtil;
import bean.Post;
import bean.TypeUtilisateur;

/**
 * Service utilitaire pour les données du profil utilisateur.
 * Centralise la logique métier utilisée dans les pages de profil.
 */
public class ProfilService {

    /**
     * Compte le nombre de publications (posts non supprimés) d'un utilisateur.
     *
     * @param idutilisateur PK numérique (refuser) de l'utilisateur
     * @return le nombre de publications
     * @throws Exception en cas d'erreur de recherche
     */
    public static int compterPublications(int idutilisateur) throws Exception {
        Post filtre = new Post();
        Object[] posts = CGenUtil.rechercher(filtre, null, null,
                " AND idutilisateur = " + idutilisateur + " AND supprime = 0");
        return (posts != null) ? posts.length : 0;
    }

    /**
     * Récupère toutes les publications (posts non supprimés) d'un utilisateur.
     *
     * @param idutilisateur PK numérique (refuser) de l'utilisateur
     * @return tableau de Post, jamais null (tableau vide si aucun résultat)
     * @throws Exception en cas d'erreur de recherche
     */
    public static Post[] getPublications(int idutilisateur) throws Exception {
        Post filtre = new Post();
        Object[] results = CGenUtil.rechercher(filtre, null, null,
                " AND idutilisateur = " + idutilisateur + " AND supprime = 0 ORDER BY created_at DESC");
        if (results == null || results.length == 0) {
            return new Post[0];
        }
        Post[] posts = new Post[results.length];
        for (int i = 0; i < results.length; i++) {
            posts[i] = (Post) results[i];
        }
        return posts;
    }

    /**
     * Récupère le libellé d'un type d'utilisateur à partir de son ID.
     *
     * @param idTypeUtilisateur l'ID du type d'utilisateur (ex: "TU0000003")
     * @return le libellé correspondant, ou l'ID lui-même si introuvable
     * @throws Exception en cas d'erreur de recherche
     */
    public static String getLibelleTypeUtilisateur(String idTypeUtilisateur) throws Exception {
        if (idTypeUtilisateur == null || idTypeUtilisateur.isEmpty()) {
            return "";
        }
        TypeUtilisateur filtre = new TypeUtilisateur();
        filtre.setId(idTypeUtilisateur);
        Object[] results = CGenUtil.rechercher(filtre, null, null,
                " AND id = '" + idTypeUtilisateur + "'");
        if (results != null && results.length > 0) {
            TypeUtilisateur tu = (TypeUtilisateur) results[0];
            return tu.getLibelle() != null ? tu.getLibelle() : idTypeUtilisateur;
        }
        return idTypeUtilisateur;
    }
}
