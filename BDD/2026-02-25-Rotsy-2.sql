-- ==============================
-- Vue complète pour les activités/événements
-- ==============================

DROP VIEW IF EXISTS v_post_activite_cpl;
CREATE OR REPLACE VIEW v_post_activite_cpl AS
SELECT
    pa.post_id,
    pa.titre,
    pa.categorie,
    pa.lieu,
    pa.adresse,
    pa.date_debut,
    pa.date_fin,
    pa.prix,
    pa.nombre_places,
    pa.places_restantes,
    pa.contact_email,
    pa.contact_tel,
    pa.lien_inscription,
    pa.lien_externe,
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
    -- Jointures pour les libellés
    COALESCE(u.nomuser || ' ' || u.prenom, 'Inconnu') AS auteur_nom,
    sp.libelle AS statut_libelle,
    vp.libelle AS visibilite_libelle
FROM post_activite pa
    INNER JOIN posts p ON p.id = pa.post_id
    LEFT JOIN utilisateur u ON u.refuser = p.idutilisateur
    LEFT JOIN statut_publication sp ON sp.id = p.idstatutpublication
    LEFT JOIN visibilite_publication vp ON vp.id = p.idvisibilite
WHERE p.supprime = 0
  AND p.idtypepublication = 'TYP00003';

-- Ajouter la vue au générateur APJ
INSERT INTO generateurtable (tablename)
SELECT 'v_post_activite_cpl'
WHERE NOT EXISTS (SELECT 1 FROM generateurtable g WHERE g.tablename = 'v_post_activite_cpl');
