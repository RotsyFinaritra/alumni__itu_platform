<%@page import="menu.MenuDynamique"%>
<%@page import="java.util.ArrayList"%>
<%@page import="utilisateur.UserMenu"%>
<%@page import="bean.CGenUtil"%>
<%@page import="mg.cnaps.utilisateur.CNAPSUser"%>
<%@page import="user.UserEJB"%>

<%
    if(request.getParameter("currentMenu")!=null && request.getParameter("currentMenu")!=""){
        session.setAttribute("currentMenu", request.getParameter("currentMenu"));
    }
    String  currentMenu =(String) request.getSession().getAttribute("currentMenu");  
    UserEJB u = (UserEJB) session.getAttribute("u");
    CNAPSUser cnapsUser = u.getCnapsUser();
    ArrayList<ArrayList<MenuDynamique>> arbre =null;
    if(session.getAttribute("MENU")==null){
        arbre = MenuDynamique.getElementMenu(request, u.getUser(), cnapsUser);
        session.setAttribute("MENU", arbre);
    }else{
        arbre = (ArrayList<ArrayList<MenuDynamique>>) session.getAttribute("MENU");
    }
    MenuDynamique[] tabMenu = null;
    if(request.getServletContext().getAttribute("tabMenu")!=null){
        tabMenu=(MenuDynamique[])request.getServletContext().getAttribute("tabMenu");
    }
 %>
<aside class="main-sidebar">
    <!-- sidebar: style can be found in sidebar.less -->
    <section class="sidebar">
        <!-- sidebar menu: : style can be found in sidebar.less -->
        <ul class="sidebar-menu" id="menuslider">

            <%=MenuDynamique.renderMenu(arbre,currentMenu,tabMenu) %>              

           
        </ul>
    </section>
    <!-- /.sidebar -->
</aside>
  