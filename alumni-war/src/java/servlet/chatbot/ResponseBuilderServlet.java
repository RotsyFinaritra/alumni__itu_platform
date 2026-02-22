package servlet.chatbot;

import chatbot.ChatBot;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import utils.ConstanteAsync;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.LocalDateTime;

@WebServlet("/response-formattor")
public class ResponseBuilderServlet extends HttpServlet {
    private String buildResponse(String map, String value,String sql) {
        return "La date d'ajourd'hui est "+ LocalDateTime.now().toString() +", Analyse les données de cette requete et repond au prompt de l'utilisateur sans parler de la requete ni de la table,si la devise n'existe pas dans les données, n'en met pas, citez juste ce qu'il demande ou donne juste le chiffre s il demande un chiffre,, calcule bien et verifie tes calculs si il ya des calcul a faire"+
                "fait bien attention au alias, si il y en a un ca veut dire que tu dois utiliser cette colonne. Par exemple id pour un nb si il y a as id dans la requete. utilise <ul><li> si on vous demande de lister qqchose et vous devez repondre formellement. "+
                "le prompt: '"+value+"'"+
                "la requete: '"+sql+"'"+
                "Formatte les nombre financiers et n'utilise pas de cours ni de symboles de cours du genre euro, dollars,£,$, etc mais formatte les en nombre financiers"+
                "le données: "+map
                +"\nRepondez formellement avec phrase complet et donne ta reponse au prompt apres avoir analyser les données et essayer de repondre par des combinaison des balise html si possible car j affiche directement votre reponse a l interieur d un balise <div>";
    }
    public String getResponse(String jsonResponse){
        Gson gson = new Gson();

        // Parser l'objet JSON principal
        JsonObject outerJson = gson.fromJson(jsonResponse, JsonObject.class);

        // Extraire le JSON encodé dans "response"
        return outerJson.get("response").getAsString();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        super.doGet(req, resp);
    }
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String map = (String) req.getAttribute("maptables");
        String val = req.getParameter("prompt");
        String sql = (String) req.getAttribute("query");
        String lien = (String)req.getAttribute("lien");
        String phrase ="";
        String type = req.getParameter("type");
        String aiResponse = null;

        if(!type.equals("saisie")){
            phrase = buildResponse(ChatBot.removeAllDoubleQuotes(map), val,sql);
            try {
                aiResponse = ChatBot.callGenerativeAI(phrase, ConstanteAsync.API_URL);
                System.out.println("val "+aiResponse);
            } catch (Exception e) {
                throw new RuntimeException(e);
            }
        }
        ChatBot chat = new ChatBot(aiResponse,lien);
        System.out.println(chat.getUrl());
        System.out.println(chat.getValue());
        Gson json = new Gson();
        String data = json.toJson(chat);

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write(data);
    }
}
