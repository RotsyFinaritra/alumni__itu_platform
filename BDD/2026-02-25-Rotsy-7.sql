-- ============================================
-- 2026-02-25 - Ajout du menu Recherche Alumni
-- ============================================

-- Ajout du menu de recherche alumni (niveau 1, sans parent = menu racine)
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENUALUMNICHAT', 'Recherche Alumni', 'fa fa-search', 'module.jsp?but=chatbot/alumni-chat.jsp', 5, 1, NULL)
ON CONFLICT (id) DO UPDATE SET libelle = EXCLUDED.libelle, icone = EXCLUDED.icone, href = EXCLUDED.href;

-- Donner accès à tous les utilisateurs (refuser='*' = tout le monde)
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRMCHAT', '*', 'MENUALUMNICHAT', NULL, NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

INSERT INTO entreprise (id, libelle, description)
SELECT 'ENT00003', 'Telma', 'Opérateur télécom malgache'
WHERE NOT EXISTS (SELECT 1 FROM entreprise WHERE UPPER(libelle) LIKE '%TELMA%');
