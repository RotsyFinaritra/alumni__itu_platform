<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="affichage.PageRecherche" %>
<%@ page import="bean.PostEmploiLib" %>
<%@ page import="bean.PostStageLib" %>
<%@ page import="user.UserEJB" %>
<%@ page import="utilitaire.CGenUtil" %>
<%@ page import="java.util.List" %>
<%
    try {
        UserEJB u = (UserEJB) session.getValue("u");
        String lien = (String) session.getValue("lien");

        // Compter les offres d'emploi actives (supprime=0)
        PostEmploiLib emploiCount = new PostEmploiLib();
        List listEmploi = CGenUtil.rechercher(emploiCount, u, "supprime = 0");
        int nbEmploi = (listEmploi != null) ? listEmploi.size() : 0;

        // Compter les offres de stage actives
        PostStageLib stageCount = new PostStageLib();
        List listStage = CGenUtil.rechercher(stageCount, u, "supprime = 0");
        int nbStage = (listStage != null) ? listStage.size() : 0;

        // 5 dernieres offres d'emploi
        PostEmploiLib emploiRecent = new PostEmploiLib();
        List listeRecentsEmploi = CGenUtil.rechercher(emploiRecent, u,
                "supprime = 0 ORDER BY created_at DESC LIMIT 5");

        // 5 dernieres offres de stage
        PostStageLib stageRecent = new PostStageLib();
        List listeRecentsStage = CGenUtil.rechercher(stageRecent, u,
                "supprime = 0 ORDER BY created_at DESC LIMIT 5");
%>
<div class="content-wrapper">
    <section class="content-header">
        <h1><i class="fa fa-briefcase"></i> Espace Carriere</h1>
        <ol class="breadcrumb">
            <li class="active"><i class="fa fa-home"></i> Espace Carriere</li>
        </ol>
    </section>
    <section class="content">

        <!-- Cartes de statistiques -->
        <div class="row">
            <div class="col-lg-4 col-xs-6">
                <div class="small-box bg-aqua">
                    <div class="inner">
                        <h3><%= nbEmploi %></h3>
                        <p>Offres d'emploi actives</p>
                    </div>
                    <div class="icon"><i class="fa fa-suitcase"></i></div>
                    <a href="<%=lien%>?but=carriere/emploi-liste.jsp" class="small-box-footer">
                        Voir toutes <i class="fa fa-arrow-circle-right"></i>
                    </a>
                </div>
            </div>
            <div class="col-lg-4 col-xs-6">
                <div class="small-box bg-green">
                    <div class="inner">
                        <h3><%= nbStage %></h3>
                        <p>Offres de stage actives</p>
                    </div>
                    <div class="icon"><i class="fa fa-graduation-cap"></i></div>
                    <a href="<%=lien%>?but=carriere/stage-liste.jsp" class="small-box-footer">
                        Voir toutes <i class="fa fa-arrow-circle-right"></i>
                    </a>
                </div>
            </div>
            <div class="col-lg-4 col-xs-6">
                <div class="small-box bg-yellow">
                    <div class="inner">
                        <h3><%= nbEmploi + nbStage %></h3>
                        <p>Total des opportunites</p>
                    </div>
                    <div class="icon"><i class="fa fa-star"></i></div>
                    <a href="#" class="small-box-footer">
                        &nbsp;
                    </a>
                </div>
            </div>
        </div>

        <!-- Actions rapides -->
        <div class="row">
            <div class="col-md-6">
                <a href="<%=lien%>?but=carriere/emploi-saisie.jsp"
                   class="btn btn-app bg-aqua">
                    <i class="fa fa-plus-circle"></i>
                    Publier une offre d'emploi
                </a>
                <a href="<%=lien%>?but=carriere/stage-saisie.jsp"
                   class="btn btn-app bg-green">
                    <i class="fa fa-plus-circle"></i>
                    Publier une offre de stage
                </a>
            </div>
        </div>

        <!-- Dernieres offres d'emploi -->
        <div class="row">
            <div class="col-md-6">
                <div class="box box-aqua">
                    <div class="box-header with-border">
                        <h3 class="box-title">
                            <i class="fa fa-suitcase"></i> Dernieres offres d'emploi
                        </h3>
                        <div class="box-tools pull-right">
                            <a href="<%=lien%>?but=carriere/emploi-liste.jsp"
                               class="btn btn-xs btn-default">
                                Voir tout
                            </a>
                        </div>
                    </div>
                    <div class="box-body no-padding">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Entreprise</th>
                                    <th>Poste</th>
                                    <th>Contrat</th>
                                    <th>Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (listeRecentsEmploi != null && !listeRecentsEmploi.isEmpty()) {
                                    for (Object obj : listeRecentsEmploi) {
                                        PostEmploiLib e = (PostEmploiLib) obj;
                                        String id = e.getTuppleID();
                                %>
                                <tr>
                                    <td>
                                        <a href="<%=lien%>?but=carriere/emploi-fiche.jsp&id=<%=id%>">
                                            <%=e.getEntreprise() != null ? e.getEntreprise() : ""%>
                                        </a>
                                    </td>
                                    <td><%=e.getPoste() != null ? e.getPoste() : ""%></td>
                                    <td><%=e.getType_contrat() != null ? e.getType_contrat() : ""%></td>
                                    <td><%=e.getCreated_at() != null ? e.getCreated_at().toString().substring(0,10) : ""%></td>
                                </tr>
                                <% }
                                   } else { %>
                                <tr><td colspan="4" class="text-center text-muted">Aucune offre d'emploi.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Dernieres offres de stage -->
            <div class="col-md-6">
                <div class="box box-success">
                    <div class="box-header with-border">
                        <h3 class="box-title">
                            <i class="fa fa-graduation-cap"></i> Dernieres offres de stage
                        </h3>
                        <div class="box-tools pull-right">
                            <a href="<%=lien%>?but=carriere/stage-liste.jsp"
                               class="btn btn-xs btn-default">
                                Voir tout
                            </a>
                        </div>
                    </div>
                    <div class="box-body no-padding">
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>Entreprise</th>
                                    <th>Duree</th>
                                    <th>Debut</th>
                                    <th>Date</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (listeRecentsStage != null && !listeRecentsStage.isEmpty()) {
                                    for (Object obj : listeRecentsStage) {
                                        PostStageLib s = (PostStageLib) obj;
                                        String id = s.getTuppleID();
                                %>
                                <tr>
                                    <td>
                                        <a href="<%=lien%>?but=carriere/stage-fiche.jsp&id=<%=id%>">
                                            <%=s.getEntreprise() != null ? s.getEntreprise() : ""%>
                                        </a>
                                    </td>
                                    <td><%=s.getDuree() != null ? s.getDuree() : ""%></td>
                                    <td><%=s.getDate_debut() != null ? s.getDate_debut().toString() : ""%></td>
                                    <td><%=s.getCreated_at() != null ? s.getCreated_at().toString().substring(0,10) : ""%></td>
                                </tr>
                                <% }
                                   } else { %>
                                <tr><td colspan="4" class="text-center text-muted">Aucune offre de stage.</td></tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>

    </section>
</div>
<%
    } catch (Exception e) {
        e.printStackTrace();
        String msgErr = (e.getMessage() != null) ? e.getMessage() : "Erreur inconnue";
%>
<script language="JavaScript">alert('Erreur carriere-accueil : <%=msgErr.replace("'", "\\'")%>');</script>
<%
    }
%>
