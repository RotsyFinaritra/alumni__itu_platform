package servlet;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet pour servir les photos de profil uploadées
 */
@WebServlet(name = "ServletProfilePhoto", urlPatterns = {"/profile-photo"})
public class ServletProfilePhoto extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String fileName = request.getParameter("file");
        
        if (fileName == null || fileName.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Nom de fichier manquant");
            return;
        }
        
        // Sécurité : empêcher les traversées de répertoire
        if (fileName.contains("..") || fileName.contains("/") || fileName.contains("\\")) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Nom de fichier invalide");
            return;
        }
        
        // Construire le chemin vers dossier.war (configuration du framework APJ)
        String uploadDir = System.getProperty("jboss.server.base.dir") + 
                          "/deployments/dossier.war/async/profiles/";
        File file = new File(uploadDir + fileName);
        
        // Log pour debug
        System.out.println("ServletProfilePhoto - Chemin recherché: " + file.getAbsolutePath());
        System.out.println("ServletProfilePhoto - Fichier existe: " + file.exists());
        
        if (!file.exists() || !file.isFile()) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Fichier introuvable: " + file.getAbsolutePath());
            return;
        }
        
        // Déterminer le type MIME
        String mimeType = getServletContext().getMimeType(file.getName());
        if (mimeType == null) {
            mimeType = "application/octet-stream";
        }
        
        response.setContentType(mimeType);
        response.setContentLength((int) file.length());
        response.setHeader("Content-Disposition", "inline; filename=\"" + file.getName() + "\"");
        
        // Envoyer le fichier
        try (InputStream in = new FileInputStream(file);
             OutputStream out = response.getOutputStream()) {
            
            byte[] buffer = new byte[4096];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
            out.flush();
        }
    }
}
