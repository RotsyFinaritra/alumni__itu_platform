package validation;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.JsonArray;
import com.google.gson.JsonElement;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

/**
 * Classe pour valider les inscriptions d'étudiants
 * contre la liste autorisée dans etudiants_autorises.json
 */
public class EtudiantValidator {
    
    private static final String JSON_FILE = "/etudiants_autorises.json";
    private JsonArray etudiants;
    
    /**
     * Charge la liste des étudiants autorisés depuis le fichier JSON
     */
    public EtudiantValidator() throws Exception {
        InputStream is = getClass().getResourceAsStream(JSON_FILE);
        if (is == null) {
            throw new Exception("Fichier etudiants_autorises.json non trouvé dans le classpath");
        }
        
        try (InputStreamReader reader = new InputStreamReader(is, StandardCharsets.UTF_8)) {
            Gson gson = new Gson();
            JsonObject root = gson.fromJson(reader, JsonObject.class);
            this.etudiants = root.getAsJsonArray("etudiants");
        }
    }
    
    /**
     * Résultat de la validation
     */
    public static class ValidationResult {
        private boolean valide;
        private String message;
        private String promotion;
        
        public ValidationResult(boolean valide, String message, String promotion) {
            this.valide = valide;
            this.message = message;
            this.promotion = promotion;
        }
        
        public boolean isValide() { return valide; }
        public String getMessage() { return message; }
        public String getPromotion() { return promotion; }
    }
    
    /**
     * Valide un étudiant
     * 
     * @param etu Numéro étudiant
     * @param nom Nom de famille (case-insensitive)
     * @param prenom Prénom (case-insensitive)
     * @return ValidationResult avec statut et message
     */
    public ValidationResult valider(String etu, String nom, String prenom) {
        if (etu == null || etu.trim().isEmpty()) {
            return new ValidationResult(false, "Le numéro étudiant (ETU) est obligatoire.", null);
        }
        
        if (nom == null || nom.trim().isEmpty()) {
            return new ValidationResult(false, "Le nom est obligatoire.", null);
        }
        
        if (prenom == null || prenom.trim().isEmpty()) {
            return new ValidationResult(false, "Le prénom est obligatoire.", null);
        }
        
        etu = etu.trim();
        nom = nom.trim().toUpperCase();
        prenom = prenom.trim();
        
        // Chercher l'étudiant dans la liste
        for (JsonElement element : etudiants) {
            JsonObject etudiant = element.getAsJsonObject();
            String etuJson = etudiant.get("etu").getAsString();
            
            if (etuJson.equals(etu)) {
                // ETU trouvé, vérifier nom et prénom
                String nomJson = etudiant.get("nom").getAsString().toUpperCase();
                String prenomJson = etudiant.get("prenom").getAsString();
                String promotionJson = etudiant.get("promotion").getAsString();
                
                if (!nomJson.equals(nom)) {
                    return new ValidationResult(false, 
                        "Le nom ne correspond pas au numéro étudiant " + etu + ". Nom attendu : " + nomJson, 
                        null);
                }
                
                if (!prenomJson.equalsIgnoreCase(prenom)) {
                    return new ValidationResult(false, 
                        "Le prénom ne correspond pas au numéro étudiant " + etu + ". Prénom attendu : " + prenomJson, 
                        null);
                }
                
                // Tout est correct
                return new ValidationResult(true, "Étudiant validé avec succès.", promotionJson);
            }
        }
        
        // ETU non trouvé
        return new ValidationResult(false, 
            "Le numéro étudiant " + etu + " n'est pas autorisé à s'inscrire. Veuillez contacter l'administration.", 
            null);
    }
    
    /**
     * Vérifie si un ETU est déjà inscrit dans la base de données
     */
    public static boolean isEtuDejaInscrit(String etu, java.sql.Connection conn) throws Exception {
        if (etu == null || etu.trim().isEmpty()) {
            return false;
        }
        
        java.sql.PreparedStatement ps = null;
        java.sql.ResultSet rs = null;
        try {
            ps = conn.prepareStatement("SELECT COUNT(*) FROM utilisateur WHERE etu = ?");
            ps.setString(1, etu.trim());
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
            return false;
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (ps != null) try { ps.close(); } catch (Exception e) {}
        }
    }
}
