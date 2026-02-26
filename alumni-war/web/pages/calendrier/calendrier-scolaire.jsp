<%@ page pageEncoding="UTF-8" %>
<%@ page import="bean.*, java.util.*, java.text.SimpleDateFormat, java.sql.Date" %>
<%@ page import="user.UserEJB" %>
<% try {
    UserEJB u = (UserEJB) session.getValue("u");
    String lien = (String) session.getValue("lien");
    if (u == null || lien == null) {
        response.sendRedirect("security-login.jsp");
        return;
    }

    int refuserInt = u.getUser().getRefuser();
    String idrole = u.getUser().getIdrole() != null ? u.getUser().getIdrole() : "";
    boolean isAdmin = "admin".equalsIgnoreCase(idrole);

    // Paramètres de recherche par dates
    String dateDebutRecherche = request.getParameter("date_debut");
    String dateFinRecherche = request.getParameter("date_fin");
    
    // Nettoyer les valeurs vides
    if (dateDebutRecherche != null && dateDebutRecherche.trim().isEmpty()) {
        dateDebutRecherche = null;
    }
    if (dateFinRecherche != null && dateFinRecherche.trim().isEmpty()) {
        dateFinRecherche = null;
    }
    
    // Mode recherche activé uniquement si au moins une date est renseignée
    boolean modeRecherche = (dateDebutRecherche != null) || (dateFinRecherche != null);

    // Mois/année courant ou paramétré
    Calendar cal = Calendar.getInstance();
    String paramMois = request.getParameter("mois");
    String paramAnnee = request.getParameter("annee");
    if (paramMois != null && paramAnnee != null) {
        cal.set(Calendar.MONTH, Integer.parseInt(paramMois));
        cal.set(Calendar.YEAR, Integer.parseInt(paramAnnee));
    }
    int moisActuel = cal.get(Calendar.MONTH);
    int anneeActuelle = cal.get(Calendar.YEAR);

    cal.set(Calendar.DAY_OF_MONTH, 1);
    int premierJour = cal.get(Calendar.DAY_OF_WEEK); // 1=Dim, 2=Lun...
    int nbJours = cal.getActualMaximum(Calendar.DAY_OF_MONTH);

    // Décaler pour commencer lundi (lun=0, mar=1, ... dim=6)
    int decalage = (premierJour + 5) % 7;

    String[] nomsMois = {"Janvier", "Février", "Mars", "Avril", "Mai", "Juin",
                          "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"};

    // Navigation mois précédent/suivant
    Calendar calPrec = (Calendar) cal.clone();
    calPrec.add(Calendar.MONTH, -1);
    Calendar calSuiv = (Calendar) cal.clone();
    calSuiv.add(Calendar.MONTH, 1);

    // Charger les événements du mois
    // Premier et dernier jour du mois (ou dates de recherche)
    String dateDebutMois, dateFinMois;
    if (modeRecherche) {
        // Mode recherche par dates personnalisées
        dateDebutMois = (dateDebutRecherche != null && !dateDebutRecherche.isEmpty()) 
                        ? dateDebutRecherche : "1900-01-01";
        dateFinMois = (dateFinRecherche != null && !dateFinRecherche.isEmpty()) 
                      ? dateFinRecherche : "2099-12-31";
    } else {
        // Mode mois par défaut
        cal.set(Calendar.DAY_OF_MONTH, 1);
        dateDebutMois = new SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());
        cal.set(Calendar.DAY_OF_MONTH, nbJours);
        dateFinMois = new SimpleDateFormat("yyyy-MM-dd").format(cal.getTime());
    }

    // Filtre par promotion (optionnel)
    String filtrePromo = request.getParameter("promo");

    CalendrierScolaire filtre = new CalendrierScolaire();
    String whereClause = " AND ((date_debut <= '" + dateFinMois + "' AND (date_fin >= '" + dateDebutMois + "' OR (date_fin IS NULL AND date_debut >= '" + dateDebutMois + "'))))";
    
    // Ajouter filtre promotion si sélectionnée
    if (filtrePromo != null && !filtrePromo.isEmpty() && !"TOUTES".equals(filtrePromo)) {
        whereClause += " AND idpromotion = '" + filtrePromo + "'";
    } else if ("VIDE".equals(filtrePromo)) {
        whereClause += " AND idpromotion IS NULL";
    }
    
    whereClause += " ORDER BY date_debut";
    Object[] events = CGenUtil.rechercher(filtre, null, null, whereClause);

    // Charger les promotions pour le filtre
    Promotion promoFiltre = new Promotion();
    Object[] promos = CGenUtil.rechercher(promoFiltre, null, null, " ORDER BY annee DESC, libelle");

    // Map jour → liste d'événements
    Map<Integer, List<CalendrierScolaire>> eventsParJour = new HashMap<Integer, List<CalendrierScolaire>>();
    if (events != null) {
        for (int d = 1; d <= nbJours; d++) {
            Calendar jourCal = Calendar.getInstance();
            jourCal.set(anneeActuelle, moisActuel, d);
            long jourTime = jourCal.getTimeInMillis();
            for (int e2 = 0; e2 < events.length; e2++) {
                CalendrierScolaire ev = (CalendrierScolaire) events[e2];
                long debTime = ev.getDate_debut().getTime();
                long finTime = ev.getDate_fin() != null ? ev.getDate_fin().getTime() : debTime;
                if (jourTime >= debTime && jourTime <= finTime) {
                    if (!eventsParJour.containsKey(d)) {
                        eventsParJour.put(d, new ArrayList<CalendrierScolaire>());
                    }
                    eventsParJour.get(d).add(ev);
                }
            }
        }
    }

    // Jour actuel
    Calendar aujourdhui = Calendar.getInstance();
    int jourAujourdhui = aujourdhui.get(Calendar.DAY_OF_MONTH);
    int moisAujourdhui = aujourdhui.get(Calendar.MONTH);
    int anneeAujourdhui = aujourdhui.get(Calendar.YEAR);
%>

<div class="content-wrapper" style="background: #f4f6f9; min-height: 100vh;">
    <section class="content" style="padding: 20px;">

        <!-- Header -->
        <div class="cal-header">
            <div class="cal-header-left">
                <h1 class="cal-title"><i class="material-icons" style="vertical-align: middle; margin-right: 8px;">calendar_today</i>Calendrier Scolaire</h1>
                <p class="cal-subtitle" style="font-size: 18px; font-weight: 500; color: #0095DA;">
                    <% if (modeRecherche) { %>
                        <i class="material-icons" style="vertical-align: middle; font-size: 20px;">search</i>
                        Résultats de recherche
                        <% if (dateDebutRecherche != null && !dateDebutRecherche.isEmpty() && dateFinRecherche != null && !dateFinRecherche.isEmpty()) { %>
                            (<%= dateDebutRecherche %> - <%= dateFinRecherche %>)
                        <% } else if (dateDebutRecherche != null && !dateDebutRecherche.isEmpty()) { %>
                            (à partir du <%= dateDebutRecherche %>)
                        <% } else if (dateFinRecherche != null && !dateFinRecherche.isEmpty()) { %>
                            (jusqu'au <%= dateFinRecherche %>)
                        <% } %>
                    <% } else { %>
                        <i class="material-icons" style="vertical-align: middle; font-size: 20px;">event</i>
                        <%= nomsMois[moisActuel] %> <%= anneeActuelle %>
                    <% } %>
                </p>
            </div>
            <div class="cal-header-right">
                <!-- Filtre promotion -->
                <select id="filtrePromo" class="cal-promo-filter" onchange="filtrerPromotion()">
                    <option value="TOUTES" <%= (filtrePromo == null || filtrePromo.isEmpty() || "TOUTES".equals(filtrePromo)) ? "selected" : "" %>>Toutes les promotions</option>
                    <option value="VIDE" <%= "VIDE".equals(filtrePromo) ? "selected" : "" %>>Événements généraux</option>
                    <% if (promos != null) {
                        for (int p = 0; p < promos.length; p++) {
                            Promotion pr = (Promotion) promos[p];
                            String selected = pr.getId().equals(filtrePromo) ? "selected" : "";
                    %>
                    <option value="<%= pr.getId() %>" <%= selected %>><%= pr.getLibelle() %> (<%= pr.getAnnee() %>)</option>
                    <% }
                    } %>
                </select>
                
                <% if (isAdmin) { %>
                <a href="<%= lien %>?but=calendrier/evenement-saisie.jsp" class="btn-add-event">
                    <i class="material-icons">add</i> Nouvel événement
                </a>
                <% } %>
            </div>
        </div>

        <!-- Formulaire de recherche par dates -->
        <div class="cal-search-box" style="background: white; padding: 15px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
            <form action="<%= lien %>?but=calendrier/calendrier-scolaire.jsp" method="post" style="display: flex; align-items: center; gap: 15px; flex-wrap: wrap;">
                <div style="display: flex; align-items: center; gap: 10px;">
                    <label style="font-weight: 500; color: #555;">
                        <i class="material-icons" style="vertical-align: middle; font-size: 18px;">date_range</i>
                        Recherche par période :
                    </label>
                </div>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <label style="color: #666; font-size: 14px;">Du :</label>
                    <input type="date" name="date_debut" class="form-control" 
                           value="<%= dateDebutRecherche != null ? dateDebutRecherche : "" %>"
                           style="padding: 6px 10px; border: 1px solid #ddd; border-radius: 4px;">
                </div>
                <div style="display: flex; align-items: center; gap: 8px;">
                    <label style="color: #666; font-size: 14px;">Au :</label>
                    <input type="date" name="date_fin" class="form-control" 
                           value="<%= dateFinRecherche != null ? dateFinRecherche : "" %>"
                           style="padding: 6px 10px; border: 1px solid #ddd; border-radius: 4px;">
                </div>
                <input type="hidden" name="promo" value="<%= filtrePromo != null ? filtrePromo : "TOUTES" %>">
                <button type="submit" class="btn btn-primary btn-sm" style="padding: 6px 15px;">
                    <i class="material-icons" style="vertical-align: middle; font-size: 18px;">search</i>
                    Rechercher
                </button>
                <% if (modeRecherche) { %>
                <a href="<%= lien %>?but=calendrier/calendrier-scolaire.jsp<%= (filtrePromo != null && !filtrePromo.isEmpty() && !"TOUTES".equals(filtrePromo) ? "&promo=" + filtrePromo : "") %>" 
                   class="btn btn-default btn-sm" style="padding: 6px 15px;">
                    <i class="material-icons" style="vertical-align: middle; font-size: 18px;">clear</i>
                    Réinitialiser
                </a>
                <% } %>
            </form>
            <% if (modeRecherche) { %>
            <div style="margin-top: 10px; padding: 8px 12px; background: #e8f4fd; border-left: 3px solid #0095DA; color: #0056a3; font-size: 13px;">
                <i class="material-icons" style="vertical-align: middle; font-size: 16px;">info</i>
                Mode recherche activé 
                <% if (dateDebutRecherche != null) { %>
                    du <%= dateDebutRecherche %>
                <% } %>
                <% if (dateFinRecherche != null) { %>
                    au <%= dateFinRecherche %>
                <% } %>
            </div>
            <% } %>
        </div>

        <!-- Navigation mois -->
        <div class="cal-nav" <%= modeRecherche ? "style='display: none;'" : "" %>>
            <a href="<%= lien %>?but=calendrier/calendrier-scolaire.jsp&mois=<%= calPrec.get(Calendar.MONTH) %>&annee=<%= calPrec.get(Calendar.YEAR) %><%= (filtrePromo != null && !filtrePromo.isEmpty() ? "&promo=" + filtrePromo : "") %>" class="cal-nav-btn">
                <i class="material-icons">chevron_left</i>
            </a>
            <span class="cal-nav-label"><%= nomsMois[moisActuel] %> <%= anneeActuelle %></span>
            <a href="<%= lien %>?but=calendrier/calendrier-scolaire.jsp&mois=<%= calSuiv.get(Calendar.MONTH) %>&annee=<%= calSuiv.get(Calendar.YEAR) %><%= (filtrePromo != null && !filtrePromo.isEmpty() ? "&promo=" + filtrePromo : "") %>" class="cal-nav-btn">
                <i class="material-icons">chevron_right</i>
            </a>
            <a href="<%= lien %>?but=calendrier/calendrier-scolaire.jsp<%= (filtrePromo != null && !filtrePromo.isEmpty() ? "?promo=" + filtrePromo : "") %>" class="cal-nav-today">Aujourd'hui</a>
        </div>

        <!-- Grille calendrier -->
        <% if (!modeRecherche) { %>
        <div class="cal-grid">
            <!-- Entêtes jours -->
            <div class="cal-day-header">Lun</div>
            <div class="cal-day-header">Mar</div>
            <div class="cal-day-header">Mer</div>
            <div class="cal-day-header">Jeu</div>
            <div class="cal-day-header">Ven</div>
            <div class="cal-day-header cal-weekend">Sam</div>
            <div class="cal-day-header cal-weekend">Dim</div>

            <!-- Cases vides avant le 1er -->
            <% for (int v = 0; v < decalage; v++) { %>
            <div class="cal-cell cal-empty"></div>
            <% } %>

            <!-- Jours du mois -->
            <% for (int jour = 1; jour <= nbJours; jour++) {
                boolean estAujourdhui = (jour == jourAujourdhui && moisActuel == moisAujourdhui && anneeActuelle == anneeAujourdhui);
                int jourSemaine = (decalage + jour - 1) % 7; // 0=lun ... 6=dim
                boolean estWeekend = (jourSemaine >= 5);
                List<CalendrierScolaire> evsDuJour = eventsParJour.get(jour);
            %>
            <div class="cal-cell<%= estAujourdhui ? " cal-today" : "" %><%= estWeekend ? " cal-weekend-cell" : "" %><%= (evsDuJour != null && evsDuJour.size() > 0) ? " cal-has-events" : "" %>"
                 <% if (evsDuJour != null && evsDuJour.size() > 0) { %>onclick="showDayEvents(<%= jour %>)"<% } %>>
                <span class="cal-day-num<%= estAujourdhui ? " cal-today-num" : "" %>"><%= jour %></span>
                <% if (evsDuJour != null) {
                    int maxShow = Math.min(evsDuJour.size(), 3);
                    for (int ei = 0; ei < maxShow; ei++) {
                        CalendrierScolaire ev = evsDuJour.get(ei);
                        String couleur = ev.getCouleur() != null ? ev.getCouleur() : "#0095DA";
                %>
                <div class="cal-event-dot" style="background: <%= couleur %>;" title="<%= ev.getTitre() %>">
                    <span class="cal-event-text"><%= ev.getTitre() %></span>
                </div>
                <% }
                    if (evsDuJour.size() > 3) { %>
                <div class="cal-event-more">+<%= evsDuJour.size() - 3 %> de plus</div>
                <% }
                } %>
            </div>
            <% } %>

            <!-- Cases vides après le dernier jour -->
            <% int totalCases = decalage + nbJours;
               int restant = (7 - (totalCases % 7)) % 7;
               for (int v = 0; v < restant; v++) { %>
            <div class="cal-cell cal-empty"></div>
            <% } %>
        </div>
        <% } else { %>
        <div class="alert alert-info" style="margin-bottom: 20px; padding: 15px; background: #e8f4fd; border-left: 4px solid #0095DA;">
            <i class="material-icons" style="vertical-align: middle;">info</i>
            <strong>Mode recherche activé</strong> - La vue calendrier est masquée. Seuls les événements correspondant à vos critères sont affichés ci-dessous.
        </div>
        <% } %>

        <!-- Liste des événements du mois -->
        <div class="cal-events-list">
            <h2 class="cal-events-title">
                <% if (modeRecherche) { %>
                    Résultats de recherche (<%= events != null ? events.length : 0 %> événement<%= (events != null && events.length > 1) ? "s" : "" %>)
                <% } else { %>
                    Événements du mois
                <% } %>
            </h2>
            <% if (events == null || events.length == 0) { %>
            <div class="cal-no-events">
                <i class="material-icons" style="font-size: 48px; color: #ccc;">event_busy</i>
                <p><%= modeRecherche ? "Aucun événement trouvé pour cette période" : "Aucun événement ce mois-ci" %></p>
            </div>
            <% } else {
                SimpleDateFormat dfDate = new SimpleDateFormat("dd/MM/yyyy");
                for (int i = 0; i < events.length; i++) {
                    CalendrierScolaire ev = (CalendrierScolaire) events[i];
                    String couleur = ev.getCouleur() != null ? ev.getCouleur() : "#0095DA";
                    // Chercher le libellé de la promotion
                    String promoLib = "";
                    if (ev.getIdpromotion() != null && !ev.getIdpromotion().isEmpty() && promos != null) {
                        for (int p = 0; p < promos.length; p++) {
                            Promotion pr = (Promotion) promos[p];
                            if (pr.getId().equals(ev.getIdpromotion())) {
                                promoLib = pr.getLibelle() + " (" + pr.getAnnee() + ")";
                                break;
                            }
                        }
                    }
            %>
            <div class="cal-event-card" style="border-left: 4px solid <%= couleur %>;">
                <div class="cal-event-card-header">
                    <div class="cal-event-card-color" style="background: <%= couleur %>;"></div>
                    <div class="cal-event-card-info">
                        <h3 class="cal-event-card-title"><%= ev.getTitre() %></h3>
                        <div class="cal-event-card-dates">
                            <i class="material-icons" style="font-size: 14px;">event</i>
                            <%= dfDate.format(ev.getDate_debut()) %>
                            <% if (ev.getDate_fin() != null && !ev.getDate_fin().equals(ev.getDate_debut())) { %>
                             → <%= dfDate.format(ev.getDate_fin()) %>
                            <% } %>
                            <% if (ev.getHeure_debut() != null && !ev.getHeure_debut().isEmpty()) { %>
                            &nbsp; <i class="material-icons" style="font-size: 14px;">schedule</i>
                            <%= ev.getHeure_debut() %>
                            <% if (ev.getHeure_fin() != null && !ev.getHeure_fin().isEmpty()) { %>
                             - <%= ev.getHeure_fin() %>
                            <% } %>
                            <% } %>
                        </div>
                        <% if (!promoLib.isEmpty()) { %>
                        <div class="cal-event-card-promo">
                            <i class="material-icons" style="font-size: 14px;">school</i> <%= promoLib %>
                        </div>
                        <% } %>
                    </div>
                    <% if (isAdmin) { %>
                    <div class="cal-event-card-actions">
                        <a href="<%= lien %>?but=calendrier/evenement-modif.jsp&id=<%= ev.getId() %>" class="cal-btn-edit" title="Modifier">
                            <i class="material-icons">edit</i>
                        </a>
                        <a href="<%= lien %>?but=apresTarif.jsp&acte=delete&id=<%= ev.getId() %>&bute=calendrier/calendrier-scolaire.jsp&classe=bean.CalendrierScolaire"
                           class="cal-btn-delete" title="Supprimer" onclick="return confirm('Supprimer cet événement ?');">
                            <i class="material-icons">delete</i>
                        </a>
                    </div>
                    <% } %>
                </div>
                <% if (ev.getDescription() != null && !ev.getDescription().isEmpty()) { %>
                <p class="cal-event-card-desc"><%= ev.getDescription() %></p>
                <% } %>
            </div>
            <% }
            } %>
        </div>

    </section>
</div>

<!-- Modal détail jour -->
<div id="dayEventsModal" class="cal-modal-overlay" style="display:none;" onclick="closeDayModal(event)">
    <div class="cal-modal">
        <div class="cal-modal-header">
            <h3 id="dayEventsTitle"></h3>
            <button onclick="document.getElementById('dayEventsModal').style.display='none'" class="cal-modal-close">&times;</button>
        </div>
        <div id="dayEventsContent" class="cal-modal-body"></div>
    </div>
</div>

<style>
/* === CALENDRIER SCOLAIRE === */
.cal-header {
    display: flex; justify-content: space-between; align-items: center;
    margin-bottom: 20px; flex-wrap: wrap; gap: 12px;
}
.cal-title {
    font-size: 24px; font-weight: 700; color: #1a1a2e; margin: 0;
    display: flex; align-items: center;
}
.cal-subtitle { color: #666; margin: 4px 0 0 0; font-size: 14px; }
.btn-add-event {
    display: inline-flex; align-items: center; gap: 6px;
    background: #0095DA; color: #fff; padding: 10px 20px;
    border-radius: 8px; text-decoration: none; font-weight: 600;
    font-size: 14px; transition: background 0.2s;
}
.btn-add-event:hover { background: #007ab8; color: #fff; text-decoration: none; }
.btn-add-event .material-icons { font-size: 18px; }

/* Filtre promotion */
.cal-promo-filter {
    padding: 8px 14px; border-radius: 8px; border: 1px solid #ddd;
    background: #fff; font-size: 14px; color: #333;
    cursor: pointer; transition: all 0.2s;
    font-weight: 500; margin-right: 10px;
}
.cal-promo-filter:hover { border-color: #0095DA; }
.cal-promo-filter:focus { outline: none; border-color: #0095DA; }
.cal-header-right {
    display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
}

/* Navigation */
.cal-nav {
    display: flex; align-items: center; gap: 12px;
    margin-bottom: 20px; justify-content: center;
}
.cal-nav-btn {
    width: 36px; height: 36px; border-radius: 50%; background: #fff;
    display: flex; align-items: center; justify-content: center;
    color: #333; text-decoration: none; box-shadow: 0 1px 3px rgba(0,0,0,0.1);
    transition: all 0.2s;
}
.cal-nav-btn:hover { background: #0095DA; color: #fff; text-decoration: none; }
.cal-nav-label { font-size: 20px; font-weight: 700; color: #1a1a2e; min-width: 200px; text-align: center; }
.cal-nav-today {
    margin-left: 12px; padding: 6px 16px; border-radius: 20px;
    background: #f0f0f0; color: #333; text-decoration: none;
    font-size: 13px; font-weight: 500; transition: all 0.2s;
}
.cal-nav-today:hover { background: #0095DA; color: #fff; text-decoration: none; }

/* Grille */
.cal-grid {
    display: grid; grid-template-columns: repeat(7, 1fr);
    background: #fff; border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.06);
    overflow: hidden; margin-bottom: 30px;
}
.cal-day-header {
    padding: 12px 8px; text-align: center; font-weight: 600;
    font-size: 12px; text-transform: uppercase; color: #666;
    background: #fafafa; border-bottom: 1px solid #eee;
}
.cal-day-header.cal-weekend { color: #e74c3c; }

.cal-cell {
    min-height: 100px; padding: 8px; border: 1px solid #f0f0f0;
    position: relative; transition: background 0.15s; cursor: default;
}
.cal-cell.cal-has-events { cursor: pointer; }
.cal-cell:hover { background: #f8f9ff; }
.cal-cell.cal-empty { background: #fafafa; }
.cal-cell.cal-today { background: #e8f4fd; }
.cal-cell.cal-weekend-cell { background: #fffafa; }
.cal-cell.cal-today.cal-weekend-cell { background: #e8f4fd; }

.cal-day-num {
    display: inline-block; font-size: 14px; font-weight: 600; color: #333;
    width: 28px; height: 28px; line-height: 28px; text-align: center;
    border-radius: 50%; margin-bottom: 4px;
}
.cal-today-num { background: #0095DA; color: #fff !important; }

.cal-event-dot {
    padding: 2px 6px; border-radius: 4px; margin-bottom: 2px;
    overflow: hidden;
}
.cal-event-text {
    font-size: 11px; color: #fff; font-weight: 500;
    white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    display: block;
}
.cal-event-more { font-size: 11px; color: #999; padding: 2px 4px; }

/* Liste événements */
.cal-events-list { margin-top: 10px; }
.cal-events-title {
    font-size: 18px; font-weight: 700; color: #1a1a2e;
    margin-bottom: 16px; padding-bottom: 8px; border-bottom: 2px solid #0095DA;
    display: inline-block;
}
.cal-no-events {
    text-align: center; padding: 40px; color: #999;
    background: #fff; border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.04);
}
.cal-event-card {
    background: #fff; border-radius: 10px; padding: 16px;
    margin-bottom: 12px; box-shadow: 0 2px 6px rgba(0,0,0,0.05);
    transition: transform 0.15s, box-shadow 0.15s;
}
.cal-event-card:hover { transform: translateY(-1px); box-shadow: 0 4px 12px rgba(0,0,0,0.08); }
.cal-event-card-header { display: flex; align-items: flex-start; gap: 12px; }
.cal-event-card-color { width: 4px; min-height: 40px; border-radius: 2px; flex-shrink: 0; display: none; }
.cal-event-card-info { flex: 1; }
.cal-event-card-title { font-size: 16px; font-weight: 600; color: #1a1a2e; margin: 0 0 4px 0; }
.cal-event-card-dates { font-size: 13px; color: #666; display: flex; align-items: center; gap: 4px; flex-wrap: wrap; }
.cal-event-card-promo { font-size: 13px; color: #0095DA; margin-top: 4px; display: flex; align-items: center; gap: 4px; }
.cal-event-card-desc { font-size: 14px; color: #555; margin: 8px 0 0 0; line-height: 1.5; }
.cal-event-card-actions { display: flex; gap: 6px; flex-shrink: 0; }
.cal-btn-edit, .cal-btn-delete {
    width: 32px; height: 32px; border-radius: 6px; display: flex;
    align-items: center; justify-content: center; transition: all 0.2s;
    text-decoration: none;
}
.cal-btn-edit { background: #fff3e0; color: #f39c12; }
.cal-btn-edit:hover { background: #f39c12; color: #fff; }
.cal-btn-delete { background: #fce4ec; color: #e74c3c; }
.cal-btn-delete:hover { background: #e74c3c; color: #fff; }
.cal-btn-edit .material-icons, .cal-btn-delete .material-icons { font-size: 16px; }

/* Modal */
.cal-modal-overlay {
    position: fixed; top: 0; left: 0; right: 0; bottom: 0;
    background: rgba(0,0,0,0.4); z-index: 9999;
    display: flex; align-items: center; justify-content: center;
}
.cal-modal {
    background: #fff; border-radius: 14px; width: 90%; max-width: 480px;
    max-height: 80vh; overflow-y: auto; box-shadow: 0 20px 60px rgba(0,0,0,0.2);
}
.cal-modal-header {
    display: flex; justify-content: space-between; align-items: center;
    padding: 16px 20px; border-bottom: 1px solid #eee;
}
.cal-modal-header h3 { margin: 0; font-size: 18px; color: #1a1a2e; }
.cal-modal-close {
    background: none; border: none; font-size: 24px; color: #999;
    cursor: pointer; line-height: 1;
}
.cal-modal-body { padding: 16px 20px; }
.cal-modal-event {
    padding: 10px; border-radius: 8px; margin-bottom: 8px;
    border-left: 3px solid #0095DA;
}
.cal-modal-event-title { font-weight: 600; font-size: 14px; color: #1a1a2e; }
.cal-modal-event-time { font-size: 12px; color: #666; margin-top: 2px; }

@media (max-width: 768px) {
    .cal-cell { min-height: 60px; padding: 4px; }
    .cal-day-num { font-size: 12px; width: 22px; height: 22px; line-height: 22px; }
    .cal-event-text { font-size: 9px; }
    .cal-nav-label { font-size: 16px; min-width: 160px; }
    .cal-header { flex-direction: column; align-items: flex-start; }
}
</style>

<script>
// Données événements pour la modal
var eventsData = {};
<%
if (events != null) {
    SimpleDateFormat dfModal = new SimpleDateFormat("dd/MM/yyyy");
    for (int jour2 = 1; jour2 <= nbJours; jour2++) {
        List<CalendrierScolaire> evsJ = eventsParJour.get(jour2);
        if (evsJ != null && evsJ.size() > 0) {
%>
eventsData[<%= jour2 %>] = [
<% for (int k = 0; k < evsJ.size(); k++) {
    CalendrierScolaire evK = evsJ.get(k);
    String coul = evK.getCouleur() != null ? evK.getCouleur() : "#0095DA";
    String timeStr = "";
    if (evK.getHeure_debut() != null && !evK.getHeure_debut().isEmpty()) {
        timeStr = evK.getHeure_debut();
        if (evK.getHeure_fin() != null && !evK.getHeure_fin().isEmpty()) timeStr += " - " + evK.getHeure_fin();
    }
%>
    {titre: "<%= evK.getTitre().replace("\"", "\\\"") %>", couleur: "<%= coul %>", temps: "<%= timeStr %>", desc: "<%= evK.getDescription() != null ? evK.getDescription().replace("\"", "\\\"").replace("\n", " ") : "" %>"}
    <%= k < evsJ.size() - 1 ? "," : "" %>
<% } %>
];
<%      }
    }
}
%>

function showDayEvents(jour) {
    var evs = eventsData[jour];
    if (!evs || evs.length === 0) return;
    document.getElementById('dayEventsTitle').textContent = jour + ' <%= nomsMois[moisActuel] %> <%= anneeActuelle %>';
    var html = '';
    for (var i = 0; i < evs.length; i++) {
        html += '<div class="cal-modal-event" style="border-left-color:' + evs[i].couleur + '">';
        html += '<div class="cal-modal-event-title">' + evs[i].titre + '</div>';
        if (evs[i].temps) html += '<div class="cal-modal-event-time"><i class="material-icons" style="font-size:12px;vertical-align:middle">schedule</i> ' + evs[i].temps + '</div>';
        if (evs[i].desc) html += '<div style="font-size:13px;color:#555;margin-top:4px">' + evs[i].desc + '</div>';
        html += '</div>';
    }
    document.getElementById('dayEventsContent').innerHTML = html;
    document.getElementById('dayEventsModal').style.display = 'flex';
}

function closeDayModal(e) {
    if (e.target === document.getElementById('dayEventsModal')) {
        document.getElementById('dayEventsModal').style.display = 'none';
    }
}

function filtrerPromotion() {
    var promo = document.getElementById('filtrePromo').value;
    var mois = <%= moisActuel %>;
    var annee = <%= anneeActuelle %>;
    var url = '<%= lien %>?but=calendrier/calendrier-scolaire.jsp&mois=' + mois + '&annee=' + annee;
    if (promo && promo !== 'TOUTES') {
        url += '&promo=' + promo;
    }
    window.location.href = url;
}
</script>

<% } catch (Exception e) { e.printStackTrace(); %>
<div class="content-wrapper">
    <section class="content">
        <div class="alert alert-danger"><i class="fa fa-exclamation-triangle"></i> Erreur: <%= e.getMessage() %></div>
    </section>
</div>
<% } %>
