<%@ page contentType="application/json; charset=UTF-8" %>
<%@ page import="java.io.InputStream" %>
<%@ page import="java.util.Scanner" %>
<%

// Charger le fichier enseignants.json depuis le classpath du JAR
ClassLoader classLoader = Thread.currentThread().getContextClassLoader();
InputStream is = classLoader.getResourceAsStream("enseignants.json");

if (is != null) {
    Scanner scanner = new Scanner(is, "UTF-8").useDelimiter("\\A");
    String jsonContent = scanner.hasNext() ? scanner.next() : "[]";
    scanner.close();
    is.close();
    
    out.print(jsonContent);
} else {
    // Fallback avec données hardcodées si le fichier ne trouve pas
    out.print("[");
    out.print("{\"code\": \"ENS001\", \"nom\": \"Rakoto\", \"prenom\": \"Jean\"},");
    out.print("{\"code\": \"ENS002\", \"nom\": \"Randrianampoinimerina\", \"prenom\": \"Marie\"},");
    out.print("{\"code\": \"ENS003\", \"nom\": \"Ramirez\", \"prenom\": \"Carlos\"},");
    out.print("{\"code\": \"ENS004\", \"nom\": \"Ramananarivo\", \"prenom\": \"Sophie\"},");
    out.print("{\"code\": \"ENS005\", \"nom\": \"Razafindrakoto\", \"prenom\": \"André\"},");
    out.print("{\"code\": \"ENS006\", \"nom\": \"Andrianavalona\", \"prenom\": \"Hélène\"},");
    out.print("{\"code\": \"ENS007\", \"nom\": \"Ranaivoson\", \"prenom\": \"Grégoire\"},");
    out.print("{\"code\": \"ENS008\", \"nom\": \"Rasamoela\", \"prenom\": \"Élisabeth\"},");
    out.print("{\"code\": \"ENS009\", \"nom\": \"Rajaonson\", \"prenom\": \"François\"},");
    out.print("{\"code\": \"ENS010\", \"nom\": \"Randriamampoinimerina\", \"prenom\": \"Zoé\"}");
    out.print("]");
}
%>
