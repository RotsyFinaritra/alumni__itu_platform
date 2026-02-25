-- =====================================================================
-- Migration : Création de generateurtable et enregistrement des tables
-- Correction de l'erreur NullPointerException dans CGenUtil.makeWhere
-- Date: 2026-02-25
-- =====================================================================

-- ==============================
-- 1. CRÉER LA TABLE GENERATEURTABLE (si elle n'existe pas)
-- Table requise par le framework APJ pour le mapping ORM
-- ==============================
CREATE TABLE IF NOT EXISTS generateurtable (
    tablename VARCHAR(100) PRIMARY KEY NOT NULL
);

COMMENT ON TABLE generateurtable IS 'Table APJ - Liste des tables mappées pour le framework ORM';

-- ==============================
-- 2. AJOUTER LES TABLES AU GÉNÉRATEUR APJ
-- Ces tables existent mais ne sont pas enregistrées dans generateurtable
-- ce qui cause une erreur NullPointerException lors des recherches APJ
-- ==============================
INSERT INTO generateurtable (tablename)
SELECT tablename FROM (VALUES 
    -- Tables APJ Framework
    ('roles'),
    ('utilisateur'),
    ('paramcrypt'),
    ('userhomepage'),
    ('historique_valeur'),
    ('mailcc'),
    ('action'),
    ('restriction'),
    ('menudynamique'),
    ('usermenu'),
    -- Tables Alumni référentiels
    ('type_utilisateur'),
    ('type_emploie'),
    ('promotion'),
    ('specialite'),
    ('option'),
    ('parcours'),
    ('competence'),
    ('competence_utilisateur'),
    ('diplome'),
    ('pays'),
    ('ville'),
    ('entreprise'),
    ('formation'),
    ('experiencepro'),
    ('reseau_social'),
    ('reseau_utilisateur'),
    -- Tables Publications
    ('type_fichier'),
    ('post_fichiers'),
    ('type_publication'),
    ('statut_publication'),
    ('visibilite_publication'),
    ('type_notification'),
    ('motif_signalement'),
    ('statut_signalement'),
    ('role_groupe'),
    ('posts'),
    ('post_stage'),
    ('post_emploi'),
    ('post_activite'),
    ('likes'),
    ('commentaires'),
    ('partages'),
    ('groupes'),
    ('groupe_membres'),
    ('topics'),
    ('utilisateur_interets'),
    ('post_topics'),
    ('notifications'),
    ('signalements'),
    ('emploi_competence'),
    ('stage_competence')
) AS t(tablename)
WHERE NOT EXISTS (SELECT 1 FROM generateurtable g WHERE g.tablename = t.tablename);

-- ==============================
-- 3. VÉRIFICATION
-- ==============================
SELECT 'Nombre total de tables dans generateurtable : ' || COUNT(*) FROM generateurtable;
