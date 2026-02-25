-- =============================================================================
-- Migration: Lier entreprise aux tables de reference
-- Date: 2026-02-24
-- =============================================================================

-- 1. Modifier post_emploi : ajouter identreprise (FK vers entreprise)
ALTER TABLE post_emploi 
    ADD COLUMN IF NOT EXISTS identreprise VARCHAR(30);

ALTER TABLE post_emploi 
    ADD CONSTRAINT post_emploi_identreprise_fkey 
    FOREIGN KEY (identreprise) REFERENCES entreprise(id);

-- Rendre entreprise (texte) nullable pour transition
ALTER TABLE post_emploi 
    ALTER COLUMN entreprise DROP NOT NULL;

-- 2. Modifier post_stage : ajouter identreprise (FK vers entreprise)
ALTER TABLE post_stage 
    ADD COLUMN IF NOT EXISTS identreprise VARCHAR(30);

ALTER TABLE post_stage 
    ADD CONSTRAINT post_stage_identreprise_fkey 
    FOREIGN KEY (identreprise) REFERENCES entreprise(id);

-- Rendre entreprise (texte) nullable pour transition
ALTER TABLE post_stage 
    ALTER COLUMN entreprise DROP NOT NULL;

-- 3. Mettre a jour les vues pour joindre la table entreprise
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
    pe.competences_requises,
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
    ps.competences_requises,
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
  AND p.idtypepublication = 'TYP00003';

-- 4. Creer index pour performances
CREATE INDEX IF NOT EXISTS idx_post_emploi_identreprise ON post_emploi(identreprise);
CREATE INDEX IF NOT EXISTS idx_post_stage_identreprise ON post_stage(identreprise);
