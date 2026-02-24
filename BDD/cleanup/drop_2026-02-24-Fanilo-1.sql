-- DROP script pour 2026-02-24-Fanilo-1.sql
-- À exécuter avant de relancer 2026-02-24-Fanilo-1.sql corrigé.

-- 1. Vues
DROP VIEW IF EXISTS v_top_contributeurs;
DROP VIEW IF EXISTS v_statistiques_posts;
DROP VIEW IF EXISTS v_posts_complets;

-- 2. Triggers
DROP TRIGGER IF EXISTS trigger_increment_likes ON likes;
DROP TRIGGER IF EXISTS trigger_decrement_likes ON likes;
DROP TRIGGER IF EXISTS trigger_increment_commentaires ON commentaires;
DROP TRIGGER IF EXISTS trigger_handle_commentaire_suppression ON commentaires;
DROP TRIGGER IF EXISTS trigger_increment_partages ON partages;
DROP TRIGGER IF EXISTS trigger_decrement_partages ON partages;
DROP TRIGGER IF EXISTS trigger_init_places_restantes ON post_activite;

-- 3. Fonctions trigger
DROP FUNCTION IF EXISTS increment_likes();
DROP FUNCTION IF EXISTS decrement_likes();
DROP FUNCTION IF EXISTS increment_commentaires();
DROP FUNCTION IF EXISTS handle_commentaire_suppression();
DROP FUNCTION IF EXISTS increment_partages();
DROP FUNCTION IF EXISTS decrement_partages();
DROP FUNCTION IF EXISTS init_places_restantes();

-- 4. Tables (ordre inverse des FK)
DROP TABLE IF EXISTS post_fichiers;
DROP TABLE IF EXISTS signalements;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS post_topics;
DROP TABLE IF EXISTS utilisateur_interets;
DROP TABLE IF EXISTS topics;
DROP TABLE IF EXISTS groupe_membres;
DROP TABLE IF EXISTS groupes;
DROP TABLE IF EXISTS partages;
DROP TABLE IF EXISTS commentaires;
DROP TABLE IF EXISTS likes;
DROP TABLE IF EXISTS post_activite;
DROP TABLE IF EXISTS post_emploi;
DROP TABLE IF EXISTS post_stage;
DROP TABLE IF EXISTS posts;
DROP TABLE IF EXISTS role_groupe;
DROP TABLE IF EXISTS statut_signalement;
DROP TABLE IF EXISTS motif_signalement;
DROP TABLE IF EXISTS type_notification;
DROP TABLE IF EXISTS type_fichier;
DROP TABLE IF EXISTS visibilite_publication;
DROP TABLE IF EXISTS statut_publication;
DROP TABLE IF EXISTS type_publication;

-- 5. Fonctions PK
DROP FUNCTION IF EXISTS getseqpostfichiers();
DROP FUNCTION IF EXISTS getseqsignalements();
DROP FUNCTION IF EXISTS getseqnotifications();
DROP FUNCTION IF EXISTS getseqposttopics();
DROP FUNCTION IF EXISTS getsequtilisateurinterets();
DROP FUNCTION IF EXISTS getseqtopics();
DROP FUNCTION IF EXISTS getseqgroupemembres();
DROP FUNCTION IF EXISTS getseqgroupes();
DROP FUNCTION IF EXISTS getseqpartages();
DROP FUNCTION IF EXISTS getseqcommentaires();
DROP FUNCTION IF EXISTS getseqlikes();
DROP FUNCTION IF EXISTS getseqposts();
DROP FUNCTION IF EXISTS getseqrolegroupe();
DROP FUNCTION IF EXISTS getseqstatutsignalement();
DROP FUNCTION IF EXISTS getseqmotifsignalement();
DROP FUNCTION IF EXISTS getseqtypenotification();
DROP FUNCTION IF EXISTS getseqtypefichier();
DROP FUNCTION IF EXISTS getseqvisibilitepublication();
DROP FUNCTION IF EXISTS getseqstatutpublication();
DROP FUNCTION IF EXISTS getseqtypepublication();

-- 6. Séquences
DROP SEQUENCE IF EXISTS seq_post_fichiers;
DROP SEQUENCE IF EXISTS seq_signalements;
DROP SEQUENCE IF EXISTS seq_notifications;
DROP SEQUENCE IF EXISTS seq_post_topics;
DROP SEQUENCE IF EXISTS seq_utilisateur_interets;
DROP SEQUENCE IF EXISTS seq_topics;
DROP SEQUENCE IF EXISTS seq_groupe_membres;
DROP SEQUENCE IF EXISTS seq_groupes;
DROP SEQUENCE IF EXISTS seq_partages;
DROP SEQUENCE IF EXISTS seq_commentaires;
DROP SEQUENCE IF EXISTS seq_likes;
DROP SEQUENCE IF EXISTS seq_posts;
DROP SEQUENCE IF EXISTS seq_role_groupe;
DROP SEQUENCE IF EXISTS seq_statut_signalement;
DROP SEQUENCE IF EXISTS seq_motif_signalement;
DROP SEQUENCE IF EXISTS seq_type_notification;
DROP SEQUENCE IF EXISTS seq_type_fichier;
DROP SEQUENCE IF EXISTS seq_visibilite_publication;
DROP SEQUENCE IF EXISTS seq_statut_publication;
DROP SEQUENCE IF EXISTS seq_type_publication;
