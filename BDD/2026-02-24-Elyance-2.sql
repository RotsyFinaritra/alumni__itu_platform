-- =====================================================
-- Migration 2026-02-24 : Fonctionnalité Modération
-- Menu modérateur + rôle + données de test
-- =====================================================

-- 1. Créer le rôle modérateur (rang=1 comme admin)
INSERT INTO roles (idrole, descrole, rang) VALUES ('moderateur', 'Modérateur', 1)
ON CONFLICT (idrole) DO NOTHING;

-- 2. Menu Modération (parent) - visible seulement pour rang <= 1
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN003', 'Modération', 'fa-shield', '#', 3, 1, NULL)
ON CONFLICT (id) DO NOTHING;

-- 2.1 Sous-menu : Gestion des utilisateurs
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN003-1', 'Gestion utilisateurs', 'fa-users-cog', 'module.jsp?but=moderation/moderation-liste.jsp', 1, 2, 'MENDYN003')
ON CONFLICT (id) DO NOTHING;

-- 2.2 Sous-menu : Historique modération
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN003-2', 'Historique', 'fa-history', 'module.jsp?but=moderation/moderation-historique.jsp', 2, 2, 'MENDYN003')
ON CONFLICT (id) DO NOTHING;

-- 3. Assignation du menu Modération aux rôles admin et moderateur
-- Pour admin
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) 
VALUES ('USRM_MOD_ADMIN', '*', 'MENDYN003', 'admin', NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

-- Pour moderateur
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) 
VALUES ('USRM_MOD_MOD', '*', 'MENDYN003', 'moderateur', NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

-- Sous-menus aussi
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) 
VALUES ('USRM_MOD_ADMIN_1', '*', 'MENDYN003-1', 'admin', NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) 
VALUES ('USRM_MOD_ADMIN_2', '*', 'MENDYN003-2', 'admin', NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) 
VALUES ('USRM_MOD_MOD_1', '*', 'MENDYN003-1', 'moderateur', NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) 
VALUES ('USRM_MOD_MOD_2', '*', 'MENDYN003-2', 'moderateur', NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

-- 4. Vue pour la liste des utilisateurs avec leur statut
DROP VIEW IF EXISTS v_utilisateur_moderation;
CREATE OR REPLACE VIEW v_utilisateur_moderation AS
SELECT 
    u.refuser,
    u.loginuser,
    u.nomuser,
    u.prenom,
    u.mail,
    u.photo,
    u.idrole,
    r.descrole AS role_libelle,
    r.rang AS role_rang,
    COALESCE(s.statut, 'actif') AS statut,
    s.motif AS dernier_motif,
    s.date_expiration,
    COALESCE(p.libelle, '') AS promotion
FROM utilisateur u
LEFT JOIN roles r ON u.idrole = r.idrole
LEFT JOIN utilisateur_statut s ON u.refuser = s.refuser
LEFT JOIN promotion p ON u.idpromotion = p.id;

-- 5. Données de test : un modérateur
-- Mot de passe: "moderateur" (encodé selon votre méthode APJ)
INSERT INTO utilisateur (loginuser, pwduser, nomuser, prenom, mail, idrole, rang)
VALUES ('moderateur', 'moderateur', 'Modérateur', 'Test', 'moderateur@itu.mg', 'moderateur', 1)
ON CONFLICT (loginuser) DO NOTHING;

-- Créer l'entrée paramcrypt pour le modérateur
INSERT INTO paramcrypt (id, niveau, croissante, idutilisateur)
SELECT 'PCRYPT_MOD', 5, 0, CAST(refuser AS VARCHAR)
FROM utilisateur WHERE loginuser = 'moderateur'
ON CONFLICT (id) DO NOTHING;

-- 6. Données de test : quelques utilisateurs à modérer
INSERT INTO utilisateur (loginuser, pwduser, nomuser, prenom, mail, idrole, rang)
VALUES ('user_test1', 'test123', 'Dupont', 'Jean', 'jean.dupont@test.mg', 'utilisateur', 2)
ON CONFLICT (loginuser) DO NOTHING;

INSERT INTO utilisateur (loginuser, pwduser, nomuser, prenom, mail, idrole, rang)
VALUES ('user_test2', 'test123', 'Martin', 'Marie', 'marie.martin@test.mg', 'utilisateur', 2)
ON CONFLICT (loginuser) DO NOTHING;

INSERT INTO utilisateur (loginuser, pwduser, nomuser, prenom, mail, idrole, rang)
VALUES ('user_banni', 'test123', 'Banni', 'Exemple', 'banni@test.mg', 'utilisateur', 2)
ON CONFLICT (loginuser) DO NOTHING;

-- Bannir l'utilisateur de test
INSERT INTO moderation_utilisateur (id, idutilisateur, idmoderateur, type_action, motif, date_action)
SELECT 'MOD000001', 
       (SELECT refuser FROM utilisateur WHERE loginuser = 'user_banni'),
       (SELECT refuser FROM utilisateur WHERE loginuser = 'moderateur'),
       'banni',
       'Test de bannissement',
       CURRENT_TIMESTAMP
WHERE EXISTS (SELECT 1 FROM utilisateur WHERE loginuser = 'user_banni')
  AND EXISTS (SELECT 1 FROM utilisateur WHERE loginuser = 'moderateur')
ON CONFLICT (id) DO NOTHING;

-- 7. Vue pour l'historique des actions de modération
DROP VIEW IF EXISTS v_moderation_historique;
CREATE OR REPLACE VIEW v_moderation_historique AS
SELECT 
    m.id,
    m.idutilisateur,
    u.nomuser AS utilisateur_nom,
    u.prenom AS utilisateur_prenom,
    m.idmoderateur,
    mod.nomuser AS moderateur_nom,
    mod.prenom AS moderateur_prenom,
    m.type_action,
    m.motif,
    TO_CHAR(m.date_action, 'DD/MM/YYYY HH24:MI') AS date_action,
    TO_CHAR(m.date_expiration, 'DD/MM/YYYY') AS date_expiration
FROM moderation_utilisateur m
LEFT JOIN utilisateur u ON m.idutilisateur = u.refuser
LEFT JOIN utilisateur mod ON m.idmoderateur = mod.refuser
ORDER BY m.date_action DESC;
