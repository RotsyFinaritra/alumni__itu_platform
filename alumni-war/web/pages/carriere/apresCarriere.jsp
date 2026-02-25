<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="bean.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="affichage.*" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Traitement Carrière</title>
</head>
<body>
<%!
    // Méthode utilitaire pour parser les dates de manière sécurisée
    private java.sql.Date parseDate(String dateStr) {
        if (dateStr == null) return null;
        dateStr = dateStr.trim();
        if (dateStr.isEmpty()) return null;
        
        try {
            // Format attendu: yyyy-MM-dd (format HTML5 date input)
            if (dateStr.matches("\\d{4}-\\d{2}-\\d{2}")) {
                return java.sql.Date.valueOf(dateStr);
            }
            // Format alternatif: dd/MM/yyyy
            if (dateStr.matches("\\d{2}/\\d{2}/\\d{4}")) {
                SimpleDateFormat sdf = new SimpleDateFormat("dd/MM/yyyy");
                java.util.Date parsed = sdf.parse(dateStr);
                return new java.sql.Date(parsed.getTime());
            }
            // Format alternatif: dd-MM-yyyy
            if (dateStr.matches("\\d{2}-\\d{2}-\\d{4}")) {
                SimpleDateFormat sdf = new SimpleDateFormat("dd-MM-yyyy");
                java.util.Date parsed = sdf.parse(dateStr);
                return new java.sql.Date(parsed.getTime());
            }
            // Dernier recours: essayer le format par défaut
            return java.sql.Date.valueOf(dateStr);
        } catch (Exception e) {
            System.err.println("Erreur parse date: " + dateStr + " - " + e.getMessage());
            return null;
        }
    }
%>
<%
    String acte = null;
    String lien = null;
    String bute = null;
    UserEJB u = null;
    Connection conn = null;
    
    try {
        lien = (String) session.getValue("lien");
        u = (UserEJB) session.getAttribute("u");
        
        if (lien == null) lien = "module.jsp";
        
        // Variables pour stocker les paramètres du formulaire
        Map<String, String> formParams = new HashMap<String, String>();
        List<String> competencesList = new ArrayList<String>();
        List<FileItem> uploadedFiles = new ArrayList<FileItem>();
        List<String> typeFichiersList = new ArrayList<String>();
        
        // Parser le formulaire multipart
        if (ServletFileUpload.isMultipartContent(request)) {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            upload.setHeaderEncoding("UTF-8");
            
            List<FileItem> items = upload.parseRequest(request);
            
            for (FileItem item : items) {
                if (item.isFormField()) {
                    String fieldName = item.getFieldName();
                    String fieldValue = item.getString("UTF-8");
                    
                    if ("competences[]".equals(fieldName)) {
                        if (fieldValue != null && !fieldValue.isEmpty()) {
                            competencesList.add(fieldValue);
                        }
                    } else if ("typeFichier[]".equals(fieldName)) {
                        typeFichiersList.add(fieldValue);
                    } else {
                        formParams.put(fieldName, fieldValue);
                    }
                } else {
                    // C'est un fichier uploadé
                    if (item.getName() != null && !item.getName().isEmpty() && item.getSize() > 0) {
                        uploadedFiles.add(item);
                    }
                }
            }
        } else {
            // Formulaire non-multipart (fallback)
            acte = request.getParameter("acte");
            bute = request.getParameter("bute");
            formParams.put("acte", acte);
            formParams.put("bute", bute);
        }
        
        acte = formParams.get("acte");
        bute = formParams.get("bute");
        if (bute == null) bute = "carriere/carriere-accueil.jsp";
        
        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);
        
        String postId = null;
        String message = "";
        
        // Répertoire d'upload pour les fichiers de carrière
        String uploadDir = System.getProperty("jboss.server.base.dir") + 
                         "/deployments/dossier.war/async/carriere";
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();
        
        // ========================
        // INSERT EMPLOI
        // ========================
        if ("insertEmploi".equalsIgnoreCase(acte)) {
            System.out.println("=== INSERT EMPLOI START ===");
            
            // 1. Générer le Post ID
            Post post = new Post();
            post.construirePK(conn);
            postId = post.getId();
            System.out.println("Post ID généré: " + postId);
            
            // 2. Insérer le Post avec SQL direct
            String sqlPost = "INSERT INTO posts (id, idtypepublication, idutilisateur, idstatutpublication, " +
                "idvisibilite, contenu, nb_likes, nb_commentaires, nb_partages, epingle, supprime) " +
                "VALUES (?, ?, ?, ?, ?, ?, 0, 0, 0, 0, 0)";
            PreparedStatement psPost = conn.prepareStatement(sqlPost);
            psPost.setString(1, postId);
            psPost.setString(2, "TYP00002"); // Offre d'emploi
            psPost.setString(3, String.valueOf(u.getUser().getRefuser()));
            psPost.setString(4, "STAT0001"); // Brouillon
            String visibilite = formParams.get("idvisibilite");
            if (visibilite == null || visibilite.isEmpty()) visibilite = "VIS00001"; // Public par défaut
            psPost.setString(5, visibilite);
            psPost.setString(6, formParams.get("contenu"));
            psPost.executeUpdate();
            psPost.close();
            System.out.println("Post inséré OK");
            
            // 3. Insérer PostEmploi avec SQL direct
            String sqlEmploi = "INSERT INTO post_emploi (post_id, identreprise, localisation, poste, type_contrat, " +
                "salaire_min, salaire_max, devise, experience_requise, niveau_etude_requis, " +
                "teletravail_possible, date_limite, contact_email, contact_tel, lien_candidature) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement psEmploi = conn.prepareStatement(sqlEmploi);
            psEmploi.setString(1, postId);
            psEmploi.setString(2, formParams.get("identreprise"));
            psEmploi.setString(3, formParams.get("localisation"));
            psEmploi.setString(4, formParams.get("poste"));
            psEmploi.setString(5, formParams.get("type_contrat"));
            
            String salaireMin = formParams.get("salaire_min");
            if (salaireMin != null && !salaireMin.isEmpty()) {
                psEmploi.setDouble(6, Double.parseDouble(salaireMin));
            } else {
                psEmploi.setNull(6, java.sql.Types.DOUBLE);
            }
            String salaireMax = formParams.get("salaire_max");
            if (salaireMax != null && !salaireMax.isEmpty()) {
                psEmploi.setDouble(7, Double.parseDouble(salaireMax));
            } else {
                psEmploi.setNull(7, java.sql.Types.DOUBLE);
            }
            
            psEmploi.setString(8, formParams.get("devise"));
            psEmploi.setString(9, formParams.get("experience_requise"));
            psEmploi.setString(10, formParams.get("niveau_etude_requis"));
            
            String teletravail = formParams.get("teletravail_possible");
            psEmploi.setInt(11, (teletravail != null && ("1".equals(teletravail) || "on".equalsIgnoreCase(teletravail))) ? 1 : 0);
            
            java.sql.Date dateLimite = parseDate(formParams.get("date_limite"));
            if (dateLimite != null) {
                psEmploi.setDate(12, dateLimite);
            } else {
                psEmploi.setNull(12, java.sql.Types.DATE);
            }
            
            psEmploi.setString(13, formParams.get("contact_email"));
            psEmploi.setString(14, formParams.get("contact_tel"));
            psEmploi.setString(15, formParams.get("lien_candidature"));
            psEmploi.executeUpdate();
            psEmploi.close();
            System.out.println("PostEmploi inséré OK");
            
            // 4. Insérer les compétences
            System.out.println("Insertion des compétences: " + competencesList.size());
            for (String compId : competencesList) {
                String sqlComp = "INSERT INTO emploi_competence (post_id, idcompetence) VALUES (?, ?)";
                PreparedStatement psComp = conn.prepareStatement(sqlComp);
                psComp.setString(1, postId);
                psComp.setString(2, compId);
                psComp.executeUpdate();
                psComp.close();
            }
            System.out.println("Compétences insérées - OK");
            
            // 5. Traiter les fichiers uploadés
            int fileIndex = 0;
            for (FileItem fileItem : uploadedFiles) {
                String originalName = fileItem.getName();
                String ext = "";
                if (originalName.contains(".")) {
                    ext = originalName.substring(originalName.lastIndexOf("."));
                }
                String uniqueName = "emploi_" + postId + "_" + System.currentTimeMillis() + "_" + fileIndex + ext;
                
                File uploadedFile = new File(uploadDir + File.separator + uniqueName);
                fileItem.write(uploadedFile);
                
                // Générer ID fichier
                PostFichier pf = new PostFichier();
                pf.construirePK(conn);
                String fichierId = pf.getId();
                
                // Insérer avec SQL direct
                String sqlFichier = "INSERT INTO post_fichiers (id, post_id, nom_fichier, nom_original, chemin, " +
                    "taille_octets, mime_type, ordre, idtypefichier) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement psFichier = conn.prepareStatement(sqlFichier);
                psFichier.setString(1, fichierId);
                psFichier.setString(2, postId);
                psFichier.setString(3, uniqueName);
                psFichier.setString(4, originalName);
                psFichier.setString(5, "carriere/" + uniqueName);
                psFichier.setLong(6, fileItem.getSize());
                psFichier.setString(7, fileItem.getContentType());
                psFichier.setInt(8, fileIndex + 1);
                
                if (fileIndex < typeFichiersList.size() && typeFichiersList.get(fileIndex) != null 
                    && !typeFichiersList.get(fileIndex).isEmpty()) {
                    psFichier.setString(9, typeFichiersList.get(fileIndex));
                } else {
                    psFichier.setNull(9, java.sql.Types.VARCHAR);
                }
                psFichier.executeUpdate();
                psFichier.close();
                fileIndex++;
            }
            
            System.out.println("=== COMMIT EMPLOI ===");
            conn.commit();
            System.out.println("=== INSERT EMPLOI SUCCESS ===");
            message = "Offre d'emploi créée avec succès";
            bute = "carriere/emploi-liste.jsp";
        }
        
        // ========================
        // INSERT STAGE
        // ========================
        else if ("insertStage".equalsIgnoreCase(acte)) {
            // 1. Générer le Post ID
            Post post = new Post();
            post.construirePK(conn);
            postId = post.getId();
            System.out.println("Stage Post ID généré: " + postId);
            
            // 2. Insérer le Post avec SQL direct
            String sqlPost = "INSERT INTO posts (id, idtypepublication, idutilisateur, idstatutpublication, " +
                "idvisibilite, contenu, nb_likes, nb_commentaires, nb_partages, epingle, supprime) " +
                "VALUES (?, ?, ?, ?, ?, ?, 0, 0, 0, 0, 0)";
            PreparedStatement psPost = conn.prepareStatement(sqlPost);
            psPost.setString(1, postId);
            psPost.setString(2, "TYP00003"); // Offre de stage
            psPost.setString(3, String.valueOf(u.getUser().getRefuser()));
            psPost.setString(4, "STAT0001"); // Brouillon
            String visibilite = formParams.get("idvisibilite");
            if (visibilite == null || visibilite.isEmpty()) visibilite = "VIS00001";
            psPost.setString(5, visibilite);
            psPost.setString(6, formParams.get("contenu"));
            psPost.executeUpdate();
            psPost.close();
            System.out.println("Post stage inséré OK");
            
            // 3. Insérer PostStage avec SQL direct
            String sqlStage = "INSERT INTO post_stage (post_id, identreprise, duree, date_debut, date_fin, " +
                "indemnite, niveau_etude_requis, convention_requise, places_disponibles, " +
                "contact_email, contact_tel, lien_candidature) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement psStage = conn.prepareStatement(sqlStage);
            psStage.setString(1, postId);
            psStage.setString(2, formParams.get("identreprise"));
            psStage.setString(3, formParams.get("duree"));
            
            java.sql.Date dateDebut = parseDate(formParams.get("date_debut"));
            if (dateDebut != null) {
                psStage.setDate(4, dateDebut);
            } else {
                psStage.setNull(4, java.sql.Types.DATE);
            }
            
            java.sql.Date dateFin = parseDate(formParams.get("date_fin"));
            if (dateFin != null) {
                psStage.setDate(5, dateFin);
            } else {
                psStage.setNull(5, java.sql.Types.DATE);
            }
            
            String indemnite = formParams.get("indemnite");
            if (indemnite != null && !indemnite.isEmpty()) {
                psStage.setDouble(6, Double.parseDouble(indemnite));
            } else {
                psStage.setNull(6, java.sql.Types.DOUBLE);
            }
            
            psStage.setString(7, formParams.get("niveau_etude_requis"));
            
            String convention = formParams.get("convention_requise");
            psStage.setInt(8, (convention != null && ("1".equals(convention) || "on".equalsIgnoreCase(convention))) ? 1 : 0);
            
            String places = formParams.get("places_disponibles");
            if (places != null && !places.isEmpty()) {
                psStage.setInt(9, Integer.parseInt(places));
            } else {
                psStage.setNull(9, java.sql.Types.INTEGER);
            }
            
            psStage.setString(10, formParams.get("contact_email"));
            psStage.setString(11, formParams.get("contact_tel"));
            psStage.setString(12, formParams.get("lien_candidature"));
            psStage.executeUpdate();
            psStage.close();
            System.out.println("PostStage inséré OK");
            
            // 4. Insérer les compétences
            for (String compId : competencesList) {
                String sqlComp = "INSERT INTO stage_competence (post_id, idcompetence) VALUES (?, ?)";
                PreparedStatement psComp = conn.prepareStatement(sqlComp);
                psComp.setString(1, postId);
                psComp.setString(2, compId);
                psComp.executeUpdate();
                psComp.close();
            }
            
            // 5. Traiter les fichiers uploadés
            int fileIndex = 0;
            for (FileItem fileItem : uploadedFiles) {
                String originalName = fileItem.getName();
                String ext = "";
                if (originalName.contains(".")) {
                    ext = originalName.substring(originalName.lastIndexOf("."));
                }
                String uniqueName = "stage_" + postId + "_" + System.currentTimeMillis() + "_" + fileIndex + ext;
                
                File uploadedFile = new File(uploadDir + File.separator + uniqueName);
                fileItem.write(uploadedFile);
                
                // Générer ID fichier
                PostFichier pf = new PostFichier();
                pf.construirePK(conn);
                String fichierId = pf.getId();
                
                String sqlFichier = "INSERT INTO post_fichiers (id, post_id, nom_fichier, nom_original, chemin, " +
                    "taille_octets, mime_type, ordre, idtypefichier) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement psFichier = conn.prepareStatement(sqlFichier);
                psFichier.setString(1, fichierId);
                psFichier.setString(2, postId);
                psFichier.setString(3, uniqueName);
                psFichier.setString(4, originalName);
                psFichier.setString(5, "carriere/" + uniqueName);
                psFichier.setLong(6, fileItem.getSize());
                psFichier.setString(7, fileItem.getContentType());
                psFichier.setInt(8, fileIndex + 1);
                
                if (fileIndex < typeFichiersList.size() && typeFichiersList.get(fileIndex) != null 
                    && !typeFichiersList.get(fileIndex).isEmpty()) {
                    psFichier.setString(9, typeFichiersList.get(fileIndex));
                } else {
                    psFichier.setNull(9, java.sql.Types.VARCHAR);
                }
                psFichier.executeUpdate();
                psFichier.close();
                fileIndex++;
            }
            
            conn.commit();
            System.out.println("=== INSERT STAGE SUCCESS ===");
            message = "Offre de stage créée avec succès";
            bute = "carriere/stage-liste.jsp";
        }
        
        // ========================
        // UPDATE EMPLOI
        // ========================
        else if ("updateEmploi".equalsIgnoreCase(acte)) {
            postId = formParams.get("post_id");
            if (postId == null) postId = formParams.get("id");
            
            // 1. Mettre à jour Post
            String sqlPost = "UPDATE posts SET contenu = ?, edited_at = CURRENT_TIMESTAMP WHERE id = ?";
            PreparedStatement psPost = conn.prepareStatement(sqlPost);
            psPost.setString(1, formParams.get("contenu"));
            psPost.setString(2, postId);
            psPost.executeUpdate();
            psPost.close();
            
            // 2. Mettre à jour PostEmploi
            PostEmploi emploi = new PostEmploi();
            emploi.setPost_id(postId);
            emploi.setIdentreprise(formParams.get("identreprise"));
            emploi.setLocalisation(formParams.get("localisation"));
            emploi.setPoste(formParams.get("poste"));
            emploi.setType_contrat(formParams.get("type_contrat"));
            
            String salaireMin = formParams.get("salaire_min");
            if (salaireMin != null && !salaireMin.isEmpty()) {
                emploi.setSalaire_min(Double.parseDouble(salaireMin));
            }
            String salaireMax = formParams.get("salaire_max");
            if (salaireMax != null && !salaireMax.isEmpty()) {
                emploi.setSalaire_max(Double.parseDouble(salaireMax));
            }
            
            emploi.setDevise(formParams.get("devise"));
            emploi.setExperience_requise(formParams.get("experience_requise"));
            emploi.setNiveau_etude_requis(formParams.get("niveau_etude_requis"));
            
            String teletravail = formParams.get("teletravail_possible");
            emploi.setTeletravail_possible(teletravail != null && ("1".equals(teletravail) || "on".equalsIgnoreCase(teletravail)) ? 1 : 0);
            
            emploi.setDate_limite(parseDate(formParams.get("date_limite")));
            
            emploi.setContact_email(formParams.get("contact_email"));
            emploi.setContact_tel(formParams.get("contact_tel"));
            emploi.setLien_candidature(formParams.get("lien_candidature"));
            emploi.updateToTable(conn);
            
            // 3. Supprimer anciennes compétences et insérer les nouvelles
            String sqlDelComp = "DELETE FROM emploi_competence WHERE post_id = ?";
            PreparedStatement psDel = conn.prepareStatement(sqlDelComp);
            psDel.setString(1, postId);
            psDel.executeUpdate();
            psDel.close();
            
            for (String compId : competencesList) {
                String sqlComp = "INSERT INTO emploi_competence (post_id, idcompetence) VALUES (?, ?)";
                PreparedStatement psComp = conn.prepareStatement(sqlComp);
                psComp.setString(1, postId);
                psComp.setString(2, compId);
                psComp.executeUpdate();
                psComp.close();
            }
            
            // 4. Traiter les nouveaux fichiers uploadés (ajout)
            int fileIndex = 0;
            for (FileItem fileItem : uploadedFiles) {
                String originalName = fileItem.getName();
                String ext = "";
                if (originalName.contains(".")) {
                    ext = originalName.substring(originalName.lastIndexOf("."));
                }
                String uniqueName = "emploi_" + postId + "_" + System.currentTimeMillis() + "_" + fileIndex + ext;
                
                File uploadedFile = new File(uploadDir + File.separator + uniqueName);
                fileItem.write(uploadedFile);
                
                PostFichier pf = new PostFichier();
                pf.construirePK(conn);
                String fichierId = pf.getId();
                
                String sqlFichier = "INSERT INTO post_fichiers (id, post_id, nom_fichier, nom_original, chemin, " +
                    "taille_octets, mime_type, ordre, idtypefichier) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement psFichier = conn.prepareStatement(sqlFichier);
                psFichier.setString(1, fichierId);
                psFichier.setString(2, postId);
                psFichier.setString(3, uniqueName);
                psFichier.setString(4, originalName);
                psFichier.setString(5, "carriere/" + uniqueName);
                psFichier.setLong(6, fileItem.getSize());
                psFichier.setString(7, fileItem.getContentType());
                psFichier.setInt(8, fileIndex + 1);
                
                if (fileIndex < typeFichiersList.size() && typeFichiersList.get(fileIndex) != null 
                    && !typeFichiersList.get(fileIndex).isEmpty()) {
                    psFichier.setString(9, typeFichiersList.get(fileIndex));
                } else {
                    psFichier.setNull(9, java.sql.Types.VARCHAR);
                }
                psFichier.executeUpdate();
                psFichier.close();
                fileIndex++;
            }
            
            conn.commit();
            message = "Offre d'emploi mise à jour avec succès";
            bute = "carriere/emploi-fiche.jsp&id=" + postId;
        }
        
        // ========================
        // UPDATE STAGE
        // ========================
        else if ("updateStage".equalsIgnoreCase(acte)) {
            postId = formParams.get("post_id");
            if (postId == null) postId = formParams.get("id");
            
            // 1. Mettre à jour Post
            String sqlPost = "UPDATE posts SET contenu = ?, edited_at = CURRENT_TIMESTAMP WHERE id = ?";
            PreparedStatement psPost = conn.prepareStatement(sqlPost);
            psPost.setString(1, formParams.get("contenu"));
            psPost.setString(2, postId);
            psPost.executeUpdate();
            psPost.close();
            
            // 2. Mettre à jour PostStage
            PostStage stage = new PostStage();
            stage.setPost_id(postId);
            stage.setIdentreprise(formParams.get("identreprise"));
            stage.setDuree(formParams.get("duree"));
            
            stage.setDate_debut(parseDate(formParams.get("date_debut")));
            stage.setDate_fin(parseDate(formParams.get("date_fin")));
            
            String indemnite = formParams.get("indemnite");
            if (indemnite != null && !indemnite.isEmpty()) {
                stage.setIndemnite(Double.parseDouble(indemnite));
            }
            
            stage.setNiveau_etude_requis(formParams.get("niveau_etude_requis"));
            
            String convention = formParams.get("convention_requise");
            stage.setConvention_requise(convention != null && ("1".equals(convention) || "on".equalsIgnoreCase(convention)) ? 1 : 0);
            
            String places = formParams.get("places_disponibles");
            if (places != null && !places.isEmpty()) {
                stage.setPlaces_disponibles(Integer.parseInt(places));
            }
            
            stage.setContact_email(formParams.get("contact_email"));
            stage.setContact_tel(formParams.get("contact_tel"));
            stage.setLien_candidature(formParams.get("lien_candidature"));
            stage.updateToTable(conn);
            
            // 3. Supprimer anciennes compétences et insérer les nouvelles
            String sqlDelComp = "DELETE FROM stage_competence WHERE post_id = ?";
            PreparedStatement psDel = conn.prepareStatement(sqlDelComp);
            psDel.setString(1, postId);
            psDel.executeUpdate();
            psDel.close();
            
            for (String compId : competencesList) {
                String sqlComp = "INSERT INTO stage_competence (post_id, idcompetence) VALUES (?, ?)";
                PreparedStatement psComp = conn.prepareStatement(sqlComp);
                psComp.setString(1, postId);
                psComp.setString(2, compId);
                psComp.executeUpdate();
                psComp.close();
            }
            
            // 4. Traiter les nouveaux fichiers uploadés (ajout)
            int fileIndex = 0;
            for (FileItem fileItem : uploadedFiles) {
                String originalName = fileItem.getName();
                String ext = "";
                if (originalName.contains(".")) {
                    ext = originalName.substring(originalName.lastIndexOf("."));
                }
                String uniqueName = "stage_" + postId + "_" + System.currentTimeMillis() + "_" + fileIndex + ext;
                
                File uploadedFile = new File(uploadDir + File.separator + uniqueName);
                fileItem.write(uploadedFile);
                
                PostFichier pf = new PostFichier();
                pf.construirePK(conn);
                String fichierId = pf.getId();
                
                String sqlFichier = "INSERT INTO post_fichiers (id, post_id, nom_fichier, nom_original, chemin, " +
                    "taille_octets, mime_type, ordre, idtypefichier) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                PreparedStatement psFichier = conn.prepareStatement(sqlFichier);
                psFichier.setString(1, fichierId);
                psFichier.setString(2, postId);
                psFichier.setString(3, uniqueName);
                psFichier.setString(4, originalName);
                psFichier.setString(5, "carriere/" + uniqueName);
                psFichier.setLong(6, fileItem.getSize());
                psFichier.setString(7, fileItem.getContentType());
                psFichier.setInt(8, fileIndex + 1);
                
                if (fileIndex < typeFichiersList.size() && typeFichiersList.get(fileIndex) != null 
                    && !typeFichiersList.get(fileIndex).isEmpty()) {
                    psFichier.setString(9, typeFichiersList.get(fileIndex));
                } else {
                    psFichier.setNull(9, java.sql.Types.VARCHAR);
                }
                psFichier.executeUpdate();
                psFichier.close();
                fileIndex++;
            }
            
            conn.commit();
            message = "Offre de stage mise à jour avec succès";
            bute = "carriere/stage-fiche.jsp&id=" + postId;
        }
        
        // Stocker le message en session pour affichage
        session.setAttribute("message_success", message);
        System.out.println("=== MESSAGE SUCCESS: " + message + " ===");
%>
<script language="JavaScript">
    document.location.replace("<%=lien%>?but=<%=bute%>");
</script>
<%
    } catch (Exception e) {
        System.err.println("=== ERREUR CARRIERE: " + e.getMessage() + " ===");
        e.printStackTrace();
        if (conn != null) {
            try { conn.rollback(); System.err.println("=== ROLLBACK EFFECTUE ==="); } catch (Exception ex) {}
        }
        session.setAttribute("message_error", "Erreur: " + e.getMessage());
%>
<script language="JavaScript">
    document.location.replace("<%=lien%>?but=<%=bute%>");
</script>
<%
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (Exception ex) {}
        }
    }
%>
</body>
</html>
