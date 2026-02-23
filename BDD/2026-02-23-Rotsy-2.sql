-- Migration : visibilite_utilisateur.visible BOOLEAN → INTEGER
-- Raison : APJ (javaToSql) ne supporte pas le type boolean Java,
--          ce qui provoque Champ.type = null → NPE dans makeWhere.
--          Le type int est correctement géré par APJ.

-- 1. Ajouter une colonne temporaire
ALTER TABLE visibilite_utilisateur
ADD COLUMN visible_tmp INTEGER;

-- 2. Copier les données (BOOLEAN → INTEGER)
UPDATE visibilite_utilisateur
SET visible_tmp = CASE
    WHEN visible IS TRUE THEN 1
    ELSE 0
END;

-- 3. Supprimer l’ancienne colonne
ALTER TABLE visibilite_utilisateur
DROP COLUMN visible;

-- 4. Renommer la colonne temporaire
ALTER TABLE visibilite_utilisateur
RENAME COLUMN visible_tmp TO visible;

-- 5. Ajouter la valeur par défaut
ALTER TABLE visibilite_utilisateur
ALTER COLUMN visible SET DEFAULT 1;