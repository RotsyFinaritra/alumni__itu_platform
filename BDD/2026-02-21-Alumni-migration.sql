-- =====================================================
-- Script MIGRATION Alumni ITU
-- A exécuter APRES le dump donation (donation0220.sql)
-- =====================================================
-- Ce script :
--   1. Supprime les tables/vues/FK donation (inutiles pour Alumni)
--   2. Modifie la table utilisateur (ajout colonnes Alumni)
--   3. Met à jour type_utilisateur (donation → Alumni)
--   4. Ajoute les rôles Alumni
--   5. Recrée les vues APJ (simplifiées)
--   6. Crée les nouvelles tables Alumni
--   7. Insère les données initiales
-- =====================================================

BEGIN;

-- =====================================================
-- PARTIE 1 : SUPPRESSION TABLES/VUES DONATION
-- On supprime tout ce qui est spécifique au projet
-- donation et qui référence utilisateur par FK
-- =====================================================

-- 1a. Supprimer les vues donation qui référencent utilisateur
DROP VIEW IF EXISTS public.absencelib CASCADE;
DROP VIEW IF EXISTS public.absencelib_annulee CASCADE;
DROP VIEW IF EXISTS public.absencelib_cree CASCADE;
DROP VIEW IF EXISTS public.absencelib_visee CASCADE;
DROP VIEW IF EXISTS public.capacitejournaliere CASCADE;
DROP VIEW IF EXISTS public.utilisateurvue_roles CASCADE;
DROP VIEW IF EXISTS public.utilisateur_equipe_cpl CASCADE;
DROP VIEW IF EXISTS public.utilisateuracade_vue CASCADE;
DROP VIEW IF EXISTS public.etat_creation_tache CASCADE;
DROP VIEW IF EXISTS public.v_historique CASCADE;
DROP VIEW IF EXISTS public.v_historique_creation_tache CASCADE;
DROP VIEW IF EXISTS public.v_historique_fileaccess CASCADE;
DROP VIEW IF EXISTS public.v_historique_log_desc CASCADE;
DROP VIEW IF EXISTS public.v_projetutilisateur_lib CASCADE;

-- Supprimer les vues APJ existantes (on va les recréer)
DROP VIEW IF EXISTS public.utilisateurvalide CASCADE;
DROP VIEW IF EXISTS public.utilisateurvue CASCADE;
DROP VIEW IF EXISTS public.utilisateurrole CASCADE;

-- 1b. Supprimer les vues donation diverses
DROP VIEW IF EXISTS public.donationlibcpl CASCADE;
DROP VIEW IF EXISTS public.donationlibcpl_materiel CASCADE;
DROP VIEW IF EXISTS public.promesselibcpl CASCADE;
DROP VIEW IF EXISTS public.analyse_donation CASCADE;
DROP VIEW IF EXISTS public.actionlib CASCADE;
DROP VIEW IF EXISTS public.actiontachelib CASCADE;
DROP VIEW IF EXISTS public.actiontachelibvalide CASCADE;
DROP VIEW IF EXISTS public.entitelib CASCADE;
DROP VIEW IF EXISTS public.avoirfclib CASCADE;
DROP VIEW IF EXISTS public.avoirfclib_cpl CASCADE;
DROP VIEW IF EXISTS public.avoirfclib_cpl_visee CASCADE;
DROP VIEW IF EXISTS public.avoirfclib_cpl_grp CASCADE;
DROP VIEW IF EXISTS public.avoirfcfille_grp CASCADE;
DROP VIEW IF EXISTS public.mouvementcaissegroupefacture CASCADE;
DROP VIEW IF EXISTS public.architecturelib CASCADE;
DROP VIEW IF EXISTS public.architecturelibavecpage CASCADE;
DROP VIEW IF EXISTS public.architecturelibbasergrp CASCADE;
DROP VIEW IF EXISTS public.architecturelibbasergrpapj CASCADE;
DROP VIEW IF EXISTS public.architecturelibbasergrpspec CASCADE;
DROP VIEW IF EXISTS public.architecturelibmetiergrp CASCADE;
DROP VIEW IF EXISTS public.architecturelibmetiergrpapj CASCADE;
DROP VIEW IF EXISTS public.architecturelibmetiergrpspec CASCADE;
DROP VIEW IF EXISTS public.architecturelibsanspagegrp CASCADE;
DROP VIEW IF EXISTS public.architecturemetierdefaut CASCADE;
DROP VIEW IF EXISTS public.architecturemetierdefautlib CASCADE;
DROP VIEW IF EXISTS public.apjclasselib CASCADE;
DROP VIEW IF EXISTS public.apjclasselib2 CASCADE;
DROP VIEW IF EXISTS public.baselib CASCADE;
DROP VIEW IF EXISTS public.baselibapj CASCADE;
DROP VIEW IF EXISTS public.baselibspec CASCADE;
DROP VIEW IF EXISTS public.basedependanceview CASCADE;
DROP VIEW IF EXISTS public.basedependanceviewlib CASCADE;
DROP VIEW IF EXISTS public.baserelationlib CASCADE;
DROP VIEW IF EXISTS public.metierlib CASCADE;
DROP VIEW IF EXISTS public.metierdependanceview CASCADE;
DROP VIEW IF EXISTS public.metierdependanceviewlib CASCADE;
DROP VIEW IF EXISTS public.page_lib CASCADE;
DROP VIEW IF EXISTS public.champdynamique_squl CASCADE;
DROP VIEW IF EXISTS public.branche_lib CASCADE;
DROP VIEW IF EXISTS public.canevatachelib CASCADE;
DROP VIEW IF EXISTS public.attribusentitelib CASCADE;
DROP VIEW IF EXISTS public.attributclasselib CASCADE;
DROP VIEW IF EXISTS public.client_tmp CASCADE;
DROP VIEW IF EXISTS public.magasin CASCADE;
DROP VIEW IF EXISTS public.tiers CASCADE;
DROP VIEW IF EXISTS public.menu_fils CASCADE;
DROP VIEW IF EXISTS public.menudynamiquelib CASCADE;

-- 1c. Supprimer les contraintes FK donation sur utilisateur
ALTER TABLE IF EXISTS public.deploiement DROP CONSTRAINT IF EXISTS deploiement_fk_3;
ALTER TABLE IF EXISTS public.cheminprojetuser DROP CONSTRAINT IF EXISTS fk_chemin_utilisateur;
ALTER TABLE IF EXISTS public.projetutilisateur DROP CONSTRAINT IF EXISTS fk_projet_utilisateur_utilisateur;
ALTER TABLE IF EXISTS public.utilisateur_equipe DROP CONSTRAINT IF EXISTS fk_ue_ressource;
ALTER TABLE IF EXISTS public.indisponibilite DROP CONSTRAINT IF EXISTS indisponibilite_idressource_fkey;
ALTER TABLE IF EXISTS public.script DROP CONSTRAINT IF EXISTS script_utilisateur_fk;
ALTER TABLE IF EXISTS public.scriptversionning DROP CONSTRAINT IF EXISTS user_svriptversion_fk;
ALTER TABLE IF EXISTS public.cnaps_user DROP CONSTRAINT IF EXISTS fk_utilisateur;
ALTER TABLE IF EXISTS public.pointage DROP CONSTRAINT IF EXISTS fk_utilisateur_refuser;
ALTER TABLE IF EXISTS public.utilisateur DROP CONSTRAINT IF EXISTS utilisateur___fk;

-- 1d. Supprimer les tables donation (qui ne servent pas à Alumni)
DROP TABLE IF EXISTS public.absence CASCADE;
DROP TABLE IF EXISTS public.typeabsence CASCADE;
DROP TABLE IF EXISTS public.action CASCADE;
DROP TABLE IF EXISTS public.actionprojet CASCADE;
DROP TABLE IF EXISTS public.actiontache CASCADE;
DROP TABLE IF EXISTS public.alertscheduler CASCADE;
DROP TABLE IF EXISTS public.categorie CASCADE;
DROP TABLE IF EXISTS public.categoriedonateur CASCADE;
DROP TABLE IF EXISTS public.categorieniveau CASCADE;
DROP TABLE IF EXISTS public.devise CASCADE;
DROP TABLE IF EXISTS public.donation CASCADE;
DROP TABLE IF EXISTS public.entitedonateur CASCADE;
DROP TABLE IF EXISTS public.projet CASCADE;
DROP TABLE IF EXISTS public.promesse CASCADE;
DROP TABLE IF EXISTS public.recepteur CASCADE;
DROP TABLE IF EXISTS public.analyses CASCADE;
DROP TABLE IF EXISTS public.apjclasse CASCADE;
DROP TABLE IF EXISTS public.typeclasse CASCADE;
DROP TABLE IF EXISTS public.relation CASCADE;
DROP TABLE IF EXISTS public.typeouinon CASCADE;
DROP TABLE IF EXISTS public.architecture CASCADE;
DROP TABLE IF EXISTS public.base CASCADE;
DROP TABLE IF EXISTS public.source CASCADE;
DROP TABLE IF EXISTS public.typebase CASCADE;
DROP TABLE IF EXISTS public.fonctionnalite CASCADE;
DROP TABLE IF EXISTS public.metier CASCADE;
DROP TABLE IF EXISTS public.typemetier CASCADE;
DROP TABLE IF EXISTS public.page CASCADE;
DROP TABLE IF EXISTS public.typepage CASCADE;
DROP TABLE IF EXISTS public.as_ingredients CASCADE;
DROP TABLE IF EXISTS public.attacher_fichier CASCADE;
DROP TABLE IF EXISTS public.attribusentite CASCADE;
DROP TABLE IF EXISTS public.attributtype CASCADE;
DROP TABLE IF EXISTS public.typeliaison CASCADE;
DROP TABLE IF EXISTS public.attributclasse CASCADE;
DROP TABLE IF EXISTS public.typeattributclasse CASCADE;
DROP TABLE IF EXISTS public.attributoracle CASCADE;
DROP TABLE IF EXISTS public.attributpostgres CASCADE;
DROP TABLE IF EXISTS public.avoirfcfille CASCADE;
DROP TABLE IF EXISTS public.avoirfc CASCADE;
DROP TABLE IF EXISTS public.categorieavoirfc CASCADE;
DROP TABLE IF EXISTS public.client CASCADE;
DROP TABLE IF EXISTS public.fournisseur CASCADE;
DROP TABLE IF EXISTS public.point CASCADE;
DROP TABLE IF EXISTS public.motifavoirfc CASCADE;
DROP TABLE IF EXISTS public.vente CASCADE;
DROP TABLE IF EXISTS public.caisse CASCADE;
DROP TABLE IF EXISTS public.mouvementcaisse CASCADE;
DROP TABLE IF EXISTS public.baserelation CASCADE;
DROP TABLE IF EXISTS public.boutonchamp CASCADE;
DROP TABLE IF EXISTS public.boutonpage CASCADE;
DROP TABLE IF EXISTS public.branche CASCADE;
DROP TABLE IF EXISTS public.canevatache CASCADE;
DROP TABLE IF EXISTS public.cote CASCADE;
DROP TABLE IF EXISTS public.type CASCADE;
DROP TABLE IF EXISTS public.disponibilite CASCADE;
DROP TABLE IF EXISTS public.indisponibilite CASCADE;
DROP TABLE IF EXISTS public.categoriecaisse CASCADE;
DROP TABLE IF EXISTS public.categorieingredient CASCADE;
DROP TABLE IF EXISTS public.champdynamique CASCADE;
DROP TABLE IF EXISTS public.pageattribut CASCADE;
DROP TABLE IF EXISTS public.pagesaisie CASCADE;
DROP TABLE IF EXISTS public.champsspeciaux CASCADE;
DROP TABLE IF EXISTS public.typechampsspeciaux CASCADE;
DROP TABLE IF EXISTS public.cheminprojetuser CASCADE;
DROP TABLE IF EXISTS public.classe CASCADE;
DROP TABLE IF EXISTS public.classeetfiche CASCADE;
DROP TABLE IF EXISTS public.niveauclient CASCADE;
DROP TABLE IF EXISTS public.cnaps_user CASCADE;
DROP TABLE IF EXISTS public.commune CASCADE;
DROP TABLE IF EXISTS public.compta_compte CASCADE;
DROP TABLE IF EXISTS public.compta_ecriture CASCADE;
DROP TABLE IF EXISTS public.compta_sous_ecriture CASCADE;
DROP TABLE IF EXISTS public.compta_classe_compte CASCADE;
DROP TABLE IF EXISTS public.compta_compte_backup CASCADE;
DROP TABLE IF EXISTS public.compta_journal CASCADE;
DROP TABLE IF EXISTS public.creation_projet CASCADE;
DROP TABLE IF EXISTS public.entite CASCADE;
DROP TABLE IF EXISTS public.deploiement CASCADE;
DROP TABLE IF EXISTS public.utilisateur_equipe CASCADE;
DROP TABLE IF EXISTS public.projetutilisateur CASCADE;
DROP TABLE IF EXISTS public.pointage CASCADE;
DROP TABLE IF EXISTS public.script CASCADE;
DROP TABLE IF EXISTS public.scriptversionning CASCADE;
DROP TABLE IF EXISTS public.log_direction CASCADE;


-- =====================================================
-- PARTIE 2 : ALTER TABLE UTILISATEUR
-- Ajouter les colonnes Alumni au table existante
-- =====================================================

-- Ajouter la colonne rang si elle n'existe pas
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='utilisateur' AND column_name='rang') THEN
        ALTER TABLE utilisateur ADD COLUMN rang INT DEFAULT 0;
    END IF;
END $$;

-- Ajouter les colonnes Alumni
ALTER TABLE utilisateur ADD COLUMN IF NOT EXISTS prenom VARCHAR(100) DEFAULT '';
ALTER TABLE utilisateur ADD COLUMN IF NOT EXISTS etu VARCHAR(50) DEFAULT '';
ALTER TABLE utilisateur ADD COLUMN IF NOT EXISTS mail VARCHAR(150) DEFAULT '';
ALTER TABLE utilisateur ADD COLUMN IF NOT EXISTS photo VARCHAR(255) DEFAULT '';
ALTER TABLE utilisateur ADD COLUMN IF NOT EXISTS idpromotion VARCHAR(30);

-- Supprimer les colonnes donation spécifiques (pas besoin pour Alumni)
ALTER TABLE utilisateur DROP COLUMN IF EXISTS acronyme;
ALTER TABLE utilisateur DROP COLUMN IF EXISTS id;
ALTER TABLE utilisateur DROP COLUMN IF EXISTS matricule;
ALTER TABLE utilisateur DROP COLUMN IF EXISTS profile;
ALTER TABLE utilisateur DROP COLUMN IF EXISTS estactif;
ALTER TABLE utilisateur DROP COLUMN IF EXISTS idequipe;


-- =====================================================
-- PARTIE 3 : MISE A JOUR TYPE_UTILISATEUR
-- Le dump donation a (id, val, desce, taux_*) → on simplifie
-- =====================================================

-- Ajouter la colonne libelle si elle n'existe pas
ALTER TABLE type_utilisateur ADD COLUMN IF NOT EXISTS libelle VARCHAR(100);

-- Copier val → libelle si val existe
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='type_utilisateur' AND column_name='val') THEN
        UPDATE type_utilisateur SET libelle = val WHERE libelle IS NULL OR libelle = '';
        ALTER TABLE type_utilisateur DROP COLUMN IF EXISTS val;
        ALTER TABLE type_utilisateur DROP COLUMN IF EXISTS desce;
        ALTER TABLE type_utilisateur DROP COLUMN IF EXISTS taux_horaire;
        ALTER TABLE type_utilisateur DROP COLUMN IF EXISTS taux_journalier;
        ALTER TABLE type_utilisateur DROP COLUMN IF EXISTS taux_mensuel;
    END IF;
END $$;

-- Supprimer les anciens type_utilisateur donation et insérer Alumni
DELETE FROM type_utilisateur;
INSERT INTO type_utilisateur (id, libelle) VALUES ('TU0000001', 'Alumni');
INSERT INTO type_utilisateur (id, libelle) VALUES ('TU0000002', 'Étudiant');
INSERT INTO type_utilisateur (id, libelle) VALUES ('TU0000003', 'Enseignant');


-- =====================================================
-- PARTIE 4 : AJOUTER ROLES ALUMNI
-- =====================================================

-- Supprimer les anciens rôles donation
DELETE FROM roles WHERE idrole NOT IN ('admin', 'alumni', 'etudiant');

-- Insérer les rôles Alumni (ignorer si déjà existants)
INSERT INTO roles (idrole, descrole, rang) VALUES ('admin', 'Administrateur', 1)
    ON CONFLICT (idrole) DO UPDATE SET descrole = 'Administrateur', rang = 1;
INSERT INTO roles (idrole, descrole, rang) VALUES ('alumni', 'Ancien étudiant', 2)
    ON CONFLICT (idrole) DO UPDATE SET descrole = 'Ancien étudiant', rang = 2;
INSERT INTO roles (idrole, descrole, rang) VALUES ('etudiant', 'Étudiant actuel', 3)
    ON CONFLICT (idrole) DO UPDATE SET descrole = 'Étudiant actuel', rang = 3;


-- =====================================================
-- PARTIE 5 : RECREER LES VUES APJ (simplifiées)
-- =====================================================

CREATE OR REPLACE VIEW utilisateurvalide AS
SELECT
    refuser, loginuser, pwduser, nomuser, adruser, teluser, idrole,
    COALESCE((SELECT r.rang FROM roles r WHERE r.idrole = u.idrole), 0) AS rang,
    '' AS service,
    COALESCE(adruser, '')::varchar AS direction
FROM utilisateur u;

CREATE OR REPLACE VIEW utilisateurvue AS
SELECT refuser, loginuser, pwduser, nomuser, adruser, teluser, idrole,
    COALESCE((SELECT r.rang FROM roles r WHERE r.idrole = u.idrole), 0) AS rang
FROM utilisateur u;

CREATE OR REPLACE VIEW utilisateurrole AS
SELECT
    refuser, loginuser, pwduser, nomuser, adruser, teluser, idrole,
    COALESCE((SELECT r.rang FROM roles r WHERE r.idrole = u.idrole), 0) AS rang,
    '' AS service,
    COALESCE(adruser, '')::varchar AS direction
FROM utilisateur u;


-- =====================================================
-- PARTIE 6 : NOUVELLES TABLES ALUMNI
-- =====================================================

-- Tables de référence
CREATE TABLE IF NOT EXISTS type_emploie (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS promotion (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    annee INTEGER NOT NULL
);

-- FK promotion sur utilisateur
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.table_constraints
        WHERE constraint_name = 'fk_utilisateur_promotion' AND table_name = 'utilisateur') THEN
        ALTER TABLE utilisateur ADD CONSTRAINT fk_utilisateur_promotion
            FOREIGN KEY (idpromotion) REFERENCES promotion(id);
    END IF;
END $$;

-- Tables métier Alumni
CREATE TABLE IF NOT EXISTS specialite (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS utilisateur_specialite (
    idutilisateur INT REFERENCES utilisateur(refuser),
    idspecialite VARCHAR(30) REFERENCES specialite(id),
    PRIMARY KEY (idutilisateur, idspecialite)
);

CREATE TABLE IF NOT EXISTS competence (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(150) NOT NULL
);

CREATE TABLE IF NOT EXISTS competence_utilisateur (
    idcompetence VARCHAR(30) REFERENCES competence(id),
    idutilisateur INT REFERENCES utilisateur(refuser),
    PRIMARY KEY (idcompetence, idutilisateur)
);

CREATE TABLE IF NOT EXISTS diplome (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(150) NOT NULL
);

-- Garder la table pays du dump si elle existe, sinon la créer
-- Le dump donation a (id, val, desce), on la transforme en (id, libelle)
DO $$ BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name='pays' AND column_name='val') THEN
        ALTER TABLE pays ADD COLUMN IF NOT EXISTS libelle VARCHAR(100);
        UPDATE pays SET libelle = val WHERE libelle IS NULL OR libelle = '';
        ALTER TABLE pays DROP COLUMN IF EXISTS val;
        ALTER TABLE pays DROP COLUMN IF EXISTS desce;
    END IF;
END $$;

CREATE TABLE IF NOT EXISTS pays (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS ville (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    idpays VARCHAR(30) REFERENCES pays(id)
);

CREATE TABLE IF NOT EXISTS ecole (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(150) NOT NULL
);

CREATE TABLE IF NOT EXISTS domaine (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(150) NOT NULL,
    idpere VARCHAR(30) REFERENCES domaine(id)
);

CREATE TABLE IF NOT EXISTS parcours (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    datedebut DATE,
    datefin DATE,
    idutilisateur INT REFERENCES utilisateur(refuser),
    iddiplome VARCHAR(30) REFERENCES diplome(id),
    iddomaine VARCHAR(30) REFERENCES domaine(id),
    idecole VARCHAR(30) REFERENCES ecole(id)
);

CREATE TABLE IF NOT EXISTS entreprise (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(150) NOT NULL,
    idville VARCHAR(30) REFERENCES ville(id),
    description TEXT
);

CREATE TABLE IF NOT EXISTS experience (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    idutilisateur INT REFERENCES utilisateur(refuser),
    datedebut DATE,
    datefin DATE,
    poste VARCHAR(150),
    iddomaine VARCHAR(30) REFERENCES domaine(id),
    identreprise VARCHAR(30) REFERENCES entreprise(id),
    idtypeemploie VARCHAR(30) REFERENCES type_emploie(id)
);

CREATE TABLE IF NOT EXISTS reseaux_sociaux (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    icone VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS reseau_utilisateur (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    idreseauxsociaux VARCHAR(30) REFERENCES reseaux_sociaux(id),
    idutilisateur INT REFERENCES utilisateur(refuser)
);


-- =====================================================
-- PARTIE 7 : SEQUENCES & FONCTIONS ALUMNI
-- (celles du dump donation sont déjà là pour historique,
--  paramcrypt, etc. On ajoute les nouvelles)
-- =====================================================

CREATE SEQUENCE IF NOT EXISTS seqtypeutilisateur MINVALUE 1 MAXVALUE 999999999999 START WITH 10 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqtypeutilisateur() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqtypeutilisateur')); END $$;

CREATE SEQUENCE IF NOT EXISTS seqtypeemploie MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqtypeemploie() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqtypeemploie')); END $$;

CREATE SEQUENCE IF NOT EXISTS seqpromotion MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqpromotion() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqpromotion')); END $$;

CREATE SEQUENCE IF NOT EXISTS seqspecialite MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqspecialite() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqspecialite')); END $$;

CREATE SEQUENCE IF NOT EXISTS seqcompetence MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqcompetence() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqcompetence')); END $$;

CREATE SEQUENCE IF NOT EXISTS seqdiplome MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqdiplome() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqdiplome')); END $$;

CREATE SEQUENCE IF NOT EXISTS seqpays MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqpays() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqpays')); END $$;

CREATE SEQUENCE IF NOT EXISTS seqville MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqville() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqville')); END $$;

CREATE SEQUENCE IF NOT EXISTS seqecole MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqecole() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqecole')); END $$;

CREATE SEQUENCE IF NOT EXISTS seqdomaine MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqdomaine() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqdomaine')); END $$;

CREATE SEQUENCE IF NOT EXISTS seqparcours MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqparcours() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqparcours')); END $$;

CREATE SEQUENCE IF NOT EXISTS seqentreprise MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqentreprise() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqentreprise')); END $$;

CREATE SEQUENCE IF NOT EXISTS seqexperience MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqexperience() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqexperience')); END $$;

CREATE SEQUENCE IF NOT EXISTS seqreseauxsociaux MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqreseauxsociaux() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqreseauxsociaux')); END $$;

CREATE SEQUENCE IF NOT EXISTS seqreseauutilisateur MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqreseauutilisateur() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqreseauutilisateur')); END $$;


-- =====================================================
-- PARTIE 8 : DONNEES INITIALES (si admin n'existe pas)
-- =====================================================

-- Mettre à jour l'admin existant ou en créer un
DO $$ BEGIN
    IF NOT EXISTS (SELECT 1 FROM utilisateur WHERE loginuser = 'admin') THEN
        INSERT INTO utilisateur (loginuser, pwduser, nomuser, adruser, teluser, idrole, rang, prenom, etu, mail)
        VALUES ('admin', 'firns', 'Admin', '', '', 'admin', 0, 'Super', '', 'admin@alumni-itu.mg');

        -- ParamCrypt pour le nouvel admin
        INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur)
        VALUES ('CRY0000001', 5, 0, (SELECT refuser::varchar FROM utilisateur WHERE loginuser = 'admin'));
    ELSE
        -- L'admin existe déjà (du dump), mettre à jour son rôle
        UPDATE utilisateur SET idrole = 'admin' WHERE loginuser = 'admin';
    END IF;
END $$;

COMMIT;

-- =====================================================
-- RÉSUMÉ DE LA MIGRATION
-- =====================================================
-- Tables conservées du dump : utilisateur, roles, paramcrypt,
--   historique, direction, menudynamique, pays (transformé)
-- Tables supprimées : ~80 tables donation
-- Vues recréées : utilisateurvalide, utilisateurvue, utilisateurrole
-- Nouvelles tables : promotion, type_emploie, specialite,
--   utilisateur_specialite, competence, competence_utilisateur,
--   diplome, ville, ecole, domaine, parcours, entreprise,
--   experience, reseaux_sociaux, reseau_utilisateur
-- =====================================================
