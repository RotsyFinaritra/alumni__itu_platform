<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="java.util.Map" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="utilisateurAcade.UtilisateurPg" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="user.UserEJB" %>
<%
    String lien = null;
    String redirectUrl = null;
    String errorMsg = null;
    try {
        final UserEJB u = (UserEJB) session.getValue("u");
        lien = (String) session.getValue("lien");
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
                    formParams.put(item.getFieldName(), item.getString("UTF-8"));
                } else if (item.getFieldName().equals("photo") && item.getSize() > 0) {
                    String fileName = item.getName();
                    String ext = fileName.substring(fileName.lastIndexOf("."));
                    String uniqueFileName = "profile_" + System.currentTimeMillis() + ext;
                    
                    String uploadDir = System.getProperty("jboss.server.base.dir") + 
                                     "/deployments/dossier.war/async/profiles";
                    File dir = new File(uploadDir);
                    if (!dir.exists()) dir.mkdirs();
                    
                    File uploadedFile = new File(uploadDir + File.separator + uniqueFileName);
                    item.write(uploadedFile);
                    photoPath = uniqueFileName;
                    
                    // Supprimer l'ancienne photo si elle existe
                    String oldPhoto = formParams.get("photo_actuelle");
                    if (oldPhoto != null && !oldPhoto.isEmpty() && !oldPhoto.equals("null")) {
                        String oldPhotoName = oldPhoto.contains("/") ? oldPhoto.substring(oldPhoto.lastIndexOf("/") + 1) : oldPhoto;
                        File oldFile = new File(uploadDir + File.separator + oldPhotoName);
                        if (oldFile.exists()) oldFile.delete();
                    }
                }
            }
        }
        
        // Charger l'utilisateur actuel
        UtilisateurPg filtre = new UtilisateurPg();
        Object[] result = CGenUtil.rechercher(filtre, null, null, " AND refuser = " + refuser);
        if (result == null || result.length == 0) throw new Exception("Utilisateur introuvable");
        UtilisateurPg utilisateur = (UtilisateurPg) result[0];
        
        // Mettre &agrave; jour les champs depuis le formulaire
        if (formParams.containsKey("nomuser")) utilisateur.setNomuser(formParams.get("nomuser"));
        if (formParams.containsKey("prenom")) utilisateur.setPrenom(formParams.get("prenom"));
        if (formParams.containsKey("mail")) utilisateur.setMail(formParams.get("mail"));
        if (formParams.containsKey("teluser")) utilisateur.setTeluser(formParams.get("teluser"));
        if (formParams.containsKey("adruser")) utilisateur.setAdruser(formParams.get("adruser"));
        if (formParams.containsKey("loginuser")) utilisateur.setLoginuser(formParams.get("loginuser"));
        
        // Gérer idpromotion : chaîne vide = null (pour les enseignants ou si non renseigné)
        if (formParams.containsKey("idpromotion")) {
            String idpromo = formParams.get("idpromotion");
            utilisateur.setIdpromotion((idpromo != null && !idpromo.trim().isEmpty()) ? idpromo : null);
        }
        
        if (formParams.containsKey("idtypeutilisateur")) utilisateur.setIdtypeutilisateur(formParams.get("idtypeutilisateur"));
        if (photoPath != null) {
            utilisateur.setPhoto(photoPath);
        }
        
        // Sauvegarder via la m&eacute;thode m&eacute;tier
        utilisateur.updateProfil();
        
        session.setAttribute("successMessage", "Profil mis &agrave; jour avec succ&egrave;s !");
        redirectUrl = lien + "?but=profil/mon-profil.jsp";
        
    } catch (Exception e) {
        e.printStackTrace();
        errorMsg = "Erreur lors de la mise &agrave; jour du profil: " + e.getMessage();
        session.setAttribute("errorMessage", errorMsg);
        if (lien != null) {
            redirectUrl = lien + "?but=profil/mon-profil-saisie.jsp";
        }
    }
%>
<% if (redirectUrl != null) { %>
<script>
    document.location.replace("<%= redirectUrl %>");
</script>
<% } else if (errorMsg != null) { %>
<div style="background:#f2dede;color:#a94442;border:1px solid #ebccd1;padding:15px;margin:10px;border-radius:4px;">
    <strong>Erreur :</strong> <%= errorMsg %>
</div>
<% } %>
