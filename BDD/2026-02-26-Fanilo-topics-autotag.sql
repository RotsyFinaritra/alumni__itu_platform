-- Script: Ajout support topics/intérêts utilisateur
-- Date: 2026-02-26

-- Vérifier que les séquences existent (déjà créées dans 2026-02-24-Fanilo-1.sql)
-- Si les tables topics, utilisateur_interets, post_topics existent déjà, ce script est optionnel.

-- Auto-tag des publications existantes basé sur leur type
-- TYP00001 (Stage) → TOP00010
-- TYP00002 (Emploi) → TOP00011  
-- TYP00003 (Activité) → TOP00022

INSERT INTO post_topics (id, post_id, topic_id, created_at)
SELECT 
    'PTOP' || LPAD(ROW_NUMBER() OVER (ORDER BY p.created_at)::TEXT, 5, '0') || 'X' as id,
    p.id as post_id,
    CASE p.idtypepublication
        WHEN 'TYP00001' THEN 'TOP00010'
        WHEN 'TYP00002' THEN 'TOP00011'
        WHEN 'TYP00003' THEN 'TOP00022'
    END as topic_id,
    p.created_at
FROM posts p
WHERE p.idtypepublication IN ('TYP00001', 'TYP00002', 'TYP00003')
AND p.supprime = 0
AND NOT EXISTS (
    SELECT 1 FROM post_topics pt WHERE pt.post_id = p.id
);
