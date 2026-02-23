<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="utilisateurAcade.UtilisateurPg" %>
<%@ page import="historique.ParamCrypt" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="utilitaire.Utilitaire" %>
<%@ page import="java.sql.Connection" %>

<%
    // Constants for password encryption (same as admin)
    final int CRYPT_NIVEAU = 5;
    final int CRYPT_CROISSANTE = 0;  // 0 = true (ascendant)
    
    Connection c = null;
    
    try {
        // Get form parameters
        String nomuser = request.getParameter("nomuser");
        String prenom = request.getParameter("prenom");
        String mail = request.getParameter("mail");
        String etu = request.getParameter("etu");
        String loginuser = request.getParameter("loginuser");
        String pwduser = request.getParameter("pwduser");
        String confirmPwd = request.getParameter("confirmPwd");
        String teluser = request.getParameter("teluser");
        String adruser = request.getParameter("adruser");
        String idtypeutilisateur = request.getParameter("idtypeutilisateur");

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
        utilisateur.setIdrole("alumni");
        // Utilise la valeur sélectionnée dans le formulaire
        utilisateur.setIdtypeutilisateur(idtypeutilisateur);

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
