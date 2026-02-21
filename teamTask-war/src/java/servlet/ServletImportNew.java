package servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import javax.websocket.Session;
import java.io.*;
import java.sql.*;
import java.text.SimpleDateFormat;
import java.util.Date;

import bean.CGenUtil;
import bean.Donation;
import bean.HistoImport;
import bean.TypeObjet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;    // pour .xls
import org.apache.poi.xssf.usermodel.XSSFWorkbook;    // pour .xlsx
import org.apache.poi.ss.usermodel.*;
import user.UserEJB;
import utilitaire.UtilDB;
import utilitaire.Utilitaire;

@WebServlet("/importExcelNew")
@MultipartConfig
public class ServletImportNew extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        UserEJB u = (UserEJB) session.getAttribute("u");
        String lien = request.getContextPath()+"/pages/"+session.getAttribute("lien").toString();
        Part filePart = request.getPart("file");

        if (filePart == null || filePart.getSize() == 0) {
            response.getWriter().println("Aucun fichier envoyé.");
            return;
        }

        String fileName = getFileName(filePart);
        Workbook workbook = null;
        Connection c = null;

        try (InputStream input = filePart.getInputStream()) {
            c = new UtilDB().GetConn();
            c.setAutoCommit(false);

            if (fileName.endsWith(".xlsx")) {
                workbook = new XSSFWorkbook(input);
            } else if (fileName.endsWith(".xls")) {
                workbook = new HSSFWorkbook(input);
            } else {
                response.getWriter().println("Format non supporté, utilisez XLS ou XLSX.");
                return;
            }

            Sheet sheet = workbook.getSheetAt(0);
            int count = 0;

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

            for (int i = 1; i <= sheet.getLastRowNum(); i++) { // ignorer header
                Row row = sheet.getRow(i);
                if (isRowEmpty(row)) continue;

                Date datyy = getCellDate(row.getCell(0), sdf);   // date
                java.sql.Date daty = Utilitaire.dateDuJourSql();
                if (datyy != null) daty = new java.sql.Date(datyy.getTime());
                String nom = getCellString(row.getCell(1));     // nom
                double pu = getCellDouble(row.getCell(7)); // pu
                String desce = getCellString(row.getCell(2));   // desce
                String idCategorie = getCellString(row.getCell(3)); // categorie (vola)
                double qte = getCellDouble(row.getCell(4));     // qte (1)
                String idCategorieDonateur = getCellString(row.getCell(8)); // particulier
                String idProjet = getCellString(row.getCell(9)); // projet (vide)
                String entitedonateur = getCellString(row.getCell(10));
                String recepteur = getCellString(row.getCell(11));
                double montant = qte * pu;
                if (pu == 0) montant = qte;

                Donation don = new Donation();
                don.setNom(nom);
                don.setMontant(montant);
                don.setDesce(desce);
                don.setDaty(daty);
                don.setQte(qte);
                // get id categorie par val
                TypeObjet typeObjet = new TypeObjet();
                typeObjet.setNomTable("categorie");
                typeObjet.setVal(idCategorie);
                TypeObjet[] categ = (TypeObjet[]) CGenUtil.rechercher(typeObjet, null, null, c, "");
                don.setIdCategorie(categ[0].getId());
                // get id categorie donateur par val
                TypeObjet tpcd = new TypeObjet();
                tpcd.setNomTable("categoriedonateur");
                tpcd.setVal(idCategorieDonateur);
                TypeObjet[] categDon = (TypeObjet[]) CGenUtil.rechercher(tpcd, null, null, c, "");
                don.setIdCategorieDonateur(categDon[0].getId());
                // get id projet par val
                TypeObjet proj = new TypeObjet();
                proj.setNomTable("projet");
                proj.setVal(idProjet);
                TypeObjet[] projs = (TypeObjet[]) CGenUtil.rechercher(proj, null, null, c, "");
                don.setIdProjet(projs[0].getId());
                // recepteur
                TypeObjet recept = new TypeObjet();
                recept.setNomTable("recepteur");
                recept.setVal(recepteur);
                TypeObjet[] recepts = (TypeObjet[]) CGenUtil.rechercher(recept, null, null, c, "");
                don.setIdRecepteur(recepts[0].getId());
                // entiteDonateur
                TypeObjet ent = new TypeObjet();
                ent.setNomTable("entitedonateur");
                ent.setVal(entitedonateur);
                TypeObjet[] ents = (TypeObjet[]) CGenUtil.rechercher(ent, null, null, c, "");
                don.setIdEntiteDonateur(ents[0].getId());

                // insertion
                don = (Donation) don.createObject(u.getUser(), c);
                HistoImport hi = new  HistoImport();
                hi.setRefobject(don.getId());
                hi.setDaty(don.getDaty());
                hi.createObject(u.getUser(), c);
                count++;
            }
            c.commit();
            System.out.println(lien);
            response.sendRedirect(lien+"?but=donation/donation-liste.jsp");

        } catch (Exception e) {
            try {
                c.rollback();
            } catch (SQLException ex) {
                throw new RuntimeException(ex);
            }
            e.printStackTrace();
            response.getWriter().println("Erreur : " + e.getMessage());
        } finally {
            try {
                c.close();
            } catch (SQLException e) {
                throw new RuntimeException(e);
            }
            if (workbook != null) workbook.close();
        }
    }

    // récupère le nom du fichier (Servlet 3.0 compatible)
    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        for (String token : contentDisp.split(";")) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
            }
        }
        return null;
    }

    // lecture cellule texte
    private String getCellString(Cell cell) {
        if (cell == null) return "";

        DataFormatter formatter = new DataFormatter();
        return formatter.formatCellValue(cell);
    }


    // lecture cellule double
    private double getCellDouble(Cell cell) {
        if (cell == null) return 0;
        if (cell.getCellType() == Cell.CELL_TYPE_NUMERIC) return cell.getNumericCellValue();
        try {
            return Double.parseDouble(getCellString(cell));
        } catch (NumberFormatException e) {
            return 0;
        }
    }

    // lecture cellule date
    private Date getCellDate(Cell cell, SimpleDateFormat sdf) {
        if (cell == null) return null;

        if (cell.getCellType() == Cell.CELL_TYPE_NUMERIC &&
                DateUtil.isCellDateFormatted(cell)) {

            return cell.getDateCellValue();

        } else if (cell.getCellType() == Cell.CELL_TYPE_STRING) {

            try {
                return sdf.parse(cell.getStringCellValue().trim());
            } catch (Exception e) {
                return null;
            }
        }

        return null;
    }

    private boolean isRowEmpty(Row row) {
        if (row == null) return true;

        DataFormatter formatter = new DataFormatter();

        for (int i = 0; i < row.getLastCellNum(); i++) {
            Cell cell = row.getCell(i);
            if (cell != null) {
                String value = formatter.formatCellValue(cell);
                if (value != null && !value.trim().isEmpty()) {
                    return false; // au moins une cellule non vide
                }
            }
        }
        return true; // toutes les cellules sont vides
    }

}
