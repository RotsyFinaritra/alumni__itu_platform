<%@page import="java.util.HashMap"%>
<%@page import="routenationale.RoutenationaleMoyenneNbdegrad"%>
<%@page import="affichage.Carte"%>
<%
      HashMap<String,String> leg=new HashMap<String,String>();
    leg.put("#b6fa41", "Station");
    leg.put("#fa7fc3", "Pont");
    leg.put("orange", "Nid de poule");
    leg.put("#3e32a8", "Fissure");
    leg.put("#0a731d", "Faïençage");
    leg.put("#c2193b", "Affaissement");
    leg.put("#a81bc4", "Pelade");
    leg.put("#29e6d3", "Ornierage");
    leg.put("#98fa9d", "Nettoyage");
    leg.put("#fcf805", "Drainage");
    leg.put("brown", "Terre");
    leg.put("#87806d", "Goudron");
    leg.put("black", "Gravillon");
    leg.put("red", "Pavé");
    
    Carte carte=new Carte();
    RoutenationaleMoyenneNbdegrad rn= new RoutenationaleMoyenneNbdegrad();
    rn.setId(request.getParameter("id"));
    carte.setData(rn.getData(null));
    carte.createLegend(null,leg);
    out.println(carte.getHtml()); 
    out.println(carte.showGeometry(false,""));
%>