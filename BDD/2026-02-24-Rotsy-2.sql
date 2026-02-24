-- =============================================================================
-- Migration : Espace Carriere - Correction types + Vues + Menu
-- Auteur    : Finaritra
-- Date      : 2026-02-24
-- Dependance: 2026-02-24-Fanilo-1.sql (schema publications)
-- =============================================================================

-- =============================================================================
-- 1. CORRECTION DES TYPES : BOOLEAN -> INTEGER (compatibilite APJ ClassMAPTable)
--    Le framework APJ (javaToSql) ne supporte pas boolean.
--    Les beans Post.java, PostStage.java, PostEmploi.java utilisent int.
-- =============================================================================

ALTER TABLE posts
    ALTER COLUMN epingle   TYPE INTEGER USING (CASE WHEN epingle THEN 1 ELSE 0 END),
    ALTER COLUMN epingle   SET DEFAULT 0,
    ALTER COLUMN supprime  TYPE INTEGER USING (CASE WHEN supprime THEN 1 ELSE 0 END),
    ALTER COLUMN supprime  SET DEFAULT 0;

ALTER TABLE post_stage
    ALTER COLUMN convention_requise TYPE INTEGER USING (CASE WHEN convention_requise THEN 1 ELSE 0 END),
    ALTER COLUMN convention_requise SET DEFAULT 0;

ALTER TABLE post_emploi
    ALTER COLUMN teletravail_possible TYPE INTEGER USING (CASE WHEN teletravail_possible THEN 1 ELSE 0 END),
    ALTER COLUMN teletravail_possible SET DEFAULT 0;

-- Correction type pour double Java (NUMERIC compatible avec double)
ALTER TABLE post_emploi
    ALTER COLUMN salaire_min TYPE NUMERIC(15,2),
    ALTER COLUMN salaire_max TYPE NUMERIC(15,2);

ALTER TABLE post_stage
    ALTER COLUMN indemnite TYPE NUMERIC(15,2);

-- =============================================================================
-- 2. VUES ENRICHIES POUR APJ PageRecherche / PageConsulte
-- =============================================================================

-- Vue offres d'emploi enrichie (PostEmploiLib)
CREATE OR REPLACE VIEW v_post_emploi_cpl AS
SELECT
    pe.post_id,
    pe.entreprise,
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
    INNER JOIN posts p          ON p.id = pe.post_id
    LEFT  JOIN utilisateur u  ON u.refuser = p.idutilisateur
    LEFT  JOIN statut_publication sp ON sp.id = p.idstatutpublication
    LEFT  JOIN visibilite_publication vp ON vp.id = p.idvisibilite
WHERE p.supprime = 0
  AND p.idtypepublication = 'TYP00002';

-- Vue offres de stage enrichie (PostStageLib)
CREATE OR REPLACE VIEW v_post_stage_cpl AS
SELECT
    ps.post_id,
    ps.entreprise,
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
    INNER JOIN posts p           ON p.id = ps.post_id
    LEFT  JOIN utilisateur u   ON u.refuser = p.idutilisateur
    LEFT  JOIN statut_publication sp  ON sp.id = p.idstatutpublication
    LEFT  JOIN visibilite_publication vp ON vp.id = p.idvisibilite
WHERE p.supprime = 0
  AND p.idtypepublication = 'TYP00001';

-- =============================================================================
-- 3. S'assurer que les donnees de reference existent (type Stage + Emploi)
--    (deja insere par 2026-02-24-Fanilo-1.sql, ON CONFLICT pour idempotence)
-- =============================================================================

INSERT INTO type_publication (id, libelle, code, icon, couleur, actif, ordre)
VALUES ('TYP00001', 'Stage',  'stage',  'fa-briefcase', '#3498db', 1, 1)
ON CONFLICT (id) DO NOTHING;

INSERT INTO type_publication (id, libelle, code, icon, couleur, actif, ordre)
VALUES ('TYP00002', 'Emploi', 'emploi', 'fa-suitcase', '#2ecc71', 1, 2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO statut_publication (id, libelle, code, icon, couleur, actif, ordre)
VALUES ('STAT00002', 'Publie', 'publie', 'fa-check-circle', '#27ae60', 1, 2)
ON CONFLICT (id) DO NOTHING;

INSERT INTO visibilite_publication (id, libelle, code, icon, couleur, actif, ordre)
VALUES ('VISI00001', 'Public',    'public',    'fa-globe',          '#3498db', 1, 1)
ON CONFLICT (id) DO NOTHING;
INSERT INTO visibilite_publication (id, libelle, code, icon, couleur, actif, ordre)
VALUES ('VISI00002', 'Groupe',    'groupe',    'fa-users',          '#9b59b6', 1, 2)
ON CONFLICT (id) DO NOTHING;
INSERT INTO visibilite_publication (id, libelle, code, icon, couleur, actif, ordre)
VALUES ('VISI00003', 'Prive',     'prive',     'fa-lock',           '#e74c3c', 1, 3)
ON CONFLICT (id) DO NOTHING;
INSERT INTO visibilite_publication (id, libelle, code, icon, couleur, actif, ordre)
VALUES ('VISI00004', 'Promotion', 'promotion', 'fa-graduation-cap', '#f39c12', 1, 4)
ON CONFLICT (id) DO NOTHING;

-- =============================================================================
-- 4. MENU ESPACE CARRIERE (MENDYN004 / USRM005)
-- =============================================================================

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN004', 'Espace Carriere', 'work', '#', 4, 1, NULL)
ON CONFLICT (id) DO NOTHING;

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN004-1', 'Tableau de bord', 'dashboard',
        'module.jsp?but=carriere/carriere-accueil.jsp', 1, 2, 'MENDYN004')
ON CONFLICT (id) DO NOTHING;

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN004-2', 'Offres d''emploi', 'business_center',
        'module.jsp?but=carriere/emploi-liste.jsp', 2, 2, 'MENDYN004')
ON CONFLICT (id) DO NOTHING;

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN004-3', 'Offres de stage', 'school',
        'module.jsp?but=carriere/stage-liste.jsp', 3, 2, 'MENDYN004')
ON CONFLICT (id) DO NOTHING;

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN004-4', 'Publier emploi', 'post_add',
        'module.jsp?but=carriere/emploi-saisie.jsp', 4, 2, 'MENDYN004')
ON CONFLICT (id) DO NOTHING;

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN004-5', 'Publier stage', 'note_add',
        'module.jsp?but=carriere/stage-saisie.jsp', 5, 2, 'MENDYN004')
ON CONFLICT (id) DO NOTHING;

-- Acces pour tous les utilisateurs
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM005',   '*', 'MENDYN004',   NULL, NULL, NULL, 0) ON CONFLICT (id) DO NOTHING;
-- INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
-- VALUES ('USRM005-1', '*', 'MENDYN004-1', NULL, NULL, NULL, 0) ON CONFLICT (id) DO NOTHING;
-- INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
-- VALUES ('USRM005-2', '*', 'MENDYN004-2', NULL, NULL, NULL, 0) ON CONFLICT (id) DO NOTHING;
-- INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
-- VALUES ('USRM005-3', '*', 'MENDYN004-3', NULL, NULL, NULL, 0) ON CONFLICT (id) DO NOTHING;
-- INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
-- VALUES ('USRM005-4', '*', 'MENDYN004-4', NULL, NULL, NULL, 0) ON CONFLICT (id) DO NOTHING;
-- INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
-- VALUES ('USRM005-5', '*', 'MENDYN004-5', NULL, NULL, NULL, 0) ON CONFLICT (id) DO NOTHING;
