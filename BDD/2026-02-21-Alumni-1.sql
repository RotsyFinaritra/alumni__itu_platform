-- =====================================================
-- Script BDD Alumni ITU - IDs VARCHAR + Sequences (APJ)
-- =====================================================

-- ==============================
-- ROLE
-- ==============================
CREATE TABLE role (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    valeur INTEGER NOT NULL
);

CREATE SEQUENCE seqrole MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqrole() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqrole')); END $$;

-- ==============================
-- TYPE_UTILISATEUR
-- ==============================
CREATE TABLE type_utilisateur (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL
);

CREATE SEQUENCE seqtypeutilisateur MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqtypeutilisateur() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqtypeutilisateur')); END $$;

-- ==============================
-- TYPE_EMPLOIE
-- ==============================
CREATE TABLE type_emploie (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL
);

CREATE SEQUENCE seqtypeemploie MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqtypeemploie() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqtypeemploie')); END $$;

-- ==============================
-- PROMOTION
-- ==============================
CREATE TABLE promotion (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(100) NOT NULL,
    annee INTEGER NOT NULL
);

CREATE SEQUENCE seqpromotion MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqpromotion() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqpromotion')); END $$;

-- ==============================
-- UTILISATEUR
-- ==============================
CREATE TABLE utilisateur (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    etu BOOLEAN DEFAULT FALSE,
    mail VARCHAR(150) NOT NULL,
    tel VARCHAR(20),
    photo VARCHAR(255),
    idrole VARCHAR(30) REFERENCES role(id),
    idtypeutilisateur VARCHAR(30) REFERENCES type_utilisateur(id),
    idpromotion VARCHAR(30) REFERENCES promotion(id)
);

CREATE SEQUENCE sequtilisateur MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getsequtilisateur() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('sequtilisateur')); END $$;

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
    idutilisateur VARCHAR(30) REFERENCES utilisateur(id),
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
    idutilisateur VARCHAR(30) REFERENCES utilisateur(id),
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
    idutilisateur VARCHAR(30) REFERENCES utilisateur(id),
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
    idutilisateur VARCHAR(30) REFERENCES utilisateur(id),
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
    idutilisateur VARCHAR(30) REFERENCES utilisateur(id)
);

CREATE SEQUENCE seqreseauutilisateur MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqreseauutilisateur() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqreseauutilisateur')); END $$;