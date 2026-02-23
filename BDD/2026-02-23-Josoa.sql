-- =====================================================
-- Script de données de test - Alumni ITU Platform
-- Auteur: Josoa
-- Date: 2026-02-23
-- Description: Insertion des données de test pour le développement
-- =====================================================

-- =====================================================
-- PARTIE 1 : DONNÉES INITIALES (Rôles et Types)
-- =====================================================

-- Rôles Alumni
INSERT INTO roles (idrole, descrole, rang) VALUES ('admin', 'Administrateur', 1);
INSERT INTO roles (idrole, descrole, rang) VALUES ('alumni', 'Ancien étudiant', 2);
INSERT INTO roles (idrole, descrole, rang) VALUES ('etudiant', 'Étudiant actuel', 3);

-- Types d'utilisateur
INSERT INTO type_utilisateur (id, libelle) VALUES ('TU0000001', 'Alumni');
INSERT INTO type_utilisateur (id, libelle) VALUES ('TU0000002', 'Étudiant');
INSERT INTO type_utilisateur (id, libelle) VALUES ('TU0000003', 'Enseignant');

-- Promotions
INSERT INTO promotion (id, libelle, annee) VALUES ('PROM0001', 'Promotion 2023', 2023);
INSERT INTO promotion (id, libelle, annee) VALUES ('PROM0002', 'Promotion 2024', 2024);
INSERT INTO promotion (id, libelle, annee) VALUES ('PROM0003', 'Promotion 2025', 2025);

-- Types d'emploi
INSERT INTO type_emploie (id, libelle) VALUES ('TE0000001', 'CDI');
INSERT INTO type_emploie (id, libelle) VALUES ('TE0000002', 'CDD');
INSERT INTO type_emploie (id, libelle) VALUES ('TE0000003', 'Stage');
INSERT INTO type_emploie (id, libelle) VALUES ('TE0000004', 'Freelance');

-- =====================================================
-- PARTIE 2 : UTILISATEURS DE TEST
-- =====================================================

-- Utilisateur admin par défaut
-- Login: admin / Mot de passe: admin
-- Chiffrement: niveau=5, croissante=0 (ascendant)
-- "admin" chiffré = "firns" (chaque char +5 dans base 36)
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, adruser, teluser, idrole, rang, prenom, etu, mail)
VALUES (1, 'admin', 'firns', 'Admin', '', '', 'admin', 0, 'Super', '', 'admin@alumni-itu.mg');

INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur)
VALUES ('CRY0000001', 5, 0, '1');

-- Utilisateur 1: Jean RAKOTO (Alumni)
-- Login: jean.rakoto / Mot de passe: test123 (chiffré = yjxy678)
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, prenom, etu, mail, teluser, adruser, idrole, rang, idtypeutilisateur, idpromotion)
VALUES (2, 'jean.rakoto', 'yjxy678', 'RAKOTO', 'Jean', 'ETU001234', 'jean.rakoto@alumni-itu.mg', '0340123456', 'Antananarivo, Madagascar', 'alumni', 2, 'TU0000001', 'PROM0001');

INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur)
VALUES ('CRY0000002', 5, 0, '2');

-- Utilisateur 2: Marie RAZAFINDRAKOTO (Alumni)
-- Login: marie.razaf / Mot de passe: test123 (chiffré = yjxy678)
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, prenom, etu, mail, teluser, adruser, idrole, rang, idtypeutilisateur, idpromotion)
VALUES (3, 'marie.razaf', 'yjxy678', 'RAZAFINDRAKOTO', 'Marie', 'ETU002345', 'marie.razaf@alumni-itu.mg', '0341234567', 'Fianarantsoa, Madagascar', 'alumni', 2, 'TU0000001', 'PROM0001');

INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur)
VALUES ('CRY0000003', 5, 0, '3');

-- Utilisateur 3: Paul ANDRIAMIHAJA (Étudiant actuel)
-- Login: paul.andriam / Mot de passe: test123 (chiffré = yjxy678)
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, prenom, etu, mail, teluser, adruser, idrole, rang, idtypeutilisateur, idpromotion)
VALUES (4, 'paul.andriam', 'yjxy678', 'ANDRIAMIHAJA', 'Paul', 'ETU003456', 'paul.andriam@itu.mg', '0342345678', 'Toamasina, Madagascar', 'etudiant', 3, 'TU0000002', 'PROM0003');

INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur)
VALUES ('CRY0000004', 5, 0, '4');

-- Utilisateur 4: Sophie RAJAONAH (Alumni avec profil complet)
-- Login: sophie.raja / Mot de passe: test123 (chiffré = yjxy678)
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, prenom, etu, mail, teluser, adruser, idrole, rang, idtypeutilisateur, idpromotion)
VALUES (5, 'sophie.raja', 'yjxy678', 'RAJAONAH', 'Sophie', 'ETU004567', 'sophie.raja@alumni-itu.mg', '0343456789', '101 Rue de l''Université, Antananarivo', 'alumni', 2, 'TU0000001', 'PROM0002');

INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur)
VALUES ('CRY0000005', 5, 0, '5');

-- Utilisateur 5: Luc RAKOTOMALALA (Enseignant)
-- Login: luc.rakotom / Mot de passe: test123 (chiffré = yjxy678)
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, prenom, etu, mail, teluser, adruser, idrole, rang, idtypeutilisateur, idpromotion)
VALUES (6, 'luc.rakotom', 'yjxy678', 'RAKOTOMALALA', 'Luc', '', 'luc.rakotom@itu.mg', '0344567890', 'Antananarivo', 'admin', 1, 'TU0000003', NULL);

INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur)
VALUES ('CRY0000006', 5, 0, '6');

-- =====================================================
-- PARTIE 3 : RÉFÉRENTIELS (Spécialités, Compétences, etc.)
-- =====================================================

-- Spécialités
INSERT INTO specialite (id, libelle) VALUES ('SPEC0001', 'Développement Web');
INSERT INTO specialite (id, libelle) VALUES ('SPEC0002', 'Data Science');
INSERT INTO specialite (id, libelle) VALUES ('SPEC0003', 'Cybersécurité');
INSERT INTO specialite (id, libelle) VALUES ('SPEC0004', 'Intelligence Artificielle');
INSERT INTO specialite (id, libelle) VALUES ('SPEC0005', 'Réseaux et Télécommunications');

-- Spécialités des utilisateurs
INSERT INTO utilisateur_specialite (idutilisateur, idspecialite) VALUES (2, 'SPEC0001');
INSERT INTO utilisateur_specialite (idutilisateur, idspecialite) VALUES (2, 'SPEC0002');
INSERT INTO utilisateur_specialite (idutilisateur, idspecialite) VALUES (3, 'SPEC0003');
INSERT INTO utilisateur_specialite (idutilisateur, idspecialite) VALUES (5, 'SPEC0004');

-- Compétences
INSERT INTO competence (id, libelle) VALUES ('COMP0001', 'Java');
INSERT INTO competence (id, libelle) VALUES ('COMP0002', 'Python');
INSERT INTO competence (id, libelle) VALUES ('COMP0003', 'JavaScript');
INSERT INTO competence (id, libelle) VALUES ('COMP0004', 'SQL');
INSERT INTO competence (id, libelle) VALUES ('COMP0005', 'React');
INSERT INTO competence (id, libelle) VALUES ('COMP0006', 'Spring Boot');
INSERT INTO competence (id, libelle) VALUES ('COMP0007', 'Docker');
INSERT INTO competence (id, libelle) VALUES ('COMP0008', 'Git');

-- Compétences des utilisateurs
INSERT INTO competence_utilisateur (idcompetence, idutilisateur) VALUES ('COMP0001', 2);
INSERT INTO competence_utilisateur (idcompetence, idutilisateur) VALUES ('COMP0003', 2);
INSERT INTO competence_utilisateur (idcompetence, idutilisateur) VALUES ('COMP0004', 2);
INSERT INTO competence_utilisateur (idcompetence, idutilisateur) VALUES ('COMP0002', 3);
INSERT INTO competence_utilisateur (idcompetence, idutilisateur) VALUES ('COMP0004', 3);
INSERT INTO competence_utilisateur (idcompetence, idutilisateur) VALUES ('COMP0002', 5);
INSERT INTO competence_utilisateur (idcompetence, idutilisateur) VALUES ('COMP0005', 5);

-- Diplômes
INSERT INTO diplome (id, libelle) VALUES ('DIP0001', 'Licence Informatique');
INSERT INTO diplome (id, libelle) VALUES ('DIP0002', 'Master Informatique');
INSERT INTO diplome (id, libelle) VALUES ('DIP0003', 'Ingénieur Informatique');
INSERT INTO diplome (id, libelle) VALUES ('DIP0004', 'Doctorat Informatique');

-- Pays
INSERT INTO pays (id, libelle) VALUES ('PAYS0001', 'Madagascar');
INSERT INTO pays (id, libelle) VALUES ('PAYS0002', 'France');
INSERT INTO pays (id, libelle) VALUES ('PAYS0003', 'Maurice');

-- Villes
INSERT INTO ville (id, libelle, idpays) VALUES ('VILLE0001', 'Antananarivo', 'PAYS0001');
INSERT INTO ville (id, libelle, idpays) VALUES ('VILLE0002', 'Fianarantsoa', 'PAYS0001');
INSERT INTO ville (id, libelle, idpays) VALUES ('VILLE0003', 'Toamasina', 'PAYS0001');
INSERT INTO ville (id, libelle, idpays) VALUES ('VILLE0004', 'Paris', 'PAYS0002');
INSERT INTO ville (id, libelle, idpays) VALUES ('VILLE0005', 'Port-Louis', 'PAYS0003');

-- Écoles
INSERT INTO ecole (id, libelle) VALUES ('ECO0001', 'ITU - Institut des Technologies de l''Université');
INSERT INTO ecole (id, libelle) VALUES ('ECO0002', 'ESPA - École Supérieure Polytechnique d''Antananarivo');
INSERT INTO ecole (id, libelle) VALUES ('ECO0003', 'Université d''Antananarivo');

-- Domaines
INSERT INTO domaine (id, libelle, idpere) VALUES ('DOM0001', 'Informatique', NULL);
INSERT INTO domaine (id, libelle, idpere) VALUES ('DOM0002', 'Développement Logiciel', 'DOM0001');
INSERT INTO domaine (id, libelle, idpere) VALUES ('DOM0003', 'Data & IA', 'DOM0001');
INSERT INTO domaine (id, libelle, idpere) VALUES ('DOM0004', 'Réseaux', 'DOM0001');
INSERT INTO domaine (id, libelle, idpere) VALUES ('DOM0005', 'Management', NULL);

-- =====================================================
-- PARTIE 4 : PARCOURS ACADÉMIQUES
-- =====================================================

-- Parcours de Jean RAKOTO
INSERT INTO parcours (id, datedebut, datefin, idutilisateur, iddiplome, iddomaine, idecole)
VALUES ('PARC0001', '2020-09-01', '2023-06-30', 2, 'DIP0003', 'DOM0002', 'ECO0001');

-- Parcours de Marie RAZAFINDRAKOTO
INSERT INTO parcours (id, datedebut, datefin, idutilisateur, iddiplome, iddomaine, idecole)
VALUES ('PARC0002', '2020-09-01', '2023-06-30', 3, 'DIP0003', 'DOM0004', 'ECO0001');

-- Parcours de Sophie RAJAONAH
INSERT INTO parcours (id, datedebut, datefin, idutilisateur, iddiplome, iddomaine, idecole)
VALUES ('PARC0003', '2021-09-01', '2024-06-30', 5, 'DIP0003', 'DOM0003', 'ECO0001');

-- =====================================================
-- PARTIE 5 : ENTREPRISES ET EXPÉRIENCES
-- =====================================================

-- Entreprises
INSERT INTO entreprise (id, libelle, idville, description)
VALUES ('ENT0001', 'Orange Madagascar', 'VILLE0001', 'Opérateur de télécommunications');

INSERT INTO entreprise (id, libelle, idville, description)
VALUES ('ENT0002', 'Telma Madagascar', 'VILLE0001', 'Opérateur de télécommunications');

INSERT INTO entreprise (id, libelle, idville, description)
VALUES ('ENT0003', 'Nexah Madagascar', 'VILLE0001', 'Entreprise de services numériques');

INSERT INTO entreprise (id, libelle, idville, description)
VALUES ('ENT0004', 'BNI Madagascar', 'VILLE0001', 'Banque nationale');

INSERT INTO entreprise (id, libelle, idville, description)
VALUES ('ENT0005', 'Accenture Madagascar', 'VILLE0001', 'Cabinet de conseil et services');

-- Expériences professionnelles de Jean RAKOTO
INSERT INTO experience (id, idutilisateur, datedebut, datefin, poste, iddomaine, identreprise, idtypeemploie)
VALUES ('EXP0001', 2, '2023-07-01', '2026-02-23', 'Développeur Full Stack', 'DOM0002', 'ENT0003', 'TE0000001');

INSERT INTO experience (id, idutilisateur, datedebut, datefin, poste, iddomaine, identreprise, idtypeemploie)
VALUES ('EXP0002', 2, '2023-01-01', '2023-06-30', 'Stagiaire Développeur', 'DOM0002', 'ENT0001', 'TE0000003');

-- Expérience de Marie RAZAFINDRAKOTO
INSERT INTO experience (id, idutilisateur, datedebut, datefin, poste, iddomaine, identreprise, idtypeemploie)
VALUES ('EXP0003', 3, '2023-07-01', '2025-12-31', 'Ingénieur Réseaux', 'DOM0004', 'ENT0002', 'TE0000002');

-- Expérience de Sophie RAJAONAH
INSERT INTO experience (id, idutilisateur, datedebut, datefin, poste, iddomaine, identreprise, idtypeemploie)
VALUES ('EXP0004', 5, '2024-07-01', '2026-02-23', 'Data Scientist', 'DOM0003', 'ENT0005', 'TE0000001');

-- =====================================================
-- PARTIE 6 : RÉSEAUX SOCIAUX
-- =====================================================

-- Types de réseaux sociaux
INSERT INTO reseaux_sociaux (id, libelle, icone) VALUES ('RS0001', 'LinkedIn', 'fab fa-linkedin');
INSERT INTO reseaux_sociaux (id, libelle, icone) VALUES ('RS0002', 'GitHub', 'fab fa-github');
INSERT INTO reseaux_sociaux (id, libelle, icone) VALUES ('RS0003', 'Facebook', 'fab fa-facebook');
INSERT INTO reseaux_sociaux (id, libelle, icone) VALUES ('RS0004', 'Twitter', 'fab fa-twitter');

-- Réseaux sociaux des utilisateurs
INSERT INTO reseau_utilisateur (id, idreseauxsociaux, idutilisateur) VALUES ('RU0001', 'RS0001', 2);
INSERT INTO reseau_utilisateur (id, idreseauxsociaux, idutilisateur) VALUES ('RU0002', 'RS0002', 2);
INSERT INTO reseau_utilisateur (id, idreseauxsociaux, idutilisateur) VALUES ('RU0003', 'RS0001', 3);
INSERT INTO reseau_utilisateur (id, idreseauxsociaux, idutilisateur) VALUES ('RU0004', 'RS0002', 5);
INSERT INTO reseau_utilisateur (id, idreseauxsociaux, idutilisateur) VALUES ('RU0005', 'RS0001', 5);

-- =====================================================
-- PARTIE 7 : MENUS DYNAMIQUES
-- =====================================================

-- Menu dynamique de test
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN001', 'Mon Profil', 'fa fa-user-circle', 'profil/mon-profil.jsp', 1, 1, NULL);

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN002', 'Accueil', 'fa fa-home', 'accueil.jsp', 0, 1, NULL);

-- Assignation du menu profil à tous les rôles
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('UM0001', NULL, 'MENDYN001', 'admin', '', '', 0);

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('UM0002', NULL, 'MENDYN001', 'alumni', '', '', 0);

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('UM0003', NULL, 'MENDYN001', 'etudiant', '', '', 0);

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('UM0004', NULL, 'MENDYN002', 'admin', '', '', 0);

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('UM0005', NULL, 'MENDYN002', 'alumni', '', '', 0);

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('UM0006', NULL, 'MENDYN002', 'etudiant', '', '', 0);

-- =====================================================
-- PARTIE 8 : SYNCHRONISATION DES SÉQUENCES
-- =====================================================

SELECT setval('sequtilisateur', 6);
SELECT setval('seqparamcrypt', 6);
SELECT setval('seqpromotion', 3);
SELECT setval('seqtypeemploie', 4);
SELECT setval('seqspecialite', 5);
SELECT setval('seqcompetence', 8);
SELECT setval('seqdiplome', 4);
SELECT setval('seqpays', 3);
SELECT setval('seqville', 5);
SELECT setval('seqecole', 3);
SELECT setval('seqdomaine', 5);
SELECT setval('seqparcours', 3);
SELECT setval('seqentreprise', 5);
SELECT setval('seqexperience', 4);
SELECT setval('seqreseauxsociaux', 4);
SELECT setval('seqreseauutilisateur', 5);
SELECT setval('seqmenudynamique', 2);
SELECT setval('sequsermenu', 6);

-- =====================================================
-- PARTIE 9 : VÉRIFICATION DES DONNÉES INSÉRÉES
-- =====================================================

-- Afficher les utilisateurs créés
SELECT 
    refuser, 
    loginuser, 
    nomuser || ' ' || prenom AS nom_complet,
    etu, 
    mail, 
    idrole,
    idtypeutilisateur
FROM utilisateur 
ORDER BY refuser;

-- Afficher le résumé des données
SELECT 
    'Utilisateurs' AS table_name, COUNT(*) AS nombre FROM utilisateur
UNION ALL
SELECT 'Promotions', COUNT(*) FROM promotion
UNION ALL
SELECT 'Spécialités', COUNT(*) FROM specialite
UNION ALL
SELECT 'Compétences', COUNT(*) FROM competence
UNION ALL
SELECT 'Entreprises', COUNT(*) FROM entreprise
UNION ALL
SELECT 'Expériences', COUNT(*) FROM experience
UNION ALL
SELECT 'Parcours', COUNT(*) FROM parcours
UNION ALL
SELECT 'Menus', COUNT(*) FROM menudynamique;

-- =====================================================
-- FIN DU SCRIPT
-- =====================================================
-- 
-- COMPTES DE TEST CRÉÉS :
-- -------------------------
-- 1. admin / admin (Administrateur)
-- 2. jean.rakoto / test123 (Alumni - profil complet)
-- 3. marie.razaf / test123 (Alumni)
-- 4. paul.andriam / test123 (Étudiant)
-- 5. sophie.raja / test123 (Alumni - profil complet)
-- 6. luc.rakotom / test123 (Enseignant/Admin)
--
-- POUR TESTER LA PAGE PROFIL :
-- URL: http://localhost:8088/alumni/pages/module.jsp?but=profil/mon-profil.jsp&currentMenu=MENDYN001
-- =====================================================
