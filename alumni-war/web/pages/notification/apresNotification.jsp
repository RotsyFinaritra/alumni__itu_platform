<%@ page import="user.UserEJB" %>
<%@ page import="bean.*, utilitaire.*, utilisateurAcade.UtilisateurAcade" %>
<%@ page contentType="application/json; charset=UTF-8" %>
<%
    response.setContentType("application/json");
    response.setCharacterEncoding("UTF-8");
    
    String result = "{\"success\":false,\"message\":\"Action non reconnue\"}";
    
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        if (u == null) {
            result = "{\"success\":false,\"message\":\"Session expirée\"}";
            out.print(result);
            return;
        }
        
        int refuserInt = u.getUser().getRefuser();
        String acte = request.getParameter("acte");
        String id = request.getParameter("id");
        
        if ("marquer_lu".equals(acte) && id != null) {
            // Marquer une notification comme lue
            Notification notifCritere = new Notification();
            notifCritere.setId(id);
            Object[] notifs = CGenUtil.rechercher(notifCritere, null, null, " AND idutilisateur = " + refuserInt);
            
            if (notifs != null && notifs.length > 0) {
                Notification n = (Notification) notifs[0];
                n.setVu(1);
                n.setLu_at(new java.sql.Timestamp(System.currentTimeMillis()));
                u.updateObject(n);
                result = "{\"success\":true,\"message\":\"Notification marquée comme lue\"}";
            } else {
                result = "{\"success\":false,\"message\":\"Notification non trouvée\"}";
            }
        }
        else if ("marquer_non_lu".equals(acte) && id != null) {
            // Marquer une notification comme non lue
            Notification notifCritere = new Notification();
            notifCritere.setId(id);
            Object[] notifs = CGenUtil.rechercher(notifCritere, null, null, " AND idutilisateur = " + refuserInt);
            
            if (notifs != null && notifs.length > 0) {
                Notification n = (Notification) notifs[0];
                n.setVu(0);
                n.setLu_at(null);
                u.updateObject(n);
                result = "{\"success\":true,\"message\":\"Notification marquée comme non lue\"}";
            } else {
                result = "{\"success\":false,\"message\":\"Notification non trouvée\"}";
            }
        }
        else if ("supprimer".equals(acte) && id != null) {
            // Supprimer une notification
            Notification notifCritere = new Notification();
            notifCritere.setId(id);
            Object[] notifs = CGenUtil.rechercher(notifCritere, null, null, " AND idutilisateur = " + refuserInt);
            
            if (notifs != null && notifs.length > 0) {
                Notification n = (Notification) notifs[0];
                u.deleteObject(n);
                result = "{\"success\":true,\"message\":\"Notification supprimée\"}";
            } else {
                result = "{\"success\":false,\"message\":\"Notification non trouvée\"}";
            }
        }
        else if ("marquer_tout_lu".equals(acte)) {
            // Marquer toutes les notifications comme lues
            Notification notifCritere = new Notification();
            Object[] notifs = CGenUtil.rechercher(notifCritere, null, null, " AND idutilisateur = " + refuserInt + " AND vu = 0");
            
            int count = 0;
            if (notifs != null) {
                java.sql.Timestamp now = new java.sql.Timestamp(System.currentTimeMillis());
                for (Object obj : notifs) {
                    Notification n = (Notification) obj;
                    n.setVu(1);
                    n.setLu_at(now);
                    u.updateObject(n);
                    count++;
                }
            }
            
            result = "{\"success\":true,\"message\":\"" + count + " notification(s) marquée(s) comme lue(s)\"}";
        }
        else if ("count_non_lu".equals(acte)) {
            // Compter les notifications non lues (pour badge header)
            Notification notifCritere = new Notification();
            Object[] notifs = CGenUtil.rechercher(notifCritere, null, null, " AND idutilisateur = " + refuserInt + " AND vu = 0");
            int count = (notifs != null) ? notifs.length : 0;
            
            result = "{\"success\":true,\"count\":" + count + "}";
        }
        else if ("get_recent".equals(acte)) {
            // Obtenir les X dernières notifications (pour dropdown header)
            int limit = 5;
            try {
                limit = Integer.parseInt(request.getParameter("limit"));
            } catch (Exception ignored) {}
            
            Notification notifCritere = new Notification();
            Object[] notifs = CGenUtil.rechercher(notifCritere, null, null, 
                " AND idutilisateur = " + refuserInt + " ORDER BY created_at DESC LIMIT " + limit);
            
            StringBuilder json = new StringBuilder("{\"success\":true,\"notifications\":[");
            
            if (notifs != null && notifs.length > 0) {
                for (int i = 0; i < notifs.length; i++) {
                    Notification n = (Notification) notifs[i];
                    
                    // Récupérer info type notification
                    String typeLibelle = "";
                    String typeIcon = "fa-bell";
                    String typeCouleur = "#3498db";
                    
                    if (n.getIdtypenotification() != null) {
                        TypeNotification typeCritere = new TypeNotification();
                        typeCritere.setId(n.getIdtypenotification());
                        Object[] types = CGenUtil.rechercher(typeCritere, null, null, null);
                        if (types != null && types.length > 0) {
                            TypeNotification t = (TypeNotification) types[0];
                            typeLibelle = t.getLibelle() != null ? t.getLibelle() : "";
                            typeIcon = t.getIcon() != null ? t.getIcon() : "fa-bell";
                            typeCouleur = t.getCouleur() != null ? t.getCouleur() : "#3498db";
                        }
                    }
                    
                    // Récupérer info émetteur
                    String emetteur = "";
                    if (n.getEmetteur_id() > 0) {
                        UtilisateurAcade userCritere = new UtilisateurAcade();
                        Object[] users = CGenUtil.rechercher(userCritere, null, null, " AND refuser = " + n.getEmetteur_id());
                        if (users != null && users.length > 0) {
                            UtilisateurAcade user = (UtilisateurAcade) users[0];
                            emetteur = ((user.getPrenom() != null ? user.getPrenom() : "") + " " + 
                                       (user.getNomuser() != null ? user.getNomuser() : "")).trim();
                        }
                    }
                    
                    String contenu = n.getContenu();
                    if (contenu == null) contenu = typeLibelle;
                    contenu = contenu.replace("\"", "\\\"").replace("\n", " ");
                    
                    String lienNotif = n.getLien();
                    if (lienNotif == null) lienNotif = "";
                    
                    if (i > 0) json.append(",");
                    json.append("{");
                    json.append("\"id\":\"").append(n.getId()).append("\",");
                    json.append("\"contenu\":\"").append(contenu).append("\",");
                    json.append("\"lien\":\"").append(lienNotif).append("\",");
                    json.append("\"vu\":").append(n.getVu()).append(",");
                    json.append("\"icon\":\"").append(typeIcon).append("\",");
                    json.append("\"couleur\":\"").append(typeCouleur).append("\",");
                    json.append("\"emetteur\":\"").append(emetteur).append("\"");
                    json.append("}");
                }
            }
            json.append("]}");
            
            result = json.toString();
        }
        
    } catch (Exception e) {
        e.printStackTrace();
        String errMsg = e.getMessage() != null ? e.getMessage().replace("\"", "'") : "Erreur inconnue";
        result = "{\"success\":false,\"message\":\"Erreur: " + errMsg + "\"}";
    }
    
    out.print(result);
%>
