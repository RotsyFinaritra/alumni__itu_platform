-- Fix: Changer les colonnes heure_debut et heure_fin de TIME vers VARCHAR
-- Car le framework APJ ne supporte pas le type TIME
-- Date : 2026-02-26

ALTER TABLE calendrier_scolaire 
    ALTER COLUMN heure_debut TYPE VARCHAR(10),
    ALTER COLUMN heure_fin TYPE VARCHAR(10);

COMMIT;
