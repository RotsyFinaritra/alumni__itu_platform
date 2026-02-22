package utils;

import utilitaire.Utilitaire;

import java.util.Calendar;

public class CalendarUtils extends Utilitaire {
    public static String heureCouranteHMS(int decalageHeure, int decalageMinute, int decalageSeconde) {
        Calendar a = Calendar.getInstance();
        if (decalageHeure > 0) {
            a.add(Calendar.HOUR_OF_DAY, decalageHeure);
        }
        if (decalageMinute > 0) {
            a.add(Calendar.MINUTE, decalageMinute);
        }
        if (decalageSeconde > 0) {
            a.add(Calendar.SECOND, decalageSeconde);
        }
        String retour = null;
        retour = String.valueOf(String.valueOf(completerInt(2, a.get(11)))).concat(":");
        retour = String.valueOf(String.valueOf((new StringBuffer(String.valueOf(String.valueOf(retour)))).append(completerInt(2, a.get(12))).append(":")));
        retour = String.valueOf(String.valueOf((new StringBuffer(String.valueOf(String.valueOf(retour)))).append(completerInt(2, a.get(13)))));
        return retour;
    }
}
