package constanteAcade;

import java.sql.Date;
import java.util.Calendar;

import utilitaire.Constante;

public class ConstanteAcade {

    public static String entiteMada = "DN00108";
    public static String recepteurEntrepriseAnalamanga = "RG00001";
    public static String DIR = "dossier.war";
    public static String ASYNC = "async";
    public static String FILES = "files";
    private static String idCP = "DIR000003";
    private static String idDirection = "DIR000002";
    private static String idPaysMada = "P00001";
    private static String typeBug="TYP002";
    private static String pont="SC00001";
    private static String idRoleDev="dev";
    private static String station="SC00002";
    private static String nidDePoule="SC00003";
    private static String fissure="SC00004";
    private static String faiencage="SC00005";
    private static String affaissement="SC00006";
    private static String pelade="SC00007";
    private static String ornierage="SC00008";
    private static String nettoyage="SC00009";
    private static String drainage="SC00010";
    private static String terre="SC00011";
    private static String goudron="SC00012";
    private static String gravillon="SC00013";
    private static String pave="SC00014";
    private static String beton="SC00015";
    public static String degradation="CAT0002";
    public static String jour = "TYP001";
    public static String ferie = "TYP002";
    public static java.sql.Date datePropositionMin = new java.sql.Date(121, 6, 20);
    public static java.sql.Date datePropositionMax =  new java.sql.Date(Calendar.getInstance().getTime().getTime());

    public static final int CREE = 10;
    public static final int STANDBY = 20;
    public static final int EN_COURS = 30;
    public static final int FAIT = 40;
    public static final int FACTURE = 50;
    public static final int ANNULE = -1;

    public static final int DG_ID = 1063;
    public static final String CP_ID_ROLE = "cp";
    public static final String DG_ID_ROLE = "dg";
    public static final String COORD_ID_ROLE = "crd";
    public static final String RSP_TEST_ID_ROLE = "rsp";
    public static final String ROLE_DESIGNER = "dsn";
    public static final int RANG_POM = 7;

    public static String getIdDirection() {
        return idDirection;
    }

    public static String getIdPaysMada() {
        return idPaysMada;
    }

    public static String getIdCP() {
        return idCP;
    }

    public static void setIdPaysMada(String idPaysMada) {
        ConstanteAcade.idPaysMada = idPaysMada;
    }

    public static String getJour() {
        return jour;
    }

    public static void setJour(String jour) {
        ConstanteAcade.jour = jour;
    }

    public static String getFerie() {
        return ferie;
    }

    public static void setFerie(String ferie) {
        ConstanteAcade.ferie = ferie;
    }
    
    public static String getIdRoleDev() {
        return idRoleDev;
    }

    public static String getTypeBug() {
        return typeBug;
    }
    public static String getPont() {
        return pont;
    }

    public static String getStation() {
        return station;
    }

    public static String getNidDePoule() {
        return nidDePoule;
    }

    public static String getFissure() {
        return fissure;
    }

    public static String getFaiencage() {
        return faiencage;
    }

    public static String getAffaissement() {
        return affaissement;
    }

    public static String getPelade() {
        return pelade;
    }

    public static String getOrnierage() {
        return ornierage;
    }

    public static String getNettoyage() {
        return nettoyage;
    }

    public static String getDrainage() {
        return drainage;
    }

    public static String getTerre() {
        return terre;
    }

    public static String getGoudron() {
        return goudron;
    }

    public static String getGravillon() {
        return gravillon;
    }

    public static String getPave() {
        return pave;
    }

    public static String getBeton() {
        return beton;
    }
    private static String polyligneRN4="vkfrBm`~`HgRtV}IoU_d@cm@uf@bUwcHkScd@txBw^hy@kNntAfnClfAyMtrAqTxh@aw@dk@_jBprAc`@pmCw}ChfEi`BrkCy~A~eAqJhvBufCtx@abIbjCcdEpmCoi@|r@sdB{IgiD`rBgg@fnAaeAte@{`AvN{]|i@bDzp@y{@|GimAFsx@~i@vAzv@{a@by@gtBxj@eyAeN}mADwGvw@mmE~tBolA|VifCzIe}C_^woH`aBkiHkuBoIo{Dl[o]ewA_h@oyC}yBk`C}Z{kDp`@}`Bq_AgvAlOyx@wo@ca@yq@kjAbi@maBvoBodAnyAal@vl@cv@hByvB~RghCkQigAl]jDprBel@hTee@m[_bAbLoPrwA_fBoIeq@|QwBzy@_zBhCc~@vd@iq@bNe[nbA_gCnVkrA|iA{_Cb_AmdB~`DddAz]s]dcB}iDfkAohEwNomC|b@iwFdIa`Czt@eNlgAa`Btr@eoCzOeaC~QcxC~kCc~A~f@{lAdmAq{@hoAy~@jAqyAmnAuoG{}CmXek@epA_IwmA|JohCw|@um@oeAkxAhx@clAjlC}xB`aCe`AxAuV`pAfBjz@m_ApLywByj@_eFq]siDmcA}eC}wAqlCfX_vAttByiCff@q_Btz@gpAvcBw^l{Bwt@hb@y_@zx@m{A~}AqXzo@oq@uUswClt@_z@n}Bm}@tt@ykBaEypB{V_vAlq@aeA`RqhBus@sfEns@ooIa`CwkBkl@bPiqCygD}e@iiAqcAt]ywAhW{v@||@AncCumAbp@wu@mKwfA_qAqgAs`@mjArJciBmuCaLabCpEo~ClMsl@rZwe@m[ejBmtAscAgwAocC}iAeg@em@onCee@y`BguB_pE{gDubC_{@c}@pe@icGgeAyhEqq@omF{PokFqdBosA}gC{rAqq@siEuhB{uAqOq_Asp@ssAgd@}uC`_FkaB~~CavDfrDkmDhhIpu@vpFdqB~rD]`dFcx@jm@yF|w@al@Jgp@zX}Pl}A{r@vyDcsAnoCafCfdCsqF|Xc~CraEy|Af~CkhCr_@ckE_^_bChXuhBr@gvCgVqgDv_AclBt_BgeC`]eX~|AolBx\\\\yrBrUoz@tVu`AlmAqwCfvB_qDrZwu@t_BmgAoGi{Arw@`]jeC~RfpAqj@jbBhMp|@i}AhfC}E~}@at@fTagCbmC{{B|z@avAlcAayCe~A{eAq@q`ArsB{b@rbA{U`r@mqBtFylBhl@lv@tmDc_Ah`CokBltAso@xzE~GnhBeu@pvBsLgE@";
    private static String polyligneRN2="|gkrBqk`aHyCol@iLeaAgBqb@sx@ob@vAyi@lQue@qBkc@xg@iVFkrBapAydDwg@isBkgBckE}FygBbrCyp@|zBr@eOqiBwuA}lBzGyqAbxAckCyaBkpCr_@m}@f}C{xBnr@uqAudBafAv|AafC{TefCueA{h@mfAw|@hy@gwAx}@qhAjz@aqByz@cpAsuFoeFz^ueIu}Cm_C|`Bg}EnmEsvN|rGu`SyuAz{H|jE_wUwpAgrJmuA}kOqz@sfNtgEwnI{_AueG{G}zK|LkmGA}dE~x@sgLnlAilI}dBouCcnHcpD_gDkvCgyCmqBwsCspByuJktDoeA}iCozPkaD{cDaJghJyk@}kOyqFqdHitDqkD}dAeyIqhB}vEwx@}pEoqBk~D_~Cq_FooFqtDatCaoNizE";
    private static double longueurPortion = 10;
    private static String idTypeLCRecette = "TLC00001";
    private static String idTypeLCDepense = "TLC00002";
    public static String idRoleDirecteur = "directeur";
    public static String idRoleUtilisateur = "utilisateur";
    public static String idRoleAdmin = "admin";
    public static String idRoleAdminFacture = "adminFacture";
    public static String idRoleAdminCompta = "compta";
    public static String idRoleDg = "dg";
    public static String idRoleSaisie = "saisie";
    public static String tableOpFfLc = "OpFfLc";
    private static String mois[] = {"Janvier", "Fevrier", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Decembre"};
    private static String moisRang[] = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"};
    private static String objetDepense = "depense";
    private static String objetRecette = "recette";
    private static String objetFacture = "facture";
    private static String objetFactureF = "factureF";
    static private String tableRecetteLC = "recettesLC";
    static private String tableFactureLC = "factureLigneCredit";
    static private String tableFactureFLC = "FactureFournisseurLC";
    static private String tableDepenseLC = "sortieFF";
    private static String idFournAuto = "clt1";
    static private String objFactureProf = "FactureProfFournisseur";
    static private String objetBc = "BC";
    static private String objetCDetailFactProf = "detFactProf";
    static private String objetDetailBC = "detBC";
    static private String objetDetailFactFourn = "detFactF";
    static private String dedFactProfFourn = "DedFACTUREProfFOURNISSEUR";
    static private String DetailLcCree = "0";
    static private String DetailLcValide = "1";
    static private String objetDedBc = "DedBc";
    static private String objetLcDetMvt = "LcDetailMvtCaisse";
    static private String objetLcDetDed = "LcDetailDed";
    static private String objetLcDetOp = "LcDetailop";
    static private String objetOpFf = "OPFACTUREFOURNISSEUR";
    static private String objetDed = "ded";
    static private String objetOp = "ORDONNERPAYEMENT";
    static private String objetLcDetail = "LcDetails";
    static private String tableDetailBC = "detailBC";
    private static String objetMvtCaisse = "mvtCaisse";
    static private String objectDetailFPF = "detailFPF";
    public static String objetFactureFournisseur = "FactureFournisseur";
    static private String opFactureFournisseur = "OPFACTUREFOURNISSEUR";
    static private String objetLigneCredit = "LigneCredit";
    static private String objetLigneCreditRecette = "LigneCreditRecette";
    static private String visaOp = "VISAORDREPAYEMENT";
    static private String visaOr = "VISAOR";
    static public String typeOpFacture = "facture";
    static public String typeOpNormale = "normale";
    static public String tableVisaOp = "VISAORDREPAYEMENT";
    static public String objetFactureClient = "FACTURECLIENT";
    public static String tableOrFcLc = "ORFCLC";
    static public String tableFactureCLC = "FactureClientLC";
    static public String factureClient = "FACTURECLIENT";
    public static final String constanteTiersStock = "TIERS1";
    public static final String constantePeriode = "T";
    public static final String constanteTypeTiers = "TYPETIERS001";
    public static final String constanteCaisse = "CAISSE001";
    
    public static final String constanteEntreeStock = "MVT000002";
    public static final String constanteSortieStock = "MVT000003";
    public static final String constanteReintegrStock = "MVT000001";
    public static final String conge = "CONGE";
    public static final String mouvement = "MOUVEMENT";
    public static final String depart = "DEPART";
    public static final String deplacement = "DEPLACEMENT";
    public static final String deces = "DECES";
    public static final String uploadDirLocation = System.getProperty("jboss.home.dir")+"/welcome-content/upload";
    public static final String uploadedDir = "/upload";
    public static final String zoneIntervenationPhoto = "zi";
    public static final String fileExtension = ".jpg";
    public static final String idClass = "CLASS";
    public static final String idTable = "TYP000001";
    public static final String idVue = "TYP000002";
    public static final String idClasse = "TYP000001";
    public static final String idFonction = "TYP000002";    
    
    
    public static double tva = 0.2;

    public static String getPolyligneRN4() {
        return polyligneRN4;
    }

    public static String getPolyligneRN2() {
        return polyligneRN2;
    }


    public static double getLongueurPortion() {
        return longueurPortion;
    }

    public static void setLongueurPortion(double longueurPortion) {
        ConstanteAcade.longueurPortion = longueurPortion;
    }
    
    
    public static String getIdTypeLCDepense() {
        return idTypeLCDepense;
    }

    public static String getDetailLcCree() {
        return DetailLcCree;
    }

    public static String getDetailLcValide() {
        return DetailLcValide;
    }

    public static String getIdTypeLCRecette() {
        return idTypeLCRecette;
    }

    public static String getIdRoleDirecteur() {
        return idRoleDirecteur;
    }

    public static String[] getMois() {
        return mois;
    }

    public static String[] getMoisRang() {
        return moisRang;
    }

    public static String getObjetDepense() {
        return objetDepense;
    }

    public static String getObjetRecette() {
        return objetRecette;
    }

    public static String getObjetFacture() {
        return objetFacture;
    }

    public static String getObjetFactureF() {
        return objetFactureF;
    }

    public static String getTableRecetteLC() {
        return tableRecetteLC;
    }

    public static String getTableFactureLC() {
        return tableFactureLC;
    }

    public static String getTableFactureFLC() {
        return tableFactureFLC;
    }

    public static String getTableDepenseLC() {
        return tableDepenseLC;
    }

    public static String getIdFournAuto() {
        return idFournAuto;
    }

    public static String getObjFactureProf() {
        return objFactureProf;
    }

    public static String getObjetBc() {
        return objetBc;
    }

    public static String getObjetCDetailFactProf() {
        return objetCDetailFactProf;
    }

    public static String getObjetDetailBC() {
        return objetDetailBC;
    }

    public static String getObjetDetailFactFourn() {
        return objetDetailFactFourn;
    }

    public static String getDedFactProfFourn() {
        return dedFactProfFourn;
    }

    public static void setObjetDedBc(String objetDedBce) {
        objetDedBc = objetDedBce;
    }

    public static String getObjetDedBc() {
        return objetDedBc;
    }

    public static void setObjetLcDetMvt(String objetLcDetMvte) {
        objetLcDetMvt = objetLcDetMvte;
    }

    public static String getObjetLcDetMvt() {
        return objetLcDetMvt;
    }

    public static String getObjetLcDetDed() {
        return objetLcDetDed;
    }

    public static String getObjetLcDetOp() {
        return objetLcDetOp;
    }

    public static String getObjetOpFf() {
        return objetOpFf;
    }

    public static String getObjetDed() {
        return objetDed;
    }

    public static String getObjetOp() {
        return objetOp;
    }

    public static String getObjetLcDetail() {
        return objetLcDetail;
    }

    public static String getTableDetailBC() {
        return tableDetailBC;
    }

    public static String getObjetMvtCaisse() {
        return objetMvtCaisse;
    }

    public static String getObjectDetailFPF() {
        return objectDetailFPF;
    }

    public static String getObjetFactureFournisseur() {
        return objetFactureFournisseur;
    }

    public static String getOpFactureFournisseur() {
        return opFactureFournisseur;
    }

    public static String getObjetLigneCredit() {
        return objetLigneCredit;
    }

    public static String getObjetLigneCreditRecette() {
        return objetLigneCreditRecette;
    }

    public static String getVisaOp() {
        return visaOp;
    }

    public static String getVisaOr() {
        return visaOr;
    }

}
