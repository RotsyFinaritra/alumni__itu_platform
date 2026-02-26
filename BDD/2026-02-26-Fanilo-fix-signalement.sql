-- Fix signalement: supprimer la FK sur traite_par qui empêche l'insertion
-- traite_par sera rempli uniquement quand un admin traite le signalement
ALTER TABLE signalements DROP CONSTRAINT IF EXISTS signalements_traite_par_fkey;
ALTER TABLE signalements ALTER COLUMN traite_par DROP NOT NULL;
ALTER TABLE signalements ALTER COLUMN traite_par SET DEFAULT NULL;
