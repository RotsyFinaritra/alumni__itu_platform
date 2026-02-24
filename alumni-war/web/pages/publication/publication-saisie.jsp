<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<%@ page import="bean.*" %>
<%@ page import="user.UserEJB" %>
<%@ page import="utilitaire.UtilDB" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>

<%
    UserEJB u = (UserEJB) session.getValue("u");
    int idutilisateur = 0;
    
    if (u != null && u.getUser() != null) {
        idutilisateur = Integer.parseInt(u.getUser().getTuppleID());
    } else {
        response.sendRedirect("login.jsp");
        return;
    }
    
    // Récupérer les types de publication
    List<Map<String, String>> typesPublication = new ArrayList<>();
    List<Map<String, String>> visibilites = new ArrayList<>();
    
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        conn = new UtilDB().GetConn();
        
        // Types de publication
        ps = conn.prepareStatement("SELECT id, libelle, code, icon, couleur FROM type_publication WHERE actif = true ORDER BY ordre");
        rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, String> type = new HashMap<>();
            type.put("id", rs.getString("id"));
            type.put("libelle", rs.getString("libelle"));
            type.put("code", rs.getString("code"));
            type.put("icon", rs.getString("icon"));
            type.put("couleur", rs.getString("couleur"));
            typesPublication.add(type);
        }
        rs.close();
        ps.close();
        
        // Visibilités
        ps = conn.prepareStatement("SELECT id, libelle, code, icon, couleur, description FROM visibilite_publication WHERE actif = true ORDER BY ordre");
        rs = ps.executeQuery();
        while (rs.next()) {
            Map<String, String> visi = new HashMap<>();
            visi.put("id", rs.getString("id"));
            visi.put("libelle", rs.getString("libelle"));
            visi.put("code", rs.getString("code"));
            visi.put("icon", rs.getString("icon"));
            visi.put("couleur", rs.getString("couleur"));
            visi.put("description", rs.getString("description"));
            visibilites.add(visi);
        }
        
    } catch (Exception e) {
        e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (Exception ignored) {}
        if (ps != null) try { ps.close(); } catch (Exception ignored) {}
        if (conn != null) try { conn.close(); } catch (Exception ignored) {}
    }
%>

<style>
.publication-form-container { max-width: 800px; margin: 20px auto; padding: 0 15px; }
.form-card { background: #fff; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.1); overflow: hidden; }
.form-header { padding: 25px; border-bottom: 2px solid #f0f0f0; background: linear-gradient(135deg, #00a65a 0%, #008d4c 100%); color: #fff; }
.form-header h2 { margin: 0 0 8px 0; font-size: 26px; }
.form-header p { margin: 0; opacity: 0.9; font-size: 14px; }

.form-body { padding: 30px; }
.form-group { margin-bottom: 25px; }
.form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #333; font-size: 14px; }
.form-group label .required { color: #e74c3c; margin-left: 3px; }
.form-group .help-text { font-size: 12px; color: #999; margin-top: 5px; }

.form-control { width: 100%; padding: 12px 15px; border: 1px solid #ddd; border-radius: 6px; font-size: 14px; transition: border-color 0.3s, box-shadow 0.3s; box-sizing: border-box; font-family: inherit; }
.form-control:focus { outline: none; border-color: #00a65a; box-shadow: 0 0 0 3px rgba(0, 166, 90, 0.1); }

textarea.form-control { min-height: 200px; resize: vertical; line-height: 1.6; }

.radio-group, .checkbox-group { display: flex; flex-wrap: wrap; gap: 15px; }
.radio-option, .checkbox-option { flex: 1; min-width: 200px; }
.radio-option input[type="radio"], .checkbox-option input[type="checkbox"] { display: none; }
.radio-option label, .checkbox-option label { display: flex; align-items: center; padding: 15px; border: 2px solid #e0e0e0; border-radius: 8px; cursor: pointer; transition: all 0.3s; }
.radio-option label:hover, .checkbox-option label:hover { border-color: #00a65a; background: #f8fff8; }
.radio-option input:checked + label, .checkbox-option input:checked + label { border-color: #00a65a; background: #f0f9f4; }

.option-icon { width: 40px; height: 40px; display: flex; align-items: center; justify-content: center; border-radius: 8px; margin-right: 12px; font-size: 18px; color: #fff; flex-shrink: 0; }
.option-content { flex: 1; }
.option-title { font-weight: 600; color: #333; margin: 0 0 3px 0; font-size: 14px; }
.option-description { font-size: 12px; color: #666; margin: 0; }

.form-actions { display: flex; gap: 15px; justify-content: flex-end; padding: 20px 30px; border-top: 1px solid #f0f0f0; background: #fafafa; }
.btn { padding: 12px 30px; border-radius: 6px; font-size: 14px; font-weight: 600; cursor: pointer; transition: all 0.3s; border: none; text-decoration: none; display: inline-block; }
.btn-primary { background: #00a65a; color: #fff; }
.btn-primary:hover { background: #008d4c; }
.btn-secondary { background: #95a5a6; color: #fff; }
.btn-secondary:hover { background: #7f8c8d; }

.alert { padding: 15px 20px; border-radius: 6px; margin-bottom: 20px; }
.alert-success { background: #d4edda; border: 1px solid #c3e6cb; color: #155724; }
.alert-error { background: #f8d7da; border: 1px solid #f5c6cb; color: #721c24; }
.alert i { margin-right: 8px; }

@media (max-width: 768px) {
    .publication-form-container { padding: 0; }
    .form-card { border-radius: 0; }
    .radio-option, .checkbox-option { min-width: 100%; }
    .form-actions { flex-direction: column; }
    .btn { width: 100%; text-align: center; }
}
</style>

<div class="publication-form-container">
    <div class="form-card">
        <div class="form-header">
            <h2><i class="fa fa-pencil-square-o"></i> Créer une publication</h2>
            <p>Partagez une offre, un événement ou une discussion avec la communauté</p>
        </div>
        
        <% 
        String successMsg = (String) session.getAttribute("success");
        String errorMsg = (String) session.getAttribute("error");
        if (successMsg != null) {
            session.removeAttribute("success");
        %>
        <div class="alert alert-success" style="margin: 20px;">
            <i class="fa fa-check-circle"></i> <%= successMsg %>
        </div>
        <% } %>
        <% if (errorMsg != null) {
            session.removeAttribute("error");
        %>
        <div class="alert alert-error" style="margin: 20px;">
            <i class="fa fa-exclamation-triangle"></i> <%= errorMsg %>
        </div>
        <% } %>
        
        <form method="post" action="publication/save-publication.jsp" id="publicationForm">
            <div class="form-body">
                
                <!-- Type de publication -->
                <div class="form-group">
                    <label>Type de publication <span class="required">*</span></label>
                    <div class="radio-group">
                        <% 
                        for (Map<String, String> type : typesPublication) { 
                            String checked = type.get("code").equals("discussion") ? "checked" : "";
                        %>
                        <div class="radio-option">
                            <input type="radio" 
                                   name="idtypepublication" 
                                   id="type-<%= type.get("code") %>" 
                                   value="<%= type.get("id") %>" 
                                   <%= checked %>
                                   required>
                            <label for="type-<%= type.get("code") %>">
                                <div class="option-icon" style="background-color: <%= type.get("couleur") %>;">
                                    <i class="<%= type.get("icon") %>"></i>
                                </div>
                                <div class="option-content">
                                    <div class="option-title"><%= type.get("libelle") %></div>
                                </div>
                            </label>
                        </div>
                        <% } %>
                    </div>
                </div>
                
                <!-- Visibilité -->
                <div class="form-group">
                    <label>Visibilité <span class="required">*</span></label>
                    <div class="radio-group">
                        <% 
                        for (Map<String, String> visi : visibilites) {
                            String checked = visi.get("code").equals("public") ? "checked" : "";
                        %>
                        <div class="radio-option">
                            <input type="radio" 
                                   name="idvisibilite" 
                                   id="visi-<%= visi.get("code") %>" 
                                   value="<%= visi.get("id") %>" 
                                   <%= checked %>
                                   required>
                            <label for="visi-<%= visi.get("code") %>">
                                <div class="option-icon" style="background-color: <%= visi.get("couleur") %>;">
                                    <i class="<%= visi.get("icon") %>"></i>
                                </div>
                                <div class="option-content">
                                    <div class="option-title"><%= visi.get("libelle") %></div>
                                    <div class="option-description"><%= visi.get("description") %></div>
                                </div>
                            </label>
                        </div>
                        <% } %>
                    </div>
                </div>
                
                <!-- Contenu -->
                <div class="form-group">
                    <label for="contenu">Contenu <span class="required">*</span></label>
                    <textarea name="contenu" 
                              id="contenu" 
                              class="form-control" 
                              placeholder="Partagez votre message avec la communauté..." 
                              required
                              maxlength="10000"></textarea>
                    <div class="help-text">
                        <span id="charCount">0</span> / 10 000 caractères
                    </div>
                </div>
                
                <!-- Options -->
                <div class="form-group">
                    <label>Options</label>
                    <div class="checkbox-group">
                        <div class="checkbox-option">
                            <input type="checkbox" name="epingle" id="epingle" value="true">
                            <label for="epingle">
                                <div class="option-icon" style="background-color: #f39c12;">
                                    <i class="fa fa-thumb-tack"></i>
                                </div>
                                <div class="option-content">
                                    <div class="option-title">Épingler la publication</div>
                                    <div class="option-description">Reste en haut de votre profil</div>
                                </div>
                            </label>
                        </div>
                    </div>
                </div>
                
            </div>
            
            <div class="form-actions">
                <a href="module.jsp?but=publication/mes-publications.jsp&currentMenu=MENDYN100-2" class="btn btn-secondary">
                    <i class="fa fa-times"></i> Annuler
                </a>
                <button type="submit" class="btn btn-primary">
                    <i class="fa fa-check"></i> Publier
                </button>
            </div>
        </form>
    </div>
</div>

<script>
// Compteur de caractères
$(document).ready(function() {
    $('#contenu').on('input', function() {
        var length = $(this).val().length;
        $('#charCount').text(length);
        
        if (length > 9000) {
            $('#charCount').css('color', '#e74c3c');
        } else {
            $('#charCount').css('color', '#666');
        }
    });
    
    // Validation avant soumission
    $('#publicationForm').on('submit', function(e) {
        var contenu = $('#contenu').val().trim();
        
        if (contenu.length < 10) {
            e.preventDefault();
            alert('Le contenu doit contenir au moins 10 caractères.');
            return false;
        }
        
        return true;
    });
});
</script>
