<%@page contentType="text/html;charset=UTF-8" %>
<%@page import="affichage.PageRecherche" %>
<%@page import="bean.SignalementPublication" %>
<%@page import="bean.SignalementCommentaire" %>
<%@page import="bean.CGenUtil" %>
<%@page import="user.UserEJB" %>
<% try {
    // Vérifier que l'utilisateur est admin ou modérateur
    UserEJB currentUser = (UserEJB) session.getValue("u");
    String role = currentUser != null ? currentUser.getUser().getIdrole() : "";
    if (currentUser == null || (!"admin".equals(role) && !"moderateur".equals(role))) {
        out.println("<div class='alert alert-danger' style='margin:20px;'><i class='fa fa-exclamation-circle'></i> Acc&egrave;s r&eacute;serv&eacute; aux administrateurs et mod&eacute;rateurs.</div>");
        return;
    }
    
    String lien = (String) session.getValue("lien");
    
    // Onglet actif (par défaut: publications)
    String tab = request.getParameter("tab");
    if (tab == null || tab.isEmpty()) {
        tab = "publications";
    }
    boolean isPublications = "publications".equals(tab);
    
    // ========== SIGNALEMENTS PUBLICATIONS ==========
    SignalementPublication tPub = new SignalementPublication();
    String[] listeCrtPub = {"id", "signaleur_nom", "motif_libelle", "statut_libelle"};
    String[] listeIntPub = {};
    String[] libEntetePub = {"id", "created_at", "signaleur_nom", "publication_auteur", "motif_libelle", "statut_libelle"};

    PageRecherche prPub = new PageRecherche(tPub, request, listeCrtPub, listeIntPub, 3, libEntetePub, libEntetePub.length);
    prPub.setTitre("Publications signal&eacute;es");
    prPub.setUtilisateur(currentUser);
    prPub.setLien(lien);
    prPub.setApres("moderation/signalement-liste.jsp&tab=publications");

    prPub.getFormu().getChamp("id").setLibelle("ID");
    prPub.getFormu().getChamp("signaleur_nom").setLibelle("Signaleur");
    prPub.getFormu().getChamp("motif_libelle").setLibelle("Motif");
    prPub.getFormu().getChamp("statut_libelle").setLibelle("Statut");

    prPub.setNpp(15);
    prPub.creerObjetPage(libEntetePub, null);

    String[] lienTableauPub = {prPub.getLien() + "?but=moderation/signalement-fiche.jsp&type=publication"};
    prPub.getTableau().setLien(lienTableauPub);
    prPub.getTableau().setColonneLien(new String[]{"id"});
    prPub.getTableau().setLibelleAffiche(new String[]{"ID", "Date", "Signal&eacute; par", "Auteur", "Motif", "Statut"});

    // Compter publications en attente
    SignalementPublication sigPubAttente = new SignalementPublication();
    sigPubAttente.setStatut_code("en_attente");
    Object[] pubAttente = CGenUtil.rechercher(sigPubAttente, null, null, "");
    int nbPubAttente = pubAttente != null ? pubAttente.length : 0;

    // ========== SIGNALEMENTS COMMENTAIRES ==========
    SignalementCommentaire tComm = new SignalementCommentaire();
    String[] listeCrtComm = {"id", "signaleur_nom", "motif_libelle", "statut_libelle"};
    String[] listeIntComm = {};
    String[] libEnteteComm = {"id", "created_at", "signaleur_nom", "commentaire_auteur", "motif_libelle", "statut_libelle"};

    PageRecherche prComm = new PageRecherche(tComm, request, listeCrtComm, listeIntComm, 3, libEnteteComm, libEnteteComm.length);
    prComm.setTitre("Commentaires signal&eacute;s");
    prComm.setUtilisateur(currentUser);
    prComm.setLien(lien);
    prComm.setApres("moderation/signalement-liste.jsp&tab=commentaires");

    prComm.getFormu().getChamp("id").setLibelle("ID");
    prComm.getFormu().getChamp("signaleur_nom").setLibelle("Signaleur");
    prComm.getFormu().getChamp("motif_libelle").setLibelle("Motif");
    prComm.getFormu().getChamp("statut_libelle").setLibelle("Statut");

    prComm.setNpp(15);
    prComm.creerObjetPage(libEnteteComm, null);

    String[] lienTableauComm = {prComm.getLien() + "?but=moderation/signalement-fiche.jsp&type=commentaire"};
    prComm.getTableau().setLien(lienTableauComm);
    prComm.getTableau().setColonneLien(new String[]{"id"});
    prComm.getTableau().setLibelleAffiche(new String[]{"ID", "Date", "Signal&eacute; par", "Auteur", "Motif", "Statut"});

    // Compter commentaires en attente
    SignalementCommentaire sigCommAttente = new SignalementCommentaire();
    sigCommAttente.setStatut_code("en_attente");
    Object[] commAttente = CGenUtil.rechercher(sigCommAttente, null, null, "");
    int nbCommAttente = commAttente != null ? commAttente.length : 0;
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-flag"></i> Gestion des Signalements</h1>
        <ol class="breadcrumb">
            <li><a href="<%=lien%>?but=moderation/moderation-liste.jsp"><i class="fa fa-shield"></i> Mod&eacute;ration</a></li>
            <li class="active">Signalements</li>
        </ol>
    </section>
    <section class="content">
        <!-- Navigation par onglets -->
        <div class="nav-tabs-custom">
            <ul class="nav nav-tabs">
                <li class="<%= isPublications ? "active" : "" %>">
                    <a href="<%=lien%>?but=moderation/signalement-liste.jsp&tab=publications">
                        <i class="fa fa-file-text"></i> Publications
                        <% if (nbCommAttente > 0) { %>
                        <span class="badge bg-red"><%= nbCommAttente %></span>
                        <% } %>
                    </a>
                </li>
                <li class="<%= !isPublications ? "active" : "" %>">
                    <a href="<%=lien%>?but=moderation/signalement-liste.jsp&tab=commentaires">
                        <i class="fa fa-comment"></i> Commentaires
                        <% if (nbPubAttente > 0) { %>
                        <span class="badge bg-blue"><%= nbPubAttente %></span>
                        <% } %>
                    </a>
                </li>
            </ul>
            
            <div class="tab-content">
                <% if (isPublications) { %>
                <!-- Onglet Publications -->
                <div class="tab-pane active">
                    <div class="box box-solid">
                        <div class="box-header with-border">
                            <h3 class="box-title"><i class="fa fa-search"></i> Recherche</h3>
                            <div class="box-tools pull-right">
                                <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i></button>
                            </div>
                        </div>
                        <div class="box-body">
                            <form action="<%=prPub.getLien()%>?but=<%= prPub.getApres() %>" method="post">
                                <% out.println(prPub.getFormu().getHtmlEnsemble()); %>
                            </form>
                        </div>
                    </div>
                    <div class="box">
                        <div class="box-header with-border">
                            <h3 class="box-title"><i class="fa fa-list"></i> Publications signal&eacute;es</h3>
                        </div>
                        <div class="box-body table-responsive">
                            <% out.println(prPub.getTableau().getHtml()); %>
                            <% out.println(prPub.getBasPage()); %>
                        </div>
                    </div>
                </div>
                <% } else { %>
                <!-- Onglet Commentaires -->
                <div class="tab-pane active">
                    <div class="box box-solid">
                        <div class="box-header with-border">
                            <h3 class="box-title"><i class="fa fa-search"></i> Recherche</h3>
                            <div class="box-tools pull-right">
                                <button type="button" class="btn btn-box-tool" data-widget="collapse"><i class="fa fa-minus"></i></button>
                            </div>
                        </div>
                        <div class="box-body">
                            <form action="<%=prComm.getLien()%>?but=<%= prComm.getApres() %>" method="post">
                                <% out.println(prComm.getFormu().getHtmlEnsemble()); %>
                            </form>
                        </div>
                    </div>
                    <div class="box">
                        <div class="box-header with-border">
                            <h3 class="box-title"><i class="fa fa-list"></i> Commentaires signal&eacute;s</h3>
                        </div>
                        <div class="box-body table-responsive">
                            <% out.println(prComm.getTableau().getHtml()); %>
                            <% out.println(prComm.getBasPage()); %>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </div>
    </section>
</div>
<% } catch (Exception e) {
    e.printStackTrace();
%>
<div class="alert alert-danger" style="margin:20px;">
    <i class="fa fa-exclamation-circle"></i> Erreur: <%=e.getMessage()%>
</div>
<% } %>
