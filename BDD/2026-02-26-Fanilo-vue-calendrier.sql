-- Vue complète du calendrier avec libellé de la promotion
-- Date : 2026-02-26

CREATE OR REPLACE VIEW calendrier_scolaire_cpl AS
SELECT 
    c.id,
    c.titre,
    c.description,
    c.date_debut,
    c.date_fin,
    c.heure_debut,
    c.heure_fin,
    c.couleur,
    c.idpromotion,
    c.created_by,
    c.created_at,
    CASE 
        WHEN p.libelle IS NOT NULL THEN p.libelle || ' (' || p.annee || ')'
        ELSE 'Tous'
    END AS libpromotion
FROM calendrier_scolaire c
LEFT JOIN promotion p ON c.idpromotion = p.id;

COMMIT;
