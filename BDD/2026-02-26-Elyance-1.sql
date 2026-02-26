-- =====================================================
-- Script d'ajout du menu Signalement pour les modérateurs
-- Date : 2026-02-26
-- =====================================================

BEGIN;
-- Vue v_signalements_publications (signalements de publications)
-- =====================

DROP VIEW IF EXISTS v_signalements_publications;
CREATE OR REPLACE VIEW v_signalements_publications AS
SELECT 
    s.id,
    s.idutilisateur,
    s.post_id,
    s.idmotifsignalement,
    s.idstatutsignalement,
    s.description,
    s.traite_par,
    s.traite_at,
    s.decision,
    s.created_at,
    -- Infos signaleur
    CONCAT(u.nomuser, ' ', u.prenom) as signaleur_nom,
    u.mail as signaleur_email,
    -- Infos motif
    ms.libelle as motif_libelle,
    ms.code as motif_code,
    ms.gravite as motif_gravite,
    ms.couleur as motif_couleur,
    ms.icon as motif_icon,
    -- Infos statut signalement
    ss.libelle as statut_libelle,
    ss.code as statut_code,
    ss.couleur as statut_couleur,
    -- Infos publication signalée
    p.contenu as publication_contenu,
    p.supprime as publication_supprime,
    p.created_at as publication_date,
    CONCAT(up.nomuser, ' ', up.prenom) as publication_auteur,
    -- Infos modérateur
    CONCAT(um.nomuser, ' ', um.prenom) as moderateur_nom
FROM signalements s
LEFT JOIN utilisateur u ON u.refuser = s.idutilisateur
LEFT JOIN motif_signalement ms ON ms.id = s.idmotifsignalement
LEFT JOIN statut_signalement ss ON ss.id = s.idstatutsignalement
LEFT JOIN posts p ON p.id = s.post_id
LEFT JOIN utilisateur up ON up.refuser = p.idutilisateur
LEFT JOIN utilisateur um ON um.refuser = s.traite_par
WHERE s.post_id IS NOT NULL AND s.commentaire_id IS NULL;

-- =====================
-- Vue v_signalements_commentaires (signalements de commentaires)
-- =====================

DROP VIEW IF EXISTS v_signalements_commentaires;
CREATE OR REPLACE VIEW v_signalements_commentaires AS
SELECT 
    s.id,
    s.idutilisateur,
    s.commentaire_id,
    s.idmotifsignalement,
    s.idstatutsignalement,
    s.description,
    s.traite_par,
    s.traite_at,
    s.decision,
    s.created_at,
    -- Infos signaleur
    CONCAT(u.nomuser, ' ', u.prenom) as signaleur_nom,
    u.mail as signaleur_email,
    -- Infos motif
    ms.libelle as motif_libelle,
    ms.code as motif_code,
    ms.gravite as motif_gravite,
    ms.couleur as motif_couleur,
    ms.icon as motif_icon,
    -- Infos statut signalement
    ss.libelle as statut_libelle,
    ss.code as statut_code,
    ss.couleur as statut_couleur,
    -- Infos commentaire signalé
    c.contenu as commentaire_contenu,
    c.supprime as commentaire_supprime,
    c.created_at as commentaire_date,
    c.post_id as commentaire_post_id,
    CONCAT(uc.nomuser, ' ', uc.prenom) as commentaire_auteur,
    -- Infos modérateur
    CONCAT(um.nomuser, ' ', um.prenom) as moderateur_nom
FROM signalements s
LEFT JOIN utilisateur u ON u.refuser = s.idutilisateur
LEFT JOIN motif_signalement ms ON ms.id = s.idmotifsignalement
LEFT JOIN statut_signalement ss ON ss.id = s.idstatutsignalement
LEFT JOIN commentaires c ON c.id = s.commentaire_id
LEFT JOIN utilisateur uc ON uc.refuser = c.idutilisateur
LEFT JOIN utilisateur um ON um.refuser = s.traite_par
WHERE s.commentaire_id IS NOT NULL;

COMMIT;
