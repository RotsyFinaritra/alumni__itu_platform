-- =====================================================
-- Migration 2026-02-24 : Menu Publications
-- Ajout du menu pour le système de publications
-- =====================================================

-- Menu principal : Publications (niveau 1, rang 3)
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN003', 'Publications', 'fa-newspaper-o', '#', 3, 1, NULL)
ON CONFLICT (id) DO NOTHING;

-- Sous-menus de Publications
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN003-1', 'Fil d''actualité', 'fa-rss', 'module.jsp?but=publication/fil-actualite.jsp', 1, 2, 'MENDYN003')
ON CONFLICT (id) DO NOTHING;

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN003-2', 'Mes publications', 'fa-book', 'module.jsp?but=publication/mes-publications.jsp', 2, 2, 'MENDYN003')
ON CONFLICT (id) DO NOTHING;

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN003-3', 'Créer une publication', 'fa-plus-circle', 'module.jsp?but=publication/creer-publication.jsp', 3, 2, 'MENDYN003')
ON CONFLICT (id) DO NOTHING;

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN003-4', 'Groupes', 'fa-users', 'module.jsp?but=publication/groupes.jsp', 4, 2, 'MENDYN003')
ON CONFLICT (id) DO NOTHING;

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN003-5', 'Mes centres d''intérêt', 'fa-heart', 'module.jsp?but=publication/centres-interet.jsp', 5, 2, 'MENDYN003')
ON CONFLICT (id) DO NOTHING;

-- Assignation du menu Publications à tous les utilisateurs
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM004', '*', 'MENDYN003', NULL, NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

-- Assignation des sous-menus à tous les utilisateurs
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM004-1', '*', 'MENDYN003-1', NULL, NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM004-2', '*', 'MENDYN003-2', NULL, NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM004-3', '*', 'MENDYN003-3', NULL, NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM004-4', '*', 'MENDYN003-4', NULL, NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM004-5', '*', 'MENDYN003-5', NULL, NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- Vérification
-- =====================================================

-- Afficher les menus créés
SELECT 
    m.id, 
    m.libelle, 
    m.icone, 
    m.href, 
    m.rang, 
    m.niveau,
    m.id_pere,
    CASE WHEN m.id_pere IS NULL THEN 'Menu principal' ELSE 'Sous-menu' END as type_menu
FROM menudynamique m
WHERE m.id LIKE 'MENDYN003%'
ORDER BY m.id_pere NULLS FIRST, m.rang;
