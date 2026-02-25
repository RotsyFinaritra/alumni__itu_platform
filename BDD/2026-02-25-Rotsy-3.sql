-- Script d'ajout du menu pour la publication d'activités/événements
-- Date : 2026-02-25

-- =====================
-- Entrées de menu pour Activités (sous Espace Carrière MENDYN004)
-- =====================

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN004-6', 'Activités / Événements', 'event', 'module.jsp?but=carriere/activite-liste.jsp', 6, 2, 'MENDYN004')
ON CONFLICT (id) DO NOTHING;

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN004-7', 'Publier activité', 'event_note', 'module.jsp?but=carriere/activite-saisie.jsp', 7, 2, 'MENDYN004')
ON CONFLICT (id) DO NOTHING;

-- =====================
-- Droits d'accès : visible par tous les utilisateurs
-- =====================

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM_ACT_001', '*', 'MENDYN004-6', NULL, NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM_ACT_002', '*', 'MENDYN004-7', NULL, NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

COMMIT;
