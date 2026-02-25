package servlet.chatbot;

import com.google.gson.Gson;
import utilitaire.UtilDB;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Chatbot Alumni - Recherche directe par mots-cles (sans API externe).
 * Analyse la question en langage naturel et genere des requetes SQL.
 */
@WebServlet("/alumni-chat")
public class AlumniChatServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String question = request.getParameter("question");
        if (question == null || question.trim().isEmpty()) {
            sendJson(response, false, "Veuillez poser une question.", null);
            return;
        }

        System.out.println("[AlumniChat] Question: " + question);

        Connection conn = null;
        try {
            conn = new UtilDB().GetConn();
            String q = question.toLowerCase().trim();

            String htmlResponse;

            if (matchesEntreprise(q)) {
                htmlResponse = rechercherParEntreprise(conn, extractKeyword(q, getEntrepriseKeywords()));
            } else if (matchesPromotion(q)) {
                htmlResponse = rechercherParPromotion(conn, extractKeyword(q, getPromotionKeywords()));
            } else if (matchesDomaine(q)) {
                htmlResponse = rechercherParDomaine(conn, extractKeyword(q, getDomaineKeywords()));
            } else if (matchesCompetence(q)) {
                htmlResponse = rechercherParCompetence(conn, extractKeyword(q, getCompetenceKeywords()));
            } else if (matchesPoste(q)) {
                htmlResponse = rechercherParPoste(conn, extractKeyword(q, getPosteKeywords()));
            } else if (matchesVille(q)) {
                htmlResponse = rechercherParVille(conn, extractKeyword(q, getVilleKeywords()));
            } else if (matchesStats(q)) {
                htmlResponse = afficherStatistiques(conn);
            } else {
                // Recherche globale par defaut
                htmlResponse = rechercheGlobale(conn, q);
            }

            sendJson(response, true, htmlResponse, null);

        } catch (Exception e) {
            e.printStackTrace();
            sendJson(response, false, "Erreur lors de la recherche: " + e.getMessage(), null);
        } finally {
            if (conn != null) try { conn.close(); } catch (Exception ignored) {}
        }
    }

    // ========== DETECTION DES INTENTIONS ==========

    private String[] getEntrepriseKeywords() {
        return new String[]{"entreprise", "societe", "boite", "travaille", "employe", "travail",
                "travailler", "bossent", "bosse", "bosser", "emploi", "embauche"};
    }
    private boolean matchesEntreprise(String q) {
        for (String kw : getEntrepriseKeywords()) {
            if (q.contains(kw)) return true;
        }
        return false;
    }

    private String[] getPromotionKeywords() {
        return new String[]{"promotion", "promo", "annee", "sortant", "diplome en", "promotion de"};
    }
    private boolean matchesPromotion(String q) {
        for (String kw : getPromotionKeywords()) {
            if (q.contains(kw)) return true;
        }
        return false;
    }

    private String[] getDomaineKeywords() {
        return new String[]{"domaine", "secteur", "branche", "filiere", "specialite"};
    }
    private boolean matchesDomaine(String q) {
        for (String kw : getDomaineKeywords()) {
            if (q.contains(kw)) return true;
        }
        return false;
    }

    private String[] getCompetenceKeywords() {
        return new String[]{"competence", "skill", "sait faire", "capable", "maitrise", "connait"};
    }
    private boolean matchesCompetence(String q) {
        for (String kw : getCompetenceKeywords()) {
            if (q.contains(kw)) return true;
        }
        return false;
    }

    private String[] getPosteKeywords() {
        return new String[]{"poste", "fonction", "role", "titre", "developpeur", "manager",
                "directeur", "ingenieur", "chef", "responsable", "analyste", "consultant"};
    }
    private boolean matchesPoste(String q) {
        for (String kw : getPosteKeywords()) {
            if (q.contains(kw)) return true;
        }
        return false;
    }

    private String[] getVilleKeywords() {
        return new String[]{"ville", "habite", "situe", "localisation", "base a", "vit a",
                "antananarivo", "tana", "toamasina", "fianarantsoa", "mahajanga"};
    }
    private boolean matchesVille(String q) {
        for (String kw : getVilleKeywords()) {
            if (q.contains(kw)) return true;
        }
        return false;
    }

    private boolean matchesStats(String q) {
        return q.contains("statistique") || q.contains("combien") || q.contains("nombre")
                || q.contains("total") || q.contains("stats");
    }

    // ========== EXTRACTION DU MOT-CLE ==========

    private String extractKeyword(String question, String[] triggers) {
        // Retirer le mot-cle declencheur et les mots communs
        String cleaned = question;
        for (String trigger : triggers) {
            cleaned = cleaned.replace(trigger, " ");
        }
        // Retirer les mots courants francais
        String[] stopWords = {"qui", "que", "quoi", "quel", "quelle", "quels", "quelles",
                "sont", "les", "des", "est", "a", "au", "aux", "de", "du", "la", "le", "un", "une",
                "dans", "sur", "par", "pour", "avec", "ont", "chez", "ou", "et",
                "ancien", "anciens", "alumni", "etudiant", "etudiants", "membre", "membres",
                "personne", "personnes", "gens", "quelqu", "tous", "tout", "toute", "toutes",
                "peut", "avoir", "fait", "deja", "comme", "itu", "il", "ils", "elle", "elles",
                "mon", "ma", "mes", "ton", "ta", "tes", "son", "sa", "ses", "leur", "leurs",
                "ce", "cette", "ces", "cet", "en", "y", "ne", "pas", "plus", "aussi"};

        for (String sw : stopWords) {
            cleaned = cleaned.replaceAll("\\b" + sw + "\\b", " ");
        }
        cleaned = cleaned.replaceAll("\\s+", " ").trim();
        // Retirer les ? et caracteres speciaux
        cleaned = cleaned.replaceAll("[?!.,;:'\"()]", "").trim();
        return cleaned.isEmpty() ? "%" : cleaned;
    }

    // ========== REQUETES DE RECHERCHE ==========

    private String rechercherParEntreprise(Connection conn, String keyword) throws Exception {
        String sql = "SELECT DISTINCT u.nomuser, u.prenom, e.libelle AS entreprise, " +
                "ex.poste, ex.datedebut, ex.datefin, p.libelle AS promotion " +
                "FROM experience ex " +
                "JOIN utilisateur u ON ex.idutilisateur = u.refuser " +
                "JOIN entreprise e ON ex.identreprise = e.id " +
                "LEFT JOIN promotion p ON u.idpromotion = p.id " +
                "WHERE LOWER(e.libelle) LIKE LOWER(?) " +
                "ORDER BY u.nomuser LIMIT 30";

        List<Map<String, String>> results = executeSearch(conn, sql, "%" + keyword + "%");

        if (results.isEmpty()) {
            return "<p>Aucun alumni trouve ayant travaille dans une entreprise correspondant a " +
                    "<strong>\"" + escapeHtml(keyword) + "\"</strong>.</p>" +
                    "<p>Essayez avec un autre nom d'entreprise.</p>";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("<p>Voici les alumni ayant travaille chez <strong>\"")
                .append(escapeHtml(keyword)).append("\"</strong> :</p><ul>");

        for (Map<String, String> row : results) {
            sb.append("<li><strong>").append(escapeHtml(row.get("nomuser")));
            if (row.get("prenom") != null && !row.get("prenom").isEmpty()) {
                sb.append(" ").append(escapeHtml(row.get("prenom")));
            }
            sb.append("</strong>");
            if (row.get("poste") != null && !row.get("poste").isEmpty()) {
                sb.append(" - <em>").append(escapeHtml(row.get("poste"))).append("</em>");
            }
            sb.append(" chez ").append(escapeHtml(row.get("entreprise")));
            if (row.get("promotion") != null) {
                sb.append(" (Promo: ").append(escapeHtml(row.get("promotion"))).append(")");
            }
            sb.append("</li>");
        }
        sb.append("</ul>");
        sb.append("<p><em>").append(results.size()).append(" resultat(s) trouve(s).</em></p>");
        return sb.toString();
    }

    private String rechercherParPromotion(Connection conn, String keyword) throws Exception {
        String sql = "SELECT u.nomuser, u.prenom, u.mail, p.libelle AS promotion, p.annee " +
                "FROM utilisateur u " +
                "JOIN promotion p ON u.idpromotion = p.id " +
                "WHERE LOWER(p.libelle) LIKE LOWER(?) OR CAST(p.annee AS TEXT) LIKE ? " +
                "ORDER BY p.annee DESC, u.nomuser LIMIT 30";

        List<Map<String, String>> results = executeSearch(conn, sql,
                "%" + keyword + "%", "%" + keyword + "%");

        if (results.isEmpty()) {
            return "<p>Aucun alumni trouve pour la promotion <strong>\"" +
                    escapeHtml(keyword) + "\"</strong>.</p>";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("<p>Alumni de la promotion <strong>\"")
                .append(escapeHtml(keyword)).append("\"</strong> :</p><ul>");

        for (Map<String, String> row : results) {
            sb.append("<li><strong>").append(escapeHtml(row.get("nomuser")));
            if (row.get("prenom") != null && !row.get("prenom").isEmpty()) {
                sb.append(" ").append(escapeHtml(row.get("prenom")));
            }
            sb.append("</strong>");
            sb.append(" - Promotion ").append(escapeHtml(row.get("promotion")));
            if (row.get("annee") != null) {
                sb.append(" (").append(escapeHtml(row.get("annee"))).append(")");
            }
            if (row.get("mail") != null && !row.get("mail").isEmpty()) {
                sb.append(" - ").append(escapeHtml(row.get("mail")));
            }
            sb.append("</li>");
        }
        sb.append("</ul>");
        sb.append("<p><em>").append(results.size()).append(" resultat(s) trouve(s).</em></p>");
        return sb.toString();
    }

    private String rechercherParDomaine(Connection conn, String keyword) throws Exception {
        String sql = "SELECT DISTINCT u.nomuser, u.prenom, d.libelle AS domaine, " +
                "ex.poste, e.libelle AS entreprise " +
                "FROM experience ex " +
                "JOIN utilisateur u ON ex.idutilisateur = u.refuser " +
                "JOIN domaine d ON ex.iddomaine = d.id " +
                "LEFT JOIN entreprise e ON ex.identreprise = e.id " +
                "WHERE LOWER(d.libelle) LIKE LOWER(?) " +
                "ORDER BY u.nomuser LIMIT 30";

        List<Map<String, String>> results = executeSearch(conn, sql, "%" + keyword + "%");

        if (results.isEmpty()) {
            return "<p>Aucun alumni trouve dans le domaine <strong>\"" +
                    escapeHtml(keyword) + "\"</strong>.</p>";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("<p>Alumni dans le domaine <strong>\"")
                .append(escapeHtml(keyword)).append("\"</strong> :</p><ul>");

        for (Map<String, String> row : results) {
            sb.append("<li><strong>").append(escapeHtml(row.get("nomuser")));
            if (row.get("prenom") != null && !row.get("prenom").isEmpty()) {
                sb.append(" ").append(escapeHtml(row.get("prenom")));
            }
            sb.append("</strong>");
            if (row.get("poste") != null) sb.append(" - ").append(escapeHtml(row.get("poste")));
            if (row.get("entreprise") != null) sb.append(" chez ").append(escapeHtml(row.get("entreprise")));
            sb.append("</li>");
        }
        sb.append("</ul>");
        return sb.toString();
    }

    private String rechercherParCompetence(Connection conn, String keyword) throws Exception {
        String sql = "SELECT u.nomuser, u.prenom, c.libelle AS competence " +
                "FROM competence_utilisateur cu " +
                "JOIN utilisateur u ON cu.idutilisateur = u.refuser " +
                "JOIN competence c ON cu.idcompetence = c.id " +
                "WHERE LOWER(c.libelle) LIKE LOWER(?) " +
                "ORDER BY u.nomuser LIMIT 30";

        List<Map<String, String>> results = executeSearch(conn, sql, "%" + keyword + "%");

        if (results.isEmpty()) {
            return "<p>Aucun alumni trouve avec la competence <strong>\"" +
                    escapeHtml(keyword) + "\"</strong>.</p>";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("<p>Alumni avec la competence <strong>\"")
                .append(escapeHtml(keyword)).append("\"</strong> :</p><ul>");

        for (Map<String, String> row : results) {
            sb.append("<li><strong>").append(escapeHtml(row.get("nomuser")));
            if (row.get("prenom") != null && !row.get("prenom").isEmpty()) {
                sb.append(" ").append(escapeHtml(row.get("prenom")));
            }
            sb.append("</strong> - ").append(escapeHtml(row.get("competence")));
            sb.append("</li>");
        }
        sb.append("</ul>");
        return sb.toString();
    }

    private String rechercherParPoste(Connection conn, String keyword) throws Exception {
        String sql = "SELECT DISTINCT u.nomuser, u.prenom, ex.poste, " +
                "e.libelle AS entreprise, ex.datedebut, ex.datefin " +
                "FROM experience ex " +
                "JOIN utilisateur u ON ex.idutilisateur = u.refuser " +
                "LEFT JOIN entreprise e ON ex.identreprise = e.id " +
                "WHERE LOWER(ex.poste) LIKE LOWER(?) " +
                "ORDER BY u.nomuser LIMIT 30";

        List<Map<String, String>> results = executeSearch(conn, sql, "%" + keyword + "%");

        if (results.isEmpty()) {
            return "<p>Aucun alumni trouve au poste <strong>\"" +
                    escapeHtml(keyword) + "\"</strong>.</p>";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("<p>Alumni au poste <strong>\"")
                .append(escapeHtml(keyword)).append("\"</strong> :</p><ul>");

        for (Map<String, String> row : results) {
            sb.append("<li><strong>").append(escapeHtml(row.get("nomuser")));
            if (row.get("prenom") != null && !row.get("prenom").isEmpty()) {
                sb.append(" ").append(escapeHtml(row.get("prenom")));
            }
            sb.append("</strong> - ").append(escapeHtml(row.get("poste")));
            if (row.get("entreprise") != null) sb.append(" chez ").append(escapeHtml(row.get("entreprise")));
            sb.append("</li>");
        }
        sb.append("</ul>");
        return sb.toString();
    }

    private String rechercherParVille(Connection conn, String keyword) throws Exception {
        String sql = "SELECT DISTINCT u.nomuser, u.prenom, v.libelle AS ville, " +
                "e.libelle AS entreprise, ex.poste " +
                "FROM experience ex " +
                "JOIN utilisateur u ON ex.idutilisateur = u.refuser " +
                "JOIN entreprise e ON ex.identreprise = e.id " +
                "JOIN ville v ON e.idville = v.id " +
                "WHERE LOWER(v.libelle) LIKE LOWER(?) " +
                "ORDER BY u.nomuser LIMIT 30";

        List<Map<String, String>> results = executeSearch(conn, sql, "%" + keyword + "%");

        if (results.isEmpty()) {
            return "<p>Aucun alumni trouve dans la ville <strong>\"" +
                    escapeHtml(keyword) + "\"</strong>.</p>";
        }

        StringBuilder sb = new StringBuilder();
        sb.append("<p>Alumni dans la ville <strong>\"")
                .append(escapeHtml(keyword)).append("\"</strong> :</p><ul>");

        for (Map<String, String> row : results) {
            sb.append("<li><strong>").append(escapeHtml(row.get("nomuser")));
            if (row.get("prenom") != null && !row.get("prenom").isEmpty()) {
                sb.append(" ").append(escapeHtml(row.get("prenom")));
            }
            sb.append("</strong>");
            if (row.get("poste") != null) sb.append(" - ").append(escapeHtml(row.get("poste")));
            if (row.get("entreprise") != null) sb.append(" chez ").append(escapeHtml(row.get("entreprise")));
            sb.append(" (").append(escapeHtml(row.get("ville"))).append(")");
            sb.append("</li>");
        }
        sb.append("</ul>");
        return sb.toString();
    }

    private String afficherStatistiques(Connection conn) throws Exception {
        StringBuilder sb = new StringBuilder();
        sb.append("<p><strong>Statistiques Alumni ITU :</strong></p><ul>");

        // Total utilisateurs
        List<Map<String, String>> r1 = executeSearch(conn,
                "SELECT COUNT(*) AS total FROM utilisateur");
        if (!r1.isEmpty()) {
            sb.append("<li>Total utilisateurs : <strong>").append(r1.get(0).get("total")).append("</strong></li>");
        }

        // Total entreprises
        List<Map<String, String>> r2 = executeSearch(conn,
                "SELECT COUNT(*) AS total FROM entreprise");
        if (!r2.isEmpty()) {
            sb.append("<li>Entreprises enregistrees : <strong>").append(r2.get(0).get("total")).append("</strong></li>");
        }

        // Total experiences
        List<Map<String, String>> r3 = executeSearch(conn,
                "SELECT COUNT(*) AS total FROM experience");
        if (!r3.isEmpty()) {
            sb.append("<li>Experiences professionnelles : <strong>").append(r3.get(0).get("total")).append("</strong></li>");
        }

        // Total promotions
        List<Map<String, String>> r4 = executeSearch(conn,
                "SELECT COUNT(*) AS total FROM promotion");
        if (!r4.isEmpty()) {
            sb.append("<li>Promotions : <strong>").append(r4.get(0).get("total")).append("</strong></li>");
        }

        // Top 5 entreprises
        List<Map<String, String>> r5 = executeSearch(conn,
                "SELECT e.libelle, COUNT(*) AS nb FROM experience ex " +
                "JOIN entreprise e ON ex.identreprise = e.id " +
                "GROUP BY e.libelle ORDER BY nb DESC LIMIT 5");
        if (!r5.isEmpty()) {
            sb.append("<li>Top entreprises :<ul>");
            for (Map<String, String> row : r5) {
                sb.append("<li>").append(escapeHtml(row.get("libelle")))
                        .append(" (").append(row.get("nb")).append(" alumni)</li>");
            }
            sb.append("</ul></li>");
        }

        sb.append("</ul>");
        return sb.toString();
    }

    private String rechercheGlobale(Connection conn, String question) throws Exception {
        // Extraire les mots significatifs >= 3 caracteres
        String[] words = question.replaceAll("[?!.,;:'\"()]", "").split("\\s+");
        List<String> searchTerms = new ArrayList<String>();
        String[] stopWords = {"qui", "que", "quoi", "quel", "quelle", "sont", "les", "des",
                "est", "dans", "sur", "par", "pour", "avec", "ont", "chez", "ont",
                "ancien", "anciens", "alumni", "etudiant", "tout", "tous"};

        for (String w : words) {
            if (w.length() >= 3) {
                boolean isStop = false;
                for (String sw : stopWords) {
                    if (w.equals(sw)) { isStop = true; break; }
                }
                if (!isStop) searchTerms.add(w);
            }
        }

        if (searchTerms.isEmpty()) {
            return "<p>Je peux vous aider a trouver des informations sur les alumni ITU !</p>" +
                    "<p>Essayez par exemple :</p><ul>" +
                    "<li>\"Qui travaille chez <em>nom entreprise</em> ?\"</li>" +
                    "<li>\"Alumni de la promotion <em>2020</em>\"</li>" +
                    "<li>\"Qui a le poste de <em>developpeur</em> ?\"</li>" +
                    "<li>\"Domaine <em>informatique</em>\"</li>" +
                    "<li>\"Statistiques\"</li></ul>";
        }

        // Chercher dans utilisateurs, entreprises et experiences
        StringBuilder sb = new StringBuilder();
        boolean found = false;

        // 1. Recherche dans les utilisateurs (nom/prenom)
        for (String term : searchTerms) {
            List<Map<String, String>> users = executeSearch(conn,
                    "SELECT u.nomuser, u.prenom, u.mail, p.libelle AS promotion " +
                    "FROM utilisateur u LEFT JOIN promotion p ON u.idpromotion = p.id " +
                    "WHERE LOWER(u.nomuser) LIKE LOWER(?) OR LOWER(u.prenom) LIKE LOWER(?) " +
                    "ORDER BY u.nomuser LIMIT 10",
                    "%" + term + "%", "%" + term + "%");

            if (!users.isEmpty()) {
                found = true;
                sb.append("<p>Utilisateurs correspondant a <strong>\"")
                        .append(escapeHtml(term)).append("\"</strong> :</p><ul>");
                for (Map<String, String> row : users) {
                    sb.append("<li><strong>").append(escapeHtml(row.get("nomuser")));
                    if (row.get("prenom") != null && !row.get("prenom").isEmpty()) {
                        sb.append(" ").append(escapeHtml(row.get("prenom")));
                    }
                    sb.append("</strong>");
                    if (row.get("promotion") != null) sb.append(" - Promo ").append(escapeHtml(row.get("promotion")));
                    if (row.get("mail") != null && !row.get("mail").isEmpty()) sb.append(" - ").append(escapeHtml(row.get("mail")));
                    sb.append("</li>");
                }
                sb.append("</ul>");
            }
        }

        // 2. Recherche dans les entreprises
        for (String term : searchTerms) {
            List<Map<String, String>> entreprises = executeSearch(conn,
                    "SELECT DISTINCT u.nomuser, u.prenom, e.libelle AS entreprise, ex.poste " +
                    "FROM experience ex " +
                    "JOIN utilisateur u ON ex.idutilisateur = u.refuser " +
                    "JOIN entreprise e ON ex.identreprise = e.id " +
                    "WHERE LOWER(e.libelle) LIKE LOWER(?) " +
                    "ORDER BY u.nomuser LIMIT 10",
                    "%" + term + "%");

            if (!entreprises.isEmpty()) {
                found = true;
                sb.append("<p>Alumni chez <strong>\"")
                        .append(escapeHtml(term)).append("\"</strong> :</p><ul>");
                for (Map<String, String> row : entreprises) {
                    sb.append("<li><strong>").append(escapeHtml(row.get("nomuser")));
                    if (row.get("prenom") != null && !row.get("prenom").isEmpty()) {
                        sb.append(" ").append(escapeHtml(row.get("prenom")));
                    }
                    sb.append("</strong>");
                    if (row.get("poste") != null) sb.append(" - ").append(escapeHtml(row.get("poste")));
                    sb.append(" chez ").append(escapeHtml(row.get("entreprise")));
                    sb.append("</li>");
                }
                sb.append("</ul>");
            }
        }

        if (!found) {
            return "<p>Aucun resultat trouve pour <strong>\"" + escapeHtml(question) + "\"</strong>.</p>" +
                    "<p>Essayez avec d'autres termes ou posez une question comme :</p><ul>" +
                    "<li>\"Qui travaille chez <em>nom entreprise</em> ?\"</li>" +
                    "<li>\"Alumni de la promotion <em>2020</em>\"</li>" +
                    "<li>\"Statistiques\"</li></ul>";
        }

        return sb.toString();
    }

    // ========== UTILITAIRES ==========

    private List<Map<String, String>> executeSearch(Connection conn, String sql, String... params) throws Exception {
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Map<String, String>> results = new ArrayList<Map<String, String>>();

        try {
            ps = conn.prepareStatement(sql);
            for (int i = 0; i < params.length; i++) {
                ps.setString(i + 1, params[i]);
            }
            rs = ps.executeQuery();
            ResultSetMetaData meta = rs.getMetaData();
            int colCount = meta.getColumnCount();

            while (rs.next()) {
                Map<String, String> row = new HashMap<String, String>();
                for (int i = 1; i <= colCount; i++) {
                    String colName = meta.getColumnLabel(i).toLowerCase();
                    Object val = rs.getObject(i);
                    row.put(colName, val != null ? val.toString() : null);
                }
                results.add(row);
            }
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception ignored) {}
            if (ps != null) try { ps.close(); } catch (Exception ignored) {}
        }

        return results;
    }

    private String escapeHtml(String text) {
        if (text == null) return "";
        return text.replace("&", "&amp;").replace("<", "&lt;")
                .replace(">", "&gt;").replace("\"", "&quot;");
    }

    private void sendJson(HttpServletResponse response, boolean success, String message, String query)
            throws IOException {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("success", success);
        if (success) {
            result.put("response", message);
        } else {
            result.put("error", message);
        }
        if (query != null) result.put("query", query);

        Gson gson = new Gson();
        response.getWriter().write(gson.toJson(result));
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect("pages/module.jsp?but=chatbot/alumni-chat.jsp");
    }
}
