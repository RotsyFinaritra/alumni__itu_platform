-- =====================================================
-- Migration 2026-02-24 : Fonctionnalité Modération
-- Menu modération pour admin (rang=1)
-- =====================================================

-- 1. Menu Modération (parent)
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN003', 'Modération', 'fa-shield', '#', 3, 1, NULL)
ON CONFLICT (id) DO NOTHING;

-- 1.1 Sous-menu : Gestion des utilisateurs
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN003-1', 'Gestion utilisateurs', 'fa-users-cog', 'module.jsp?but=moderation/moderation-liste.jsp', 1, 2, 'MENDYN003')
ON CONFLICT (id) DO NOTHING;

-- 1.2 Sous-menu : Historique modération
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN003-2', 'Historique', 'fa-history', 'module.jsp?but=moderation/moderation-historique.jsp', 2, 2, 'MENDYN003')
ON CONFLICT (id) DO NOTHING;

-- 2. Assignation du menu Modération au rôle admin UNIQUEMENT
-- Note: refuser doit être NULL (pas '*') pour que seul le rôle soit vérifié
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) 
VALUES ('USRM_MOD_ADMIN', NULL, 'MENDYN003', 'admin', NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) 
VALUES ('USRM_MOD_ADMIN_1', NULL, 'MENDYN003-1', 'admin', NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) 
VALUES ('USRM_MOD_ADMIN_2', NULL, 'MENDYN003-2', 'admin', NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

-- 3. Vue pour la liste des utilisateurs avec leur statut
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

-- 4. Vue pour l'historique des actions de modération
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
