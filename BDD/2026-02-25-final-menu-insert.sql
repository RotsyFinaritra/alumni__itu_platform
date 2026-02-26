-- =====================================================
-- Script d'insertion des menus dynamiques
-- Espace Carrière avec niveau 3
-- Date : 2026-02-25
-- =====================================================

BEGIN;

-- Nettoyage
DELETE FROM usermenu;
DELETE FROM menudynamique;

-- =====================
-- Menus niveau 1
-- =====================

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere) VALUES
('MENDYNPROFIL', 'Profil', 'person', '#', 1, 1, NULL),
('MENDYNANNUAIRE', 'Annuaire', 'group', '#', 2, 1, NULL),
('MENDYNADMIN', 'Modération', 'shield', '#', 3, 1, NULL),
('MENDYNCARRIERE', 'Espace Carrière', 'work', '#', 4, 1, NULL);

-- =====================
-- Profil (niveau 2)
-- =====================

INSERT INTO menudynamique VALUES
('MENDYNPROFIL-1', 'Mon profil', 'badge',
 'module.jsp?but=profil/mon-profil.jsp', 1, 2, 'MENDYNPROFIL'),

('MENDYNPROFIL-2', 'Mes compétences', 'star',
 'module.jsp?but=profil/competence-saisie.jsp', 2, 2, 'MENDYNPROFIL'),

('MENDYNPROFIL-3', 'Confidentialité', 'lock',
 'module.jsp?but=profil/visibilite.jsp', 3, 2, 'MENDYNPROFIL');

-- =====================
-- Annuaire (niveau 2)
-- =====================

INSERT INTO menudynamique VALUES
('MENDYNANNUAIRE-1', 'Recherche alumni', 'search',
 'module.jsp?but=annuaire/annuaire-liste.jsp', 1, 2, 'MENDYNANNUAIRE');

-- ('MENDYNANNUAIRE-2', 'Promotions', 'school',
--  'module.jsp?but=annuaire/promotions.jsp', 2, 2, 'MENDYNANNUAIRE');

-- =====================
-- Espace Carrière – niveau 2
-- =====================

INSERT INTO menudynamique VALUES
('MENDYNCARRIERE-1', 'Tableau de bord', 'dashboard',
 'module.jsp?but=carriere/carriere-accueil.jsp', 1, 2, 'MENDYNCARRIERE'),

('MENDYNCARRIERE-2', 'Emplois', 'business_center', '#', 2, 2, 'MENDYNCARRIERE'),

('MENDYNCARRIERE-3', 'Stages', 'school', '#', 3, 2, 'MENDYNCARRIERE'),

('MENDYNCARRIERE-4', 'Activités / Événements', 'event', '#', 4, 2, 'MENDYNCARRIERE');

-- =====================
-- Emplois – niveau 3
-- =====================

INSERT INTO menudynamique VALUES
('MENDYNCARRIERE-2-1', 'Liste des emplois', 'list',
 'module.jsp?but=carriere/emploi-liste.jsp', 1, 3, 'MENDYNCARRIERE-2'),

('MENDYNCARRIERE-2-2', 'Publier un emploi', 'post_add',
 'module.jsp?but=carriere/emploi-saisie.jsp', 2, 3, 'MENDYNCARRIERE-2');

-- =====================
-- Stages – niveau 3
-- =====================

INSERT INTO menudynamique VALUES
('MENDYNCARRIERE-3-1', 'Liste des stages', 'list',
 'module.jsp?but=carriere/stage-liste.jsp', 1, 3, 'MENDYNCARRIERE-3'),

('MENDYNCARRIERE-3-2', 'Publier un stage', 'note_add',
 'module.jsp?but=carriere/stage-saisie.jsp', 2, 3, 'MENDYNCARRIERE-3');

-- =====================
-- Activités – niveau 3
-- =====================

INSERT INTO menudynamique VALUES
('MENDYNCARRIERE-4-1', 'Liste des activités', 'event_available',
 'module.jsp?but=carriere/activite-liste.jsp', 1, 3, 'MENDYNCARRIERE-4'),

('MENDYNCARRIERE-4-2', 'Publier une activité', 'event_note',
 'module.jsp?but=carriere/activite-saisie.jsp', 2, 3, 'MENDYNCARRIERE-4');

-- =====================
-- Modération (niveau 2)
-- =====================

INSERT INTO menudynamique VALUES
('MENDYNADMIN-1', 'Gestion utilisateurs', 'group',
 'module.jsp?but=moderation/moderation-liste.jsp', 1, 2, 'MENDYNADMIN'),

('MENDYNADMIN-2', 'Historique', 'history',
 'module.jsp?but=moderation/moderation-historique.jsp', 2, 2, 'MENDYNADMIN'),

 ('MENDYNADMIN-3', 'Publications', 'article', 
 'module.jsp?but=moderation/publication-admin-liste.jsp', 3, 2, 'MENDYNADMIN'),

 ('MENDYNADMIN-4', 'Signalements', 'report',
 'module.jsp?but=moderation/signalement-liste.jsp', 4, 2, 'MENDYNADMIN');

 INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENUALUMNICHAT', 'Assistant IA', 'chat', 'module.jsp?but=chatbot/alumni-chat.jsp', 5, 1, NULL)
ON CONFLICT (id) DO UPDATE SET libelle = EXCLUDED.libelle, icone = EXCLUDED.icone, href = EXCLUDED.href;


-- =====================
-- Droits utilisateurs (usermenu)
-- =====================

-- Menus visibles par tous
INSERT INTO usermenu VALUES
('USRM001', '*', 'MENDYNPROFIL', NULL, NULL, NULL, 0),
('USRM002', '*', 'MENDYNANNUAIRE', NULL, NULL, NULL, 0),
('USRM003', '*', 'MENDYNCARRIERE', NULL, NULL, NULL, 0);

-- Accès Espace carrière niveau 3
INSERT INTO usermenu VALUES
('USRM_CAR_1', '*', 'MENDYNCARRIERE-2-1', NULL, NULL, NULL, 0),
('USRM_CAR_2', '*', 'MENDYNCARRIERE-2-2', 'admin', NULL, NULL, 0),
('USRM_CAR_3', '*', 'MENDYNCARRIERE-3-1', NULL, NULL, NULL, 0),
('USRM_CAR_4', '*', 'MENDYNCARRIERE-3-2', 'admin', NULL, NULL, 0),
('USRM_CAR_5', '*', 'MENDYNCARRIERE-4-1', NULL, NULL, NULL, 0),
('USRM_CAR_6', '*', 'MENDYNCARRIERE-4-2', 'admin', NULL, NULL, 0),
('USRM_CAR_7', '*', 'MENDYNCARRIERE-2-2', 'alumni', NULL, NULL, 0),
('USRM_CAR_8', '*', 'MENDYNCARRIERE-3-2', 'alumni', NULL, NULL, 0),
('USRM_CAR_9', '*', 'MENDYNCARRIERE-4-2', 'alumni', NULL, NULL, 0);

-- Modération : admin uniquement
INSERT INTO usermenu VALUES
('USRM_MOD_1', NULL, 'MENDYNADMIN', 'admin', NULL, NULL, 0),
('USRM_MOD_2', NULL, 'MENDYNADMIN-1', 'admin', NULL, NULL, 0),
('USRM_MOD_3', NULL, 'MENDYNADMIN-2', 'admin', NULL, NULL, 0),
('USRM_MOD_4', NULL, 'MENDYNADMIN-3', 'admin', NULL, NULL, 0),
('USRM_MOD_5', NULL, 'MENDYNADMIN-4', 'admin', NULL, NULL, 0);

-- Étudiants : interdiction de publier (interdit=1)
INSERT INTO usermenu VALUES
('USRM_ETU_1', NULL, 'MENDYNCARRIERE-2-2', 'etudiant', NULL, NULL, 1),  -- Publier emploi interdit
('USRM_ETU_2', NULL, 'MENDYNCARRIERE-3-2', 'etudiant', NULL, NULL, 1),  -- Publier stage interdit
('USRM_ETU_3', NULL, 'MENDYNCARRIERE-4-2', 'etudiant', NULL, NULL, 1);  -- Publier activité interdit

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRMCHAT', '*', 'MENUALUMNICHAT', NULL, NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

COMMIT;


-- Donner accès à tous les utilisateurs (refuser='*' = tout le monde)
