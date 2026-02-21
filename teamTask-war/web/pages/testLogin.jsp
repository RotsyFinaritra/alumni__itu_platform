
<%@page import="bean.TypeObjet"%>
<%@page import="user.*"%>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>
<%@ page import="bean.CGenUtil" %>
<%@ page import="lc.Direction" %>
<%@ page import="java.net.InetAddress" %>
<%@ page import="historique.MapUtilisateur" %>

<%
    UserEJB u = null;
    String username = null;
    String pwd = null;
    historique.MapUtilisateur ut = null;
    String lien;
    String queryString;
    String ip = null;
    String host = null;
    String mot_vide = "";
    String mot_avec_espace = "mot espace";
    String mot = "mot";
    String mot_null = null;

%>

<%    try {
        username = request.getParameter("identifiant");
        pwd = request.getParameter("passe");

        u = UserEJBClient.lookupUserEJBBeanLocal();

        u.testLogin(username, pwd);
        System.out.println("METY APRES TEST LOGIN!!!!!!!!!!!!!!!!!");
        session.setAttribute("username",username);
        session.setAttribute("u", u);
        ut = u.getUser();

        TypeObjet crd = new TypeObjet();
        crd.setNomTable("DIRECTION");
        crd.setId(ut.getAdruser());
        TypeObjet[] ret = (TypeObjet[]) CGenUtil.rechercher(crd, null, null, "");


        session.setAttribute("entmenu", "_all-skins");
        session.setAttribute("lang", "fr");
        
       
        lien = "module.jsp";
        if (session.getAttribute("pageName") != null) {
            String pageName = session.getValue("pageName").toString();
            if (!pageName.equals("")) {
                lien = pageName;
            }
        }


        queryString = "but=accueil.jsp";//
        
        String queryURL = request.getQueryString();
        if (queryURL != null && !queryURL.equals("")) {
            queryString = queryURL;
        }
        if (ret.length > 0) {
            session.setAttribute("dirlib", ret[0].getVal());
            u.setIdDirection(ret[0].getVal());
        }

        if (ut.isSuperUser() == true) {
            session.setAttribute("dir", "%");
            session.setAttribute("dirlib", "");
            session.setAttribute("lien", lien);
            String menu = "admin.jsp";
            session.setAttribute("menu", menu);
            out.println("<script language='JavaScript'> document.location.replace('" + lien + "?" + queryString + "');</script>");
        } 
        else if (ut.getIdrole().compareTo("dg") == 0) {
            String menu = "module.jsp";
            System.out.println(" ===================================== " + ut.getRefuser() + " ==================== ");
            if (ut.getRefuser() == 1060) {
                menu = "module.jsp";
            } else if (ut.getRefuser() == 103) {
                menu = "module_recap.jsp";
            }
            session.setAttribute("lien", lien);

            session.setAttribute("menu", menu);
            session.setAttribute("dir", ut.getAdruser());
            out.println("<script language='JavaScript'> document.location.replace('" + lien + "?" + queryString + "');</script>");
        } /**
         * *
         */
        else if (ut.getIdrole().compareTo("visiteur") == 0) {
            session.setAttribute("lien", lien);
            String menu = "module_visiteurs.jsp";
            session.setAttribute("menu", menu);
            session.setAttribute("dir", ut.getAdruser());
            out.println("<script language='JavaScript'> document.location.replace('" + lien + "?" + queryString + "');</script>");
        } else if (ut.getIdrole().compareTo("caisse") == 0) {
            String menu = "module_caisse.jsp";
            lien = "module.jsp";
            session.setAttribute("lien", lien);
            session.setAttribute("menu", menu);
            session.setAttribute("dir", ut.getAdruser());
            out.println("<script language='JavaScript'> document.location.replace('" + lien + "?but=caisse/mouvement-caisse.jsp&typeEtat=sortie');</script>");
        } else if (ut.getIdrole().compareTo("amende") == 0) {
            String menu = "module_amende.jsp";
            lien = "module.jsp";
            session.setAttribute("lien", lien);
            session.setAttribute("menu", menu);
            session.setAttribute("dir", ut.getAdruser());
            out.println("<script language='JavaScript'> document.location.replace('" + lien + "?but=amende/amende-liste.jsp');</script>");
        } else if (ut.getIdrole().compareTo("acte") == 0) {
            String menu = "module_acte.jsp";
            if (ut.getRefuser() == 101) {
                menu = "module_acte.jsp";
            } else if (ut.getRefuser() == 11) {
                menu = "module_saisie_acte.jsp";
            } else if (ut.getRefuser() == 40) {
                menu = "module_imprime_acte.jsp";
            }

            lien = "module.jsp";
            session.setAttribute("lien", lien);
            session.setAttribute("menu", menu);
            session.setAttribute("dir", ut.getAdruser());
            out.println("<script language='JavaScript'> document.location.replace('" + lien + "?but=acte/demande-licence-liste.jsp&saisie=acte/demandegen-saisie.jsp');</script>");
        } else if (ut.getIdrole().compareTo("permis") == 0) {
            String menu = "module_permis.jsp";
            if (ut.getRefuser() == 100) {
                menu = "module_permis.jsp";
            } else if (ut.getRefuser() == 10) {
                menu = "module_validation.jsp";
            } else if (ut.getRefuser() == 50) {
                menu = "module_permis.jsp";
            }
            lien = "module.jsp";
            session.setAttribute("lien", lien);

            session.setAttribute("menu", menu);
            session.setAttribute("dir", ut.getAdruser());
            out.println("<script language='JavaScript'> document.location.replace('" + lien + "?but=inscription/dossierInscription-liste.jsp');</script>");
        } else {
            session.setAttribute("dir", "%");
            session.setAttribute("dirlib", "");
            //lien = "module.jsp";
            session.setAttribute("lien", lien);
            String menu = "module_visiteurs.jsp";
            session.setAttribute("menu", menu);
            out.println("<script language='JavaScript'> document.location.replace('" + lien + "?" + queryString + "');</script>");

        }
    } catch (Exception e) {

        e.printStackTrace();
        session.setAttribute("errorLogin", e.getMessage());
%>
<script language="JavaScript">
    // alert("Login ou mot de passe errone");
    document.location.replace("../index.jsp");
</script>
<%
        return;
    }
%>



<script language='JavaScript'> document.location.replace('<%=lien%>?"<%=queryString%>');</script>
