package uploadbean;

import bean.*;
import affichage.PageInsert;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import user.UserEJB;
import utilitaire.UtilDB;
import utilitaire.Utilitaire;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;

/**
 * Servlet pour gérer les formulaires d'insertion et modification des postes emploi/stage
 * avec support des uploads de fichiers multipart
 */
@WebServlet("/CarriereFormServlet")
public class CarriereFormServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private ServletFileUpload uploader = null;

    private void createDir(String path) {
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }
    }

    @Override
    public void init() {
        DiskFileItemFactory fileFactory = new DiskFileItemFactory();
        File filesDir = (File) getServletContext().getAttribute(StringUtil.FILES_DIR_FILE);
        if (filesDir != null) {
            fileFactory.setRepository(filesDir);
        }
        this.uploader = new ServletFileUpload(fileFactory);
        // Limite à 50 Mo
        this.uploader.setFileSizeMax(50 * 1024 * 1024);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        Connection conn = null;
        String lien = "pages/module.jsp";
        String bute = "carriere/carriere-accueil.jsp";
        String postId = null;

        try {
            UserEJB u = (UserEJB) request.getSession().getAttribute("u");
            if (u == null) {
                throw new ServletException("Session expirée");
            }
            lien = (String) request.getSession().getAttribute("lien");
            if (lien == null) lien = "pages/module.jsp";

            // Récupérer les paramètres (multipart ou standard)
            HashMap<String, String> params = new HashMap<>();
            List<FileItem> uploadedFiles = new ArrayList<>();

            if (ServletFileUpload.isMultipartContent(request)) {
                List<FileItem> fileItemsList = uploader.parseRequest(request);
                for (FileItem fileItem : fileItemsList) {
                    if (fileItem.isFormField()) {
                        String fieldName = fileItem.getFieldName();
                        String fieldValue = fileItem.getString("UTF-8");
                        // Gérer les champs multiples (competences[])
                        if (params.containsKey(fieldName)) {
                            params.put(fieldName, params.get(fieldName) + "," + fieldValue);
                        } else {
                            params.put(fieldName, fieldValue);
                        }
                    } else if (fileItem.getName() != null && !fileItem.getName().isEmpty() && fileItem.getSize() > 0) {
                        uploadedFiles.add(fileItem);
                    }
                }
            } else {
                // Formulaire standard (non-multipart)
                for (String paramName : request.getParameterMap().keySet()) {
                    String[] values = request.getParameterValues(paramName);
                    if (values != null) {
                        params.put(paramName, String.join(",", values));
                    }
                }
            }

            String acte = params.get("acte");
            postId = params.get("id");
            bute = params.get("bute");
            if (bute == null || bute.isEmpty()) bute = "carriere/carriere-accueil.jsp";

            conn = new UtilDB().GetConn();
            conn.setAutoCommit(false);

            // =====================================================================
            // INSERT EMPLOI
            // =====================================================================
            if ("insertEmploi".equalsIgnoreCase(acte)) {
                postId = insertEmploi(conn, u, params);
                saveUploadedFiles(conn, postId, "emploi", uploadedFiles, params);
                bute = "carriere/emploi-fiche.jsp";
                conn.commit();
            }
            // =====================================================================
            // INSERT STAGE
            // =====================================================================
            else if ("insertStage".equalsIgnoreCase(acte)) {
                postId = insertStage(conn, u, params);
                saveUploadedFiles(conn, postId, "stage", uploadedFiles, params);
                bute = "carriere/stage-fiche.jsp";
                conn.commit();
            }
            // =====================================================================
            // UPDATE EMPLOI
            // =====================================================================
            else if ("updateEmploi".equalsIgnoreCase(acte)) {
                updateEmploi(conn, u, params, postId);
                saveUploadedFiles(conn, postId, "emploi", uploadedFiles, params);
                bute = "carriere/emploi-fiche.jsp";
                conn.commit();
            }
            // =====================================================================
            // UPDATE STAGE
            // =====================================================================
            else if ("updateStage".equalsIgnoreCase(acte)) {
                updateStage(conn, u, params, postId);
                saveUploadedFiles(conn, postId, "stage", uploadedFiles, params);
                bute = "carriere/stage-fiche.jsp";
                conn.commit();
            }
            else {
                throw new ServletException("Action non reconnue: " + acte);
            }

            // Redirection vers la page de fiche
            response.sendRedirect(lien + "?but=" + bute + "&id=" + postId);

        } catch (Exception e) {
            e.printStackTrace();
            if (conn != null) {
                try { conn.rollback(); } catch (Exception ignored) {}
            }
            // Redirection avec message d'erreur
            String errorMsg = e.getMessage() != null ? e.getMessage() : "Erreur inconnue";
            response.sendRedirect(lien + "?but=" + bute + "&error=" + java.net.URLEncoder.encode(errorMsg, "UTF-8"));
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (Exception ignored) {}
            }
        }
    }

    /**
     * Insère un nouveau poste emploi
     */
    private String insertEmploi(Connection conn, UserEJB u, HashMap<String, String> params) throws Exception {
        // 1. Créer le Post parent
        Post post = new Post();
        post.construirePK(conn);
        post.setIdtypepublication("TYP00002"); // Emploi
        post.setIdstatutpublication("STAT00002");
        post.setIdvisibilite("VISI00001");
        post.setIdutilisateur(Integer.parseInt(u.getUser().getTuppleID()));
        post.setContenu(params.get("contenu") != null ? params.get("contenu") : "");
        post.setEpingle(0);
        post.setSupprime(0);
        post.setNb_likes(0);
        post.setNb_commentaires(0);
        post.setNb_partages(0);
        post.insertToTable(conn);
        String postId = post.getTuppleID();

        // 2. Créer PostEmploi
        PostEmploi emploi = new PostEmploi();
        emploi.setPost_id(postId);
        emploi.setIdentreprise(params.get("identreprise"));
        emploi.setPoste(params.get("poste"));
        emploi.setType_contrat(params.get("type_contrat"));
        emploi.setLocalisation(params.get("localisation"));
        
        if (params.get("salaire_min") != null && !params.get("salaire_min").isEmpty()) {
            try { emploi.setSalaire_min(Double.parseDouble(params.get("salaire_min"))); } catch (Exception ignored) {}
        }
        if (params.get("salaire_max") != null && !params.get("salaire_max").isEmpty()) {
            try { emploi.setSalaire_max(Double.parseDouble(params.get("salaire_max"))); } catch (Exception ignored) {}
        }
        
        emploi.setDevise(params.get("devise") != null ? params.get("devise") : "MGA");
        emploi.setExperience_requise(params.get("experience_requise"));
        emploi.setNiveau_etude_requis(params.get("niveau_etude_requis"));
        
        if (params.get("teletravail_possible") != null && !params.get("teletravail_possible").isEmpty()) {
            try { emploi.setTeletravail_possible(Integer.parseInt(params.get("teletravail_possible"))); } catch (Exception ignored) {}
        }
        
        if (params.get("date_limite") != null && !params.get("date_limite").isEmpty()) {
            try { emploi.setDate_limite(java.sql.Date.valueOf(params.get("date_limite"))); } catch (Exception ignored) {}
        }
        
        emploi.setContact_email(params.get("contact_email"));
        emploi.setContact_tel(params.get("contact_tel"));
        emploi.setLien_candidature(params.get("lien_candidature"));
        emploi.insertToTable(conn);

        // 3. Insérer les compétences
        insertCompetences(conn, postId, params.get("competences[]"), "emploi");

        return postId;
    }

    /**
     * Insère un nouveau poste stage
     */
    private String insertStage(Connection conn, UserEJB u, HashMap<String, String> params) throws Exception {
        // 1. Créer le Post parent
        Post post = new Post();
        post.construirePK(conn);
        post.setIdtypepublication("TYP00001"); // Stage
        post.setIdstatutpublication("STAT00002");
        post.setIdvisibilite("VISI00001");
        post.setIdutilisateur(Integer.parseInt(u.getUser().getTuppleID()));
        post.setContenu(params.get("contenu") != null ? params.get("contenu") : "");
        post.setEpingle(0);
        post.setSupprime(0);
        post.setNb_likes(0);
        post.setNb_commentaires(0);
        post.setNb_partages(0);
        post.insertToTable(conn);
        String postId = post.getTuppleID();

        // 2. Créer PostStage
        PostStage stage = new PostStage();
        stage.setPost_id(postId);
        stage.setIdentreprise(params.get("identreprise"));
        stage.setDuree(params.get("duree"));
        
        if (params.get("date_debut") != null && !params.get("date_debut").isEmpty()) {
            try { stage.setDate_debut(java.sql.Date.valueOf(params.get("date_debut"))); } catch (Exception ignored) {}
        }
        if (params.get("date_fin") != null && !params.get("date_fin").isEmpty()) {
            try { stage.setDate_fin(java.sql.Date.valueOf(params.get("date_fin"))); } catch (Exception ignored) {}
        }
        if (params.get("indemnite") != null && !params.get("indemnite").isEmpty()) {
            try { stage.setIndemnite(Double.parseDouble(params.get("indemnite"))); } catch (Exception ignored) {}
        }
        
        stage.setNiveau_etude_requis(params.get("niveau_etude_requis"));
        
        if (params.get("convention_requise") != null && !params.get("convention_requise").isEmpty()) {
            try { stage.setConvention_requise(Integer.parseInt(params.get("convention_requise"))); } catch (Exception ignored) {}
        }
        if (params.get("places_disponibles") != null && !params.get("places_disponibles").isEmpty()) {
            try { stage.setPlaces_disponibles(Integer.parseInt(params.get("places_disponibles"))); } catch (Exception ignored) {}
        } else {
            stage.setPlaces_disponibles(1);
        }
        
        stage.setContact_email(params.get("contact_email"));
        stage.setContact_tel(params.get("contact_tel"));
        stage.setLien_candidature(params.get("lien_candidature"));
        stage.insertToTable(conn);

        // 3. Insérer les compétences
        insertCompetences(conn, postId, params.get("competences[]"), "stage");

        return postId;
    }

    /**
     * Met à jour un poste emploi existant
     */
    private void updateEmploi(Connection conn, UserEJB u, HashMap<String, String> params, String postId) throws Exception {
        // 1. Update Post
        Post post = new Post();
        post.setId(postId);
        if (params.get("contenu") != null) {
            post.setContenu(params.get("contenu"));
        }
        post.updateToTable(conn, new String[]{"contenu"}, new String[]{post.getContenu()});

        // 2. Update PostEmploi
        String sql = "UPDATE post_emploi SET identreprise=?, poste=?, type_contrat=?, localisation=?, " +
                    "salaire_min=?, salaire_max=?, devise=?, experience_requise=?, niveau_etude_requis=?, " +
                    "teletravail_possible=?, date_limite=?, contact_email=?, contact_tel=?, lien_candidature=? " +
                    "WHERE post_id=?";
        
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, params.get("identreprise"));
        ps.setString(2, params.get("poste"));
        ps.setString(3, params.get("type_contrat"));
        ps.setString(4, params.get("localisation"));
        
        double salMin = 0, salMax = 0;
        try { salMin = Double.parseDouble(params.get("salaire_min")); } catch (Exception ignored) {}
        try { salMax = Double.parseDouble(params.get("salaire_max")); } catch (Exception ignored) {}
        ps.setDouble(5, salMin);
        ps.setDouble(6, salMax);
        
        ps.setString(7, params.get("devise") != null ? params.get("devise") : "MGA");
        ps.setString(8, params.get("experience_requise"));
        ps.setString(9, params.get("niveau_etude_requis"));
        
        int teletravail = 0;
        try { teletravail = Integer.parseInt(params.get("teletravail_possible")); } catch (Exception ignored) {}
        ps.setInt(10, teletravail);
        
        java.sql.Date dateLimite = null;
        if (params.get("date_limite") != null && !params.get("date_limite").isEmpty()) {
            try { dateLimite = java.sql.Date.valueOf(params.get("date_limite")); } catch (Exception ignored) {}
        }
        ps.setDate(11, dateLimite);
        
        ps.setString(12, params.get("contact_email"));
        ps.setString(13, params.get("contact_tel"));
        ps.setString(14, params.get("lien_candidature"));
        ps.setString(15, postId);
        ps.executeUpdate();
        ps.close();

        // 3. Gérer les compétences
        updateCompetences(conn, postId, params.get("competences[]"), "emploi");
    }

    /**
     * Met à jour un poste stage existant
     */
    private void updateStage(Connection conn, UserEJB u, HashMap<String, String> params, String postId) throws Exception {
        // 1. Update Post
        Post post = new Post();
        post.setId(postId);
        if (params.get("contenu") != null) {
            post.setContenu(params.get("contenu"));
        }
        post.updateToTable(conn, new String[]{"contenu"}, new String[]{post.getContenu()});

        // 2. Update PostStage
        String sql = "UPDATE post_stage SET identreprise=?, duree=?, date_debut=?, date_fin=?, " +
                    "indemnite=?, niveau_etude_requis=?, convention_requise=?, places_disponibles=?, " +
                    "contact_email=?, contact_tel=?, lien_candidature=? WHERE post_id=?";
        
        PreparedStatement ps = conn.prepareStatement(sql);
        ps.setString(1, params.get("identreprise"));
        ps.setString(2, params.get("duree"));
        
        java.sql.Date dateDebut = null, dateFin = null;
        if (params.get("date_debut") != null && !params.get("date_debut").isEmpty()) {
            try { dateDebut = java.sql.Date.valueOf(params.get("date_debut")); } catch (Exception ignored) {}
        }
        if (params.get("date_fin") != null && !params.get("date_fin").isEmpty()) {
            try { dateFin = java.sql.Date.valueOf(params.get("date_fin")); } catch (Exception ignored) {}
        }
        ps.setDate(3, dateDebut);
        ps.setDate(4, dateFin);
        
        double indemnite = 0;
        try { indemnite = Double.parseDouble(params.get("indemnite")); } catch (Exception ignored) {}
        ps.setDouble(5, indemnite);
        
        ps.setString(6, params.get("niveau_etude_requis"));
        
        int convention = 0, places = 1;
        try { convention = Integer.parseInt(params.get("convention_requise")); } catch (Exception ignored) {}
        try { places = Integer.parseInt(params.get("places_disponibles")); } catch (Exception ignored) {}
        ps.setInt(7, convention);
        ps.setInt(8, places);
        
        ps.setString(9, params.get("contact_email"));
        ps.setString(10, params.get("contact_tel"));
        ps.setString(11, params.get("lien_candidature"));
        ps.setString(12, postId);
        ps.executeUpdate();
        ps.close();

        // 3. Gérer les compétences
        updateCompetences(conn, postId, params.get("competences[]"), "stage");
    }

    /**
     * Insère les compétences pour un poste
     */
    private void insertCompetences(Connection conn, String postId, String competencesStr, String type) throws Exception {
        if (competencesStr == null || competencesStr.isEmpty()) return;
        
        String[] competences = competencesStr.split(",");
        for (String idComp : competences) {
            if (idComp != null && !idComp.trim().isEmpty()) {
                if ("emploi".equals(type)) {
                    EmploiCompetence ec = new EmploiCompetence();
                    ec.setPost_id(postId);
                    ec.setIdcompetence(idComp.trim());
                    ec.insertToTable(conn);
                } else {
                    StageCompetence sc = new StageCompetence();
                    sc.setPost_id(postId);
                    sc.setIdcompetence(idComp.trim());
                    sc.insertToTable(conn);
                }
            }
        }
    }

    /**
     * Met à jour les compétences (supprime les anciennes et insère les nouvelles)
     */
    private void updateCompetences(Connection conn, String postId, String competencesStr, String type) throws Exception {
        // Supprimer les anciennes
        String tableName = "emploi".equals(type) ? "emploi_competence" : "stage_competence";
        PreparedStatement ps = conn.prepareStatement("DELETE FROM " + tableName + " WHERE post_id = ?");
        ps.setString(1, postId);
        ps.executeUpdate();
        ps.close();
        
        // Insérer les nouvelles
        insertCompetences(conn, postId, competencesStr, type);
    }

    /**
     * Sauvegarde les fichiers uploadés
     */
    private void saveUploadedFiles(Connection conn, String postId, String typePost, 
                                   List<FileItem> uploadedFiles, HashMap<String, String> params) throws Exception {
        if (uploadedFiles == null || uploadedFiles.isEmpty()) return;
        
        // Créer le dossier de destination
        String dossier = typePost + "_" + postId;
        String basePath = StringUtil.PATH_DIR + File.separator + "post_fichiers" + File.separator + dossier;
        createDir(basePath);
        
        // Trouver l'ordre max actuel
        PostFichier critere = new PostFichier();
        Object[] existants = CGenUtil.rechercher(critere, null, null, conn,
                " AND post_id = '" + postId + "' ORDER BY ordre DESC");
        int ordreMax = 0;
        if (existants != null && existants.length > 0) {
            PostFichier dernier = (PostFichier) existants[0];
            ordreMax = dernier.getOrdre() != null ? dernier.getOrdre() : 0;
        }
        
        int fileIndex = 1;
        for (FileItem fileItem : uploadedFiles) {
            // Récupérer le type de fichier correspondant
            String typeFichierId = params.get("typeFichier" + fileIndex);
            if (typeFichierId == null || typeFichierId.isEmpty()) {
                typeFichierId = "TFIC00001"; // Type par défaut
            }
            
            // Nom du fichier
            String originalName = fileItem.getName();
            int lastDot = originalName.lastIndexOf('.');
            String ext = lastDot > 0 ? originalName.substring(lastDot + 1) : "";
            String baseName = lastDot > 0 ? originalName.substring(0, lastDot) : originalName;
            
            // Générer un nom unique
            String uniqueName = baseName.replaceAll("[^a-zA-Z0-9.-]", "_") +
                    "-" + Utilitaire.heureCourante().replace(":", "") +
                    Utilitaire.dateDuJour().replace("/", "") +
                    "." + ext;
            
            // Sauvegarder le fichier
            String filePath = basePath + File.separator + uniqueName;
            File file = new File(filePath);
            fileItem.write(file);
            
            // Créer l'enregistrement PostFichier
            PostFichier pf = new PostFichier();
            pf.construirePK(conn);
            pf.setPost_id(postId);
            pf.setIdtypefichier(typeFichierId);
            pf.setNom_fichier(uniqueName);
            pf.setNom_original(originalName);
            pf.setChemin(filePath);
            pf.setTaille_octets(fileItem.getSize());
            pf.setMime_type(fileItem.getContentType());
            pf.setOrdre(++ordreMax);
            pf.insertToTable(conn);
            
            fileIndex++;
        }
    }
}
