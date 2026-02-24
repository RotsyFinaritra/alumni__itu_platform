-- =====================================================
-- Migration 2026-02-24 : Vue Annuaire Utilisateurs
-- Vue complète pour l'annuaire avec photo, ville, pays
-- =====================================================

DROP VIEW IF EXISTS v_utilisateurpg_libcpl;

CREATE OR REPLACE VIEW v_utilisateurpg_libcpl AS
SELECT 
    u.refuser,
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
    (
        SELECT string_agg(c.libelle, ', ')
        FROM competence_utilisateur cu
        JOIN competence c ON cu.idcompetence = c.id
        WHERE cu.idutilisateur = u.refuser
    ) AS competence,
    (
        SELECT e2.libelle
        FROM experience e
        JOIN entreprise e2 ON e.identreprise = e2.id
        WHERE e.idutilisateur = u.refuser
        ORDER BY e.datedebut DESC NULLS LAST
        LIMIT 1
    ) AS entreprise,
    (
        SELECT v.id
        FROM experience e
        JOIN entreprise ent ON e.identreprise = ent.id
        JOIN ville v ON ent.idville = v.id
        WHERE e.idutilisateur = u.refuser
        ORDER BY e.datedebut DESC NULLS LAST
        LIMIT 1
    ) AS idville,
    (
        SELECT v.libelle
        FROM experience e
        JOIN entreprise ent ON e.identreprise = ent.id
        JOIN ville v ON ent.idville = v.id
        WHERE e.idutilisateur = u.refuser
        ORDER BY e.datedebut DESC NULLS LAST
        LIMIT 1
    ) AS ville,
    (
        SELECT pa.id
        FROM experience e
        JOIN entreprise ent ON e.identreprise = ent.id
        JOIN ville v ON ent.idville = v.id
        JOIN pays pa ON v.idpays = pa.id
        WHERE e.idutilisateur = u.refuser
        ORDER BY e.datedebut DESC NULLS LAST
        LIMIT 1
    ) AS idpays,
    (
        SELECT pa.libelle
        FROM experience e
        JOIN entreprise ent ON e.identreprise = ent.id
        JOIN ville v ON ent.idville = v.id
        JOIN pays pa ON v.idpays = pa.id
        WHERE e.idutilisateur = u.refuser
        ORDER BY e.datedebut DESC NULLS LAST
        LIMIT 1
    ) AS pays
FROM utilisateur u
LEFT JOIN promotion p ON u.idpromotion = p.id
LEFT JOIN type_utilisateur t ON u.idtypeutilisateur = t.id;

-- Mise à jour du menu annuaire
UPDATE menudynamique
SET href = 'module.jsp?but=annuaire/annuaire-liste.jsp'
WHERE id = 'MENDYN002-1';