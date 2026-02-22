<%@ page pageEncoding="UTF-8" contentType="text/html; charset=UTF-8" %>
<link href="${pageContext.request.contextPath}/assets/css/accueil.css" rel="stylesheet" type="text/css" />
<div class="content-wrapper">
    
    <div class="row m-0">
        <div class="col-md-12 nopadding">
            <h1 class="title-service h142pxBold m-0">Bienvenue sur votre espace de gestion</h1>
            <p class="desc-service h617pxRegular">Planifiez, suivez et analysez l&rsquo;avancement de vos projets en toute simplicit&eacute; gr&acirc;ce &agrave; une interface intuitive.</p>
        </div>
        <div class="col-md-12 nopadding card-wrapper">
            <a href="module.jsp?but=chart/projet-etat-kanban.jsp&currentMenu=MENDYN253" class="card col-md-4">
                <i class="fa fa fa-solid   fa-arrow-right arrow"></i>
                <img src="${pageContext.request.contextPath}/assets/img/kanban.png" class="icon" />
                <div class="card-content">
                    <h3 class="h617pxSemibold">Kanban Projets</h3>
                    <p class="Body14pxRegular">Organisez vos tâches et visualisez l’état d’avancement par colonne.</p>
                </div>
            </a>

            <a href="module.jsp?but=tache/tache-liste.jsp&currentMenu=MEN0006" class="card col-md-4">
                <i class="fa fa fa-solid   fa-arrow-right arrow"></i>
                <img src="${pageContext.request.contextPath}/assets/img/tache.png" class="icon" />
                <div class="card-content">
                    <h3 class="h617pxSemibold">Tâches du jour</h3>
                    <p class="Body14pxRegular">Consultez les tâches planifiées pour la journée et restez organisé.</p>
                </div>
            </a>

            <a href="module.jsp?but=creationprojet/etatprojet.jsp&currentMenu=MENDYN252" class="card col-md-4">
                <i class="fa fa fa-solid   fa-arrow-right arrow"></i>
                <img src="${pageContext.request.contextPath}/assets/img/gantt.png" class="icon" />
                <div class="card-content">
                    <h3 class="h617pxSemibold">Visualisation Projets par Phase</h3>
                    <p class="Body14pxRegular">Obtenez une vue d’ensemble de l’état de vos projets en un clin d’œil.</p>
                </div>
            </a>

            <a href="module.jsp?but=chart/analyse.jsp&currentMenu=MENDYN251" class="card col-md-4">
                <i class="fa fa fa-solid   fa-arrow-right arrow"></i>
                <img src="${pageContext.request.contextPath}/assets/img/chart.png" class="icon" />
                <div class="card-content">
                    <h3 class="h617pxSemibold">Dashboard</h3>
                    <p class="Body14pxRegular">Visualisez les indicateurs clés de performance de vos projets.</p>
                </div>
            </a>

            <a href="module.jsp?but=filemanager/file-liste-2.jsp&currentMenu=MEN0081" class="card col-md-4">
                <i class="fa fa fa-solid   fa-arrow-right arrow"></i>
                <img src="${pageContext.request.contextPath}/assets/img/gestion-fichiers.png" class="icon" />
                <div class="card-content">
                    <h3 class="h617pxSemibold">Gestion de fichiers</h3>
                    <p class="Body14pxRegular">Centralisez, consultez et partagez vos documents de projet en toute sécurité.</p>
                </div>
            </a>
            <a href="module.jsp?but=analyse/analyse-creation-tache.jsp&currentMenu=MF001i" class="card col-md-4">
                <i class="fa fa fa-solid   fa-arrow-right arrow"></i>
                <img src="${pageContext.request.contextPath}/assets/img/creationtache.png" class="icon" />
                <div class="card-content">
                    <h3 class="h617pxSemibold">État de création de tâches</h3>
                    <p class="Body14pxRegular">Suivez la création des tâches par responsable en temps réel</p>
                </div>
            </a>
            <a href="module.jsp?but=analyse/analyse-croise-duree.jsp&currentMenu=MENSE003" class="card col-md-4">
                <i class="fa fa fa-solid   fa-arrow-right arrow"></i>
                <img src="${pageContext.request.contextPath}/assets/img/timingtache.png" class="icon" />
                <div class="card-content">
                    <h3 class="h617pxSemibold">Timing des Tâches</h3>
                    <p class="Body14pxRegular">Comparez les durées estimées et réelles pour chaque tâche.</p>
                </div>
            </a>
            <a href="module.jsp?but=etatGlobal/etat-tache-par-jour-complet.jsp&currentMenu=MEN0085ii" class="card col-md-4">
                <i class="fa fa fa-solid   fa-arrow-right arrow"></i>
                <img src="${pageContext.request.contextPath}/assets/img/ressources.png" class="icon" />
                <div class="card-content">
                    <h3 class="h617pxSemibold">État par ressource par jour</h3>
                    <p class="Body14pxRegular">Analysez les tâches attribuées et terminées par ressource chaque jour.</p>
                </div>
            </a>

        </div>
    </div>
</div>
