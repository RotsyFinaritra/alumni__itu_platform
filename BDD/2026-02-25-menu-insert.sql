-- Script d'insertion des menus dynamiques
-- Date : 2026-02-25

-- Suppression des anciens menus pour éviter les doublons
DELETE FROM menudynamique;

-- =====================
-- Menus parent (niveau 1)
-- =====================

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN001', 'Profil', 'person', '#', 1, 1, NULL);

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN002', 'Annuaire', 'group', '#', 2, 1, NULL);

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN006', 'Modération', 'shield', '#', 3, 1, NULL);

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN004', 'Espace Carriere', 'work', '#', 4, 1, NULL);

-- =====================
-- Fils de Profil (MENDYN001)
-- =====================

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN001-1', 'Mon profil', 'badge', 'module.jsp?but=profil/mon-profil.jsp', 1, 2, 'MENDYN001');

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN001-2', 'Mes compétences', 'star', 'module.jsp?but=profil/competence-saisie.jsp', 2, 2, 'MENDYN001');

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN001-3', 'Confidentialité', 'lock', 'module.jsp?but=profil/visibilite.jsp', 3, 2, 'MENDYN001');

-- =====================
-- Fils de Annuaire (MENDYN002)
-- =====================

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN002-1', 'Recherche alumni', 'search', 'module.jsp?but=annuaire/annuaire-liste.jsp', 1, 2, 'MENDYN002');

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN002-2', 'Promotions', 'school', 'module.jsp?but=annuaire/promotions.jsp', 2, 2, 'MENDYN002');

-- =====================
-- Fils de Espace Carriere (MENDYN004)
-- =====================

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN004-1', 'Tableau de bord', 'dashboard', 'module.jsp?but=carriere/carriere-accueil.jsp', 1, 2, 'MENDYN004');

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN004-2', 'Offres d''emploi', 'business_center', 'module.jsp?but=carriere/emploi-liste.jsp', 2, 2, 'MENDYN004');

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN004-3', 'Offres de stage', 'school', 'module.jsp?but=carriere/stage-liste.jsp', 3, 2, 'MENDYN004');

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN004-4', 'Publier emploi', 'post_add', 'module.jsp?but=carriere/emploi-saisie.jsp', 4, 2, 'MENDYN004');

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN004-5', 'Publier stage', 'note_add', 'module.jsp?but=carriere/stage-saisie.jsp', 5, 2, 'MENDYN004');

-- =====================
-- Fils de Modération (MENDYN006)
-- =====================

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN006-1', 'Gestion utilisateurs', 'group', 'module.jsp?but=moderation/moderation-liste.jsp', 1, 2, 'MENDYN006');

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN006-2', 'Historique', 'history', 'module.jsp?but=moderation/moderation-historique.jsp', 2, 2, 'MENDYN006');

-- =====================
-- Assignation des menus aux utilisateurs/rôles (usermenu)
-- =====================

-- Suppression des anciens enregistrements pour éviter les doublons
DELETE FROM usermenu WHERE id IN (
    'USRM001', 'USRM002', 'USRM003', 'USRM005',
    'USRM_MOD_ADMIN', 'USRM_MOD_ADMIN_1', 'USRM_MOD_ADMIN_2'
);

-- Menus visibles par tous les utilisateurs (refuser='*')
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM001', '*', 'MENDYN001', NULL, NULL, NULL, 0);

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM002', '*', 'MENDYN002', NULL, NULL, NULL, 0);

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM003', '*', 'MENDYN001-3', NULL, NULL, NULL, 0);

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM005', '*', 'MENDYN004', NULL, NULL, NULL, 0);

-- Menus Modération réservés au rôle admin
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM_MOD_ADMIN', NULL, 'MENDYN006', 'admin', NULL, NULL, 0);

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM_MOD_ADMIN_1', NULL, 'MENDYN006-1', 'admin', NULL, NULL, 0);

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM_MOD_ADMIN_2', NULL, 'MENDYN006-2', 'admin', NULL, NULL, 0);

COMMIT;
