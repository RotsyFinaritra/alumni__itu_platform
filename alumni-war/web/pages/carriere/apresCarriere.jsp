<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="user.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="bean.*" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.sql.*" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="affichage.*" %>
<%@ page import="utils.PublicationPermission" %>

<!DOCTYPE html>
<html>
<body>
<%!
    // Methode utilitaire pour parser les dates
    private java.sql.Date parseDate(String dateStr) {
        if (dateStr == null || dateStr.trim().isEmpty()) return null;
        dateStr = dateStr.trim();
        try {
            if (dateStr.matches("\\d{4}-\\d{2}-\\d{2}")) return java.sql.Date.valueOf(dateStr);
            return java.sql.Date.valueOf(dateStr);
        } catch (Exception e) { return null; }
    }

    // Methode utilitaire pour parser les timestamps
    private Timestamp parseTimestamp(String tsStr) {
        if (tsStr == null || tsStr.trim().isEmpty()) return null;
        try {
            String normalized = tsStr.trim().replace("T", " ");
            if (!normalized.contains(":")) normalized += " 00:00:00";
            else if (normalized.split(":").length == 2) normalized += ":00";
            return Timestamp.valueOf(normalized);
        } catch (Exception e) { return null; }
    }

    // Methode utilitaire pour parser un double depuis String
    private double parseDoubleSafe(String s) {
        if (s == null || s.trim().isEmpty()) return 0;
        try { return Double.parseDouble(s.trim()); } catch (Exception e) { return 0; }
    }

    // Methode utilitaire pour parser un int depuis String
    private int parseIntSafe(String s) {
        if (s == null || s.trim().isEmpty()) return 0;
        try { return Integer.parseInt(s.trim()); } catch (Exception e) { return 0; }
    }

    // Methode utilitaire pour parser un boolean-like (1, on, true)
    private int parseBoolInt(String s) {
        return (s != null && ("1".equals(s) || "on".equalsIgnoreCase(s) || "true".equalsIgnoreCase(s))) ? 1 : 0;
    }
%>
<%
    String acte = null;
    String lien = null;
    String bute = null;
    UserEJB u = null;

    try {
        lien = (String) session.getValue("lien");
        u = (UserEJB) session.getAttribute("u");
        if (lien == null) lien = "module.jsp";

        // Variables pour stocker les parametres du formulaire
        Map<String, String> formParams = new HashMap<String, String>();
        List<String> competencesList = new ArrayList<String>();
        List<FileItem> uploadedFiles = new ArrayList<FileItem>();
        List<String> typeFichiersList = new ArrayList<String>();

        // Parser le formulaire (multipart ou standard)
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
                        if (fieldValue != null && !fieldValue.isEmpty()) competencesList.add(fieldValue);
                    } else if ("typeFichier[]".equals(fieldName)) {
                        typeFichiersList.add(fieldValue);
                    } else {
                        formParams.put(fieldName, fieldValue);
                    }
                } else {
                    if (item.getName() != null && !item.getName().isEmpty() && item.getSize() > 0) {
                        uploadedFiles.add(item);
                    }
                }
            }
        } else {
            java.util.Enumeration paramNames = request.getParameterNames();
            while (paramNames.hasMoreElements()) {
                String name = (String) paramNames.nextElement();
                if ("competences[]".equals(name)) {
                    String[] vals = request.getParameterValues(name);
                    if (vals != null) for (String v : vals) { if (v != null && !v.isEmpty()) competencesList.add(v); }
                } else {
                    formParams.put(name, request.getParameter(name));
                }
            }
        }

        acte = formParams.get("acte");
        bute = formParams.get("bute");
        if (acte == null) acte = "";
        if (bute == null) bute = "carriere/carriere-accueil.jsp";

        String postId = formParams.get("id");
        String id = postId;

        // ========================
        // CONTRÔLE D'ACCÈS AVANT INSERT - DÉSACTIVÉ
        // ========================
        /*
        boolean isInsertAction = acte.toLowerCase().startsWith("insert");
        if (isInsertAction && !PublicationPermission.peutPublier(u)) {
            String messageErreur = PublicationPermission.getMessageErreur(u);
            // alert JS + redirect vers carriere-accueil.jsp
            response.sendRedirect(lien + "?but=carriere/carriere-accueil.jsp");
            return;
        }
        */
        // ========================

        // Repertoire d'upload pour les fichiers de carriere
        String uploadDir = System.getProperty("jboss.server.base.dir") +
                         "/deployments/dossier.war/async/carriere";
        File dir = new File(uploadDir);
        if (!dir.exists()) dir.mkdirs();

        // ========================
        // INSERT EMPLOI
        // ========================
        if ("insertEmploi".equalsIgnoreCase(acte)) {

            // 1. Creer le Post parent via createObject
            Post post = new Post();
            post.setIdtypepublication("TYP00002"); // Offre d'emploi
            post.setIdstatutpublication("STAT00002"); // Publie
            String visibilite = formParams.get("idvisibilite");
            post.setIdvisibilite(visibilite != null && !visibilite.isEmpty() ? visibilite : "VISI00001");
            post.setIdutilisateur(Integer.parseInt(String.valueOf(u.getUser().getRefuser())));
            post.setContenu(formParams.get("contenu") != null ? formParams.get("contenu") : "");
            post.setEpingle(0);
            post.setSupprime(0);
            post.setNb_likes(0);
            post.setNb_commentaires(0);
            post.setNb_partages(0);
            post.setCreated_at(new Timestamp(System.currentTimeMillis()));
            Post postInsere = (Post) u.createObject(post);
            postId = postInsere.getTuppleID();
            id = postId;

            // 2. Creer PostEmploi via createObject
            PostEmploi emploi = new PostEmploi();
            emploi.setPost_id(postId);
            emploi.setIdentreprise(formParams.get("identreprise"));
            emploi.setLocalisation(formParams.get("localisation"));
            emploi.setPoste(formParams.get("poste"));
            emploi.setType_contrat(formParams.get("type_contrat"));
            emploi.setSalaire_min(parseDoubleSafe(formParams.get("salaire_min")));
            emploi.setSalaire_max(parseDoubleSafe(formParams.get("salaire_max")));
            emploi.setDevise(formParams.get("devise"));
            emploi.setExperience_requise(formParams.get("experience_requise"));
            emploi.setNiveau_etude_requis(formParams.get("niveau_etude_requis"));
            emploi.setTeletravail_possible(parseBoolInt(formParams.get("teletravail_possible")));
            emploi.setDate_limite(parseDate(formParams.get("date_limite")));
            emploi.setContact_email(formParams.get("contact_email"));
            emploi.setContact_tel(formParams.get("contact_tel"));
            emploi.setLien_candidature(formParams.get("lien_candidature"));
            u.createObject(emploi);

            // 3. Creer les competences via CGenUtil.save
            for (String compId : competencesList) {
                if (compId != null && !compId.trim().isEmpty()) {
                    EmploiCompetence ec = new EmploiCompetence();
                    ec.setPost_id(postId);
                    ec.setIdcompetence(compId);
                    CGenUtil.save(ec);
                }
            }

            // 4. Traiter les fichiers uploades via createObject
            int fileIndex = 0;
            for (FileItem fileItem : uploadedFiles) {
                String originalName = fileItem.getName();
                String ext = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf(".")) : "";
                String uniqueName = "emploi_" + postId + "_" + System.currentTimeMillis() + "_" + fileIndex + ext;
                File uploadedFile = new File(uploadDir + File.separator + uniqueName);
                fileItem.write(uploadedFile);

                PostFichier pf = new PostFichier();
                pf.setPost_id(postId);
                pf.setNom_fichier(uniqueName);
                pf.setNom_original(originalName);
                pf.setChemin("carriere/" + uniqueName);
                pf.setTaille_octets(fileItem.getSize());
                pf.setMime_type(fileItem.getContentType());
                pf.setOrdre(fileIndex + 1);
                if (fileIndex < typeFichiersList.size() && typeFichiersList.get(fileIndex) != null
                    && !typeFichiersList.get(fileIndex).isEmpty()) {
                    pf.setIdtypefichier(typeFichiersList.get(fileIndex));
                }
                u.createObject(pf);
                fileIndex++;
            }

            bute = "carriere/emploi-fiche.jsp";
        }

        // ========================
        // INSERT STAGE
        // ========================
        else if ("insertStage".equalsIgnoreCase(acte)) {

            // 1. Creer le Post parent via createObject
            Post post = new Post();
            post.setIdtypepublication("TYP00001"); // Offre de stage
            post.setIdstatutpublication("STAT00002");
            String visibilite = formParams.get("idvisibilite");
            post.setIdvisibilite(visibilite != null && !visibilite.isEmpty() ? visibilite : "VISI00001");
            post.setIdutilisateur(Integer.parseInt(String.valueOf(u.getUser().getRefuser())));
            post.setContenu(formParams.get("contenu") != null ? formParams.get("contenu") : "");
            post.setEpingle(0);
            post.setSupprime(0);
            post.setNb_likes(0);
            post.setNb_commentaires(0);
            post.setNb_partages(0);
            post.setCreated_at(new Timestamp(System.currentTimeMillis()));
            Post postInsere = (Post) u.createObject(post);
            postId = postInsere.getTuppleID();
            id = postId;

            // 2. Creer PostStage via createObject
            PostStage stage = new PostStage();
            stage.setPost_id(postId);
            stage.setIdentreprise(formParams.get("identreprise"));
            stage.setDuree(formParams.get("duree"));
            stage.setDate_debut(parseDate(formParams.get("date_debut")));
            stage.setDate_fin(parseDate(formParams.get("date_fin")));
            stage.setIndemnite(parseDoubleSafe(formParams.get("indemnite")));
            stage.setNiveau_etude_requis(formParams.get("niveau_etude_requis"));
            stage.setConvention_requise(parseBoolInt(formParams.get("convention_requise")));
            stage.setPlaces_disponibles(parseIntSafe(formParams.get("places_disponibles")));
            stage.setContact_email(formParams.get("contact_email"));
            stage.setContact_tel(formParams.get("contact_tel"));
            stage.setLien_candidature(formParams.get("lien_candidature"));
            u.createObject(stage);

            // 3. Creer les competences via CGenUtil.save
            for (String compId : competencesList) {
                if (compId != null && !compId.trim().isEmpty()) {
                    StageCompetence sc = new StageCompetence();
                    sc.setPost_id(postId);
                    sc.setIdcompetence(compId);
                    CGenUtil.save(sc);
                }
            }

            // 4. Traiter les fichiers uploades via createObject
            int fileIndex = 0;
            for (FileItem fileItem : uploadedFiles) {
                String originalName = fileItem.getName();
                String ext = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf(".")) : "";
                String uniqueName = "stage_" + postId + "_" + System.currentTimeMillis() + "_" + fileIndex + ext;
                File uploadedFile = new File(uploadDir + File.separator + uniqueName);
                fileItem.write(uploadedFile);

                PostFichier pf = new PostFichier();
                pf.setPost_id(postId);
                pf.setNom_fichier(uniqueName);
                pf.setNom_original(originalName);
                pf.setChemin("carriere/" + uniqueName);
                pf.setTaille_octets(fileItem.getSize());
                pf.setMime_type(fileItem.getContentType());
                pf.setOrdre(fileIndex + 1);
                if (fileIndex < typeFichiersList.size() && typeFichiersList.get(fileIndex) != null
                    && !typeFichiersList.get(fileIndex).isEmpty()) {
                    pf.setIdtypefichier(typeFichiersList.get(fileIndex));
                }
                u.createObject(pf);
                fileIndex++;
            }

            bute = "carriere/stage-fiche.jsp";
        }

        // ========================
        // INSERT ACTIVITE
        // ========================
        else if ("insertActivite".equalsIgnoreCase(acte)) {

            // 1. Creer le Post parent via createObject
            Post post = new Post();
            post.setIdtypepublication("TYP00003"); // Activite
            post.setIdstatutpublication("STAT00002");
            String visibilite = formParams.get("idvisibilite");
            post.setIdvisibilite(visibilite != null && !visibilite.isEmpty() ? visibilite : "VISI00001");
            post.setIdutilisateur(Integer.parseInt(String.valueOf(u.getUser().getRefuser())));
            post.setContenu(formParams.get("contenu") != null ? formParams.get("contenu") : "");
            post.setEpingle(0);
            post.setSupprime(0);
            post.setNb_likes(0);
            post.setNb_commentaires(0);
            post.setNb_partages(0);
            post.setCreated_at(new Timestamp(System.currentTimeMillis()));
            Post postInsere = (Post) u.createObject(post);
            postId = postInsere.getTuppleID();
            id = postId;

            // 2. Creer PostActivite via createObject
            PostActivite activite = new PostActivite();
            activite.setPost_id(postId);
            activite.setTitre(formParams.get("titre"));
            String idcat = formParams.get("idcategorie");
            activite.setIdcategorie(idcat != null && !idcat.trim().isEmpty() ? idcat : null);
            activite.setLieu(formParams.get("lieu"));
            activite.setAdresse(formParams.get("adresse"));
            activite.setDate_debut(parseTimestamp(formParams.get("date_debut")));
            activite.setDate_fin(parseTimestamp(formParams.get("date_fin")));
            activite.setPrix(parseDoubleSafe(formParams.get("prix")));
            int nbPlaces = parseIntSafe(formParams.get("nombre_places"));
            activite.setNombre_places(nbPlaces);
            activite.setPlaces_restantes(nbPlaces); // places_restantes = nombre_places au debut
            activite.setContact_email(formParams.get("contact_email"));
            activite.setContact_tel(formParams.get("contact_tel"));
            activite.setLien_inscription(formParams.get("lien_inscription"));
            activite.setLien_externe(formParams.get("lien_externe"));
            u.createObject(activite);

            // 3. Traiter les fichiers uploades via createObject
            int fileIndex = 0;
            for (FileItem fileItem : uploadedFiles) {
                String originalName = fileItem.getName();
                String ext = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf(".")) : "";
                String uniqueName = "activite_" + postId + "_" + System.currentTimeMillis() + "_" + fileIndex + ext;
                File uploadedFile = new File(uploadDir + File.separator + uniqueName);
                fileItem.write(uploadedFile);

                PostFichier pf = new PostFichier();
                pf.setPost_id(postId);
                pf.setNom_fichier(uniqueName);
                pf.setNom_original(originalName);
                pf.setChemin("carriere/" + uniqueName);
                pf.setTaille_octets(fileItem.getSize());
                pf.setMime_type(fileItem.getContentType());
                pf.setOrdre(fileIndex + 1);
                if (fileIndex < typeFichiersList.size() && typeFichiersList.get(fileIndex) != null
                    && !typeFichiersList.get(fileIndex).isEmpty()) {
                    pf.setIdtypefichier(typeFichiersList.get(fileIndex));
                }
                u.createObject(pf);
                fileIndex++;
            }

            bute = "carriere/activite-fiche.jsp";
        }

        // ========================
        // UPDATE EMPLOI
        // ========================
        else if ("updateEmploi".equalsIgnoreCase(acte)) {
            postId = formParams.get("post_id");
            if (postId == null) postId = formParams.get("id");
            id = postId;

            // 1. Update Post via SQL direct (évite d'écraser idtypepublication et autres colonnes)
            {
                Connection conn = null;
                PreparedStatement ps = null;
                try {
                    conn = new UtilDB().GetConn();
                    String contenu = formParams.get("contenu") != null ? formParams.get("contenu") : "";
                    String visibilite = formParams.get("idvisibilite");
                    StringBuilder sql = new StringBuilder("UPDATE posts SET contenu = ?, edited_at = CURRENT_TIMESTAMP");
                    if (visibilite != null && !visibilite.isEmpty()) sql.append(", idvisibilite = ?");
                    sql.append(" WHERE id = ?");
                    ps = conn.prepareStatement(sql.toString());
                    int idx = 1;
                    ps.setString(idx++, contenu);
                    if (visibilite != null && !visibilite.isEmpty()) ps.setString(idx++, visibilite);
                    ps.setString(idx++, postId);
                    ps.executeUpdate();
                } finally {
                    if (ps != null) try { ps.close(); } catch (Exception ignored) {}
                    if (conn != null) try { conn.close(); } catch (Exception ignored) {}
                }
            }

            // 2. Update PostEmploi via updateObject
            PostEmploi emploi = new PostEmploi();
            emploi.setPost_id(postId);
            emploi.setIdentreprise(formParams.get("identreprise"));
            emploi.setLocalisation(formParams.get("localisation"));
            emploi.setPoste(formParams.get("poste"));
            emploi.setType_contrat(formParams.get("type_contrat"));
            emploi.setSalaire_min(parseDoubleSafe(formParams.get("salaire_min")));
            emploi.setSalaire_max(parseDoubleSafe(formParams.get("salaire_max")));
            emploi.setDevise(formParams.get("devise"));
            emploi.setExperience_requise(formParams.get("experience_requise"));
            emploi.setNiveau_etude_requis(formParams.get("niveau_etude_requis"));
            emploi.setTeletravail_possible(parseBoolInt(formParams.get("teletravail_possible")));
            emploi.setDate_limite(parseDate(formParams.get("date_limite")));
            emploi.setContact_email(formParams.get("contact_email"));
            emploi.setContact_tel(formParams.get("contact_tel"));
            emploi.setLien_candidature(formParams.get("lien_candidature"));
            u.updateObject(emploi);

            // 3. Supprimer anciennes competences via deleteObject, puis recreer via CGenUtil.save
            EmploiCompetence ecDel = new EmploiCompetence();
            ecDel.setPost_id(postId);
            u.deleteObjetFille(ecDel);

            for (String compId : competencesList) {
                if (compId != null && !compId.trim().isEmpty()) {
                    EmploiCompetence ec = new EmploiCompetence();
                    ec.setPost_id(postId);
                    ec.setIdcompetence(compId);
                    CGenUtil.save(ec);
                }
            }

            // 4. Traiter les nouveaux fichiers uploades via createObject
            int fileIndex = 0;
            for (FileItem fileItem : uploadedFiles) {
                String originalName = fileItem.getName();
                String ext = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf(".")) : "";
                String uniqueName = "emploi_" + postId + "_" + System.currentTimeMillis() + "_" + fileIndex + ext;
                File uploadedFile = new File(uploadDir + File.separator + uniqueName);
                fileItem.write(uploadedFile);

                PostFichier pf = new PostFichier();
                pf.setPost_id(postId);
                pf.setNom_fichier(uniqueName);
                pf.setNom_original(originalName);
                pf.setChemin("carriere/" + uniqueName);
                pf.setTaille_octets(fileItem.getSize());
                pf.setMime_type(fileItem.getContentType());
                pf.setOrdre(fileIndex + 1);
                if (fileIndex < typeFichiersList.size() && typeFichiersList.get(fileIndex) != null
                    && !typeFichiersList.get(fileIndex).isEmpty()) {
                    pf.setIdtypefichier(typeFichiersList.get(fileIndex));
                }
                u.createObject(pf);
                fileIndex++;
            }

            bute = "carriere/emploi-fiche.jsp";
        }

        // ========================
        // UPDATE STAGE
        // ========================
        else if ("updateStage".equalsIgnoreCase(acte)) {
            postId = formParams.get("post_id");
            if (postId == null) postId = formParams.get("id");
            id = postId;

            // 1. Update Post via SQL direct (évite d'écraser idtypepublication et autres colonnes)
            {
                Connection conn = null;
                PreparedStatement ps = null;
                try {
                    conn = new UtilDB().GetConn();
                    String contenu = formParams.get("contenu") != null ? formParams.get("contenu") : "";
                    String visibilite = formParams.get("idvisibilite");
                    StringBuilder sql = new StringBuilder("UPDATE posts SET contenu = ?, edited_at = CURRENT_TIMESTAMP");
                    if (visibilite != null && !visibilite.isEmpty()) sql.append(", idvisibilite = ?");
                    sql.append(" WHERE id = ?");
                    ps = conn.prepareStatement(sql.toString());
                    int idx = 1;
                    ps.setString(idx++, contenu);
                    if (visibilite != null && !visibilite.isEmpty()) ps.setString(idx++, visibilite);
                    ps.setString(idx++, postId);
                    ps.executeUpdate();
                } finally {
                    if (ps != null) try { ps.close(); } catch (Exception ignored) {}
                    if (conn != null) try { conn.close(); } catch (Exception ignored) {}
                }
            }

            // 2. Update PostStage via updateObject
            PostStage stage = new PostStage();
            stage.setPost_id(postId);
            stage.setIdentreprise(formParams.get("identreprise"));
            stage.setDuree(formParams.get("duree"));
            stage.setDate_debut(parseDate(formParams.get("date_debut")));
            stage.setDate_fin(parseDate(formParams.get("date_fin")));
            stage.setIndemnite(parseDoubleSafe(formParams.get("indemnite")));
            stage.setNiveau_etude_requis(formParams.get("niveau_etude_requis"));
            stage.setConvention_requise(parseBoolInt(formParams.get("convention_requise")));
            stage.setPlaces_disponibles(parseIntSafe(formParams.get("places_disponibles")));
            stage.setContact_email(formParams.get("contact_email"));
            stage.setContact_tel(formParams.get("contact_tel"));
            stage.setLien_candidature(formParams.get("lien_candidature"));
            u.updateObject(stage);

            // 3. Supprimer anciennes competences via deleteObjetFille, puis recreer via CGenUtil.save
            StageCompetence scDel = new StageCompetence();
            scDel.setPost_id(postId);
            u.deleteObjetFille(scDel);

            for (String compId : competencesList) {
                if (compId != null && !compId.trim().isEmpty()) {
                    StageCompetence sc = new StageCompetence();
                    sc.setPost_id(postId);
                    sc.setIdcompetence(compId);
                    CGenUtil.save(sc);
                }
            }

            // 4. Traiter les nouveaux fichiers uploades via createObject
            int fileIndex = 0;
            for (FileItem fileItem : uploadedFiles) {
                String originalName = fileItem.getName();
                String ext = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf(".")) : "";
                String uniqueName = "stage_" + postId + "_" + System.currentTimeMillis() + "_" + fileIndex + ext;
                File uploadedFile = new File(uploadDir + File.separator + uniqueName);
                fileItem.write(uploadedFile);

                PostFichier pf = new PostFichier();
                pf.setPost_id(postId);
                pf.setNom_fichier(uniqueName);
                pf.setNom_original(originalName);
                pf.setChemin("carriere/" + uniqueName);
                pf.setTaille_octets(fileItem.getSize());
                pf.setMime_type(fileItem.getContentType());
                pf.setOrdre(fileIndex + 1);
                if (fileIndex < typeFichiersList.size() && typeFichiersList.get(fileIndex) != null
                    && !typeFichiersList.get(fileIndex).isEmpty()) {
                    pf.setIdtypefichier(typeFichiersList.get(fileIndex));
                }
                u.createObject(pf);
                fileIndex++;
            }

            bute = "carriere/stage-fiche.jsp";
        }

        // ========================
        // UPDATE ACTIVITE
        // ========================
        else if ("updateActivite".equalsIgnoreCase(acte)) {
            postId = formParams.get("post_id");
            if (postId == null) postId = formParams.get("id");
            id = postId;

            // 1. Update Post via SQL direct (évite d'écraser idtypepublication et autres colonnes)
            {
                Connection conn = null;
                PreparedStatement ps = null;
                try {
                    conn = new UtilDB().GetConn();
                    String contenu = formParams.get("contenu") != null ? formParams.get("contenu") : "";
                    String visibilite = formParams.get("idvisibilite");
                    StringBuilder sql = new StringBuilder("UPDATE posts SET contenu = ?, edited_at = CURRENT_TIMESTAMP");
                    if (visibilite != null && !visibilite.isEmpty()) sql.append(", idvisibilite = ?");
                    sql.append(" WHERE id = ?");
                    ps = conn.prepareStatement(sql.toString());
                    int idx = 1;
                    ps.setString(idx++, contenu);
                    if (visibilite != null && !visibilite.isEmpty()) ps.setString(idx++, visibilite);
                    ps.setString(idx++, postId);
                    ps.executeUpdate();
                } finally {
                    if (ps != null) try { ps.close(); } catch (Exception ignored) {}
                    if (conn != null) try { conn.close(); } catch (Exception ignored) {}
                }
            }

            // 2. Update PostActivite via updateObject
            PostActivite activite = new PostActivite();
            activite.setPost_id(postId);
            activite.setTitre(formParams.get("titre"));
            String idcat = formParams.get("idcategorie");
            activite.setIdcategorie(idcat != null && !idcat.trim().isEmpty() ? idcat : null);
            activite.setLieu(formParams.get("lieu"));
            activite.setAdresse(formParams.get("adresse"));
            activite.setDate_debut(parseTimestamp(formParams.get("date_debut")));
            activite.setDate_fin(parseTimestamp(formParams.get("date_fin")));
            activite.setPrix(parseDoubleSafe(formParams.get("prix")));
            int nbPlaces = parseIntSafe(formParams.get("nombre_places"));
            activite.setNombre_places(nbPlaces);
            activite.setPlaces_restantes(nbPlaces);
            activite.setContact_email(formParams.get("contact_email"));
            activite.setContact_tel(formParams.get("contact_tel"));
            activite.setLien_inscription(formParams.get("lien_inscription"));
            u.updateObject(activite);

            // 3. Traiter les nouveaux fichiers uploades via createObject
            int fileIndex = 0;
            for (FileItem fileItem : uploadedFiles) {
                String originalName = fileItem.getName();
                String ext = originalName.contains(".") ? originalName.substring(originalName.lastIndexOf(".")) : "";
                String uniqueName = "activite_" + postId + "_" + System.currentTimeMillis() + "_" + fileIndex + ext;
                File uploadedFile = new File(uploadDir + File.separator + uniqueName);
                fileItem.write(uploadedFile);

                PostFichier pf = new PostFichier();
                pf.setPost_id(postId);
                pf.setNom_fichier(uniqueName);
                pf.setNom_original(originalName);
                pf.setChemin("carriere/" + uniqueName);
                pf.setTaille_octets(fileItem.getSize());
                pf.setMime_type(fileItem.getContentType());
                pf.setOrdre(fileIndex + 1);
                if (fileIndex < typeFichiersList.size() && typeFichiersList.get(fileIndex) != null
                    && !typeFichiersList.get(fileIndex).isEmpty()) {
                    pf.setIdtypefichier(typeFichiersList.get(fileIndex));
                }
                u.createObject(pf);
                fileIndex++;
            }

            bute = "carriere/activite-fiche.jsp";
        }

%>
<script language="JavaScript">
    document.location.replace("<%=lien%>?but=<%=bute%>&id=<%=Utilitaire.champNull(id)%>");
</script>
<%
    } catch (Exception e) {
        e.printStackTrace();
        String msgErr = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
%>
<script language="JavaScript">
    alert('<%=msgErr.replace("'", "\\'")%>');
    history.back();
</script>
<%
    }
%>
</body>
</html>
