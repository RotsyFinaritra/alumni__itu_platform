/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package servlet;

import bean.CGenUtil;
import bean.TypeObjet;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.Part;
import upload.UploadImage;
import utilitaire.UtilDB;
import utilitaire.UtilUpload;

/**
 *
 * @author Matiasy
 */
@WebServlet(name = "ServletUpload2", urlPatterns = {"/ServletUpload2"})
@MultipartConfig
public class ServletUpload2 extends HttpServlet {
private static final long serialVersionUID = 1L;
    public ServletUpload2()
        {
          super();
          //System.out.println("FileUploadServlet Initialized & Instantiated.");
        }
  
    public void service(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException
        {
            String fileName = "";
            if(request.getParameter("custname")!=null && !request.getParameter("custname").isEmpty() ){
                fileName = request.getParameter("custname");
            }
            String redir  = "";
            if(request.getParameter("redir")!=null && !request.getParameter("redir").isEmpty() ){
                redir = request.getParameter("redir");
            }
            //System.out.println("redirrrsdsfefe-"+redir);
           String ret = new UtilUpload().fileUploadWithDesiredFilePathAndName(request,response,fileName,redir);
           String id="";
           if(request.getParameter("idUpdate")!=null && !request.getParameter("idUpdate").isEmpty()){
              // System.out.println("ID---"+id);
               id=request.getParameter("idUpdate");
               UploadImage o = new UploadImage();
               //o.setNomTable("UPLOAD_IMAGE");
               o.setId(id);
                try {
                    UploadImage[] l = ( UploadImage[] )CGenUtil.rechercher(o, null, null, "");
                    if(l.length>0){
                        l[0].setVal(ret);
                        l[0].upDateToTable();
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
               
           }
           //f(request.)
           
        }
}
