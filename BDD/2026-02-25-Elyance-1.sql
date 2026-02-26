-- =====================================================
-- Script: Ajout du menu Publication dans Modération
-- Auteur: Elyance
-- Date: 2026-02-25
-- =====================================================

BEGIN;

-- =====================================================
-- 1. Ajout du sous-menu Publication sous Modération
-- =====================================================

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYNADMIN-3', 'Publications', 'article', 'module.jsp?but=moderation/publication-admin-liste.jsp', 3, 2, 'MENDYNADMIN')
ON CONFLICT (id) DO UPDATE SET 
    libelle = EXCLUDED.libelle, 
    icone = EXCLUDED.icone, 
    href = EXCLUDED.href,
    rang = EXCLUDED.rang;

-- =====================================================
-- 2. Droits d'accès: Admin uniquement
-- =====================================================

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM_MOD_4', NULL, 'MENDYNADMIN-3', 'admin', NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- 3. Vue admin pour les publications (avec infos complètes)
-- =====================================================

DROP VIEW IF EXISTS v_posts_admin;
CREATE OR REPLACE VIEW v_posts_admin AS
SELECT 
    p.id,
    p.idutilisateur,
    p.idgroupe,
    p.idtypepublication,
    p.idstatutpublication,
    p.idvisibilite,
    p.contenu,
    p.epingle,
    p.supprime,
    p.date_suppression,
    p.nb_likes,
    p.nb_commentaires,
    p.nb_partages,
    p.created_at,
    p.edited_at,
    p.edited_by,
    u.nomuser,
    u.prenom,
    u.mail as email_auteur,
    u.photo as photo_auteur,
    CONCAT(u.nomuser, ' ', u.prenom) as nom_complet,
    tp.libelle as type_libelle,
    tp.code as type_code,
    tp.icon as type_icon,
    tp.couleur as type_couleur,
    sp.libelle as statut_libelle,
    sp.code as statut_code,
    sp.couleur as statut_couleur,
    vp.libelle as visibilite_libelle,
    vp.code as visibilite_code,
    g.nom as groupe_nom,
    CAST((SELECT COUNT(*) FROM likes WHERE post_id = p.id) AS INTEGER) as nb_likes_reel,
    CAST((SELECT COUNT(*) FROM commentaires WHERE post_id = p.id AND supprime = 0) AS INTEGER) as nb_commentaires_reel,
    CAST((SELECT COUNT(*) FROM partages WHERE post_id = p.id) AS INTEGER) as nb_partages_reel,
    CAST((SELECT COUNT(*) FROM post_fichiers WHERE post_id = p.id) AS INTEGER) as nb_fichiers,
    CAST((SELECT COUNT(*) FROM signalements WHERE post_id = p.id) AS INTEGER) as nb_signalements
FROM posts p
LEFT JOIN utilisateur u ON u.refuser = p.idutilisateur
LEFT JOIN type_publication tp ON tp.id = p.idtypepublication
LEFT JOIN statut_publication sp ON sp.id = p.idstatutpublication
LEFT JOIN visibilite_publication vp ON vp.id = p.idvisibilite
LEFT JOIN groupes g ON g.id = p.idgroupe;
-- =====================================================
-- Commande pour ajouter ce script:
-- PGPASSWORD=root psql -h localhost -U postgres -d alumni_itu -f BDD/2026-02-25-Elyance-3.sql
-- =====================================================
