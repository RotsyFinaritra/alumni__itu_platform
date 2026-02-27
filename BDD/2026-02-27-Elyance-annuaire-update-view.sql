-- Mise à jour pour annuaire: ajout identreprise à la vue
-- Date: 2026-02-27
-- Auteur: Elyance

-- Recréer la vue v_utilisateurpg_libcpl avec identreprise
DROP VIEW IF EXISTS v_utilisateurpg_libcpl;

CREATE OR REPLACE VIEW v_utilisateurpg_libcpl AS
SELECT u.refuser,
    u.loginuser,
    u.nomuser,
    u.prenom,
    u.mail,
    u.teluser,
    u.adruser,
    u.photo,
    u.idtypeutilisateur,
    u.idpromotion,
    COALESCE(p.libelle, '') AS promotion,
    COALESCE(t.libelle, '') AS typeutilisateur,
    -- Liste des compétences (libellés concaténés)
    (SELECT string_agg(c.libelle, ', ')
     FROM competence_utilisateur cu
     JOIN competence c ON cu.idcompetence = c.id
     WHERE cu.idutilisateur = u.refuser) AS competence,
    -- ID de l'entreprise actuelle (la plus récente)
    (SELECT e.identreprise
     FROM experience e
     WHERE e.idutilisateur = u.refuser
     ORDER BY e.datedebut DESC NULLS LAST
     LIMIT 1) AS identreprise,
    -- Libellé de l'entreprise actuelle
    (SELECT e2.libelle
     FROM experience e
     JOIN entreprise e2 ON e.identreprise = e2.id
     WHERE e.idutilisateur = u.refuser
     ORDER BY e.datedebut DESC NULLS LAST
     LIMIT 1) AS entreprise,
    -- ID de la ville de l'entreprise actuelle
    (SELECT v.id
     FROM experience e
     JOIN entreprise ent ON e.identreprise = ent.id
     JOIN ville v ON ent.idville = v.id
     WHERE e.idutilisateur = u.refuser
     ORDER BY e.datedebut DESC NULLS LAST
     LIMIT 1) AS idville,
    -- Libellé de la ville
    (SELECT v.libelle
     FROM experience e
     JOIN entreprise ent ON e.identreprise = ent.id
     JOIN ville v ON ent.idville = v.id
     WHERE e.idutilisateur = u.refuser
     ORDER BY e.datedebut DESC NULLS LAST
     LIMIT 1) AS ville,
    -- ID du pays
    (SELECT pa.id
     FROM experience e
     JOIN entreprise ent ON e.identreprise = ent.id
     JOIN ville v ON ent.idville = v.id
     JOIN pays pa ON v.idpays = pa.id
     WHERE e.idutilisateur = u.refuser
     ORDER BY e.datedebut DESC NULLS LAST
     LIMIT 1) AS idpays,
    -- Libellé du pays
    (SELECT pa.libelle
     FROM experience e
     JOIN entreprise ent ON e.identreprise = ent.id
     JOIN ville v ON ent.idville = v.id
     JOIN pays pa ON v.idpays = pa.id
     WHERE e.idutilisateur = u.refuser
     ORDER BY e.datedebut DESC NULLS LAST
     LIMIT 1) AS pays
FROM utilisateur u
LEFT JOIN promotion p ON u.idpromotion = p.id
LEFT JOIN type_utilisateur t ON u.idtypeutilisateur = t.id;
