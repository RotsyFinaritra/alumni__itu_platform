package utils;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Map;

public abstract class EventSender {
    protected PrintWriter out;
    public EventSender(PrintWriter out) {
        this.out = out;
    }
    abstract public void sendProgress(String message) throws IOException ;
    abstract public void sendError(String message) throws IOException ;
    abstract public void sendDone(String redirect, Map<String, String> data) throws IOException ;
}
