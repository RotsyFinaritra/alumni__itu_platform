-- ============================================================================
-- CORRECTION DES FONCTIONS DE SÉQUENCE POUR LE SYSTÈME DE PUBLICATIONS
-- Date: 2026-02-24
-- Auteur: Fanilo
-- 
-- Les fonctions doivent retourner INTEGER (uniquement la valeur de séquence)
-- Le framework APJ gère le préfixe et le formatage via preparePk()
-- Exemple: preparePk("POST", "getseqposts") => POST00001
-- ============================================================================

-- DROP des anciennes fonctions VARCHAR
DROP FUNCTION IF EXISTS getseqtypenotification();
DROP FUNCTION IF EXISTS getseqmotifsignalement();
DROP FUNCTION IF EXISTS getseqstatutsignalement();
DROP FUNCTION IF EXISTS getseqrolegroupe();
DROP FUNCTION IF EXISTS getseqposts();
DROP FUNCTION IF EXISTS getseqlikes();
DROP FUNCTION IF EXISTS getseqcommentaires();
DROP FUNCTION IF EXISTS getseqpartages();
DROP FUNCTION IF EXISTS getseqgroupes();
DROP FUNCTION IF EXISTS getseqgroupemembres();
DROP FUNCTION IF EXISTS getseqtopics();
DROP FUNCTION IF EXISTS getsequtilisateurinterets();
DROP FUNCTION IF EXISTS getseqposttopics();
DROP FUNCTION IF EXISTS getseqnotifications();
DROP FUNCTION IF EXISTS getseqsignalements();
DROP FUNCTION IF EXISTS getseqpostfichiers();

-- Fonctions pour les référentiels
CREATE OR REPLACE FUNCTION getseqtypenotification() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_type_notification')); 
END $$;

CREATE OR REPLACE FUNCTION getseqmotifsignalement() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_motif_signalement')); 
END $$;

CREATE OR REPLACE FUNCTION getseqstatutsignalement() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_statut_signalement')); 
END $$;

CREATE OR REPLACE FUNCTION getseqrolegroupe() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_role_groupe')); 
END $$;

-- Fonctions principales
CREATE OR REPLACE FUNCTION getseqposts() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_posts')); 
END $$;

CREATE OR REPLACE FUNCTION getseqlikes() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_likes')); 
END $$;

CREATE OR REPLACE FUNCTION getseqcommentaires() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_commentaires')); 
END $$;

CREATE OR REPLACE FUNCTION getseqpartages() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_partages')); 
END $$;

CREATE OR REPLACE FUNCTION getseqgroupes() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_groupes')); 
END $$;

CREATE OR REPLACE FUNCTION getseqgroupemembres() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_groupe_membres')); 
END $$;

CREATE OR REPLACE FUNCTION getseqtopics() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_topics')); 
END $$;

CREATE OR REPLACE FUNCTION getsequtilisateurinterets() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_utilisateur_interets')); 
END $$;

CREATE OR REPLACE FUNCTION getseqposttopics() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_post_topics')); 
END $$;

CREATE OR REPLACE FUNCTION getseqnotifications() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_notifications')); 
END $$;

CREATE OR REPLACE FUNCTION getseqsignalements() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_signalements')); 
END $$;

CREATE OR REPLACE FUNCTION getseqpostfichiers() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_post_fichiers')); 
END $$;

-- Fonctions pour le module carrières
CREATE OR REPLACE FUNCTION getseqentreprise() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_entreprise')); 
END $$;

CREATE OR REPLACE FUNCTION getseqpostemploi() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_post_emploi')); 
END $$;

CREATE OR REPLACE FUNCTION getseqpoststage() RETURNS INTEGER LANGUAGE plpgsql AS $$ 
BEGIN 
    RETURN (SELECT nextval('seq_post_stage')); 
END $$;

-- Vérification que les séquences existent (sinon les créer)
DO $$
BEGIN
    -- Séquences référentiels
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_type_notification') THEN
        CREATE SEQUENCE seq_type_notification START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_motif_signalement') THEN
        CREATE SEQUENCE seq_motif_signalement START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_statut_signalement') THEN
        CREATE SEQUENCE seq_statut_signalement START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_role_groupe') THEN
        CREATE SEQUENCE seq_role_groupe START WITH 1;
    END IF;
    
    -- Séquences principales
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_posts') THEN
        CREATE SEQUENCE seq_posts START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_likes') THEN
        CREATE SEQUENCE seq_likes START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_commentaires') THEN
        CREATE SEQUENCE seq_commentaires START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_partages') THEN
        CREATE SEQUENCE seq_partages START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_groupes') THEN
        CREATE SEQUENCE seq_groupes START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_groupe_membres') THEN
        CREATE SEQUENCE seq_groupe_membres START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_topics') THEN
        CREATE SEQUENCE seq_topics START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_utilisateur_interets') THEN
        CREATE SEQUENCE seq_utilisateur_interets START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_post_topics') THEN
        CREATE SEQUENCE seq_post_topics START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_notifications') THEN
        CREATE SEQUENCE seq_notifications START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_signalements') THEN
        CREATE SEQUENCE seq_signalements START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_post_fichiers') THEN
        CREATE SEQUENCE seq_post_fichiers START WITH 1;
    END IF;
    
    -- Séquences carrières
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_entreprise') THEN
        CREATE SEQUENCE seq_entreprise START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_post_emploi') THEN
        CREATE SEQUENCE seq_post_emploi START WITH 1;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_class WHERE relname = 'seq_post_stage') THEN
        CREATE SEQUENCE seq_post_stage START WITH 1;
    END IF;
END $$;
