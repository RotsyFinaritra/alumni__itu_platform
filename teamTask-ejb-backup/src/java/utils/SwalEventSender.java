package utils;

import com.google.gson.JsonObject;

import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.HashMap;
import java.util.Map;

public class SwalEventSender extends EventSender{
    public SwalEventSender(PrintWriter out) {
        super(out);
    }
    public SwalEventSender(HttpServletResponse response) throws IOException {
        this(response.getWriter());
        response.setContentType("text/event-stream");
        response.setCharacterEncoding("UTF-8");
        response.setHeader("Cache-Control", "no-cache");
    }

    @Override
    public void sendProgress(String message) throws IOException {
        out.print("event: progress\n");
        out.print("data: " + message + "\n\n");
        out.flush();
    }

    @Override
    public void sendError(String message) throws IOException {
        out.print("event: error\n");
        out.print("data: " + message + "\n\n");
        out.flush();
    }

    @Override
    public void sendDone(String redirect, Map<String, String> data) throws IOException {
        com.google.gson.JsonObject res = new JsonObject();
        res.addProperty("url", redirect);
        for (Map.Entry<String, String> entry : data.entrySet()) {
            res.addProperty(entry.getKey(), entry.getValue());
        }
        out.print("event: done\n");
        out.print("data: " + res.toString() + "\n\n");
        out.flush();
    }

    public void sendDoneAnalyse(String url, String idAnalyse) throws IOException {
        Map<String, String> data = new HashMap<String, String>();
        data.put("idAnalyse", idAnalyse);
        sendDone(url, data);
    }
}
