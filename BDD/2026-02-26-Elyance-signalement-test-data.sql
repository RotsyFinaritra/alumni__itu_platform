-- =====================================================
-- Script de données de test pour les signalements
-- Date : 2026-02-26
-- =====================================================

BEGIN;

-- =====================
-- Nouvelles publications de test
-- =====================

-- Publication normale
INSERT INTO posts (id, idutilisateur, idtypepublication, idstatutpublication, idvisibilite, contenu, epingle, supprime, nb_likes, nb_commentaires, nb_partages, created_at)
VALUES 
('POST000010', 1, 'TYP00002', 'STAT00002', 'VISI00001', 'Ceci est une publication de test normale. Bienvenue sur notre plateforme alumni !', 0, 0, 5, 2, 0, NOW() - INTERVAL '3 days'),
('POST000011', 1, 'TYP00002', 'STAT00002', 'VISI00001', 'Publication avec contenu inapproprié simulé - Lorem ipsum dolor sit amet, consectetur adipiscing elit.', 0, 0, 3, 1, 0, NOW() - INTERVAL '2 days'),
('POST000012', 1, 'TYP00002', 'STAT00002', 'VISI00001', 'Offre emploi fictive - Rejoignez notre équipe dynamique ! Contenu potentiellement spam.', 0, 0, 1, 0, 0, NOW() - INTERVAL '1 day'),
('POST000013', 1, 'TYP00002', 'STAT00002', 'VISI00001', 'Contenu haineux simulé pour test - Ce message est une simulation à des fins de test.', 0, 0, 0, 3, 0, NOW() - INTERVAL '12 hours'),
('POST000014', 1, 'TYP00002', 'STAT00002', 'VISI00001', 'Publication avec fausses informations - Test des signalements.', 0, 0, 2, 1, 0, NOW() - INTERVAL '6 hours');

-- Mise à jour des séquences
SELECT setval('seq_posts', 14, true);

-- =====================
-- Commentaires de test
-- =====================

INSERT INTO commentaires (id, idutilisateur, post_id, parent_id, contenu, supprime, created_at)
VALUES 
('COMM000010', 1, 'POST000003', NULL, 'Super publication ! Merci pour le partage.', 0, NOW() - INTERVAL '2 days'),
('COMM000011', 1, 'POST000003', NULL, 'Je suis tout à fait daccord avec ce point de vue.', 0, NOW() - INTERVAL '2 days'),
('COMM000012', 1, 'POST000003', NULL, 'Commentaire inapproprié simulé - test de modération.', 0, NOW() - INTERVAL '1 day'),
('COMM000013', 1, 'POST000003', NULL, 'Commentaire de spam avec lien suspect - http://spam-test.com', 0, NOW() - INTERVAL '10 hours'),
('COMM000014', 1, 'POST000003', NULL, 'Insultes simulées pour test - contenu offensant fictif.', 0, NOW() - INTERVAL '8 hours'),
('COMM000015', 1, 'POST000003', NULL, 'Réponse normale au post.', 0, NOW() - INTERVAL '6 hours'),
('COMM000016', 1, 'POST000003', NULL, 'Ce commentaire contient de la désinformation simulée.', 0, NOW() - INTERVAL '4 hours');

-- Mise à jour des séquences
SELECT setval('seq_commentaires', 16, true);

-- =====================
-- Signalements de PUBLICATIONS (différents statuts)
-- =====================

-- Signalements EN ATTENTE (statut: SSIG00001)
INSERT INTO signalements (id, idutilisateur, post_id, commentaire_id, idmotifsignalement, idstatutsignalement, description, created_at)
VALUES 
('SIG0000001', 1, 'POST000011', NULL, 'MSIG00001', 'SSIG00001', 'Cette publication contient du contenu inapproprié.', NOW() - INTERVAL '1 day'),
('SIG0000002', 1, 'POST000012', NULL, 'MSIG00002', 'SSIG00001', 'Ceci ressemble à du spam publicitaire.', NOW() - INTERVAL '20 hours'),
('SIG0000003', 1, 'POST000013', NULL, 'MSIG00003', 'SSIG00001', 'Propos haineux détectés dans cette publication.', NOW() - INTERVAL '15 hours'),
('SIG0000004', 1, 'POST000014', NULL, 'MSIG00004', 'SSIG00001', 'Publication avec fausses informations.', NOW() - INTERVAL '5 hours');

-- Signalement EN COURS (statut: SSIG00002)
INSERT INTO signalements (id, idutilisateur, post_id, commentaire_id, idmotifsignalement, idstatutsignalement, description, created_at)
VALUES 
('SIG0000005', 1, 'POST000010', NULL, 'MSIG00001', 'SSIG00002', 'Signalement en cours de traitement.', NOW() - INTERVAL '3 hours');

-- Signalement TRAITÉ (statut: SSIG00003)
INSERT INTO signalements (id, idutilisateur, post_id, commentaire_id, idmotifsignalement, idstatutsignalement, description, traite_par, traite_at, decision, created_at)
VALUES 
('SIG0000006', 1, 'POST000001', NULL, 'MSIG00001', 'SSIG00003', 'Publication signalée et supprimée.', 1, NOW() - INTERVAL '1 hour', 'Publication supprimée car contenu inapproprié confirmé.', NOW() - INTERVAL '2 days');

-- =====================
-- Signalements de COMMENTAIRES (différents statuts)
-- =====================

-- Signalements EN ATTENTE
INSERT INTO signalements (id, idutilisateur, post_id, commentaire_id, idmotifsignalement, idstatutsignalement, description, created_at)
VALUES 
('SIG0000007', 1, NULL, 'COMM000012', 'MSIG00001', 'SSIG00001', 'Ce commentaire est inapproprié.', NOW() - INTERVAL '18 hours'),
('SIG0000008', 1, NULL, 'COMM000013', 'MSIG00002', 'SSIG00001', 'Commentaire de spam avec liens suspects.', NOW() - INTERVAL '9 hours'),
('SIG0000009', 1, NULL, 'COMM000014', 'MSIG00003', 'SSIG00001', 'Commentaire contenant des insultes.', NOW() - INTERVAL '7 hours'),
('SIG0000010', 1, NULL, 'COMM000016', 'MSIG00004', 'SSIG00001', 'Désinformation dans ce commentaire.', NOW() - INTERVAL '3 hours');

-- Signalement de commentaire REJETÉ (statut: SSIG00004)
INSERT INTO signalements (id, idutilisateur, post_id, commentaire_id, idmotifsignalement, idstatutsignalement, description, traite_par, traite_at, decision, created_at)
VALUES 
('SIG0000011', 1, NULL, 'COMM000010', 'MSIG00001', 'SSIG00004', 'Je pense que ce commentaire est inapproprié.', 1, NOW() - INTERVAL '30 minutes', 'Signalement rejeté - contenu conforme aux règles.', NOW() - INTERVAL '1 day');

-- Mise à jour des séquences
SELECT setval('seq_signalements', 11, true);

COMMIT;

-- =====================
-- Résumé des données de test insérées
-- =====================
-- Publications: POST000010 à POST000014 (5 nouvelles)
-- Commentaires: COMM000010 à COMM000016 (7 nouveaux)
-- Signalements de publications: SIG0000001 à SIG0000006 (6)
--   - 4 en attente (POST000011, POST000012, POST000013, POST000014)
--   - 1 en cours (POST000010)
--   - 1 traité (POST000001)
-- Signalements de commentaires: SIG0000007 à SIG0000011 (5)
--   - 4 en attente (COMM000012, COMM000013, COMM000014, COMM000016)
--   - 1 rejeté (COMM000010)
