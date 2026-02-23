-- =====================================================
-- SCRIPT RAPIDE : Insertion des données de test uniquement
-- Utiliser ce script si la BDD est déjà créée
-- =====================================================

-- Promotions de test
INSERT INTO promotion (id, libelle, annee) VALUES ('PROM0001', 'Promotion 2023', 2023);
INSERT INTO promotion (id, libelle, annee) VALUES ('PROM0002', 'Promotion 2024', 2024);
INSERT INTO promotion (id, libelle, annee) VALUES ('PROM0003', 'Promotion 2025', 2025);

-- Types d'emploi
INSERT INTO type_emploie (id, libelle) VALUES ('TE0000001', 'CDI');
INSERT INTO type_emploie (id, libelle) VALUES ('TE0000002', 'CDD');
INSERT INTO type_emploie (id, libelle) VALUES ('TE0000003', 'Stage');
INSERT INTO type_emploie (id, libelle) VALUES ('TE0000004', 'Freelance');

-- Utilisateurs de test
-- IMPORTANT: Tous les mots de passe sont "test123" (chiffré = yjxy678 avec niveau=5, croissante=0)

-- Utilisateur 1: Jean RAKOTO (Alumni)
-- Login: jean.rakoto / Mot de passe: test123
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, prenom, etu, mail, teluser, adruser, idrole, rang, idtypeutilisateur, idpromotion)
VALUES (2, 'jean.rakoto', 'yjxy678', 'RAKOTO', 'Jean', 'ETU001234', 'jean.rakoto@alumni-itu.mg', '0340123456', 'Antananarivo, Madagascar', 'alumni', 2, 'TU0000001', 'PROM0001');
INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur) VALUES ('CRY0000002', 5, 0, '2');

-- Utilisateur 2: Marie RAZAFINDRAKOTO (Alumni)
-- Login: marie.razaf / Mot de passe: test123
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, prenom, etu, mail, teluser, adruser, idrole, rang, idtypeutilisateur, idpromotion)
VALUES (3, 'marie.razaf', 'yjxy678', 'RAZAFINDRAKOTO', 'Marie', 'ETU002345', 'marie.razaf@alumni-itu.mg', '0341234567', 'Fianarantsoa, Madagascar', 'alumni', 2, 'TU0000001', 'PROM0001');
INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur) VALUES ('CRY0000003', 5, 0, '3');

-- Utilisateur 3: Paul ANDRIAMIHAJA (Étudiant)
-- Login: paul.andriam / Mot de passe: test123
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, prenom, etu, mail, teluser, adruser, idrole, rang, idtypeutilisateur, idpromotion)
VALUES (4, 'paul.andriam', 'yjxy678', 'ANDRIAMIHAJA', 'Paul', 'ETU003456', 'paul.andriam@itu.mg', '0342345678', 'Toamasina, Madagascar', 'etudiant', 3, 'TU0000002', 'PROM0003');
INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur) VALUES ('CRY0000004', 5, 0, '4');

-- Utilisateur 4: Sophie RAJAONAH (Alumni avec profil complet)
-- Login: sophie.raja / Mot de passe: test123
INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, prenom, etu, mail, teluser, adruser, idrole, rang, idtypeutilisateur, idpromotion)
VALUES (5, 'sophie.raja', 'yjxy678', 'RAJAONAH', 'Sophie', 'ETU004567', 'sophie.raja@alumni-itu.mg', '0343456789', '101 Rue de l''Université, Antananarivo', 'alumni', 2, 'TU0000001', 'PROM0002');
INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur) VALUES ('CRY0000005', 5, 0, '5');

-- Menu dynamique pour le profil
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN001', 'Mon Profil', 'fa fa-user-circle', 'profil/mon-profil.jsp', 1, 1, NULL);

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN002', 'Accueil', 'fa fa-home', 'accueil.jsp', 0, 1, NULL);

-- Assignation du menu à tous les rôles
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) VALUES ('UM0001', NULL, 'MENDYN001', 'admin', '', '', 0);
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) VALUES ('UM0002', NULL, 'MENDYN001', 'alumni', '', '', 0);
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) VALUES ('UM0003', NULL, 'MENDYN001', 'etudiant', '', '', 0);
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) VALUES ('UM0004', NULL, 'MENDYN002', 'admin', '', '', 0);
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) VALUES ('UM0005', NULL, 'MENDYN002', 'alumni', '', '', 0);
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) VALUES ('UM0006', NULL, 'MENDYN002', 'etudiant', '', '', 0);

-- Synchroniser les séquences
SELECT setval('sequtilisateur', 6);
SELECT setval('seqparamcrypt', 6);
SELECT setval('seqpromotion', 3);
SELECT setval('seqtypeemploie', 4);
SELECT setval('seqmenudynamique', 2);
SELECT setval('sequsermenu', 6);

-- Afficher les utilisateurs créés
SELECT 
    refuser, 
    loginuser, 
    nomuser, 
    prenom, 
    etu, 
    mail, 
    idrole 
FROM utilisateur 
ORDER BY refuser;
