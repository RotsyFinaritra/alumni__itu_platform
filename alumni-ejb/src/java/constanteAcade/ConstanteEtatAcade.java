/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package constanteAcade;

import utilitaire.ConstanteEtat; 
import utilitaireAcade.UtilitaireAcade;

public class ConstanteEtatAcade extends ConstanteEtat {

    private static final int etatAnnuler = 0;
    private static final int etatEnAttente = 7;
    private static final int etatFait = 10;
    private static final int etatCreer = 1;
    private static final int etatLivraison = 20;
    private static final int etatCloture = 9;
    private static final int etatValider = 11;
    private static final int etatPaye = 40;
    private static final int etatEncoursPayement = 30;
    private static final int cloture = 9;
    private static final int fait = 10;
    private static final int valider = 11;
    private static final int payer = 40;
    private static final int etatdeploye = 20;
    private static final int livrer = 20;
    private static final int effectuer = 12;
    private static final int etatRembourser = 5;
    private static final int etatAnnulerPayer = 6;
    private static final int etatACloturer = 8;
    private static final int etatALivrer = 12;
    public static final String etatreport="5";
    public static final int constanteEtatFinaliser = 4;
    private static final int etatDeployePreprod = 41;
    private static final int etatDeployeProd = 51;
    private static final int etatFail = 12;
    private static final int etatSuccess = 21;


    public static final int CREE = 10;
    public static final int STANDBY = 20;
    public static final int EN_COURS = 30;
    public static final int FAIT = 40;
    public static final int FACTURE = 50;
    public static final int ANNULE = -1;

    public static final int SOUS_TACHE_NON_COMMENCE = 1;
    public static final int SOUS_TACHE_EN_PAUSE = 20;
    public static final int SOUS_TACHE_EN_COURS = 30;
    public static final int SOUS_TACHE_EN_RETARD = 35;
    public static final int SOUS_TACHE_TERMINE = 40;

    public static final int creeDevis = 1;
    public static String phaseInit = "PHS0001";

    public static final int faitDevis = 20;

    public static final int valideInterneDevis = 30;

    public static final int valideClientDevis = 40;
    
    public static int getEtatDeployePreprod() {
        return etatDeployePreprod;
    }

    public static int getEtatFail() {
        return etatFail;
    }

    public static int getEtatSuccess() {
        return etatSuccess;
    }

    public static int getEtatDeployeProd() {
        return etatDeployeProd;
    }

    public static int getEtatRembourser() {
        return etatRembourser;
    }

    public static int getEtatAnnulerPayer() {
        return etatAnnulerPayer;
    }

    public static int getEtatACloturer() {
        return etatACloturer;
    }
    
    public static int getEtatDeploye() {
        return etatdeploye;
    }

    public static int getEtatALivrer() {
        return etatALivrer;
    }

    public static String getEtatreport() {
        return etatreport;
    }

    public static int getEffectuer() {
        return effectuer;
    }
    

    public static int getCloture() {
        return cloture;
    }

    public static int getFait() {
        return fait;
    }

    public static int getValider() {
        return valider;
    }

    public static int getPayer() {
        return payer;
    }

    public static int getLivrer() {
        return livrer;
    }

    public static int getEtatFait() {
        return etatFait;
    }

    
    public static int getEtatLivraison() {
        return etatLivraison;
    }

    public static int getEtatPaye() {
        return etatPaye;
    }

    public static int getEtatCreer() {
        return etatCreer;
    }

    public static int getEtatAnnuler() {
        return etatAnnuler;
    }

    public static int getEtatCloture() {
        return etatCloture;
    }

    public static int getEtatValider() {
        return etatValider;
    }
	
	public static int getEtatEncoursPayement(){
		return etatEncoursPayement;
	}
	

    public static String etatToChaine(String valeur) {
        int val = UtilitaireAcade.stringToInt(valeur);
	if(val == ConstanteEtatAcade.getEtatCreer()) return "<b style='color:lightskyblue'>CR&Eacute;&Eacute;(E)</b>";
        if(val == ConstanteEtatAcade.getEtatValider()) return "<b style='color:green'>VIS&Eacute;(E)</b>";
        if(val == ConstanteEtatAcade.getEtatAnnuler()) return "<b style='color:orange'>ANNUL&Eacute;(E)</b>";
        if(val == ConstanteEtatAcade.getEtatCloture()) return "<b style='color:orange'>CLOTUR&Eacute;(E)</b>";
        if(val == ConstanteEtatAcade.getEtatLivraison()) return "<b style='color:green'>LIVR&Eacute;(E)</b>";
        if(val == ConstanteEtatAcade.getEtatPaye()) return "<b style='color:green'>PAY&Eacute;</b>";
        if(val == ConstanteEtatAcade.getEtatFait()) return "<b style='color:green'>PRET A LIVRER</b>";
        if(val == ConstanteEtatAcade.getEtatRembourser()) return "<b style='color:green'>REMBOURS&Eacute;(E)</b>";
        if(val == ConstanteEtatAcade.getEtatACloturer()) return "<b style='color:orange'>A CLOTURER</b>";
        if(val == ConstanteEtatAcade.getEtatALivrer()) return "<b style='color:green'>A LIVRER</b>";
		if(val == ConstanteEtatAcade.getEtatEncoursPayement()) return "<b style='color:yellow'>EN COURS DE PAIEMENT</b>";
        return "<b>AUTRE</b>";
    }
    public static String etatToChaineLivraison(int valeur)
    {
        return etatToChaineLivraison(String.valueOf(valeur));
    }
    public static String etatToChaineLivraison(String valeur) {
        int val = UtilitaireAcade.stringToInt(valeur);
	if(val == ConstanteEtatAcade.getEtatCreer()) return "Cree";
        if(val == ConstanteEtatAcade.getEtatValider()) return "Couloir";
        if(val == ConstanteEtatAcade.getEtatAnnuler()) return "Annule";
        if(val == ConstanteEtatAcade.getEtatCloture()) return "Cloture";
        if((val == ConstanteEtatAcade.getEtatLivraison())||val == ConstanteEtatAcade.getEtatPaye()) return "Livree";
        //if(val == ConstanteEtatAcade.getEtatPaye()) return "Paye";
        if(val == ConstanteEtatAcade.getEtatFait()) return "Fait";
        if(val == ConstanteEtatAcade.getEtatRembourser()) return "rembourse";
        if(val == ConstanteEtatAcade.getEtatACloturer()) return "A Cloturer";
        if(val == ConstanteEtatAcade.getEtatALivrer()) return "A Livrer";
	if(val == ConstanteEtatAcade.getEtatEncoursPayement()) return "<b style='color:yellow'>EN COURS DE PAIEMENT</b>";
        return "AUTRE";
    }
    public static int chaineToEtat(String chaine)
    {
        if(chaine.compareToIgnoreCase("cree")==0 ) return ConstanteEtatAcade.getEtatCreer();
        if(chaine.compareToIgnoreCase("valide")==0 || chaine.compareToIgnoreCase("cloture")==0) return ConstanteEtatAcade.getEtatValider();
        int val=UtilitaireAcade.stringToInt(chaine);
        if(val>0)return val;
        return 0;
    }

    public static int getEtatEnAttente() {
        return etatEnAttente;
    }
    
    public static int getConstanteEtatFinaliser() {
	return constanteEtatFinaliser;
    }

}
