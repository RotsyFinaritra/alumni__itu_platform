<%
    String lien = (String) session.getAttribute("lien");
    String but = request.getParameter("but");
    String entmenu = (String) session.getAttribute("entmenu");
%>
<aside class="main-sidebar">
    <!-- sidebar: style can be found in sidebar.less -->
    <section class="sidebar">
        <!-- sidebar menu: : style can be found in sidebar.less -->
        <ul class="sidebar-menu" id="menuslider">
            <li class="header">Gestion de Paie</li>
            <li class="treeview">
                <a href="#">
                    <i class="fa fa-globe"></i> <span>Employ&eacute;</span> <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/employe/infopersonel-liste.jsp"><i class="fa fa-list-alt"></i>Liste</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/employe/employe-saisie.jsp"><i class="fa fa-plus"></i>Cr&eacute;ation</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/employe/employe-analyse.jsp"><i class="fa fa-search"></i>Analyse</a></li>
                </ul>
            </li>
            <li class="treeview">
                <a href="#">
                    <i class="fa fa-globe"></i> <span>Avancement</span> <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">           
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/avancement/avancement-liste.jsp"><i class="fa fa-list-alt"></i>Liste</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/avancement/avancement-saisie.jsp"><i class="fa fa-plus"></i>Cr&eacute;ation</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/avancement/avancement-analyse.jsp"><i class="fa fa-search"></i>Analyse</a></li>
                </ul>
            </li>
            <li class="treeview">
                <a href="#">
                    <i class="fa fa-globe"></i> <span>&Eacute;l&eacute;ment de Paie</span> <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/element/element-liste.jsp"><i class="fa fa-list-alt"></i>Liste</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/element/element-saisie.jsp"><i class="fa fa-plus"></i>Cr&eacute;ation</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/element/element-analyse.jsp"><i class="fa fa-search"></i>Analyse</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/element/histoelementdepaie-liste.jsp"><i class="fa fa-search"></i>Historique</a></li>

                    <li class="treeview">
                        <a href="#">
                            <i class="fa fa-globe"></i> <span>Rubrique</span> <i class="fa fa-angle-left pull-right"></i>
                        </a>
                        <ul class="treeview-menu">
                            <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/element/rubrique-liste.jsp"><i class="fa fa-list-alt"></i>Liste</a></li>
                            <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/element/rubrique-saisie.jsp"><i class="fa fa-plus"></i>Cr&eacute;ation</a></li>
                        </ul>
                    </li>


                </ul>
            </li>
            <li class="treeview">
                <a href="#">
                    <i class="fa fa-globe"></i> <span>Demande Avance</span> <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/demandeavance/demandeavance-liste.jsp"><i class="fa fa-list-alt"></i>Liste</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/demandeavance/demandeavance-saisie.jsp"><i class="fa fa-plus"></i>Cr&eacute;ation</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/demandeavance/demandeavance-analyse.jsp"><i class="fa fa-search"></i>Analyse</a></li>
                </ul>
            </li>
            <li class="treeview">
                <a href="#">
                    <i class="fa fa-globe"></i> <span>Pr&ecirc;t</span> <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/pret/pret-liste.jsp"><i class="fa fa-list-alt"></i>Liste</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/pret/pret-saisie.jsp"><i class="fa fa-plus"></i>Cr&eacute;ation</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/pret/pret-analyse.jsp"><i class="fa fa-search"></i>Analyse</a></li>
                </ul>
            </li>
            <li class="treeview">
                <a href="#">
                    <i class="fa fa-globe"></i> <span>Edition</span> <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">

                    <li class="treeview">
                        <a href="#">
                            <i class="fa fa-globe"></i> <span>Formation</span> <i class="fa fa-angle-left pull-right"></i>
                        </a>
                        <ul class="treeview-menu">
                            <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/edition/formation-liste.jsp"><i class="fa fa-list-alt"></i>Liste</a></li>
                            <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/edition/formation-saisie.jsp"><i class="fa fa-plus"></i>Cr&eacute;ation</a></li>
                            <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/edition/formation-analyse.jsp"><i class="fa fa-search"></i>Analyse</a></li>
                        </ul>
                    </li>
                    <li class="treeview">
                        <a href="#">
                            <i class="fa fa-globe"></i> <span>Exercice hors CNaPS</span> <i class="fa fa-angle-left pull-right"></i>
                        </a>
                        <ul class="treeview-menu">
                            <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/edition/exhorscnaps-liste.jsp"><i class="fa fa-list-alt"></i>Liste</a></li>
                            <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/edition/exhorscnaps-saisie.jsp"><i class="fa fa-plus"></i>Cr&eacute;ation</a></li>
                            <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/edition/exhorscnaps-analyse.jsp"><i class="fa fa-search"></i>Analyse</a></li>
                        </ul>
                    </li>

                </ul>
            </li>
            <li class="treeview">
                <a href="#">
                    <i class="fa fa-globe"></i> <span>Paiement</span> <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/paiement/paiement-liste.jsp"><i class="fa fa-list-alt"></i>Liste</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/paiement/paiement-saisie.jsp"><i class="fa fa-plus"></i>Cr&eacute;ation</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/paiement/paiement-analyse.jsp"><i class="fa fa-search"></i>Analyse</a></li>
                </ul>
            </li>
            <li class="treeview">
                <a href="#">
                    <i class="fa fa-wrench"></i> <span>Configuration</span> <i class="fa fa-angle-left pull-right"></i>
                </a>
                <ul class="treeview-menu">
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/configuration/idvaldesce.jsp&ciblename=PAIE_TYPE_REMBOURSEMENT"><i class="fa fa-circle-o"></i>Type Remboursement</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/configuration/idvaldesce.jsp&ciblename=PAIE_NATURE_PRET"><i class="fa fa-circle-o"></i>Nature Pr&ecirc;t</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/configuration/idvaldesce.jsp&ciblename=PAIE_CAT_MODIF"><i class="fa fa-circle-o"></i>Cat&eacute;gorie Motif</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/configuration/idvaldesce.jsp&ciblename=PAIE_TYPEPAIEMENT"><i class="fa fa-circle-o"></i>Type de paiement</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/configuration/idvaldesce.jsp&ciblename=PAIE_MODEPAIEMENT"><i class="fa fa-circle-o"></i>Mode de paiement</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/configuration/idvaldesce.jsp&ciblename=SIG_FARITANY"><i class="fa fa-circle-o"></i>Faritany</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/configuration/idvaldesce.jsp&ciblename=PAIE_BANQUE"><i class="fa fa-circle-o"></i>Banque</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/configuration/idvaldesce.jsp&ciblename=PAIE_FONCTION"><i class="fa fa-circle-o"></i>Fonction</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/configuration/idvaldesce.jsp&ciblename=PAIE_CATEGORIE"><i class="fa fa-circle-o"></i>Cat&eacute;gorie</a></li>
                    <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/configuration/idvaldesce.jsp&ciblename=PAIE_DOMAINE"><i class="fa fa-circle-o"></i>Domaine</a></li>
                    <li class="treeview">
                        <a href="#">
                            <i class="fa fa-globe"></i> <span>Diplome</span> <i class="fa fa-angle-left pull-right"></i>
                        </a>
                        <ul class="treeview-menu">
                            <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/configuration/diplome-liste.jsp"><i class="fa fa-list-alt"></i>Liste</a></li>
                            <li><a href="${pageContext.request.contextPath}/pages/paie.jsp?but=paie/configuration/diplome-saisie.jsp"><i class="fa fa-plus"></i>Cr&eacute;ation</a></li>
                        </ul>
                    </li>

                </ul>
            </li>
            <li class="treeview"><a href="${pageContext.request.contextPath}/pages/module.jsp?but=travailleur/travailleur-liste.jsp&idmenu=module.jsp"><i class="fa fa-mail-reply"></i><span>Revenir au menu general</span></a></li>
        </ul>
    </section>
    <!-- /.sidebar -->
</aside>