-- Supprimer la contrainte FK sur traite_par qui refuse la valeur 0
ALTER TABLE signalements DROP CONSTRAINT IF EXISTS signalements_traite_par_fkey;

-- Rendre traite_par nullable et sans default
ALTER TABLE signalements ALTER COLUMN traite_par DROP NOT NULL;
ALTER TABLE signalements ALTER COLUMN traite_par SET DEFAULT NULL;
