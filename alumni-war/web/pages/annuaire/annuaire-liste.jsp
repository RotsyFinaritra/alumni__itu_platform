<%@page import="affichage.PageRecherche"%>
<%@page import="affichage.Liste"%>
<%@page import="annuaire.UtilisateurPgLibCPL"%>
<%@page import="bean.PromotionAff"%>
<%@page import="bean.PaysAff"%>
<%@page import="bean.VilleAff"%>
<%@page import="bean.TypeUtilisateurAff"%>
<%@page import="bean.CompetenceAff"%>
<%@page import="bean.EntrepriseAff"%>
<%@page import="bean.CGenUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% 
try {
    UtilisateurPgLibCPL filtre = new UtilisateurPgLibCPL();
    
    // Champs de critères : texte et autocomplete
    // Note: idcompetence est géré via sous-requête (relation N:N), identreprise est l'ID de l'entreprise actuelle
    String listeCrt[] = {"nomuser", "prenom", "idpromotion", "idtypeutilisateur", "identreprise", "idpays", "idville"};
    String listeInt[] = {};
    // Colonnes affichées dans le tableau
    String libEntete[] = {"photo", "nomuser", "prenom", "promotion", "typeutilisateur", "competence", "entreprise", "ville", "pays", "mail"};
    
    PageRecherche pr = new PageRecherche(filtre, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Annuaire des utilisateurs");
    user.UserEJB currentUser = (user.UserEJB) session.getValue("u");
    pr.setUtilisateur(currentUser);
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("annuaire/annuaire-liste.jsp");
    pr.setNpp(24);
    
    // Exclure l'utilisateur connecté des résultats
    String whereClause = " AND refuser <> " + currentUser.getUser().getTuppleID();
    
    // Gérer la recherche par compétence (relation N:N via sous-requête)
    String idcompetence = request.getParameter("idcompetence");
    if (idcompetence != null && !idcompetence.trim().isEmpty()) {
        whereClause += " AND refuser IN (SELECT idutilisateur FROM competence_utilisateur WHERE idcompetence = '" + idcompetence.replace("'", "''") + "')";
    }
    pr.setAWhere(whereClause);
    
    // Utiliser des autocomplete avec affichage id-libelle (beans Aff)
    pr.getFormu().getChamp("idpromotion").setPageAppelComplete("bean.PromotionAff", "id", "v_promotion_aff");
    pr.getFormu().getChamp("idtypeutilisateur").setPageAppelComplete("bean.TypeUtilisateurAff", "id", "v_type_utilisateur_aff");
    pr.getFormu().getChamp("idpays").setPageAppelComplete("bean.PaysAff", "id", "v_pays_aff");
    // Ville dépend du pays sélectionné - compare avec la ville de l'entreprise actuelle
    pr.getFormu().getChamp("idpays").setAutre("onchange=\"updateVilleFilter(this.value)\"");
    pr.getFormu().getChamp("idville").setPageAppelComplete("bean.VilleAff", "id", "v_ville_aff");
    // Entreprise en autocomplete avec ID
    pr.getFormu().getChamp("identreprise").setPageAppelComplete("bean.EntrepriseAff", "id", "v_entreprise_aff");
    
    // Labels des champs de recherche
    pr.getFormu().getChamp("nomuser").setLibelle("Nom");
    pr.getFormu().getChamp("prenom").setLibelle("Pr&eacute;nom");
    pr.getFormu().getChamp("idpromotion").setLibelle("Promotion");
    pr.getFormu().getChamp("idtypeutilisateur").setLibelle("Type");
    pr.getFormu().getChamp("identreprise").setLibelle("Entreprise");
    pr.getFormu().getChamp("idpays").setLibelle("Pays");
    pr.getFormu().getChamp("idville").setLibelle("Ville");
    
    String[] colSomme = null;
    pr.creerObjetPage(libEntete, colSomme);
    
    // Récupérer les résultats pour l'affichage en cartes
    Object[] resultats = pr.getListe();
%>
<style>
.annuaire-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
    gap: 20px;
    padding: 20px 0;
}
.alumni-card {
    background: #fff;
    border-radius: 12px;
    box-shadow: 0 2px 12px rgba(0,0,0,0.08);
    overflow: hidden;
    transition: transform 0.2s, box-shadow 0.2s;
    display: block;
    cursor: pointer;
}
.alumni-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 25px rgba(0,0,0,0.12);
}
.alumni-card:focus {
    outline: 2px solid #3c8dbc;
    outline-offset: 2px;
}
.alumni-card-header {
    background: linear-gradient(135deg, #5b8dd9 0%, #4a75ba 100%);
    padding: 20px;
    text-align: center;
}
.alumni-photo {
    width: 90px;
    height: 90px;
    border-radius: 50%;
    border: 3px solid #fff;
    object-fit: cover;
    background: #e9ecef;
}
.alumni-card-body {
    padding: 15px;
}
.alumni-name {
    font-size: 16px;
    font-weight: 600;
    color: #333;
    margin: 0 0 5px 0;
    text-align: center;
}
.alumni-promo {
    font-size: 13px;
    color: #5b8dd9;
    text-align: center;
    margin-bottom: 12px;
}
.alumni-info {
    font-size: 12px;
    color: #666;
    margin: 6px 0;
    display: flex;
    align-items: flex-start;
}
.alumni-info i {
    width: 18px;
    color: #5b8dd9;
    margin-right: 8px;
    text-align: center;
}
.alumni-info span {
    flex: 1;
    word-break: break-word;
}
.alumni-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 5px;
    margin-top: 10px;
}
.alumni-tag {
    background: #e3f2fd;
    color: #1976d2;
    padding: 3px 8px;
    border-radius: 12px;
    font-size: 11px;
}
.search-section {
    background: #fff;
    padding: 20px;
    border-radius: 8px;
    margin-bottom: 20px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.05);
}
.results-count {
    color: #666;
    margin-bottom: 15px;
    font-size: 14px;
}
</style>

<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-users"></i> <%= pr.getTitre() %></h1>
        <a href="<%=pr.getLien()%>?but=accueil.jsp" class="back-link" style="float:right; margin-top:-40px;">
            <i class="fa fa-arrow-left"></i> Retour à l'accueil
        </a>
    </section>
    <section class="content">
        <!-- Formulaire de recherche -->
        <div class="search-section">
            <form action="<%=pr.getLien()%>?but=annuaire/annuaire-liste.jsp" method="post">
                <% out.println(pr.getFormu().getHtmlEnsemble()); %>
                <!-- Champ compétence supplémentaire (relation N:N, géré via sous-requête) -->
                <div class="form-group" style="margin-top: 10px;">
                    <label for="idcompetence">Comp&eacute;tence</label>
                    <input type="text" class="form-control autocomplete" id="idcompetencelibelle" name="idcompetencelibelle"
                           placeholder="Rechercher une comp&eacute;tence..."
                           ac_classe="bean.CompetenceAff" ac_nomTable="v_competence_aff" 
                           ac_champValeur="id" ac_champAffiche="aff"
                           ac_useMotCle="true" value="<%= request.getParameter("idcompetencelibelle") != null ? request.getParameter("idcompetencelibelle") : "" %>" />
                    <input type="hidden" id="idcompetence" name="idcompetence" 
                           value="<%= request.getParameter("idcompetence") != null ? request.getParameter("idcompetence") : "" %>" />
                </div>
            </form>
        </div>
        
        <!-- Résultats -->
        <% if (resultats != null && resultats.length > 0) { %>
        <div class="results-count">
            <strong><%= resultats.length %></strong> alumni trouv&eacute;(s)
        </div>
        <div class="annuaire-grid">
            <% for (Object obj : resultats) { 
                UtilisateurPgLibCPL u = (UtilisateurPgLibCPL) obj;
                String photoUrl = (u.getPhoto() != null && !u.getPhoto().isEmpty()) 
                    ? request.getContextPath() + "/profile-photo?file=" + u.getPhoto()
                    : request.getContextPath() + "/assets/img/user-placeholder.svg";
                String nomComplet = (u.getNomuser() != null ? u.getNomuser() : "") + " " + (u.getPrenom() != null ? u.getPrenom() : "");
                String profilUrl = pr.getLien() + "?but=profil/mon-profil.jsp&refuser=" + u.getRefuser();
            %>
            <a href="<%= profilUrl %>" class="alumni-card" style="text-decoration: none; color: inherit;">
                <div class="alumni-card-header">
                    <img src="<%= photoUrl %>" alt="Photo" class="alumni-photo" 
                         onerror="this.src='<%= request.getContextPath() %>/assets/img/user-placeholder.svg'">
                </div>
                <div class="alumni-card-body">
                    <h4 class="alumni-name"><%= nomComplet.trim() %></h4>
                    <% if (u.getPromotion() != null && !u.getPromotion().isEmpty()) { %>
                    <div class="alumni-promo"><i class="fa fa-graduation-cap"></i> <%= u.getPromotion() %></div>
                    <% } %>
                    
                    <% if (u.getTypeutilisateur() != null && !u.getTypeutilisateur().isEmpty()) { %>
                    <div class="alumni-info">
                        <i class="fa fa-user"></i>
                        <span><%= u.getTypeutilisateur() %></span>
                    </div>
                    <% } %>
                    
                    <% if (u.getEntreprise() != null && !u.getEntreprise().isEmpty()) { %>
                    <div class="alumni-info">
                        <i class="fa fa-building"></i>
                        <span><%= u.getEntreprise() %></span>
                    </div>
                    <% } %>
                    
                    <% if (u.getVille() != null && !u.getVille().isEmpty()) { %>
                    <div class="alumni-info">
                        <i class="fa fa-map-marker"></i>
                        <span><%= u.getVille() %><% if (u.getPays() != null && !u.getPays().isEmpty()) { %>, <%= u.getPays() %><% } %></span>
                    </div>
                    <% } %>
                    
                    <% if (u.getMail() != null && !u.getMail().isEmpty()) { %>
                    <div class="alumni-info">
                        <i class="fa fa-envelope"></i>
                        <span><%= u.getMail() %></span>
                    </div>
                    <% } %>
                    
                    <% if (u.getCompetence() != null && !u.getCompetence().isEmpty()) { 
                        String[] competences = u.getCompetence().split(",");
                        int maxTags = Math.min(competences.length, 3);
                    %>
                    <div class="alumni-tags">
                        <% for (int i = 0; i < maxTags; i++) { %>
                        <span class="alumni-tag"><%= competences[i].trim() %></span>
                        <% } %>
                        <% if (competences.length > 3) { %>
                        <span class="alumni-tag">+<%= competences.length - 3 %></span>
                        <% } %>
                    </div>
                    <% } %>
                </div>
            </a>
            <% } %>
        </div>
        
        <!-- Pagination -->
        <div style="margin-top: 20px;">
            <%= pr.getBasPage() %>
        </div>
        <% } else { %>
        <div class="alert alert-info">
            <i class="fa fa-info-circle"></i> Aucun r&eacute;sultat. Modifiez vos crit&egrave;res de recherche.
        </div>
        <% } %>
    </section>
</div>

<script>
// Fonction pour filtrer les villes en fonction du pays sélectionné
function updateVilleFilter(idpays) {
    var villeInput = document.querySelector('input[name="idville"]');
    if (villeInput) {
        // Réinitialiser le champ ville quand le pays change
        villeInput.value = '';
        
        // Mettre à jour le filtre WHERE pour l'autocomplete ville
        if (idpays && idpays.trim() !== '') {
            villeInput.setAttribute('ac_where', "AND idpays = '" + idpays + "'");
        } else {
            villeInput.removeAttribute('ac_where');
        }
    }
}
</script>

<%
} catch(Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'><strong>Erreur :</strong> " + e.getMessage() + "</div>");
}
%>