-- ==============================
-- Modifications post_activite : date/heure, catégorie FK, prix double, optionnels
-- ==============================

-- 1. Créer la table categorie_activite
CREATE TABLE IF NOT EXISTS categorie_activite (
    id VARCHAR(50) PRIMARY KEY,
    libelle VARCHAR(200) NOT NULL
);

-- Séquence et fonction PK
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_categorie_activite') THEN
        CREATE SEQUENCE seq_categorie_activite START WITH 1;
    END IF;
END $$;

CREATE OR REPLACE FUNCTION getseqcategorieactivite() RETURNS INTEGER LANGUAGE plpgsql AS $$
BEGIN
    RETURN (SELECT nextval('seq_categorie_activite'));
END $$;

-- Ajouter au générateur APJ
INSERT INTO generateurtable (tablename)
SELECT 'categorie_activite'
WHERE NOT EXISTS (SELECT 1 FROM generateurtable g WHERE g.tablename = 'categorie_activite');

-- Données initiales
INSERT INTO categorie_activite (id, libelle) VALUES ('CATACT001', 'Conférence') ON CONFLICT (id) DO NOTHING;
INSERT INTO categorie_activite (id, libelle) VALUES ('CATACT002', 'Atelier') ON CONFLICT (id) DO NOTHING;
INSERT INTO categorie_activite (id, libelle) VALUES ('CATACT003', 'Séminaire') ON CONFLICT (id) DO NOTHING;
INSERT INTO categorie_activite (id, libelle) VALUES ('CATACT004', 'Formation') ON CONFLICT (id) DO NOTHING;
INSERT INTO categorie_activite (id, libelle) VALUES ('CATACT005', 'Rencontre alumni') ON CONFLICT (id) DO NOTHING;
INSERT INTO categorie_activite (id, libelle) VALUES ('CATACT006', 'Compétition') ON CONFLICT (id) DO NOTHING;
INSERT INTO categorie_activite (id, libelle) VALUES ('CATACT007', 'Sortie') ON CONFLICT (id) DO NOTHING;
INSERT INTO categorie_activite (id, libelle) VALUES ('CATACT008', 'Autre') ON CONFLICT (id) DO NOTHING;

-- 2. Modifier la table post_activite
-- Changer categorie en FK vers categorie_activite (renommer en idcategorie)
ALTER TABLE post_activite ADD COLUMN IF NOT EXISTS idcategorie VARCHAR(50) REFERENCES categorie_activite(id);

-- Migrer les données existantes (si catégorie textuelle existe déjà)
-- UPDATE post_activite SET idcategorie = ... WHERE categorie IS NOT NULL;

-- Supprimer l'ancienne colonne categorie
DROP VIEW IF EXISTS v_post_activite_cpl;
ALTER TABLE post_activite DROP COLUMN IF EXISTS categorie;

-- date_debut et date_fin restent en TIMESTAMP (APJ gère nativement java.sql.Timestamp)
-- Pas de modification de type nécessaire pour ces colonnes

-- Changer prix de DECIMAL vers DOUBLE PRECISION
ALTER TABLE post_activite ALTER COLUMN prix TYPE DOUBLE PRECISION;

-- 3. Recréer la vue v_post_activite_cpl
CREATE OR REPLACE VIEW v_post_activite_cpl AS
SELECT
    pa.post_id,
    pa.titre,
    pa.idcategorie,
    ca.libelle AS categorie_libelle,
    pa.lieu,
    pa.adresse,
    pa.date_debut,
    pa.date_fin,
    pa.prix,
    pa.nombre_places,
    pa.places_restantes,
    pa.contact_email,
    pa.contact_tel,
    pa.lien_inscription,
    pa.lien_externe,
    -- Champs depuis posts
    p.contenu,
    p.idutilisateur,
    p.idgroupe,
    p.idvisibilite,
    p.idstatutpublication,
    p.nb_likes,
    p.nb_commentaires,
    p.nb_partages,
    p.created_at,
    p.edited_at,
    p.epingle,
    p.supprime,
    -- Jointures pour les libellés
    COALESCE(u.nomuser || ' ' || u.prenom, 'Inconnu') AS auteur_nom,
    sp.libelle AS statut_libelle,
    vp.libelle AS visibilite_libelle
FROM post_activite pa
    INNER JOIN posts p ON p.id = pa.post_id
    LEFT JOIN categorie_activite ca ON ca.id = pa.idcategorie
    LEFT JOIN utilisateur u ON u.refuser = p.idutilisateur
    LEFT JOIN statut_publication sp ON sp.id = p.idstatutpublication
    LEFT JOIN visibilite_publication vp ON vp.id = p.idvisibilite
WHERE p.supprime = 0
  AND p.idtypepublication = 'TYP00003';

COMMIT;
