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
    li{
        margin-bottom: 12px;
    }
</style>
<script type="text/javascript">
    function showMenuResultatActivite() {
        if (document.getElementById("menu-to-collapse-right-resultat").style.display === 'none' || document.getElementById("menu-to-collapse-right-resultat").style.display === '')
            document.getElementById("menu-to-collapse-right-resultat").style.display = 'block';
        else
            document.getElementById("menu-to-collapse-right-resultat").style.display = 'none';
    }
</script>
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
                        <!--<a href="/commune/pages/module.jsp?but=acte/demande-saisie.jsp&amp;currentMenu=ELM000007" class="menu-niveau-1"><i class="fa fa-edit"></i>&nbsp;Acte</a>-->                        
                        <a href="/commune/pages/module.jsp?but=acte/demande-liste.jsp&amp;" class="menu-niveau-1"><i class="fa fa-edit"></i>Demande acte unique</a>
                    </li>
                    <li><a href="/commune/pages/module.jsp?but=acte/demande-groupe.jsp&amp;" class="menu-niveau-1"><i class="fa fa-edit"></i>Demande acte group&eacute;</a></li>
                   
                </div>

            </div>
        </section>
        <!-- /.sidebar -->
    </aside>
</div>