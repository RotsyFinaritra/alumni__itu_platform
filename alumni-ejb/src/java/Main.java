/**
 *
 * @author NERD
 */
import bean.CGenUtil;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import java.io.IOException;
import java.math.RoundingMode;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;
public class Main {
    public static double arrondirDecimalWithMode(double a, String pattern, RoundingMode mode) {//pattern deux chffires apr�s la virgule #.##
        DecimalFormat df = new DecimalFormat(pattern);
        df.setRoundingMode(mode); //RoundingMode.HALF_UP, RoundingMode.HALF_DOWN
        String format = df.format(a).replace(",", ".");
        return Double.valueOf(format);
    }
    public static double[] arrondirEtAppoint(double montant , int arrondi){
        double[] ret = new double[2];
        System.out.println("montant : "+montant);
        int partieEntiere = (int) montant;
        System.out.println("partieEntiere : "+partieEntiere);
        double partieDecimal = montant - partieEntiere;
        partieDecimal = arrondirDecimalWithMode(partieDecimal, "#.##", RoundingMode.HALF_UP);
        System.out.println("partieDecimal : "+partieDecimal);
        int dernierNombreParLArrondi = partieEntiere % arrondi;
        System.out.println("dernierNombreParLArrondi : "+dernierNombreParLArrondi);
        double test = dernierNombreParLArrondi + partieDecimal;
        System.out.println("test : "+test);
        if(test>=50){
            System.out.println("mididtra 1");
            System.out.println("dernierNombreParLArrondi + (arrondi - dernierNombreParLArrondi)) "+(arrondi - dernierNombreParLArrondi));
            ret[0] = partieEntiere + (arrondi - dernierNombreParLArrondi);
            ret[1] = arrondirDecimalWithMode((ret[0] - montant), "#.##", RoundingMode.CEILING);
        }
        if(test<50){
            System.out.println("mididtra 3");
            ret[0] = partieEntiere - dernierNombreParLArrondi;
            ret[1] = arrondirDecimalWithMode((ret[0] - montant), "#.##", RoundingMode.CEILING);
        }
        return ret;
    }
    
        //static int ad = 0;
    //static int tousles = 150;
    public static void main(String[] args) throws IOException {
//        //System.out.println("HELLO WORLD : "+utilitaireAcade.UtilitaireAcade.dateDuJour());
//        final GsonBuilder builder = new GsonBuilder();
//        final Gson gson = builder.create();
//        Date daty = UtilitaireAcade.stringDate("02/11/2015");

        
        
       /* Connection c = null;
        try {*/
            //double[] ret = arrondirEtAppoint(110403.92, 100);
            //System.out.println(ret[0]);
            //System.out.println(ret[1]);
        /*Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss.SSS").create();
        
        Tache t = new Tache();
        t.setHeure("20:30");
        String countryObj = gson.toJson(t);                    */
            
    /*        c = new UtilDB().GetConn();
            c.setAutoCommit(false);
            TacheRecap tr = new TacheRecap();
            //tr.setNomTable("tachenonentametotal");
            tr.setNomTable("tache_debutertotal");
            TacheRecap[]result1 = (TacheRecap[])CGenUtil.rechercher(tr, null, null, c, "");
            tr.setNomTable("tachenonentametotal");
            TacheRecap[]result2 = (TacheRecap[])CGenUtil.rechercher(tr, null, null, c, "");            
            for(int i = 0; i<result1.length; i++){
                Notification notif2 = (Notification)result1[i].createNotifTacheD("1060", c);
            }
            for(int i = 0; i<result2.length; i++){
                Notification notif1 = (Notification)result2[i].createNotifTacheNE("1060", c);                
            }            
            c.commit();
        } catch (Exception ex) {
            ex.printStackTrace();
            if (c!=null){
                c.rollback();
            }            
        }finally{
            if (c != null) {
                c.close();
            }            
        }
        
    }*/
   
   
        //BufferedReader bufferRead = new BufferedReader(new InputStreamReader(System.in));
        //String s = bufferRead.readLine();
        String s = "5";
//        System.out.println("s = " + s);
        //tousles = Integer.valueOf(s).intValue();
        try {
//           System.out.print("Veuillez entre le nombre de boucles en secondes = ");
//          //  Timer timer = new Timer();
//            //timer.schedule(new TimerTask() {
//
//                        try {
//                            UtilisateurService US = new UtilisateurService();
//                            // get enchere where etat = 0 ou 1
//                            ////List<Mail_to_send> mail = SendMailService.getMailNonEnvoye();
//                            java.util.Date now = utilitaireAcade.UtilitaireAcade.convertToUtilDate(utilitaireAcade.UtilitaireAcade.dateDuJourSql(), utilitaireAcade.UtilitaireAcade.heureCouranteTime());
////                            System.out.println("*** daty androany = " + now);
//							List<Mail_to_send> mail = new ArrayList<Mail_to_send>();
//							Mail_to_send m1 = new Mail_to_send();
//							m1.setSubject("R�sultat d'analyse t�che du "+utilitaireAcade.UtilitaireAcade.dateDuJour());
//							m1.setContenue("Bonjour, <br><br>"
//                                                                + "Voici le r�sultat de l'analyse crois�e des t�ches effectu�es par notre �quipe aujourd'hui.<br><br>"
//                                                                + ""+(new Report()).getHTMLAnalyseCroise()+""
//                                                                        + "<br><br> Cordialement.");
//							//m1.setDestinataire("raharimanana99@gmail.com");
//							mail.add(m1);
//                            if(mail.size()>0){
//                                System.out.println("nahita mail : "+mail.size());
//                                for(int i=0; i < mail.size(); i++){
//
//                                    String rep = US.sendMailGenerique(mail.get(i));
//                                   // System.out.println("--- e "+rep);
//                                    /*if(rep.equals("SUCCESS")){
//                                        SendMailService.updateSendMail(mail.get(i), 11);
//                                    }*/
//                                }
//                            }else{
//                                System.out.println("tsy nahita mail");
//                            }
//                            /*List<MdpOublie> mdp = MdpOublie_SendMail.getMailNonEnvoyeMdpOublie();
//                            if(mdp.size() > 0 ){
//                                for(int i=0; i < mail.size(); i++){
//                                    String rep = US.sendMailGeneriqueMdp(mdp.get(i));
//                                    if(rep.equals("SUCCESS")){
//                                        SendMailService.updateSendMailMdp(mdp.get(i), 11);
//                                    }
//                                }
//                            }*/
//
//                        } catch (Exception ex) {
//                            ex.printStackTrace();
//                        }
//
                    
                
            // TODO code application logic here
        } catch (Exception ex) {
            ex.printStackTrace();
        }
    }    
}
