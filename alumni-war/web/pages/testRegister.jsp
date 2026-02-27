<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="utilisateurAcade.UtilisateurPg" %>
<%@ page import="historique.ParamCrypt" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="utilitaire.Utilitaire" %>
<%@ page import="validation.EtudiantValidator" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.io.File" %>
<%@ page import="java.util.List" %>
<%@ page import="org.apache.commons.fileupload.FileItem" %>
<%@ page import="org.apache.commons.fileupload.disk.DiskFileItemFactory" %>
<%@ page import="org.apache.commons.fileupload.servlet.ServletFileUpload" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="bean.Groupe" %>
<%@ page import="bean.GroupeMembre" %>
<%@ page import="bean.CGenUtil" %>

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
        String profCode = formParams.get("prof_code");
        String loginuser = formParams.get("loginuser");
        String pwduser = formParams.get("pwduser");
        String confirmPwd = formParams.get("confirmPwd");
        String teluser = formParams.get("teluser");
        String adruser = formParams.get("adruser");
        String idtypeutilisateur = formParams.get("idtypeutilisateur");
        String idpromotion = formParams.get("promotion");

        // Validate required fields (différent selon le type)
        boolean isEnseignant = "TU0000003".equals(idtypeutilisateur);
        
        if (loginuser == null || loginuser.trim().isEmpty() ||
            pwduser == null || pwduser.trim().isEmpty() ||
            nomuser == null || nomuser.trim().isEmpty() ||
            prenom == null || prenom.trim().isEmpty() ||
            mail == null || mail.trim().isEmpty()) {
            session.setAttribute("errorInscription", "Tous les champs obligatoires doivent être renseignés.");
            response.sendRedirect("inscription.jsp");
            return;
        }
        
        // Vérifier l'identification selon le type
        if (isEnseignant) {
            if (profCode == null || profCode.trim().isEmpty()) {
                session.setAttribute("errorInscription", "Le code enseignant est obligatoire.");
                response.sendRedirect("inscription.jsp");
                return;
            }
        } else {
            if (etu == null || etu.trim().isEmpty()) {
                session.setAttribute("errorInscription", "Le numéro étudiant (ETU) est obligatoire.");
                response.sendRedirect("inscription.jsp");
                return;
            }
        }

        // Check password confirmation
        if (!pwduser.equals(confirmPwd)) {
            session.setAttribute("errorInscription", "Les mots de passe ne correspondent pas.");
            response.sendRedirect("inscription.jsp");
            return;
        }

        // Open database connection
        c = new UtilDB().GetConn();
        
        if (isEnseignant) {
            // VALIDATION ENSEIGNANT: Vérifier le code prof
            // Charger la liste des enseignants depuis le classpath
            ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
            java.io.InputStream is = classLoader.getResourceAsStream("enseignants.json");
            java.util.Scanner scanner = new java.util.Scanner(is, "UTF-8").useDelimiter("\\A");
            String jsonContent = scanner.hasNext() ? scanner.next() : "[]";
            scanner.close();
            is.close();
            
            // Parser le JSON simple
            boolean profFound = false;
            String[] profs = jsonContent.split("\\{");
            for (String prof : profs) {
                if (prof.contains("\"code\": \"" + profCode + "\"")) {
                    profFound = true;
                    break;
                }
            }
            
            if (!profFound) {
                session.setAttribute("errorInscription", "Code enseignant invalide. Veuillez sélectionner parmi la liste.");
                response.sendRedirect("inscription.jsp");
                return;
            }
            
            // Vérifier si le code enseignant est déjà inscrit
            if (EtudiantValidator.isEtuDejaInscrit(profCode, c)) {
                session.setAttribute("errorInscription", "Ce code enseignant est déjà inscrit. Veuillez vous connecter.");
                response.sendRedirect("inscription.jsp");
                return;
            }
        } else {
            // VALIDATION ÉTUDIANT: Valider ETU avec nom/prénom
            // VALIDATION 1: Vérifier si l'ETU est déjà inscrit
            if (EtudiantValidator.isEtuDejaInscrit(etu, c)) {
                session.setAttribute("errorInscription", "Le numéro étudiant " + etu + " est déjà inscrit. Veuillez vous connecter.");
                response.sendRedirect("inscription.jsp");
                return;
            }
            
            // VALIDATION 2: Valider l'ETU avec nom/prénom et récupérer la promotion
            EtudiantValidator validator = null;
            EtudiantValidator.ValidationResult validationResult = null;
            try {
                validator = new EtudiantValidator();
                validationResult = validator.valider(etu, nomuser, prenom);
            } catch (Exception ex) {
                System.err.println("Erreur lors du chargement de la liste des étudiants: " + ex.getMessage());
                ex.printStackTrace();
                session.setAttribute("errorInscription", "Erreur système: impossible de valider votre inscription. Veuillez contacter l'administration.");
                response.sendRedirect("inscription.jsp");
                return;
            }
            
            if (!validationResult.isValide()) {
                session.setAttribute("errorInscription", validationResult.getMessage());
                response.sendRedirect("inscription.jsp");
                return;
            }
            
            // Récupérer la promotion depuis la validation
            String promotionValidee = validationResult.getPromotion();
            
            // Récupérer l'ID de la promotion depuis la base
            bean.Promotion promoObj = new bean.Promotion();
            promoObj.setId(promotionValidee);
            Object[] promoResult = bean.CGenUtil.rechercher(promoObj, null, null, c, "");
            if (promoResult == null || promoResult.length == 0) {
                session.setAttribute("errorInscription", "Promotion " + promotionValidee + " non trouvée dans la base de données. Veuillez contacter l'administration.");
                response.sendRedirect("inscription.jsp");
                return;
            }
            
            // Utiliser la promotion validée (écrase celle du formulaire si différente)
            idpromotion = promotionValidee;
        }

        // Encrypt password
        String encryptedPwd = Utilitaire.cryptWord(pwduser, CRYPT_NIVEAU, CRYPT_CROISSANTE);

        // Log for debug
        String identifiant = isEnseignant ? profCode : etu;
        System.out.println("Registration: loginuser=" + loginuser +
               ", nomuser=" + nomuser +
               ", prenom=" + prenom +
               ", mail=" + mail +
               ", identifiant=" + identifiant +
               ", type=" + (isEnseignant ? "enseignant" : "étudiant") +
               ", promotion=" + idpromotion);

        c.setAutoCommit(false);

        // Create UtilisateurPg object
        UtilisateurPg utilisateur = new UtilisateurPg();
        utilisateur.setLoginuser(loginuser);
        utilisateur.setPwduser(encryptedPwd);
        utilisateur.setNomuser(nomuser);
        utilisateur.setPrenom(prenom);
        utilisateur.setMail(mail);
        
        // Définir l'identification selon le type d'utilisateur
        utilisateur.setEtu(isEnseignant ? profCode : etu);
        
        utilisateur.setTeluser(teluser != null ? teluser : "");
        utilisateur.setAdruser(adruser != null ? adruser : "");
        utilisateur.setIdrole(UtilisateurPg.getIdRoleEquivalent(idtypeutilisateur));
        utilisateur.setIdtypeutilisateur(idtypeutilisateur);
        
        // Promotion seulement pour les étudiants
        utilisateur.setIdpromotion(!isEnseignant && idpromotion != null && !idpromotion.trim().isEmpty() ? idpromotion : null);
        
        // Photo: utiliser celle uploadée ou mettre une photo par défaut (comme Facebook)
        if (photoPath != null && !photoPath.isEmpty()) {
            utilisateur.setPhoto(photoPath);
        } else {
            utilisateur.setPhoto("user-placeholder.svg");
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

        // Ajouter l'utilisateur au groupe de sa promotion (seulement pour les étudiants)
        if (!isEnseignant && idpromotion != null && !idpromotion.trim().isEmpty()) {
            try {
                Object[] groupeResult = CGenUtil.rechercher(new Groupe(), null, null, 
                    " AND idpromotion = '" + idpromotion.trim() + "' AND actif = 1");
                if (groupeResult != null && groupeResult.length > 0) {
                    Groupe groupe = (Groupe) groupeResult[0];
                    GroupeMembre gm = new GroupeMembre();
                    gm.construirePK(c);
                    gm.setIdutilisateur(newUserId);
                    gm.setIdgroupe(groupe.getId());
                    gm.setIdrole("ROLE00003"); // Membre
                    gm.setStatut("actif");
                    gm.setJoined_at(new java.sql.Timestamp(System.currentTimeMillis()));
                    gm.insertToTable(c);
                    System.out.println("Registration: User " + newUserId + " added to group " + groupe.getId() + " (promotion " + idpromotion + ")");
                }
            } catch (Exception gmEx) {
                System.err.println("Warning: Could not add user to promotion group: " + gmEx.getMessage());
                // Ne pas bloquer l'inscription si l'ajout au groupe échoue
            }
        }

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
