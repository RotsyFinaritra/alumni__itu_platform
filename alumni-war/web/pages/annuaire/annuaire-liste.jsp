<%@page import="affichage.PageRecherche"%>
<%@page import="affichage.Liste"%>
<%@page import="annuaire.UtilisateurPgLibCPL"%>
<%@page import="bean.Promotion"%>
<%@page import="bean.Pays"%>
<%@page import="bean.Ville"%>
<%@page import="bean.TypeUtilisateur"%>
<%@page import="bean.CGenUtil"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% 
try {
    UtilisateurPgLibCPL filtre = new UtilisateurPgLibCPL();
    
    // Champs de critères : les ID pour les selects, texte pour les autres
    String listeCrt[] = {"nomuser", "prenom", "idpromotion", "idtypeutilisateur", "competence", "entreprise", "idpays", "idville"};
    String listeInt[] = {};
    // Colonnes affichées dans le tableau
    String libEntete[] = {"photo", "nomuser", "prenom", "promotion", "typeutilisateur", "competence", "entreprise", "ville", "pays", "mail"};
    
    PageRecherche pr = new PageRecherche(filtre, request, listeCrt, listeInt, 3, libEntete, libEntete.length);
    pr.setTitre("Annuaire des Alumni");
    user.UserEJB currentUser = (user.UserEJB) session.getValue("u");
    pr.setUtilisateur(currentUser);
    pr.setLien((String) session.getValue("lien"));
    pr.setApres("annuaire/annuaire-liste.jsp");
    pr.setNpp(24);
    
    // Exclure l'utilisateur connecté des résultats
    pr.setAWhere(" AND refuser <> " + currentUser.getUser().getTuppleID());
    
    // Convertir les champs FK en listes déroulantes
    Liste[] listes = new Liste[3];
    listes[0] = new Liste("idtypeutilisateur", new TypeUtilisateur(), "libelle", "id");
    listes[1] = new Liste("idpays", new Pays(), "libelle", "id");
    listes[2] = new Liste("idville", new Ville(), "libelle", "id");
    pr.getFormu().changerEnChamp(listes);
    
    // Promotion avec autocomplete recherchable
    pr.getFormu().getChamp("idpromotion").setPageAppelComplete("bean.Promotion", "id", "promotion");
    
    // Labels des champs de recherche
    pr.getFormu().getChamp("nomuser").setLibelle("Nom");
    pr.getFormu().getChamp("prenom").setLibelle("Pr&eacute;nom");
    pr.getFormu().getChamp("idpromotion").setLibelle("Promotion");
    pr.getFormu().getChamp("idtypeutilisateur").setLibelle("Type");
    pr.getFormu().getChamp("competence").setLibelle("Comp&eacute;tence");
    pr.getFormu().getChamp("entreprise").setLibelle("Entreprise");
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
    background: linear-gradient(135deg, #3c8dbc 0%, #2c6090 100%);
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
    color: #3c8dbc;
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
    color: #3c8dbc;
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
<%
} catch(Exception e) {
    e.printStackTrace();
    out.println("<div class='alert alert-danger'><strong>Erreur :</strong> " + e.getMessage() + "</div>");
}
%>