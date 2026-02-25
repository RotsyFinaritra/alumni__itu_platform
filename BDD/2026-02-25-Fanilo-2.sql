-- Contrainte unique sur likes : une personne ne peut aimer une publication qu'une seule fois
-- Supprimer les doublons existants avant d'ajouter la contrainte
DELETE FROM likes WHERE id NOT IN (
    SELECT MIN(id) FROM likes GROUP BY post_id, idutilisateur
);

-- Ajouter la contrainte unique
ALTER TABLE likes ADD CONSTRAINT uq_likes_post_user UNIQUE (post_id, idutilisateur);
