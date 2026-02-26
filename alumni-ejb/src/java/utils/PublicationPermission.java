package utils;

import bean.CGenUtil;
import bean.Post;
import user.UserEJB;
import utilitaire.UtilDB;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

/**
 * Classe utilitaire pour gérer les permissions de publication par rôle.
 * 
 * Règles :
 * - etudiant : ne peut PAS publier
 * - alumni : peut publier max 3 posts/jour
 * - admin : peut publier sans limite
 * - enseignant : peut publier sans limite
 */
public class PublicationPermission {
    
    // Limite quotidienne pour les alumni
    public static final int LIMITE_QUOTIDIENNE_ALUMNI = 3;
    
    public static boolean peutPublier(UserEJB u) {
        if (u == null || u.getUser() == null) return false;
        
        String role = u.getUser().getIdrole();
        if (role == null) return false;
        
        // Les étudiants ne peuvent pas publier
        if ("etudiant".equalsIgnoreCase(role)) {
            return false;
        }
        
        // Admin et enseignant peuvent toujours publier
        if ("admin".equalsIgnoreCase(role) || "enseignant".equalsIgnoreCase(role)) {
            return true;
        }
        
        // Alumni : vérifier la limite quotidienne
        if ("alumni".equalsIgnoreCase(role)) {
            int nbPublicationsAujourdhui = compterPublicationsJour(u);
            return nbPublicationsAujourdhui < LIMITE_QUOTIDIENNE_ALUMNI;
        }
        
        return false;
    }
    
    public static boolean afficherBoutonAjouter(UserEJB u) {
        if (u == null || u.getUser() == null) return false;
        
        String role = u.getUser().getIdrole();
        if (role == null) return false;
        
        // Étudiants : masquer le bouton
        if ("etudiant".equalsIgnoreCase(role)) {
            return false;
        }
        
        return true;
    }
    
    /**
     * Compte le nombre de publications de l'utilisateur aujourd'hui.
     * @param u UserEJB de l'utilisateur
     * @return nombre de publications du jour
     */
    public static int compterPublicationsJour(UserEJB u) {
        if (u == null || u.getUser() == null) return 0;
        
        Connection c = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            c = new UtilDB().GetConn();
            String sql = "SELECT COUNT(*) FROM posts WHERE idutilisateur = ? AND DATE(created_at) = CURRENT_DATE";
            ps = c.prepareStatement(sql);
            ps.setInt(1, Integer.parseInt(String.valueOf(u.getUser().getRefuser())));
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try { if (rs != null) rs.close(); } catch (Exception e) {}
            try { if (ps != null) ps.close(); } catch (Exception e) {}
            try { if (c != null) c.close(); } catch (Exception e) {}
        }
        
        return 0;
    }
    
    /**
     * Retourne le nombre de publications restantes pour aujourd'hui.
     * @param u UserEJB de l'utilisateur
     * @return nombre de publications restantes (-1 si illimité, 0 si interdit)
     */
    public static int publicationsRestantes(UserEJB u) {
        if (u == null || u.getUser() == null) return 0;
        
        String role = u.getUser().getIdrole();
        if (role == null) return 0;
        
        if ("etudiant".equalsIgnoreCase(role)) {
            return 0;
        }
        
        if ("admin".equalsIgnoreCase(role) || "enseignant".equalsIgnoreCase(role)) {
            return -1; // Illimité
        }
        
        if ("alumni".equalsIgnoreCase(role)) {
            int dejaPubblies = compterPublicationsJour(u);
            return Math.max(0, LIMITE_QUOTIDIENNE_ALUMNI - dejaPubblies);
        }
        
        return 0;
    }
    
    /**
     * Retourne un message d'erreur approprié selon le rôle.
     * @param u UserEJB de l'utilisateur
     * @return message d'erreur ou null si autorisé
     */
    public static String getMessageErreur(UserEJB u) {
        if (u == null || u.getUser() == null) {
            return "Vous devez être connecté pour publier.";
        }
        
        String role = u.getUser().getIdrole();
        if (role == null) {
            return "Rôle utilisateur non défini.";
        }
        
        if ("etudiant".equalsIgnoreCase(role)) {
            return "Les étudiants ne sont pas autorisés à publier des offres. " +
                   "Cette fonctionnalité est réservée aux alumni et enseignants.";
        }
        
        if ("alumni".equalsIgnoreCase(role)) {
            int restantes = publicationsRestantes(u);
            if (restantes <= 0) {
                return "Vous avez atteint votre limite de " + LIMITE_QUOTIDIENNE_ALUMNI + 
                       " publications par jour. Réessayez demain.";
            }
        }
        
        return null; // Pas d'erreur
    }
    
    /**
     * Vérifie si le rôle est "etudiant".
     */
    public static boolean estEtudiant(UserEJB u) {
        if (u == null || u.getUser() == null) return false;
        String role = u.getUser().getIdrole();
        return "etudiant".equalsIgnoreCase(role);
    }
    
    /**
     * Vérifie si le rôle est "alumni".
     */
    public static boolean estAlumni(UserEJB u) {
        if (u == null || u.getUser() == null) return false;
        String role = u.getUser().getIdrole();
        return "alumni".equalsIgnoreCase(role);
    }
    
    /**
     * Vérifie si le rôle est "admin".
     */
    public static boolean estAdmin(UserEJB u) {
        if (u == null || u.getUser() == null) return false;
        String role = u.getUser().getIdrole();
        return "admin".equalsIgnoreCase(role);
    }
}
