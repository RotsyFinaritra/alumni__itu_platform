<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="utilisateurAcade.UtilisateurAcade" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="user.UserEJB" %>
<%@ page import="java.sql.Connection" %>
<%
    try {
        final UserEJB u = (UserEJB) session.getValue("u");
        final String lien = (String) session.getValue("lien");
        final String refuser = u.getUser().getTuppleID();
        
        String photoPath = null;
        Map<String, String> formParams = new HashMap<String, String>();
        
        // V&eacute;rifier si le formulaire est de type multipart
        if (ServletFileUpload.isMultipartContent(request)) {
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            
            List<FileItem> items = upload.parseRequest(request);
            
            for (FileItem item : items) {
                if (item.isFormField()) {
                    // Champ normal du formulaire
                    formParams.put(item.getFieldName(), item.getString("UTF-8"));
                } else if (item.getFieldName().equals("photo") && item.getSize() > 0) {
                    // Fichier photo upload&eacute;
                    String fileName = item.getName();
                    String ext = fileName.substring(fileName.lastIndexOf("."));
                    
                    // G&eacute;n&eacute;rer un nom unique
                    String uniqueFileName = "profile_" + System.currentTimeMillis() + ext;
                    
                    // Utiliser dossier.war comme dans le framework APJ
                    String uploadDir = System.getProperty("jboss.server.base.dir") + 
                                     "/deployments/dossier.war/async/profiles";
                    File dir = new File(uploadDir);
                    if (!dir.exists()) {
                        dir.mkdirs();
                    }
                    
                    // Sauvegarder le fichier
                    File uploadedFile = new File(uploadDir + File.separator + uniqueFileName);
                    item.write(uploadedFile);
                    
                    System.out.println("update-profil.jsp - Nouvelle photo sauvegard&eacute;e: " + uploadedFile.getAbsolutePath());
                    
                    // Stocker le nom du fichier pour la base
                    photoPath = uniqueFileName;
                    
                    // Supprimer l'ancienne photo si elle existe
                    String oldPhoto = formParams.get("photo_actuelle");
                    if (oldPhoto != null && !oldPhoto.isEmpty() && !oldPhoto.equals("null")) {
                        String oldPhotoName = oldPhoto;
                        if (oldPhoto.contains("/")) {
                            oldPhotoName = oldPhoto.substring(oldPhoto.lastIndexOf("/") + 1);
                        }
                        File oldFile = new File(uploadDir + File.separator + oldPhotoName);
                        if (oldFile.exists()) {
                            oldFile.delete();
                            System.out.println("update-profil.jsp - Ancienne photo supprim&eacute;e: " + oldFile.getAbsolutePath());
                        }
                    }
                }
            }
        }
        
        // Charger l'utilisateur actuel
        UtilisateurAcade filtre = new UtilisateurAcade();
        Object[] result = CGenUtil.rechercher(filtre, null, null, " AND refuser = " + refuser);
        if (result == null || result.length == 0) {
            throw new Exception("Utilisateur introuvable");
        }
        UtilisateurAcade utilisateur = (UtilisateurAcade) result[0];
        
        // Mettre &agrave; jour les champs du formulaire
        if (formParams.containsKey("nomuser")) utilisateur.setNomuser(formParams.get("nomuser"));
        if (formParams.containsKey("prenom")) utilisateur.setPrenom(formParams.get("prenom"));
        if (formParams.containsKey("mail")) utilisateur.setMail(formParams.get("mail"));
        if (formParams.containsKey("teluser")) utilisateur.setTeluser(formParams.get("teluser"));
        if (formParams.containsKey("adruser")) utilisateur.setAdruser(formParams.get("adruser"));
        if (formParams.containsKey("loginuser")) utilisateur.setLoginuser(formParams.get("loginuser"));
        if (formParams.containsKey("idpromotion")) {
            try {
                utilisateur.setIdpromotion(Integer.parseInt(formParams.get("idpromotion")));
            } catch (NumberFormatException e) {}
        }
        if (formParams.containsKey("idtypeutilisateur")) {
            try {
                utilisateur.setIdtypeutilisateur(Integer.parseInt(formParams.get("idtypeutilisateur")));
            } catch (NumberFormatException e) {}
        }
        
        // Mettre &agrave; jour la photo si une nouvelle a &eacute;t&eacute; upload&eacute;e
        if (photoPath != null) {
            utilisateur.setPhoto(photoPath);
        }
        
        // Sauvegarder en base de donn&eacute;es
        Connection conn = null;
        try {
            conn = utilisateur.getConnection();
            utilisateur.updateObject("SYSTEM", conn);
            
            session.setAttribute("successMessage", "Profil mis &agrave; jour avec succ&egrave;s !");
        } finally {
            if (conn != null) conn.close();
        }
        
        // Rediriger vers la page de profil
        response.sendRedirect(lien + "?but=profil/mon-profil.jsp");
        
    } catch (Exception e) {
        e.printStackTrace();
        session.setAttribute("errorMessage", "Erreur lors de la mise &agrave; jour du profil: " + e.getMessage());
        response.sendRedirect(lien + "?but=profil/mon-profil-saisie.jsp");
    }
%>
