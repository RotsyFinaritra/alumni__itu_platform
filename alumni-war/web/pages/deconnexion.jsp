<%@ page import="user.*" %>
<%@ page import="utilitaireAcade.*" %>
<%@ page import="utilitaire.*" %>
<%
        try
        {
          if (session.getAttribute("u") != null)
          {
            session.removeAttribute("u");
            session.removeAttribute("lien");
            session.removeAttribute("dir");
            session.removeAttribute("dirlib");
            session.removeAttribute("menu");
            session.invalidate();
          }
          response.sendRedirect(request.getContextPath() + "/index.jsp");
          return;
        }
        catch (Exception e)
        {
          session.invalidate();
          response.sendRedirect(request.getContextPath() + "/index.jsp");
          return;
        }
%>