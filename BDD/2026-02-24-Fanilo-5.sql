-- =====================================================================
-- Migration : Création des tables emploi_competence et stage_competence
-- Permettre plusieurs compétences par offre d'emploi/stage
-- Date: 2026-02-24
-- =====================================================================

-- ==============================
-- 1. CRÉER LA TABLE EMPLOI_COMPETENCE
-- ==============================
CREATE TABLE emploi_competence (
    post_id VARCHAR(50) NOT NULL REFERENCES post_emploi(post_id) ON DELETE CASCADE,
    idcompetence VARCHAR(30) NOT NULL REFERENCES competence(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, idcompetence)
);

COMMENT ON TABLE emploi_competence IS 'Association many-to-many entre offres d''emploi et compétences';
COMMENT ON COLUMN emploi_competence.post_id IS 'FK vers post_emploi';
COMMENT ON COLUMN emploi_competence.idcompetence IS 'FK vers competence';

-- Index pour performances
CREATE INDEX idx_emploi_competence_post ON emploi_competence(post_id);
CREATE INDEX idx_emploi_competence_comp ON emploi_competence(idcompetence);

-- ==============================
-- 2. CRÉER LA TABLE STAGE_COMPETENCE
-- ==============================
CREATE TABLE stage_competence (
    post_id VARCHAR(50) NOT NULL REFERENCES post_stage(post_id) ON DELETE CASCADE,
    idcompetence VARCHAR(30) NOT NULL REFERENCES competence(id) ON DELETE CASCADE,
    PRIMARY KEY (post_id, idcompetence)
);

COMMENT ON TABLE stage_competence IS 'Association many-to-many entre offres de stage et compétences';
COMMENT ON COLUMN stage_competence.post_id IS 'FK vers post_stage';
COMMENT ON COLUMN stage_competence.idcompetence IS 'FK vers competence';

-- Index pour performances
CREATE INDEX idx_stage_competence_post ON stage_competence(post_id);
CREATE INDEX idx_stage_competence_comp ON stage_competence(idcompetence);

-- ==============================
-- 3. SUPPRIMER LES COLONNES competences_requises
-- ==============================
ALTER TABLE post_emploi DROP COLUMN IF EXISTS competences_requises;
ALTER TABLE post_stage DROP COLUMN IF EXISTS competences_requises;

-- ==============================
-- 4. METTRE À JOUR LES VUES
-- Les compétences seront agrégées depuis les nouvelles tables
-- ==============================

DROP VIEW IF EXISTS v_post_emploi_cpl;
CREATE OR REPLACE VIEW v_post_emploi_cpl AS
SELECT
    pe.post_id,
    pe.identreprise,
    COALESCE(e.libelle, pe.entreprise) AS entreprise,
    pe.localisation,
    pe.poste,
    pe.type_contrat,
    pe.salaire_min,
    pe.salaire_max,
    pe.devise,
    pe.experience_requise,
    -- Compétences agrégées depuis emploi_competence
    (SELECT string_agg(c.libelle, ', ' ORDER BY c.libelle) 
     FROM emploi_competence ec 
     JOIN competence c ON c.id = ec.idcompetence 
     WHERE ec.post_id = pe.post_id) AS competences_requises,
    pe.niveau_etude_requis,
    pe.teletravail_possible,
    pe.date_limite,
    pe.contact_email,
    pe.contact_tel,
    pe.lien_candidature,
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
    -- Jointures pour les libelles
    COALESCE(u.nomuser || ' ' || u.prenom, 'Inconnu') AS auteur_nom,
    sp.libelle AS statut_libelle,
    vp.libelle AS visibilite_libelle
FROM post_emploi pe
    INNER JOIN posts p ON p.id = pe.post_id
    LEFT JOIN entreprise e ON e.id = pe.identreprise
    LEFT JOIN utilisateur u ON u.refuser = p.idutilisateur
    LEFT JOIN statut_publication sp ON sp.id = p.idstatutpublication
    LEFT JOIN visibilite_publication vp ON vp.id = p.idvisibilite
WHERE p.supprime = 0
  AND p.idtypepublication = 'TYP00002';

DROP VIEW IF EXISTS v_post_stage_cpl;
CREATE OR REPLACE VIEW v_post_stage_cpl AS
SELECT
    ps.post_id,
    ps.identreprise,
    COALESCE(e.libelle, ps.entreprise) AS entreprise,
    ps.localisation,
    ps.duree,
    ps.date_debut,
    ps.date_fin,
    ps.indemnite,
    ps.niveau_etude_requis,
    -- Compétences agrégées depuis stage_competence
    (SELECT string_agg(c.libelle, ', ' ORDER BY c.libelle) 
     FROM stage_competence sc 
     JOIN competence c ON c.id = sc.idcompetence 
     WHERE sc.post_id = ps.post_id) AS competences_requises,
    ps.convention_requise,
    ps.places_disponibles,
    ps.contact_email,
    ps.contact_tel,
    ps.lien_candidature,
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
    -- Jointures pour les libelles
    COALESCE(u.nomuser || ' ' || u.prenom, 'Inconnu') AS auteur_nom,
    sp.libelle AS statut_libelle,
    vp.libelle AS visibilite_libelle
FROM post_stage ps
    INNER JOIN posts p ON p.id = ps.post_id
    LEFT JOIN entreprise e ON e.id = ps.identreprise
    LEFT JOIN utilisateur u ON u.refuser = p.idutilisateur
    LEFT JOIN statut_publication sp ON sp.id = p.idstatutpublication
    LEFT JOIN visibilite_publication vp ON vp.id = p.idvisibilite
WHERE p.supprime = 0
  AND p.idtypepublication = 'TYP00001';

-- ==============================
-- 5. AJOUTER TABLES AU GÉNÉRATEUR APJ
-- ==============================
INSERT INTO generateurtable (tablename)
SELECT tablename FROM (VALUES ('emploi_competence'), ('stage_competence')) AS t(tablename)
WHERE NOT EXISTS (SELECT 1 FROM generateurtable g WHERE g.tablename = t.tablename);
