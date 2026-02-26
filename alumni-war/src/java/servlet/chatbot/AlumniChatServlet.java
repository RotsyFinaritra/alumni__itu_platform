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
            } else if (matchesEvenement(q)) {
                htmlResponse = rechercherEvenements(conn, q);
            } else if (matchesSuggestionConnexion(q)) {
                int userId = getUserIdFromSession(request);
                htmlResponse = suggererConnexions(conn, userId);
            } else if (matchesPublication(q)) {
                htmlResponse = rechercherPublications(conn, q);
            } else if (matchesParcours(q)) {
                htmlResponse = analyserParcours(conn, q);
            } else if (matchesNavigation(q)) {
                htmlResponse = aiderNavigation(q);
            } else if (matchesExport(q)) {
                htmlResponse = genererExport(conn, q, request);
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

    private boolean matchesEvenement(String q) {
        return q.contains("evenement") || q.contains("calendrier") || q.contains("agenda")
                || q.contains("programme") || q.contains("activite") || q.contains("ce mois")
                || q.contains("cette semaine") || q.contains("prochainement") || q.contains("prevu");
    }

    private boolean matchesSuggestionConnexion(String q) {
        return (q.contains("suggere") || q.contains("recommande") || q.contains("trouve"))
                && (q.contains("alumni") || q.contains("contacts") || q.contains("reseau")
                || q.contains("connexion") || q.contains("dans mon domaine") || q.contains("m'aider"));
    }

    private boolean matchesPublication(String q) {
        return q.contains("publication") || q.contains("post") || q.contains("article")
                || q.contains("offre d'emploi") || q.contains("stage") || q.contains("recrute")
                || q.contains("dernier") || q.contains("recent") || q.contains("actualite");
    }

    private boolean matchesParcours(String q) {
        return (q.contains("parcours") || q.contains("carriere") || q.contains("evolution")
                || q.contains("typique") || q.contains("apres") || q.contains("devenir"))
                && (q.contains("diplome") || q.contains("sortie") || q.contains("promotion"));
    }

    private boolean matchesNavigation(String q) {
        return (q.contains("comment") || q.contains("ou") || q.contains("aide"))
                && (q.contains("creer") || q.contains("modifier") || q.contains("signaler")
                || q.contains("profil") || q.contains("publication") || q.contains("menu"));
    }

    private boolean matchesExport(String q) {
        return q.contains("export") || q.contains("telecharge") || q.contains("csv")
                || q.contains("excel") || q.contains("rapport") || q.contains("genere");
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

    // ========== NOUVELLES FONCTIONNALITES ==========

    /**
     * Recherche des evenements du calendrier scolaire
     */
    private String rechercherEvenements(Connection conn, String question) throws Exception {
        StringBuilder sb = new StringBuilder();
        
        // Detecter la periode
        String whereClause = "";
        String periodeTitre = "Prochains evenements";
        
        if (question.contains("ce mois") || question.contains("du mois")) {
            whereClause = " AND EXTRACT(MONTH FROM date_debut) = EXTRACT(MONTH FROM CURRENT_DATE) " +
                         "AND EXTRACT(YEAR FROM date_debut) = EXTRACT(YEAR FROM CURRENT_DATE)";
            periodeTitre = "Evenements de ce mois";
        } else if (question.contains("cette semaine")) {
            whereClause = " AND date_debut >= CURRENT_DATE AND date_debut < CURRENT_DATE + INTERVAL '7 days'";
            periodeTitre = "Evenements de cette semaine";
        } else if (question.contains("aujourd'hui") || question.contains("auj")) {
            whereClause = " AND date_debut = CURRENT_DATE";
            periodeTitre = "Evenements d'aujourd'hui";
        } else {
            whereClause = " AND date_debut >= CURRENT_DATE";
        }
        
        // Detecter si c'est pour une promotion specifique
        String promoKeyword = extractKeyword(question, new String[]{"promotion", "promo"});
        if (promoKeyword != null && !promoKeyword.trim().isEmpty()) {
            List<Map<String, String>> promos = executeSearch(conn,
                "SELECT id FROM promotion WHERE LOWER(libelle) LIKE LOWER(?)", 
                "%" + promoKeyword + "%");
            if (!promos.isEmpty()) {
                whereClause += " AND idpromotion = '" + promos.get(0).get("id") + "'";
                periodeTitre += " - Promotion " + promoKeyword;
            }
        }
        
        List<Map<String, String>> events = executeSearch(conn,
            "SELECT c.titre, c.description, c.date_debut, c.date_fin, c.heure_debut, c.heure_fin, " +
            "c.couleur, COALESCE(p.libelle || ' (' || p.annee || ')', 'Tous') AS promotion " +
            "FROM calendrier_scolaire c LEFT JOIN promotion p ON c.idpromotion = p.id " +
            "WHERE 1=1 " + whereClause + " ORDER BY c.date_debut LIMIT 20");
        
        sb.append("<h4><i class='fa fa-calendar'></i> ").append(periodeTitre).append("</h4>");
        
        if (events.isEmpty()) {
            sb.append("<p class='text-muted'>Aucun evenement trouve pour cette periode.</p>");
        } else {
            sb.append("<div class='event-results'>");
            for (Map<String, String> ev : events) {
                String couleur = ev.get("couleur") != null ? ev.get("couleur") : "#0095DA";
                sb.append("<div class='event-item' style='border-left: 4px solid ").append(couleur).append(";'>");
                sb.append("<h5 style='color: ").append(couleur).append(";'>").append(escapeHtml(ev.get("titre"))).append("</h5>");
                sb.append("<p><i class='fa fa-calendar-o'></i> ")
                  .append(ev.get("date_debut"));
                if (ev.get("date_fin") != null && !ev.get("date_fin").equals(ev.get("date_debut"))) {
                    sb.append(" au ").append(ev.get("date_fin"));
                }
                if (ev.get("heure_debut") != null) {
                    sb.append(" <i class='fa fa-clock-o'></i> ").append(ev.get("heure_debut"));
                    if (ev.get("heure_fin") != null) {
                        sb.append("-").append(ev.get("heure_fin"));
                    }
                }
                sb.append("</p>");
                if (ev.get("promotion") != null) {
                    sb.append("<p><i class='fa fa-users'></i> ").append(ev.get("promotion")).append("</p>");
                }
                if (ev.get("description") != null && !ev.get("description").isEmpty()) {
                    sb.append("<p class='text-muted'>").append(escapeHtml(ev.get("description"))).append("</p>");
                }
                sb.append("</div>");
            }
            sb.append("</div>");
        }
        
        return sb.toString();
    }

    /**
     * Suggere des connexions basees sur le profil utilisateur
     */
    private String suggererConnexions(Connection conn, int userId) throws Exception {
        StringBuilder sb = new StringBuilder();
        sb.append("<h4><i class='fa fa-users'></i> Suggestions de connexions</h4>");
        
        if (userId <= 0) {
            sb.append("<p class='text-warning'>Connectez-vous pour obtenir des suggestions personnalisees.</p>");
            return sb.toString();
        }
        
        // Obtenir le profil de l'utilisateur
        List<Map<String, String>> userProfile = executeSearch(conn,
            "SELECT idpromotion FROM utilisateur WHERE refuser = ?", String.valueOf(userId));
        
        if (userProfile.isEmpty()) {
            sb.append("<p class='text-muted'>Profil non trouve.</p>");
            return sb.toString();
        }
        
        String idPromotion = userProfile.get(0).get("idpromotion");
        
        // Suggestions 1 : Meme promotion
        sb.append("<h5>Alumni de votre promotion</h5>");
        List<Map<String, String>> samePromo = executeSearch(conn,
            "SELECT u.refuser, u.nomuser, u.prenom, u.mail, p.libelle AS promotion " +
            "FROM utilisateur u LEFT JOIN promotion p ON u.idpromotion = p.id " +
            "WHERE u.idpromotion = ? AND u.refuser != ? LIMIT 5",
            idPromotion, String.valueOf(userId));
        
        if (!samePromo.isEmpty()) {
            sb.append("<ul class='alumni-suggestions'>");
            for (Map<String, String> alum : samePromo) {
                sb.append("<li><strong>").append(escapeHtml(alum.get("nomuser")))
                  .append(" ").append(escapeHtml(alum.get("prenom"))).append("</strong>");
                if (alum.get("mail") != null) {
                    sb.append(" - ").append(escapeHtml(alum.get("mail")));
                }
                sb.append("</li>");
            }
            sb.append("</ul>");
        } else {
            sb.append("<p class='text-muted'>Aucun alumni de votre promotion trouve.</p>");
        }
        
        // Suggestions 2 : Domaines similaires (basé sur les experiences)
        sb.append("<h5>Alumni dans des domaines similaires</h5>");
        List<Map<String, String>> sameDomain = executeSearch(conn,
            "SELECT DISTINCT u.refuser, u.nomuser, u.prenom, u.mail, d.libelle AS domaine " +
            "FROM experience ex1 " +
            "JOIN experience ex2 ON ex1.iddomaine = ex2.iddomaine " +
            "JOIN utilisateur u ON ex2.idutilisateur = u.refuser " +
            "LEFT JOIN domaine d ON ex2.iddomaine = d.id " +
            "WHERE ex1.idutilisateur = ? AND ex2.idutilisateur != ? LIMIT 5",
            String.valueOf(userId), String.valueOf(userId));
        
        if (!sameDomain.isEmpty()) {
            sb.append("<ul class='alumni-suggestions'>");
            for (Map<String, String> alum : sameDomain) {
                sb.append("<li><strong>").append(escapeHtml(alum.get("nomuser")))
                  .append(" ").append(escapeHtml(alum.get("prenom"))).append("</strong>");
                if (alum.get("domaine") != null) {
                    sb.append(" (").append(escapeHtml(alum.get("domaine"))).append(")");
                }
                sb.append("</li>");
            }
            sb.append("</ul>");
        } else {
            sb.append("<p class='text-muted'>Aucun alumni dans des domaines similaires.</p>");
        }
        
        // Suggestions 3 : Entreprises d'interet
        sb.append("<h5>Alumni dans des entreprises cibles</h5>");
        List<Map<String, String>> topCompanies = executeSearch(conn,
            "SELECT u.nomuser, u.prenom, u.mail, e.libelle AS entreprise, ex.poste " +
            "FROM experience ex " +
            "JOIN utilisateur u ON ex.idutilisateur = u.refuser " +
            "JOIN entreprise e ON ex.identreprise = e.id " +
            "WHERE e.id IN (SELECT identreprise FROM experience GROUP BY identreprise ORDER BY COUNT(*) DESC LIMIT 5) " +
            "AND u.refuser != ? AND ex.datefin IS NULL " +
            "ORDER BY e.libelle LIMIT 10",
            String.valueOf(userId));
        
        if (!topCompanies.isEmpty()) {
            sb.append("<ul class='alumni-suggestions'>");
            for (Map<String, String> alum : topCompanies) {
                sb.append("<li><strong>").append(escapeHtml(alum.get("nomuser")))
                  .append(" ").append(escapeHtml(alum.get("prenom"))).append("</strong>");
                sb.append(" - ").append(escapeHtml(alum.get("entreprise")));
                if (alum.get("poste") != null) {
                    sb.append(" (").append(escapeHtml(alum.get("poste"))).append(")");
                }
                sb.append("</li>");
            }
            sb.append("</ul>");
        } else {
            sb.append("<p class='text-muted'>Aucune suggestion pour le moment.</p>");
        }
        
        return sb.toString();
    }

    /**
     * Recherche dans les publications
     */
    private String rechercherPublications(Connection conn, String question) throws Exception {
        StringBuilder sb = new StringBuilder();
        
        String typeFilter = "";
        String titre = "Publications recentes";
        
        if (question.contains("offre") || question.contains("emploi") || question.contains("recrute")) {
            typeFilter = " AND p.type_publication = 'TYP00002'";
            titre = "Offres d'emploi";
        } else if (question.contains("stage")) {
            typeFilter = " AND p.type_publication = 'TYP00001'";
            titre = "Offres de stage";
        } else if (question.contains("evenement")) {
            typeFilter = " AND p.type_publication = 'TYP00003'";
            titre = "Evenements";
        }
        
        // Extraire mots-cles pour recherche
        String[] words = question.split(" ");
        String searchTerm = "";
        for (String w : words) {
            if (w.length() > 4 && !w.equals("publication") && !w.equals("offre") 
                && !w.equals("stage") && !w.equals("emploi")) {
                searchTerm = w;
                break;
            }
        }
        
        String searchFilter = "";
        if (!searchTerm.isEmpty()) {
            searchFilter = " AND (LOWER(p.titre) LIKE LOWER('%" + searchTerm + "%') " +
                          "OR LOWER(p.contenu) LIKE LOWER('%" + searchTerm + "%'))";
            titre += " - \"" + searchTerm + "\"";
        }
        
        List<Map<String, String>> pubs = executeSearch(conn,
            "SELECT p.id, p.titre, p.contenu, p.created_at, p.type_publication, " +
            "u.nomuser, u.prenom, tp.libelle AS type " +
            "FROM posts p " +
            "JOIN utilisateur u ON p.auteur_id = u.refuser " +
            "LEFT JOIN type_publication tp ON p.type_publication = tp.id " +
            "WHERE p.supprime = false " + typeFilter + searchFilter +
            " ORDER BY p.created_at DESC LIMIT 15");
        
        sb.append("<h4><i class='fa fa-newspaper-o'></i> ").append(titre).append("</h4>");
        
        if (pubs.isEmpty()) {
            sb.append("<p class='text-muted'>Aucune publication trouvee.</p>");
        } else {
            sb.append("<div class='publication-results'>");
            for (Map<String, String> pub : pubs) {
                sb.append("<div class='pub-item'>");
                sb.append("<h5>").append(escapeHtml(pub.get("titre"))).append("</h5>");
                sb.append("<p class='text-muted'><i class='fa fa-user'></i> ")
                  .append(escapeHtml(pub.get("prenom"))).append(" ")
                  .append(escapeHtml(pub.get("nomuser")));
                if (pub.get("type") != null) {
                    sb.append(" · ").append(escapeHtml(pub.get("type")));
                }
                sb.append("</p>");
                String contenu = pub.get("contenu");
                if (contenu != null && contenu.length() > 200) {
                    contenu = contenu.substring(0, 200) + "...";
                }
                sb.append("<p>").append(escapeHtml(contenu)).append("</p>");
                sb.append("<p class='text-muted'><i class='fa fa-clock-o'></i> ")
                  .append(pub.get("created_at")).append("</p>");
                sb.append("</div>");
            }
            sb.append("</div>");
        }
        
        return sb.toString();
    }

    /**
     * Analyse des parcours professionnels
     */
    private String analyserParcours(Connection conn, String question) throws Exception {
        StringBuilder sb = new StringBuilder();
        
        String promoKeyword = extractKeyword(question, new String[]{"promotion", "promo", "diplome", "sortie"});
        
        if (promoKeyword != null && !promoKeyword.trim().isEmpty()) {
            // Analyse pour une promotion specifique
            List<Map<String, String>> promo = executeSearch(conn,
                "SELECT id, libelle, annee FROM promotion WHERE LOWER(libelle) LIKE LOWER(?) OR CAST(annee AS VARCHAR) = ?",
                "%" + promoKeyword + "%", promoKeyword);
            
            if (!promo.isEmpty()) {
                String idPromo = promo.get(0).get("id");
                String libellePromo = promo.get(0).get("libelle") + " (" + promo.get(0).get("annee") + ")";
                
                sb.append("<h4><i class='fa fa-line-chart'></i> Parcours - ").append(libellePromo).append("</h4>");
                
                // Nombre d'alumni
                List<Map<String, String>> count = executeSearch(conn,
                    "SELECT COUNT(*) AS total FROM utilisateur WHERE idpromotion = ?", idPromo);
                sb.append("<p><strong>").append(count.get(0).get("total")).append(" alumni</strong></p>");
                
                // Top entreprises
                List<Map<String, String>> topEntreprises = executeSearch(conn,
                    "SELECT e.libelle, COUNT(DISTINCT ex.idutilisateur) AS nb " +
                    "FROM experience ex " +
                    "JOIN utilisateur u ON ex.idutilisateur = u.refuser " +
                    "JOIN entreprise e ON ex.identreprise = e.id " +
                    "WHERE u.idpromotion = ? " +
                    "GROUP BY e.libelle ORDER BY nb DESC LIMIT 5", idPromo);
                
                if (!topEntreprises.isEmpty()) {
                    sb.append("<h5>Top 5 entreprises</h5><ul>");
                    for (Map<String, String> ent : topEntreprises) {
                        sb.append("<li><strong>").append(escapeHtml(ent.get("libelle")))
                          .append("</strong> (").append(ent.get("nb")).append(" alumni)</li>");
                    }
                    sb.append("</ul>");
                }
                
                // Domaines principaux
                List<Map<String, String>> topDomaines = executeSearch(conn,
                    "SELECT d.libelle, COUNT(DISTINCT ex.idutilisateur) AS nb " +
                    "FROM experience ex " +
                    "JOIN utilisateur u ON ex.idutilisateur = u.refuser " +
                    "JOIN domaine d ON ex.iddomaine = d.id " +
                    "WHERE u.idpromotion = ? " +
                    "GROUP BY d.libelle ORDER BY nb DESC LIMIT 5", idPromo);
                
                if (!topDomaines.isEmpty()) {
                    sb.append("<h5>Principaux domaines</h5><ul>");
                    for (Map<String, String> dom : topDomaines) {
                        sb.append("<li><strong>").append(escapeHtml(dom.get("libelle")))
                          .append("</strong> (").append(dom.get("nb")).append(" alumni)</li>");
                    }
                    sb.append("</ul>");
                }
                
                // Postes courants
                List<Map<String, String>> topPostes = executeSearch(conn,
                    "SELECT ex.poste, COUNT(*) AS nb " +
                    "FROM experience ex " +
                    "JOIN utilisateur u ON ex.idutilisateur = u.refuser " +
                    "WHERE u.idpromotion = ? AND ex.poste IS NOT NULL AND ex.datefin IS NULL " +
                    "GROUP BY ex.poste ORDER BY nb DESC LIMIT 5", idPromo);
                
                if (!topPostes.isEmpty()) {
                    sb.append("<h5>Postes actuels</h5><ul>");
                    for (Map<String, String> poste : topPostes) {
                        sb.append("<li><strong>").append(escapeHtml(poste.get("poste")))
                          .append("</strong> (").append(poste.get("nb")).append(")</li>");
                    }
                    sb.append("</ul>");
                }
            } else {
                sb.append("<p class='text-warning'>Promotion non trouvee.</p>");
            }
        } else {
            // Parcours general
            sb.append("<h4><i class='fa fa-line-chart'></i> Analyse des parcours ITU</h4>");
            
            sb.append("<h5>Secteurs les plus prises</h5>");
            List<Map<String, String>> secteurs = executeSearch(conn,
                "SELECT d.libelle, COUNT(DISTINCT ex.idutilisateur) AS nb " +
                "FROM experience ex " +
                "JOIN domaine d ON ex.iddomaine = d.id " +
                "GROUP BY d.libelle ORDER BY nb DESC LIMIT 8");
            
            if (!secteurs.isEmpty()) {
                sb.append("<ul>");
                for (Map<String, String> s : secteurs) {
                    sb.append("<li><strong>").append(escapeHtml(s.get("libelle")))
                      .append("</strong> : ").append(s.get("nb")).append(" alumni</li>");
                }
                sb.append("</ul>");
            }
            
            sb.append("<h5>Entreprises qui recrutent le plus d'ITU</h5>");
            List<Map<String, String>> employeurs = executeSearch(conn,
                "SELECT e.libelle, COUNT(DISTINCT ex.idutilisateur) AS nb " +
                "FROM experience ex " +
                "JOIN entreprise e ON ex.identreprise = e.id " +
                "GROUP BY e.libelle ORDER BY nb DESC LIMIT 10");
            
            if (!employeurs.isEmpty()) {
                sb.append("<ul>");
                for (Map<String, String> emp : employeurs) {
                    sb.append("<li><strong>").append(escapeHtml(emp.get("libelle")))
                      .append("</strong> : ").append(emp.get("nb")).append(" alumni</li>");
                }
                sb.append("</ul>");
            }
        }
        
        return sb.toString();
    }

    /**
     * Aide a la navigation
     */
    private String aiderNavigation(String question) {
        StringBuilder sb = new StringBuilder();
        sb.append("<h4><i class='fa fa-question-circle'></i> Aide a la navigation</h4>");
        
        if (question.contains("creer") || question.contains("publier")) {
            if (question.contains("publication") || question.contains("post")) {
                sb.append("<h5>Creer une publication</h5>");
                sb.append("<ol>");
                sb.append("<li>Cliquez sur <strong>Publications</strong> dans le menu</li>");
                sb.append("<li>Cliquez sur le bouton <strong>+ Nouvelle publication</strong></li>");
                sb.append("<li>Choisissez le type (Stage, Emploi, Evenement, Actualite)</li>");
                sb.append("<li>Remplissez le titre et le contenu</li>");
                sb.append("<li>Ajoutez des topics (facultatif)</li>");
                sb.append("<li>Cliquez sur <strong>Publier</strong></li>");
                sb.append("</ol>");
            }
        } else if (question.contains("modifier") || question.contains("editer")) {
            if (question.contains("profil")) {
                sb.append("<h5>Modifier votre profil</h5>");
                sb.append("<ol>");
                sb.append("<li>Cliquez sur votre nom en haut a droite</li>");
                sb.append("<li>Selectionnez <strong>Mon profil</strong></li>");
                sb.append("<li>Cliquez sur <strong>Modifier le profil</strong></li>");
                sb.append("<li>Modifiez vos informations</li>");
                sb.append("<li>Cliquez sur <strong>Enregistrer</strong></li>");
                sb.append("</ol>");
            } else if (question.contains("experience")) {
                sb.append("<h5>Modifier une experience</h5>");
                sb.append("<ol>");
                sb.append("<li>Allez sur <strong>Mon profil</strong></li>");
                sb.append("<li>Section <strong>Experiences professionnelles</strong></li>");
                sb.append("<li>Cliquez sur l'icone <i class='fa fa-edit'></i> de l'experience</li>");
                sb.append("<li>Modifiez les informations</li>");
                sb.append("<li>Cliquez sur <strong>Enregistrer</strong></li>");
                sb.append("</ol>");
            }
        } else if (question.contains("signaler") || question.contains("report")) {
            sb.append("<h5>Signaler un contenu</h5>");
            sb.append("<ol>");
            sb.append("<li>Ouvrez la publication concernee</li>");
            sb.append("<li>Cliquez sur le bouton <strong>Signaler</strong></li>");
            sb.append("<li>Selectionnez le motif du signalement</li>");
            sb.append("<li>Ajoutez un commentaire (facultatif)</li>");
            sb.append("<li>Cliquez sur <strong>Envoyer</strong></li>");
            sb.append("</ol>");
        } else if (question.contains("evenement") || question.contains("calendrier")) {
            sb.append("<h5>Consulter le calendrier</h5>");
            sb.append("<ol>");
            sb.append("<li>Cliquez sur <strong>Calendrier</strong> dans le menu</li>");
            sb.append("<li>Naviguez entre les mois avec les fleches</li>");
            sb.append("<li>Cliquez sur un jour pour voir les evenements</li>");
            sb.append("<li>Utilisez le filtre pour afficher une promotion specifique</li>");
            sb.append("</ol>");
            sb.append("<p class='text-muted'>Note: Seuls les administrateurs peuvent creer des evenements.</p>");
        } else {
            sb.append("<p>Je peux vous aider avec :</p>");
            sb.append("<ul>");
            sb.append("<li><strong>Creer une publication</strong></li>");
            sb.append("<li><strong>Modifier votre profil</strong></li>");
            sb.append("<li><strong>Signaler un contenu</strong></li>");
            sb.append("<li><strong>Consulter le calendrier</strong></li>");
            sb.append("<li><strong>Gerer vos experiences</strong></li>");
            sb.append("</ul>");
            sb.append("<p>Posez une question plus specifique pour obtenir de l'aide detaillee !</p>");
        }
        
        return sb.toString();
    }

    /**
     * Generation d'export de donnees
     */
    private String genererExport(Connection conn, String question, HttpServletRequest request) throws Exception {
        StringBuilder sb = new StringBuilder();
        sb.append("<h4><i class='fa fa-download'></i> Export de donnees</h4>");
        
        // Determiner le type d'export
        String exportType = "alumni";
        if (question.contains("entreprise")) {
            exportType = "entreprises";
        } else if (question.contains("experience")) {
            exportType = "experiences";
        } else if (question.contains("publication")) {
            exportType = "publications";
        } else if (question.contains("statistique") || question.contains("rapport")) {
            exportType = "statistiques";
        }
        
        sb.append("<p>Generation d'un export <strong>").append(exportType).append("</strong> en cours...</p>");
        sb.append("<div class='alert alert-info'>");
        sb.append("<i class='fa fa-info-circle'></i> ");
        sb.append("Pour generer un export CSV, utilisez le module d'export dans le menu principal. ");
        sb.append("Vous pourrez filtrer les donnees et choisir les colonnes a exporter.");
        sb.append("</div>");
        
        // Lien vers le module d'export (à créer)
        String lien = (String) request.getSession().getValue("lien");
        if (lien != null) {
            sb.append("<p><a href='").append(lien).append("?but=export/export-").append(exportType)
              .append(".jsp' class='btn btn-primary'><i class='fa fa-download'></i> Acceder au module d'export</a></p>");
        }
        
        // Apercu des données
        sb.append("<h5>Apercu des donnees disponibles :</h5>");
        
        if (exportType.equals("alumni")) {
            List<Map<String, String>> count = executeSearch(conn,
                "SELECT COUNT(*) AS total FROM utilisateur");
            sb.append("<p><strong>").append(count.get(0).get("total")).append(" alumni</strong> dans la base</p>");
            
            List<Map<String, String>> byPromo = executeSearch(conn,
                "SELECT p.libelle, p.annee, COUNT(u.refuser) AS nb " +
                "FROM promotion p " +
                "LEFT JOIN utilisateur u ON p.id = u.idpromotion " +
                "GROUP BY p.libelle, p.annee ORDER BY p.annee DESC LIMIT 10");
            
            if (!byPromo.isEmpty()) {
                sb.append("<ul>");
                for (Map<String, String> p : byPromo) {
                    sb.append("<li>").append(escapeHtml(p.get("libelle")))
                      .append(" (").append(p.get("annee")).append(") : ")
                      .append(p.get("nb")).append(" alumni</li>");
                }
                sb.append("</ul>");
            }
        }
        
        return sb.toString();
    }

    /**
     * Recupere l'ID utilisateur depuis la session
     */
    private int getUserIdFromSession(HttpServletRequest request) {
        try {
            Object userObj = request.getSession().getValue("u");
            if (userObj != null) {
                // Utiliser reflection pour obtenir l'ID
                java.lang.reflect.Method getUser = userObj.getClass().getMethod("getUser");
                Object user = getUser.invoke(userObj);
                java.lang.reflect.Method getRefuser = user.getClass().getMethod("getRefuser");
                return (Integer) getRefuser.invoke(user);
            }
        } catch (Exception e) {
            System.out.println("[AlumniChat] Erreur recuperation userId: " + e.getMessage());
        }
        return -1;
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
