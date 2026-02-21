-- ==============================
-- ROLE
-- ==============================
CREATE TABLE role (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    valeur INTEGER NOT NULL
);

-- ==============================
-- TYPE_UTILISATEUR
-- ==============================
CREATE TABLE type_utilisateur (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL
);

-- ==============================
-- TYPE_EMPLOIE
-- ==============================
CREATE TABLE type_emploie (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL
);

-- ==============================
-- PROMOTION
-- ==============================
CREATE TABLE promotion (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    annee INTEGER NOT NULL
);

-- ==============================
-- UTILISATEUR
-- ==============================
CREATE TABLE utilisateur (
    id SERIAL PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) NOT NULL,
    etu BOOLEAN DEFAULT FALSE,
    mail VARCHAR(150) NOT NULL,
    tel VARCHAR(20),
    photo VARCHAR(255),
    id_role INTEGER REFERENCES role(id),
    id_type_utilisateur INTEGER REFERENCES type_utilisateur(id),
    id_promotion INTEGER REFERENCES promotion(id)
);

-- ==============================
-- SPECIALITE
-- ==============================
CREATE TABLE specialite (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL
);

-- ==============================
-- UTILISATEUR_SPECIALITE
-- ==============================
CREATE TABLE utilisateur_specialite (
    id_utilisateur INTEGER REFERENCES utilisateur(id),
    id_specialite INTEGER REFERENCES specialite(id),
    PRIMARY KEY (id_utilisateur, id_specialite)
);

-- ==============================
-- COMPETENCE
-- ==============================
CREATE TABLE competence (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(150) NOT NULL
);

-- ==============================
-- COMPETENCE_UTILISATEUR
-- ==============================
CREATE TABLE competence_utilisateur (
    id_competence INTEGER REFERENCES competence(id),
    id_utilisateur INTEGER REFERENCES utilisateur(id),
    PRIMARY KEY (id_competence, id_utilisateur)
);

-- ==============================
-- DIPLOME
-- ==============================
CREATE TABLE diplome (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(150) NOT NULL
);

-- ==============================
-- PAYS
-- ==============================
CREATE TABLE pays (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL
);

-- ==============================
-- VILLE
-- ==============================
CREATE TABLE ville (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    id_pays INTEGER REFERENCES pays(id)
);

-- ==============================
-- ECOLE
-- ==============================
CREATE TABLE ecole (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(150) NOT NULL
);

-- ==============================
-- DOMAINE
-- ==============================
CREATE TABLE domaine (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(150) NOT NULL,
    id_pere INTEGER REFERENCES domaine(id)
);

-- ==============================
-- PARCOURS
-- ==============================
CREATE TABLE parcours (
    id SERIAL PRIMARY KEY,
    date_debut DATE,
    date_fin DATE,
    id_utilisateur INTEGER REFERENCES utilisateur(id),
    id_diplome INTEGER REFERENCES diplome(id),
    id_domaine INTEGER REFERENCES domaine(id),
    id_ecole INTEGER REFERENCES ecole(id)
);

-- ==============================
-- ENTREPRISE
-- ==============================
CREATE TABLE entreprise (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(150) NOT NULL,
    id_ville INTEGER REFERENCES ville(id),
    description TEXT
);

-- ==============================
-- EXPERIENCE
-- ==============================
CREATE TABLE experience (
    id SERIAL PRIMARY KEY,
    id_utilisateur INTEGER REFERENCES utilisateur(id),
    date_debut DATE,
    date_fin DATE,
    poste VARCHAR(150),
    id_domaine INTEGER REFERENCES domaine(id),
    id_entreprise INTEGER REFERENCES entreprise(id),
    id_type_emploie INTEGER REFERENCES type_emploie(id)
);

-- ==============================
-- RESEAUX_SOCIAUX
-- ==============================
CREATE TABLE reseaux_sociaux (
    id SERIAL PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    icone VARCHAR(255)
);

-- ==============================
-- RESEAU_UTILISATEUR
-- ==============================
CREATE TABLE reseau_utilisateur (
    id SERIAL PRIMARY KEY,
    id_reseaux_sociaux INTEGER REFERENCES reseaux_sociaux(id),
    id_utilisateur INTEGER REFERENCES utilisateur(id)
);