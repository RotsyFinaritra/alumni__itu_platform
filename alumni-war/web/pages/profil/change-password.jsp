<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="utilisateurAcade.UtilisateurPg" %>
<%@ page import="user.UserEJB" %>
<%@ page import="historique.MapUtilisateur" %>
<%@ page import="bean.ClassMAPTable" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="utilitaire.Utilitaire" %>
<%@ page import="utilitaireAcade.UtilitaireAcade" %>

<%
    UserEJB u = (user.UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    MapUtilisateur userSession = u.getUser();
    String refuser = String.valueOf(userSession.getRefuser());
    
    String oldPassword = request.getParameter("old_password");
    String newPassword = request.getParameter("pwduser");
    String confirmPassword = request.getParameter("confirm_password");
    
    String message = "";
    String messageType = "error";
    
    try {
        // Vérifier que les champs sont remplis
        if (oldPassword == null || newPassword == null || confirmPassword == null ||
            oldPassword.trim().isEmpty() || newPassword.trim().isEmpty() || confirmPassword.trim().isEmpty()) {
            message = "Tous les champs sont obligatoires";
        }
        // Vérifier que les nouveaux mots de passe correspondent
        else if (!newPassword.equals(confirmPassword)) {
            message = "Les nouveaux mots de passe ne correspondent pas";
        }
        // Vérifier la longueur minimale
        else if (newPassword.length() < 6) {
            message = "Le mot de passe doit contenir au moins 6 caractères";
        }
        else {
            Connection c = null;
            try {
                c = new Utilitaire().GetConn();
                
                // Récupérer l'utilisateur actuel
                UtilisateurPg utilisateur = new UtilisateurPg();
                utilisateur.setValChamp("refuser", refuser);
                utilisateur.setNomTable("utilisateur");
                UtilisateurPg[] users = (UtilisateurPg[]) ClassMAPTable.getValCriterion(utilisateur, null, c);
                
                if (users != null && users.length > 0) {
                    UtilisateurPg currentUser = users[0];
                    
                    // Vérifier l'ancien mot de passe
                    String currentPasswordHash = currentUser.getPwduser();
                    
                    // Comparer avec l'ancien mot de passe (adapté selon votre méthode de hashage)
                    // Si vous utilisez un hash MD5, utilisez UtilitaireAcade.crypte()
                    String oldPasswordToCheck = oldPassword;
                    try {
                        oldPasswordToCheck = UtilitaireAcade.crypte(oldPassword);
                    } catch (Exception ex) {
                        // Si pas de cryptage, comparaison directe
                    }
                    
                    if (!currentPasswordHash.equals(oldPasswordToCheck) && !currentPasswordHash.equals(oldPassword)) {
                        message = "L'ancien mot de passe est incorrect";
                    } else {
                        // Mettre à jour le mot de passe
                        currentUser.setValChamp("refuser", refuser);
                        
                        // Crypter le nouveau mot de passe
                        String newPasswordHash = newPassword;
                        try {
                            newPasswordHash = UtilitaireAcade.crypte(newPassword);
                        } catch (Exception ex) {
                            // Si pas de cryptage, utiliser tel quel
                        }
                        
                        currentUser.setPwduser(newPasswordHash);
                        currentUser.setNomTable("utilisateur");
                        
                        // Sauvegarder
                        ClassMAPTable.updateTable(currentUser, c);
                        
                        message = "Mot de passe modifié avec succès !";
                        messageType = "success";
                    }
                } else {
                    message = "Utilisateur non trouvé";
                }
            } catch (Exception e) {
                message = "Erreur lors de la modification : " + e.getMessage();
                e.printStackTrace();
            } finally {
                if (c != null) try { c.close(); } catch (Exception e) {}
            }
        }
    } catch (Exception e) {
        message = "Erreur : " + e.getMessage();
        e.printStackTrace();
    }
    
    // Redirection avec message
    if (messageType.equals("success")) {
%>
        <script>
            alert("<%=message%>");
            window.location.href = "<%=lien%>?but=profil/mon-profil.jsp&currentMenu=MENDYN001-1";
        </script>
<%
    } else {
%>
        <script>
            alert("<%=message%>");
            history.back();
        </script>
<%
    }
%>
