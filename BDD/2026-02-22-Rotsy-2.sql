-- Active: 1765439577522@@127.0.0.1@5432@alumni_itu

ALTER TABLE utilisateur
ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE TABLE visibilite_utilisateur (
    idutilisateur INT REFERENCES utilisateur (refuser),
    nomchamp VARCHAR(50) NOT NULL, -- 'telephone', 'mail', 'entreprise', 'photo', ...
    visible BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (idutilisateur, nomchamp)
);


CREATE TABLE moderation_utilisateur (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    idutilisateur INT REFERENCES utilisateur (refuser),
    idmoderateur INT REFERENCES utilisateur (refuser),
    type_action VARCHAR(20) NOT NULL, -- 'suspendu', 'banni', 'leve'
    motif VARCHAR(255),
    date_action TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_expiration DATE -- NULL = permanent (banni)
);

CREATE SEQUENCE seqmoderationutilisateur START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE FUNCTION getseqmoderationutilisateur() RETURNS integer 
LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqmoderationutilisateur')); END $$;

CREATE OR REPLACE VIEW utilisateur_statut AS
SELECT
    u.refuser,
    u.loginuser,
    u.nomuser,
    u.idrole,
    CASE
        WHEN m.type_action = 'leve' THEN 'actif'
        WHEN m.type_action IS NULL THEN 'actif'
        WHEN m.date_expiration IS NOT NULL
        AND m.date_expiration < CURRENT_DATE THEN 'actif'
        ELSE m.type_action
    END AS statut,
    m.motif,
    m.date_expiration,
    m.idmoderateur
FROM utilisateur u
    LEFT JOIN LATERAL (
        SELECT *
        FROM moderation_utilisateur
        WHERE
            idutilisateur = u.refuser
        ORDER BY date_action DESC
        LIMIT 1
    ) m ON true;

-- CREATE OR REPLACE VIEW utilisateurvalide AS
-- SELECT u.*, '' AS service, COALESCE(u.adruser, '') AS direction
-- FROM utilisateur u
-- WHERE
--     u.refuser NOT IN (
--         SELECT refuser
--         FROM utilisateur_statut
--         WHERE
--             statut IN ('suspendu', 'banni')
--     );

DROP VIEW IF EXISTS utilisateurvalide;
CREATE OR REPLACE VIEW utilisateurvalide AS
SELECT 
    u.*, 
    '' AS service, 
    COALESCE(u.adruser, '') AS direction
FROM utilisateur u
JOIN utilisateur_statut s 
    ON s.refuser = u.refuser
WHERE s.statut = 'actif';