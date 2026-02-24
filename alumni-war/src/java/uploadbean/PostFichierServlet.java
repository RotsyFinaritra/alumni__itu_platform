package uploadbean;

import bean.CGenUtil;
import bean.PostFichier;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import user.UserEJB;
import utilitaire.UtilDB;
import utilitaire.Utilitaire;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletOutputStream;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.util.HashMap;
import java.util.List;

@WebServlet("/PostFichierServlet")
public class PostFichierServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;
    private ServletFileUpload uploader = null;

    private void createDir(String path) {
        File file = new File(path);
        if (!file.exists()) {
            file.mkdirs();
        }
    }

    @Override
    public void init() {
        DiskFileItemFactory fileFactory = new DiskFileItemFactory();
        File filesDir = (File) getServletContext().getAttribute(StringUtil.FILES_DIR_FILE);
        if (filesDir != null) {
            fileFactory.setRepository(filesDir);
        }
        this.uploader = new ServletFileUpload(fileFactory);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        
        if ("download".equals(action)) {
            downloadFile(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Action non supportée");
        }
    }

    private void downloadFile(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String id = request.getParameter("id");
            if (id == null || id.isEmpty()) {
                throw new ServletException("ID fichier requis");
            }
            
            // Récupérer le fichier depuis la BDD
            PostFichier critere = new PostFichier();
            Object[] fichiers = CGenUtil.rechercher(critere, null, null, " AND id = '" + id + "'");
            
            if (fichiers == null || fichiers.length == 0) {
                throw new ServletException("Fichier non trouvé");
            }
            
            PostFichier pf = (PostFichier) fichiers[0];
            File file = new File(pf.getChemin());
            
            if (!file.exists()) {
                throw new ServletException("Fichier physique non trouvé: " + pf.getChemin());
            }
            
            InputStream inputStream = new FileInputStream(file);
            String mimeType = pf.getMime_type();
            if (mimeType == null) {
                ServletContext context = getServletContext();
                mimeType = context.getMimeType(file.getAbsolutePath());
            }
            
            response.setContentType(mimeType != null ? mimeType : "application/octet-stream");
            response.setContentLength((int) file.length());
            response.setHeader("Content-Disposition", "attachment; filename=\"" + pf.getNom_original() + "\"");
            
            ServletOutputStream os = response.getOutputStream();
            byte[] bufferData = new byte[1024];
            int read;
            while ((read = inputStream.read(bufferData)) != -1) {
                os.write(bufferData, 0, read);
            }
            os.flush();
            os.close();
            inputStream.close();
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Erreur téléchargement: " + e.getMessage());
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        Connection conn = null;
        try {
            if (!ServletFileUpload.isMultipartContent(request)) {
                throw new ServletException("Content type is not multipart/form-data");
            }
            
            HashMap<String, String> params = new HashMap<>();
            HashMap<String, FileItem> fichiers = new HashMap<>();
            
            List<FileItem> fileItemsList = uploader.parseRequest(request);
            
            // Séparer les paramètres des fichiers
            for (FileItem fileItem : fileItemsList) {
                if (fileItem.isFormField()) {
                    params.put(fileItem.getFieldName(), fileItem.getString("UTF-8"));
                } else if (fileItem.getName() != null && !fileItem.getName().isEmpty()) {
                    fichiers.put(fileItem.getFieldName(), fileItem);
                }
            }
            
            String action = params.get("action");
            
            if ("upload".equals(action)) {
                uploadFiles(request, response, params, fichiers);
            } else {
                throw new ServletException("Action non supportée: " + action);
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            throw new ServletException("Erreur upload: " + e.getMessage());
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (Exception ignored) {}
            }
        }
    }

    private void uploadFiles(HttpServletRequest request, HttpServletResponse response,
                            HashMap<String, String> params, HashMap<String, FileItem> fichiers) 
            throws Exception {
        
        String postId = params.get("postId");
        String typePost = params.get("type");
        String dossier = params.get("dossier");
        
        if (postId == null || postId.isEmpty()) {
            throw new Exception("postId requis");
        }
        
        // Créer le dossier de destination
        String basePath = StringUtil.PATH_DIR + File.separator + "post_fichiers" + File.separator + dossier;
        createDir(basePath);
        
        UserEJB u = (UserEJB) request.getSession().getAttribute("u");
        Connection conn = new UtilDB().GetConn();
        
        try {
            conn.setAutoCommit(false);
            
            // Trouver l'ordre max actuel
            PostFichier critere = new PostFichier();
            Object[] existants = CGenUtil.rechercher(critere, null, null, conn, 
                " AND post_id = '" + postId + "' ORDER BY ordre DESC");
            int ordreMax = 0;
            if (existants != null && existants.length > 0) {
                PostFichier dernier = (PostFichier) existants[0];
                ordreMax = dernier.getOrdre() != null ? dernier.getOrdre() : 0;
            }
            
            // Traiter chaque fichier
            for (String fieldName : fichiers.keySet()) {
                FileItem fileItem = fichiers.get(fieldName);
                
                // Extraire le numéro du champ (fichier1, fichier2, etc.)
                String numStr = fieldName.replace("fichier", "");
                String typeFichierId = params.get("typeFichier" + numStr);
                
                // Nom du fichier
                String originalName = fileItem.getName();
                int lastDot = originalName.lastIndexOf('.');
                String ext = lastDot > 0 ? originalName.substring(lastDot + 1) : "";
                String baseName = lastDot > 0 ? originalName.substring(0, lastDot) : originalName;
                
                // Générer un nom unique
                String uniqueName = baseName.replaceAll("[^a-zA-Z0-9.-]", "_") + 
                                   "-" + Utilitaire.heureCourante().replace(":", "") + 
                                   Utilitaire.dateDuJour().replace("/", "") + 
                                   "." + ext;
                
                // Sauvegarder le fichier
                String filePath = basePath + File.separator + uniqueName;
                File file = new File(filePath);
                fileItem.write(file);
                
                // Créer l'enregistrement PostFichier
                PostFichier pf = new PostFichier();
                pf.construirePK(conn);
                pf.setPost_id(postId);
                pf.setIdtypefichier(typeFichierId != null && !typeFichierId.isEmpty() ? typeFichierId : "TFIC00001");
                pf.setNom_fichier(uniqueName);
                pf.setNom_original(originalName);
                pf.setChemin(filePath);
                pf.setTaille_octets(fileItem.getSize());
                pf.setMime_type(fileItem.getContentType());
                pf.setOrdre(++ordreMax);
                
                pf.insertToTable(conn);
            }
            
            conn.commit();
            
            // Rediriger vers la page de fichiers
            String lien = "pages/module.jsp?but=carriere/post-fichiers.jsp&postId=" + postId + "&type=" + typePost;
            response.sendRedirect(lien);
            
        } catch (Exception e) {
            conn.rollback();
            throw e;
        } finally {
            conn.close();
        }
    }
}
