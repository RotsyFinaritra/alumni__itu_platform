<%@page import="bean.CGenUtil"%>
<%@page import="java.util.HashMap"%>
<%@page import="portion.Portion"%>
<%@page import="details.DetailsLibComplet"%>
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
    Portion p = new Portion();
    p.setId(request.getParameter("id"));
    Portion new_portion = p.getPortion(null);
    DetailsLibComplet[] tDetailsComplet = new_portion.getDetailsLibComplet(null);
    if(tDetailsComplet.length>0){
        carte.setData(tDetailsComplet);
    }
    carte.createLegend(null,leg);
    out.println(carte.getHtml()); 
    out.println(carte.showGeometry(false,""));
%>