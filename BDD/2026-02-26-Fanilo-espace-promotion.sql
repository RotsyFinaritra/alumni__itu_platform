-- =====================================================
-- Espace Promotion - Groupes privés par promotion
-- Date : 2026-02-26
-- =====================================================

BEGIN;

-- 1. Ajouter idpromotion à la table groupes (lien vers promotion)
ALTER TABLE groupes ADD COLUMN IF NOT EXISTS idpromotion VARCHAR(30) REFERENCES promotion(id);

-- 2. Créer séquence pour groupes si elle n'existe pas
CREATE SEQUENCE IF NOT EXISTS seqgroupes START WITH 1;
CREATE OR REPLACE FUNCTION getseqgroupes() RETURNS INTEGER AS 
$$ BEGIN RETURN (SELECT nextval('seqgroupes')); END $$ LANGUAGE plpgsql;

-- 3. Créer séquence pour groupe_membres si elle n'existe pas
CREATE SEQUENCE IF NOT EXISTS seqgroupemembres START WITH 1;
CREATE OR REPLACE FUNCTION getseqgroupemembres() RETURNS INTEGER AS 
$$ BEGIN RETURN (SELECT nextval('seqgroupemembres')); END $$ LANGUAGE plpgsql;

-- 4. Créer automatiquement un groupe pour chaque promotion existante
INSERT INTO groupes (id, nom, description, type_groupe, created_by, actif, idpromotion)
SELECT 
    'GRP' || LPAD(CAST(nextval('seqgroupes') AS VARCHAR), 7, '0'),
    'Promotion ' || p.libelle,
    'Espace privé de la promotion ' || p.libelle || ' (année ' || p.annee || ')',
    'promotion',
    1,
    1,
    p.id
FROM promotion p
WHERE NOT EXISTS (SELECT 1 FROM groupes g WHERE g.idpromotion = p.id);

-- 5. Ajouter automatiquement les membres à leur groupe de promotion
INSERT INTO groupe_membres (id, idutilisateur, idgroupe, idrole, statut)
SELECT 
    'GMBR' || LPAD(CAST(nextval('seqgroupemembres') AS VARCHAR), 6, '0'),
    u.refuser,
    g.id,
    'ROLE00003',
    'actif'
FROM utilisateur u
JOIN groupes g ON g.idpromotion = u.idpromotion
WHERE u.idpromotion IS NOT NULL
  AND u.idpromotion != ''
  AND NOT EXISTS (
      SELECT 1 FROM groupe_membres gm 
      WHERE gm.idutilisateur = u.refuser AND gm.idgroupe = g.id
  );

-- 6. Menu Espace Promotion (niveau 1)
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYNPROMO', 'Espace Promotion', 'school', 'module.jsp?but=promotion/espace-promotion.jsp', 6, 1, NULL)
ON CONFLICT (id) DO UPDATE SET libelle = EXCLUDED.libelle, icone = EXCLUDED.icone, href = EXCLUDED.href;

-- 7. Droits d'accès : visible par tous
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM_PROMO', '*', 'MENDYNPROMO', NULL, NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

COMMIT;
