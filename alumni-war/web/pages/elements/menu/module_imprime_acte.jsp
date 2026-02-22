<%@page import="menu.MenuDynamique"%>
<%@page import="java.util.ArrayList"%>
<%@page import="utilisateur.UserMenu"%>
<%@page import="bean.CGenUtil"%>
<%@page import="user.UserEJB"%>

<%
    if (request.getParameter("currentMenu") != null && request.getParameter("currentMenu") != "") {
        session.setAttribute("currentMenu", request.getParameter("currentMenu"));
    }
    String currentMenu = (String) request.getSession().getAttribute("currentMenu");
    UserEJB u = (UserEJB) session.getAttribute("u");
    ArrayList<ArrayList<MenuDynamique>> arbre = null;
    if (session.getAttribute("MENU") == null) {
        arbre = MenuDynamique.getElementMenu(request, u.getUser());
        session.setAttribute("MENU", arbre);
    } else {
        arbre = (ArrayList<ArrayList<MenuDynamique>>) session.getAttribute("MENU");
    }
    MenuDynamique[] tabMenu = null;
    if (request.getServletContext().getAttribute("tabMenu") != null) {
        tabMenu = (MenuDynamique[]) request.getServletContext().getAttribute("tabMenu");
    }
%>
<style>
    #menuslider {
        max-height: 580px;
        overflow-y: auto;
    }

    #menuslider li {
        list-style-type: none;
    }

    #menu-body {
        margin-top: 5px;
        margin-bottom: 5px;
        margin-right:5px;
        background-color: rgb(249, 249, 249);
        font-size: 15px;
    }

    .skin-blue .sidebar a {
        color: #FFFF;
    }

    #menu-to-collapse-right-resultat {
        background-color: rgb(249, 249, 249);
        font-size: 15px;
        position: absolute;
        top: 210px;
        left: 230px;
        display: none;
        max-height: 233px;
        overflow-y: auto;
        border: 1px solid rgb(209, 209, 209);
    }

    #menu-to-collapse-right-activite {
        background-color: rgb(249, 249, 249);
        font-size: 15px;
        position: absolute;
        top: 210px;
        left: 230px;
        display: none;
        max-height: 240px;
        overflow-y: auto;
        border: 1px solid rgb(209, 209, 209);
    }

    #menu-to-collapse-right-geographie {
        width: 250px;
        background-color: rgb(249, 249, 249);
        font-size: 15px;
        position: absolute;
        top: 210px;
        left: 230px;
        display: none;
        max-height: 240px;
        overflow-y: auto;
        border: 1px solid rgb(209, 209, 209);
    }

    .menu-niveau-5 {
        font-size: 10px !important;
    }

    .menu-niveau-4 {
        font-size: 11px !important;
    }

    .menu-niveau-3 {
        font-size: 11px !important;
        margin-left: -50px;
    }

    .menu-niveau-2 {
        font-size: 12px !important;
        max-height: 20px;
        margin-left: -25px;
    }

    .menu-niveau-1 {
        font-size: 12px !important;
    }
</style>
<script type="text/javascript">
    function showMenuResultatActivite() {
        document.getElementById("menu-to-collapse-right-activite").style.display = 'none';
        document.getElementById("menu-to-collapse-right-geographie").style.display = 'none';
        if (document.getElementById("menu-to-collapse-right-resultat").style.display === 'none' || document.getElementById("menu-to-collapse-right-resultat").style.display === '')
            document.getElementById("menu-to-collapse-right-resultat").style.display = 'block';
        else
            document.getElementById("menu-to-collapse-right-resultat").style.display = 'none';
    }

    function showMenuSaisieActivite() {
        document.getElementById("menu-to-collapse-right-resultat").style.display = 'none';
        document.getElementById("menu-to-collapse-right-geographie").style.display = 'none';
        if (document.getElementById("menu-to-collapse-right-activite").style.display === 'none' || document.getElementById("menu-to-collapse-right-activite").style.display === '')
            document.getElementById("menu-to-collapse-right-activite").style.display = 'block';
        else
            document.getElementById("menu-to-collapse-right-activite").style.display = 'none';
    }

    function showMenuGeographie() {
        document.getElementById("menu-to-collapse-right-resultat").style.display = 'none';
        document.getElementById("menu-to-collapse-right-activite").style.display = 'none';
        if (document.getElementById("menu-to-collapse-right-geographie").style.display === 'none' || document.getElementById("menu-to-collapse-right-geographie").style.display === '')
            document.getElementById("menu-to-collapse-right-geographie").style.display = 'block';
        else
            document.getElementById("menu-to-collapse-right-geographie").style.display = 'none';
    }
</script>
<%
    String lien = (String) session.getValue("lien");
%>
<div style="background-color:rgb(206,206,206);  ">
    <aside class="main-sidebar" style="background-color:rgb(249,249,249);">
        <!-- sidebar: style can be found in sidebar.less -->
        <section class="sidebar" style="margin-left: 5px; background-color:rgb(249,249,249); ">
            <!-- sidebar menu: : style can be found in sidebar.less -->
            <!--<ul class="  sidebar-menu" id="menuslider" style="background-color:rgb(114,172,77)">

%=MenuDynamique.renderMenu(arbre, currentMenu, tabMenu)%>              

</ul>-->
            <div class="sidebar-menu" id="menuslider" style="background-color:rgb(249, 249, 249); color:black; ">
                <div id="menu-body">
                   <li>
                        <a href="#" class="menu-niveau-1"><i class="fa fa-folder-open"></i>Actes administratifs</a>
                        <ul class="   ">
                            <li>
                                <a href="" class="menu-niveau-2"><i class="fa fa-folder-open"></i>Licence</a>
                                <ul class="">
                                    <li><a href="<%=lien%>?but=acte/demande-licence-liste.jsp&saisie=acte/nouvelledemande.jsp&idtype_demandelicence=Licence" class="menu-niveau-3">Liste licence</a></li>
                                </ul>
                            </li>
                            <li>
                                <a href="" class="menu-niveau-2"><i class="fa fa-folder-open"></i>Autorisation speciale</a>
                                <ul class="">
                                    <li><a href="<%=lien%>?but=acte/demande-licence-liste.jsp&saisie=acte/autorisation.jsp&idtype_demandelicence=Autorisation%" class="menu-niveau-3">Liste Autorisation speciale</a></li>
                                </ul>
                            </li>
                        </ul>
                    </li>
                </div>

            </div>
        </section>
        <!-- /.sidebar -->
    </aside>
</div>