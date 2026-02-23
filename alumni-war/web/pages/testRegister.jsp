<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="utilisateurAcade.UtilisateurPg" %>
<%@ page import="historique.ParamCrypt" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="utilitaire.Utilitaire" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="java.util.HashMap" %>

<%
    // Constants for password encryption (same as admin)
    final int CRYPT_NIVEAU = 5;
    final int CRYPT_CROISSANTE = 0;  // 0 = true (ascendant)
    
    Connection c = null;
    
    try {
        // Variables pour stocker les données du formulaire
        HashMap<String, String> formParams = new HashMap<>();
        String photoPath = null;
        
        // Vérifier si c'est un formulaire multipart (avec fichier)
        if (ServletFileUpload.isMultipartContent(request)) {
            // Configuration de l'upload
            DiskFileItemFactory factory = new DiskFileItemFactory();
            ServletFileUpload upload = new ServletFileUpload(factory);
            
            // Parser la requête
            List<FileItem> items = upload.parseRequest(request);
            
            // Traiter les items
            for (FileItem item : items) {
                if (item.isFormField()) {
                    // C'est un champ de formulaire normal
                    formParams.put(item.getFieldName(), item.getString("UTF-8"));
                } else {
                    // C'est un fichier
                    if (item.getName() != null && !item.getName().isEmpty()) {
                        // Récupérer le nom et l'extension du fichier
                        String fileName = item.getName();
                        int lastDot = fileName.lastIndexOf('.');
                        String ext = lastDot > 0 ? fileName.substring(lastDot) : "";
                        
                        // Générer un nom unique avec timestamp
                        String uniqueFileName = "profile_" + System.currentTimeMillis() + ext;
                        
                        // Utiliser dossier.war comme dans le framework APJ
                        String uploadDir = System.getProperty("jboss.server.base.dir") + 
                                         "/deployments/dossier.war/async/profiles";
                        File dir = new File(uploadDir);
                        if (!dir.exists()) {
                            dir.mkdirs();
                        }
                        
                        // Log pour debug
                        System.out.println("testRegister.jsp - Répertoire upload: " + uploadDir);
                        
                        // Sauvegarder le fichier
                        File uploadedFile = new File(uploadDir + File.separator + uniqueFileName);
                        item.write(uploadedFile);
                        
                        System.out.println("testRegister.jsp - Fichier sauvegardé: " + uploadedFile.getAbsolutePath());
                        
                        // Stocker uniquement le nom du fichier
                        photoPath = uniqueFileName;
                    }
                }
            }
        } else {
            // Formulaire sans fichier (fallback - ne devrait pas arriver)
            session.setAttribute("errorInscription", "Erreur de format de formulaire.");
            response.sendRedirect("inscription.jsp");
            return;
        }
        
        // Récupérer les paramètres du formulaire
        String nomuser = formParams.get("nomuser");
        String prenom = formParams.get("prenom");
        String mail = formParams.get("mail");
        String etu = formParams.get("etu");
        String loginuser = formParams.get("loginuser");
        String pwduser = formParams.get("pwduser");
        String confirmPwd = formParams.get("confirmPwd");
        String teluser = formParams.get("teluser");
        String adruser = formParams.get("adruser");
        String idtypeutilisateur = formParams.get("idtypeutilisateur");
        String idpromotion = formParams.get("promotion");

        // Validate required fields
        if (loginuser == null || loginuser.trim().isEmpty() ||
            pwduser == null || pwduser.trim().isEmpty() ||
            nomuser == null || nomuser.trim().isEmpty() ||
            prenom == null || prenom.trim().isEmpty() ||
            mail == null || mail.trim().isEmpty()) {
            session.setAttribute("errorInscription", "Tous les champs obligatoires doivent être renseignés.");
            response.sendRedirect("inscription.jsp");
            return;
        }

        // Check password confirmation
        if (!pwduser.equals(confirmPwd)) {
            session.setAttribute("errorInscription", "Les mots de passe ne correspondent pas.");
            response.sendRedirect("inscription.jsp");
            return;
        }

        // Encrypt password
        String encryptedPwd = Utilitaire.cryptWord(pwduser, CRYPT_NIVEAU, CRYPT_CROISSANTE);

        // Log for debug
        System.out.println("Registration: loginuser=" + loginuser +
               ", nomuser=" + nomuser +
               ", prenom=" + prenom +
               ", mail=" + mail +
               ", etu=" + etu);

        // Open database connection
        c = new UtilDB().GetConn();
        c.setAutoCommit(false);

        // Create UtilisateurPg object (refuser est int, compatible avec la BDD)
        UtilisateurPg utilisateur = new UtilisateurPg();
        utilisateur.setLoginuser(loginuser);
        utilisateur.setPwduser(encryptedPwd);
        utilisateur.setNomuser(nomuser);
        utilisateur.setPrenom(prenom);
        utilisateur.setMail(mail);
        utilisateur.setEtu(etu != null ? etu : "");
        utilisateur.setTeluser(teluser != null ? teluser : "");
        utilisateur.setAdruser(adruser != null ? adruser : "");
        utilisateur.setIdrole("utilisateur");
        // Utilise la valeur sélectionnée dans le formulaire
        utilisateur.setIdtypeutilisateur(idtypeutilisateur);
        // Ajoute la promotion sélectionnée
        utilisateur.setIdpromotion(idpromotion);
        // Ajoute la photo si elle a été uploadée
        if (photoPath != null) {
            utilisateur.setPhoto(photoPath);
        }

        // Generate primary key and create user
        utilisateur.construirePK(c);
        int newUserId = utilisateur.getRefuser();
        
        System.out.println("DEBUG: New user refuser = " + newUserId);
        
        // Insert user into database (SYSTEM as creator since no logged user)
        utilisateur.createObject("SYSTEM", c);

        // Create ParamCrypt record for the new user
        ParamCrypt paramCrypt = new ParamCrypt(CRYPT_NIVEAU, CRYPT_CROISSANTE, String.valueOf(newUserId));
        paramCrypt.createObject("SYSTEM", c);

        // Commit transaction
        c.commit();

        System.out.println("Registration successful for user: " + loginuser);
        
        session.setAttribute("successInscription", "Inscription réussie. Vous pouvez maintenant vous connecter.");
        response.sendRedirect("../index.jsp");
        
    } catch (Exception e) {
        e.printStackTrace();
        
        // Rollback on error
        if (c != null) {
            try {
                c.rollback();
            } catch (Exception rollbackEx) {
                rollbackEx.printStackTrace();
            }
        }
        
        session.setAttribute("errorInscription", "Erreur lors de l'inscription: " + e.getMessage());
        response.sendRedirect("inscription.jsp");
        
    } finally {
        // Close connection
        if (c != null) {
            try {
                c.close();
            } catch (Exception closeEx) {
                closeEx.printStackTrace();
            }
        }
    }
%>
