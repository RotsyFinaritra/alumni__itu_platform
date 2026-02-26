<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*, utilitaire.*, java.sql.*, java.io.*, java.util.*, user.UserEJB" %>
<%@ page import="org.apache.commons.fileupload.*, org.apache.commons.fileupload.disk.*, org.apache.commons.fileupload.servlet.*" %>
<%
try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    if (u == null || lien == null) {
        response.sendRedirect("security-login.jsp");
        return;
    }
    
    int refuserInt = u.getUser().getRefuser();
    String bute = "accueil.jsp";
    String contenu = null;
    String idtypepublication = "TYP00004";
    String idvisibilite = "VISI00001";
    String idgroupe = null;
    String acte = null;
    
    FileItem fichierItem = null;
    
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
                
                if ("contenu".equals(fieldName)) {
                    contenu = fieldValue;
                } else if ("idtypepublication".equals(fieldName)) {
                    idtypepublication = fieldValue;
                } else if ("idvisibilite".equals(fieldName)) {
                    idvisibilite = fieldValue;
                } else if ("idgroupe".equals(fieldName)) {
                    idgroupe = fieldValue;
                } else if ("acte".equals(fieldName)) {
                    acte = fieldValue;
                } else if ("bute".equals(fieldName)) {
                    bute = fieldValue;
                }
            } else {
                // C'est un fichier
                if (item.getName() != null && !item.getName().isEmpty() && item.getSize() > 0) {
                    fichierItem = item;
                }
            }
        }
    } else {
        // Fallback pour requêtes non-multipart
        contenu = request.getParameter("contenu");
        idtypepublication = request.getParameter("idtypepublication");
        idvisibilite = request.getParameter("idvisibilite");
        idgroupe = request.getParameter("idgroupe");
        acte = request.getParameter("acte");
        bute = request.getParameter("bute");
        if (bute == null) bute = "accueil.jsp";
    }
    
    // Valider le contenu
    if (contenu == null || contenu.trim().isEmpty()) {
        throw new Exception("Le contenu ne peut pas être vide");
    }
    
    Connection conn = null;
    try {
        conn = new UtilDB().GetConn();
        conn.setAutoCommit(false);
        
        // 1. Créer la publication
        Post post = new Post();
        post.setContenu(contenu.trim());
        post.setIdutilisateur(refuserInt);
        post.setIdtypepublication(idtypepublication != null ? idtypepublication : "TYP00004");
        post.setIdvisibilite(idvisibilite != null ? idvisibilite : "VISI00001");
        post.setIdstatutpublication("STAT00002"); // Publié
        if (idgroupe != null && !idgroupe.trim().isEmpty()) {
            post.setIdgroupe(idgroupe.trim());
        }
        post.setSupprime(0);
        post.setNb_likes(0);
        post.setNb_commentaires(0);
        post.setNb_partages(0);
        post.setCreated_at(new Timestamp(System.currentTimeMillis()));
        
        post.construirePK(conn);
        post.insertToTable(conn);
        String newPostId = post.getTuppleID();
        
        // 2. Si un fichier est attaché, le sauvegarder
        if (fichierItem != null && newPostId != null) {
            // Créer le répertoire si nécessaire (utilise le même chemin que PostFichierServlet)
            String basePath = System.getProperty("jboss.server.base.dir") + "/deployments/dossier.war/post_fichiers/simple";
            File dir = new File(basePath);
            if (!dir.exists()) {
                dir.mkdirs();
            }
            
            // Nom original et extension
            String originalName = fichierItem.getName();
            // Extraire juste le nom de fichier (sans le chemin)
            if (originalName.contains("\\")) {
                originalName = originalName.substring(originalName.lastIndexOf("\\") + 1);
            }
            if (originalName.contains("/")) {
                originalName = originalName.substring(originalName.lastIndexOf("/") + 1);
            }
            
            int lastDot = originalName.lastIndexOf('.');
            String ext = lastDot > 0 ? originalName.substring(lastDot + 1) : "";
            String baseName = lastDot > 0 ? originalName.substring(0, lastDot) : originalName;
            
            // Générer un nom unique
            String timestamp = new java.text.SimpleDateFormat("HHmmssddMMyyyy").format(new java.util.Date());
            String uniqueName = baseName.replaceAll("[^a-zA-Z0-9._-]", "_") + "_" + timestamp + "." + ext;
            
            // Sauvegarder le fichier
            String filePath = basePath + File.separator + uniqueName;
            File savedFile = new File(filePath);
            fichierItem.write(savedFile);
            
            // Déterminer le type de fichier
            String mimeType = fichierItem.getContentType();
            String typeFichier = "TFIC00001"; // Autre par défaut
            if (mimeType != null) {
                if (mimeType.startsWith("image/")) {
                    typeFichier = "TFIC00002"; // Image
                } else if (mimeType.equals("application/pdf")) {
                    typeFichier = "TFIC00003"; // PDF
                } else if (mimeType.contains("word") || mimeType.contains("document")) {
                    typeFichier = "TFIC00004"; // Word
                } else if (mimeType.contains("excel") || mimeType.contains("spreadsheet")) {
                    typeFichier = "TFIC00005"; // Excel
                } else if (mimeType.contains("powerpoint") || mimeType.contains("presentation")) {
                    typeFichier = "TFIC00006"; // PowerPoint
                }
            }
            
            // Créer l'enregistrement PostFichier
            PostFichier pf = new PostFichier();
            pf.construirePK(conn);
            pf.setPost_id(newPostId);
            pf.setIdtypefichier(typeFichier);
            pf.setNom_fichier(uniqueName);
            pf.setNom_original(originalName);
            pf.setChemin("simple/" + uniqueName); // Chemin relatif
            pf.setTaille_octets(fichierItem.getSize());
            pf.setMime_type(mimeType);
            pf.setOrdre(1);
            
            pf.insertToTable(conn);
        }
        
        conn.commit();
        
%><script language="JavaScript">document.location.replace("<%=lien%>?but=<%=bute%>");</script><%
        
    } catch (Exception e) {
        if (conn != null) {
            try { conn.rollback(); } catch (Exception ignored) {}
        }
        throw e;
    } finally {
        if (conn != null) {
            try { conn.close(); } catch (Exception ignored) {}
        }
    }
    
} catch (Exception e) {
    e.printStackTrace();
%>
<script language="JavaScript">
    alert('Erreur: <%=e.getMessage().replace("'", "\\'")%>');
    history.back();
</script>
<% } %>
