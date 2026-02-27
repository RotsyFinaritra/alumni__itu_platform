-- ============================================================================
-- Script de nettoyage des données
-- Date: 2026-02-27
-- Description: Supprime les données des tables utilisateur, publications,
--              calendrier, modération, signalements et toutes les tables liées
-- ============================================================================
-- ORDRE : tables enfants (FK) d'abord, puis tables parentes

BEGIN;

-- ============================================================================
-- 1. SIGNALEMENTS
-- ============================================================================
DELETE FROM signalements;

-- ============================================================================
-- 2. NOTIFICATIONS
-- ============================================================================
DELETE FROM notifications;

-- ============================================================================
-- 3. PUBLICATIONS - Tables enfants d'abord
-- ============================================================================

-- 3a. Interactions sur les posts
DELETE FROM likes;
DELETE FROM commentaires;
DELETE FROM partages;

-- 3b. Fichiers joints aux posts
DELETE FROM post_fichiers;

-- 3c. Tags/topics des posts
DELETE FROM post_topics;

-- 3d. Compétences liées aux offres emploi/stage
DELETE FROM emploi_competence;
DELETE FROM stage_competence;

-- 3e. Détails spécifiques par type de post
DELETE FROM post_activite;
DELETE FROM post_emploi;
DELETE FROM post_stage;

-- 3f. Table principale des publications
DELETE FROM posts;

-- ============================================================================
-- 4. GROUPES - Membres (données liées aux utilisateurs)
-- ============================================================================
DELETE FROM groupe_membres;
DELETE FROM groupes;

-- ============================================================================
-- 5. CALENDRIER SCOLAIRE
-- ============================================================================
DELETE FROM calendrier_scolaire;

-- ============================================================================
-- 6. MODÉRATION UTILISATEUR
-- ============================================================================
DELETE FROM moderation_utilisateur;

-- ============================================================================
-- 7. HISTORIQUES
-- ============================================================================
DELETE FROM historique_valeur;
DELETE FROM historique;

-- ============================================================================
-- 8. UTILISATEUR - Tables liées d'abord
-- ============================================================================

-- 8a. Compétences et spécialités de l'utilisateur
DELETE FROM competence_utilisateur;
DELETE FROM utilisateur_specialite;

-- 8b. Centres d'intérêt
DELETE FROM utilisateur_interets;

-- 8c. Réseaux sociaux de l'utilisateur
DELETE FROM reseau_utilisateur;

-- 8d. Parcours académique
DELETE FROM parcours;

-- 8e. Expérience professionnelle
DELETE FROM experience;

-- 8f. Visibilité profil
DELETE FROM visibilite_utilisateur;

-- 8g. Annulations utilisateur
DELETE FROM annulationutilisateur;

-- 8h. Menus et accès utilisateur
DELETE FROM usermenu;

-- 8i. Table principale utilisateur
DELETE FROM utilisateur;

-- ============================================================================
-- 9. Reset des séquences
-- ============================================================================
ALTER SEQUENCE utilisateur_refuser_seq RESTART WITH 1;

COMMIT;

-- Vérification
SELECT 'utilisateur' AS table_name, COUNT(*) AS nb FROM utilisateur
UNION ALL SELECT 'posts', COUNT(*) FROM posts
UNION ALL SELECT 'commentaires', COUNT(*) FROM commentaires
UNION ALL SELECT 'likes', COUNT(*) FROM likes
UNION ALL SELECT 'notifications', COUNT(*) FROM notifications
UNION ALL SELECT 'signalements', COUNT(*) FROM signalements
UNION ALL SELECT 'calendrier_scolaire', COUNT(*) FROM calendrier_scolaire
UNION ALL SELECT 'moderation_utilisateur', COUNT(*) FROM moderation_utilisateur
UNION ALL SELECT 'historique', COUNT(*) FROM historique
UNION ALL SELECT 'groupes', COUNT(*) FROM groupes
UNION ALL SELECT 'parcours', COUNT(*) FROM parcours
UNION ALL SELECT 'experience', COUNT(*) FROM experience
ORDER BY table_name;
