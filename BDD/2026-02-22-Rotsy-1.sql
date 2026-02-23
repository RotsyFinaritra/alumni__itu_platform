
-- Menu 1 : Profil (parent)
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN001', 'Profil', 'fa-user', '#', 1, 1, NULL);

-- Fils de Profil
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN001-1', 'Mon profil', 'fa-id-card', 'module.jsp?but=pages/profil/mon-profil.jsp', 1, 2, 'MENDYN001');

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN001-2', 'Mes compétences', 'fa-star', 'module.jsp?but=pages/profil/competences.jsp', 2, 2, 'MENDYN001');

-- Menu 2 : Annuaire (parent)
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN002', 'Annuaire', 'fa-users', '#', 2, 1, NULL);

-- Fils de Annuaire
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN002-1', 'Recherche alumni', 'fa-search', 'module.jsp?but=pages/annuaire/recherche.jsp', 1, 2, 'MENDYN002');

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN002-2', 'Promotions', 'fa-graduation-cap', 'module.jsp?but=pages/annuaire/promotions.jsp', 2, 2, 'MENDYN002');

-- Assignation des menus aux rôles (admin et alumni voient tout)
-- idrole='admin'
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) VALUES ('USRM001', '*', 'MENDYN001',   NULL, NULL, NULL, 0);
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit) VALUES ('USRM002', '*', 'MENDYN002',   NULL, NULL, NULL, 0);
