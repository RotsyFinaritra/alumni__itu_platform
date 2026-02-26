-- =====================================================
-- Synchronisation : Tous les utilisateurs dans leur groupe de promotion
-- Date : 2026-02-26
-- =====================================================

BEGIN;

-- 1. S'assurer que TOUTES les promotions ont un groupe
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

-- 2. Ajouter TOUS les utilisateurs existants à leur groupe de promotion
--    (ceux qui ont un idpromotion et ne sont pas encore membres)
INSERT INTO groupe_membres (id, idutilisateur, idgroupe, idrole, statut, joined_at)
SELECT 
    'GMBR' || LPAD(CAST(nextval('seqgroupemembres') AS VARCHAR), 6, '0'),
    u.refuser,
    g.id,
    'ROLE00003',
    'actif',
    NOW()
FROM utilisateur u
JOIN groupes g ON g.idpromotion = u.idpromotion
WHERE u.idpromotion IS NOT NULL
  AND u.idpromotion != ''
  AND NOT EXISTS (
      SELECT 1 FROM groupe_membres gm 
      WHERE gm.idutilisateur = u.refuser AND gm.idgroupe = g.id
  );

COMMIT;
