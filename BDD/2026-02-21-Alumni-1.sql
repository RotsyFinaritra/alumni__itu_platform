-- =====================================================
-- Script BDD Alumni ITU
-- Tables APJ Framework (auth) + Tables Alumni (metier)
-- =====================================================

-- =====================================================
-- PARTIE 1 : TABLES APJ FRAMEWORK (obligatoires pour le login)
-- Ces tables sont requises par apj-core.jar (MapUtilisateur,
-- MapRoles, ParamCrypt, MapHistorique)
-- =====================================================

-- ==============================
-- ROLES (APJ - MapRoles)
-- Table: "roles" | PK: idrole (VARCHAR)
-- ==============================
CREATE TABLE roles (
    idrole VARCHAR(30) PRIMARY KEY NOT NULL,
    descrole VARCHAR(100) NOT NULL,
    rang INT DEFAULT 0
);

-- ==============================
-- TYPE_UTILISATEUR (Alumni)
-- ==============================
CREATE TABLE type_utilisateur (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL
);

CREATE SEQUENCE seqtypeutilisateur MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqtypeutilisateur() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqtypeutilisateur')); END $$;

-- ==============================
-- TYPE_EMPLOIE (Alumni)
-- ==============================
CREATE TABLE type_emploie (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL
);

CREATE SEQUENCE seqtypeemploie MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqtypeemploie() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqtypeemploie')); END $$;

-- ==============================
-- PROMOTION (Alumni)
-- ==============================
CREATE TABLE promotion (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    annee INTEGER NOT NULL
);

CREATE SEQUENCE seqpromotion MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqpromotion() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqpromotion')); END $$;

-- ==============================
-- UTILISATEUR (APJ + Alumni FUSIONNE)
-- Table: "utilisateur" | PK: refuser (INT)
-- Colonnes APJ obligatoires : refuser, loginuser, pwduser,
--   nomuser, adruser, teluser, idrole, rang
-- Colonnes Alumni ajoutées : prenom, etu, mail, photo,
--   idtypeutilisateur, idpromotion
-- ==============================
CREATE TABLE utilisateur (
    -- Colonnes APJ (obligatoires pour MapUtilisateur)
    refuser SERIAL PRIMARY KEY,
    loginuser VARCHAR(100) NOT NULL UNIQUE,
    pwduser VARCHAR(255) NOT NULL,
    nomuser VARCHAR(100) NOT NULL,
    adruser VARCHAR(100) DEFAULT '',
    teluser VARCHAR(20) DEFAULT '',
    idrole VARCHAR(30) REFERENCES roles(idrole),
    rang INT DEFAULT 0,
    -- Colonnes Alumni (profil enrichi)
    prenom VARCHAR(100) DEFAULT '',
    etu VARCHAR(50) DEFAULT '',
    mail VARCHAR(150) DEFAULT '',
    photo VARCHAR(255) DEFAULT '',
    idtypeutilisateur VARCHAR(30) REFERENCES type_utilisateur(id),
    idpromotion VARCHAR(30) REFERENCES promotion(id)
);

CREATE SEQUENCE sequtilisateur MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getsequtilisateur() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('sequtilisateur')); END $$;

-- ==============================
-- PARAMCRYPT (APJ - chiffrement mot de passe)
-- Table: "paramcrypt" | PK: id (VARCHAR)
-- Chaque utilisateur a une entrée qui définit le
-- niveau et sens de chiffrement de son mot de passe
-- ==============================
CREATE TABLE paramcrypt (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    niveau INT NOT NULL DEFAULT 5,
    croissante INT NOT NULL DEFAULT 0,
    idutilisateur VARCHAR(30) NOT NULL
);

CREATE SEQUENCE seqparamcrypt MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqparamcrypt() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqparamcrypt')); END $$;

-- ==============================
-- HISTORIQUE (APJ - log des actions)
-- Table: "historique" | PK: idhistorique (VARCHAR)
-- ==============================
CREATE TABLE historique (
    idhistorique VARCHAR(30) PRIMARY KEY NOT NULL,
    datehistorique DATE DEFAULT CURRENT_DATE,
    heure VARCHAR(20) DEFAULT '',
    objet VARCHAR(255) DEFAULT '',
    action VARCHAR(255) DEFAULT '',
    idutilisateur VARCHAR(30) DEFAULT '',
    refobjet VARCHAR(255) DEFAULT ''
);

CREATE SEQUENCE seqhistorique MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqhistorique() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqhistorique')); END $$;

-- ==============================
-- ANNULATIONUTILISATEUR (APJ - activation/désactivation)
-- Table: "annulationutilisateur" | PK: idannulationuser
-- ==============================
CREATE TABLE annulationutilisateur (
    idannulationuser VARCHAR(30) PRIMARY KEY NOT NULL,
    refuser VARCHAR(30) DEFAULT '',
    daty DATE DEFAULT CURRENT_DATE
);

CREATE SEQUENCE seqannulationutilisateur MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqannulationutilisateur() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqannulationutilisateur')); END $$;

-- ==============================
-- DIRECTION (APJ - utilisé dans testLogin.jsp)
-- Table générique TypeObjet : id + val
-- ==============================
CREATE TABLE direction (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    val VARCHAR(255) DEFAULT ''
);

-- ==============================
-- USERHOMEPAGE (APJ - page d'accueil par rôle)
-- ==============================
CREATE TABLE userhomepage (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    codeservice VARCHAR(50) DEFAULT '',
    urlpage VARCHAR(255) DEFAULT '',
    idrole VARCHAR(30) DEFAULT '',
    codedir VARCHAR(50) DEFAULT ''
);

CREATE SEQUENCE sequserhomepage MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getsequserhomepage() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('sequserhomepage')); END $$;

-- ==============================
-- VUES APJ (requises par UtilisateurUtil.testeValide)
-- ==============================

-- Vue UtilisateurValide : utilisée par testeValide(user, pass)
-- Retourne MapUtilisateurServiceDirection (extends MapUtilisateur + service + direction)
CREATE OR REPLACE VIEW utilisateurvalide AS
SELECT
    refuser, loginuser, pwduser, nomuser, adruser, teluser, idrole, rang,
    '' AS service,
    COALESCE(adruser, '') AS direction
FROM utilisateur;

-- Vue utilisateurVue : utilisée par testeValide("utilisateurVue", user, pass)
CREATE OR REPLACE VIEW utilisateurvue AS
SELECT refuser, loginuser, pwduser, nomuser, adruser, teluser, idrole, rang
FROM utilisateur;

-- Vue utilisateurrole : table par défaut de MapUtilisateurServiceDirection
CREATE OR REPLACE VIEW utilisateurrole AS
SELECT
    refuser, loginuser, pwduser, nomuser, adruser, teluser, idrole, rang,
    '' AS service,
    COALESCE(adruser, '') AS direction
FROM utilisateur;


-- =====================================================
-- PARTIE 2 : TABLES ALUMNI (métier)
-- =====================================================

-- ==============================
-- SPECIALITE
-- ==============================
CREATE TABLE specialite (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL
);

CREATE SEQUENCE seqspecialite MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqspecialite() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqspecialite')); END $$;

-- ==============================
-- UTILISATEUR_SPECIALITE
-- ==============================
CREATE TABLE utilisateur_specialite (
    idutilisateur INT REFERENCES utilisateur(refuser),
    idspecialite VARCHAR(30) REFERENCES specialite(id),
    PRIMARY KEY (idutilisateur, idspecialite)
);

-- ==============================
-- COMPETENCE
-- ==============================
CREATE TABLE competence (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(150) NOT NULL
);

CREATE SEQUENCE seqcompetence MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqcompetence() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqcompetence')); END $$;

-- ==============================
-- COMPETENCE_UTILISATEUR
-- ==============================
CREATE TABLE competence_utilisateur (
    idcompetence VARCHAR(30) REFERENCES competence(id),
    idutilisateur INT REFERENCES utilisateur(refuser),
    PRIMARY KEY (idcompetence, idutilisateur)
);

-- ==============================
-- DIPLOME
-- ==============================
CREATE TABLE diplome (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(150) NOT NULL
);

CREATE SEQUENCE seqdiplome MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqdiplome() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqdiplome')); END $$;

-- ==============================
-- PAYS
-- ==============================
CREATE TABLE pays (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL
);

CREATE SEQUENCE seqpays MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqpays() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqpays')); END $$;

-- ==============================
-- VILLE
-- ==============================
CREATE TABLE ville (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    idpays VARCHAR(30) REFERENCES pays(id)
);

CREATE SEQUENCE seqville MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqville() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqville')); END $$;

-- ==============================
-- ECOLE
-- ==============================
CREATE TABLE ecole (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(150) NOT NULL
);

CREATE SEQUENCE seqecole MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqecole() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqecole')); END $$;

-- ==============================
-- DOMAINE
-- ==============================
CREATE TABLE domaine (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(150) NOT NULL,
    idpere VARCHAR(30) REFERENCES domaine(id)
);

CREATE SEQUENCE seqdomaine MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqdomaine() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqdomaine')); END $$;

-- ==============================
-- PARCOURS
-- ==============================
CREATE TABLE parcours (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    datedebut DATE,
    datefin DATE,
    idutilisateur INT REFERENCES utilisateur(refuser),
    iddiplome VARCHAR(30) REFERENCES diplome(id),
    iddomaine VARCHAR(30) REFERENCES domaine(id),
    idecole VARCHAR(30) REFERENCES ecole(id)
);

CREATE SEQUENCE seqparcours MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqparcours() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqparcours')); END $$;

-- ==============================
-- ENTREPRISE
-- ==============================
CREATE TABLE entreprise (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(150) NOT NULL,
    idville VARCHAR(30) REFERENCES ville(id),
    description TEXT
);

CREATE SEQUENCE seqentreprise MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqentreprise() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqentreprise')); END $$;

-- ==============================
-- EXPERIENCE
-- ==============================
CREATE TABLE experience (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    idutilisateur INT REFERENCES utilisateur(refuser),
    datedebut DATE,
    datefin DATE,
    poste VARCHAR(150),
    iddomaine VARCHAR(30) REFERENCES domaine(id),
    identreprise VARCHAR(30) REFERENCES entreprise(id),
    idtypeemploie VARCHAR(30) REFERENCES type_emploie(id)
);

CREATE SEQUENCE seqexperience MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqexperience() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqexperience')); END $$;

-- ==============================
-- RESEAUX_SOCIAUX
-- ==============================
CREATE TABLE reseaux_sociaux (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    icone VARCHAR(255)
);

CREATE SEQUENCE seqreseauxsociaux MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqreseauxsociaux() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqreseauxsociaux')); END $$;

-- ==============================
-- RESEAU_UTILISATEUR
-- ==============================
CREATE TABLE reseau_utilisateur (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    idreseauxsociaux VARCHAR(30) REFERENCES reseaux_sociaux(id),
    idutilisateur INT REFERENCES utilisateur(refuser)
);

CREATE SEQUENCE seqreseauutilisateur MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqreseauutilisateur() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqreseauutilisateur')); END $$;


-- =====================================================
-- PARTIE 3 : DONNEES INITIALES
-- =====================================================

-- Rôles Alumni
INSERT INTO roles (idrole, descrole, rang) VALUES ('admin', 'Administrateur', 1);
INSERT INTO roles (idrole, descrole, rang) VALUES ('alumni', 'Ancien étudiant', 2);
INSERT INTO roles (idrole, descrole, rang) VALUES ('etudiant', 'Étudiant actuel', 3);

-- Types d'utilisateur
INSERT INTO type_utilisateur (id, libelle) VALUES ('TU0000001', 'Alumni');
INSERT INTO type_utilisateur (id, libelle) VALUES ('TU0000002', 'Étudiant');
INSERT INTO type_utilisateur (id, libelle) VALUES ('TU0000003', 'Enseignant');

-- Utilisateur admin par défaut
-- Login: admin / Mot de passe: admin
-- Chiffrement: niveau=5, croissante=0 (ascendant)
-- "admin" chiffré = "firns" (chaque char +5 dans base 36)
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, adruser, teluser, idrole, rang, prenom, etu, mail)
VALUES (1, 'admin', 'firns', 'Admin', '', '', 'admin', 0, 'Super', FALSE, 'admin@alumni-itu.mg');

-- ParamCrypt pour l'admin (lié à refuser=1)
INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur)
VALUES ('CRY0000001', 5, 0, '1');

-- Synchroniser la séquence avec les données initiales
SELECT setval('sequtilisateur', 1);
SELECT setval('seqparamcrypt', 1);
SELECT setval('seqtypeutilisateur', 3);