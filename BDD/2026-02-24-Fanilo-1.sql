-- ============================================================================
-- Script de création du système de publications Alumni ITU
-- Auteur: Fanilo
-- Date: 24 février 2026
-- Description: Tables complètes pour posts, groupes, notifications, modération
-- ============================================================================

-- ============================================================================
-- 1. SÉQUENCES POUR LES PRIMARY KEYS
-- ============================================================================

CREATE SEQUENCE IF NOT EXISTS seq_type_publication START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_statut_publication START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_visibilite_publication START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_type_fichier START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_type_notification START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_motif_signalement START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_statut_signalement START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_role_groupe START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_posts START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_likes START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_commentaires START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_partages START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_groupes START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_groupe_membres START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_topics START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_utilisateur_interets START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_post_topics START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_notifications START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_signalements START WITH 1;
CREATE SEQUENCE IF NOT EXISTS seq_post_fichiers START WITH 1;

-- ============================================================================
-- 2. FONCTIONS GÉNÉRATRICES DE CLÉS PRIMAIRES
-- ============================================================================

CREATE OR REPLACE FUNCTION getseqtypepublication() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'TYP' || LPAD(nextval('seq_type_publication')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqstatutpublication() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'STAT' || LPAD(nextval('seq_statut_publication')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqvisibilitepublication() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'VISI' || LPAD(nextval('seq_visibilite_publication')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqtypefichier() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'TFIC' || LPAD(nextval('seq_type_fichier')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqtypenotification() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'TNOT' || LPAD(nextval('seq_type_notification')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqmotifsignalement() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'MSIG' || LPAD(nextval('seq_motif_signalement')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqstatutsignalement() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'SSIG' || LPAD(nextval('seq_statut_signalement')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqrolegroupe() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'ROLE' || LPAD(nextval('seq_role_groupe')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqposts() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'POST' || LPAD(nextval('seq_posts')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqlikes() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'LIKE' || LPAD(nextval('seq_likes')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqcommentaires() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'COMM' || LPAD(nextval('seq_commentaires')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqpartages() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'PART' || LPAD(nextval('seq_partages')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqgroupes() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'GRP' || LPAD(nextval('seq_groupes')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqgroupemembres() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'GMBR' || LPAD(nextval('seq_groupe_membres')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqtopics() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'TOP' || LPAD(nextval('seq_topics')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getsequtilisateurinterets() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'UINT' || LPAD(nextval('seq_utilisateur_interets')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqposttopics() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'PTOP' || LPAD(nextval('seq_post_topics')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqnotifications() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'NOTIF' || LPAD(nextval('seq_notifications')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqsignalements() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'SIG' || LPAD(nextval('seq_signalements')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION getseqpostfichiers() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'PFIC' || LPAD(nextval('seq_post_fichiers')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 3. TABLES DE RÉFÉRENTIEL
-- ============================================================================

-- 3.1 Types de publication
CREATE TABLE type_publication (
    id VARCHAR(50) PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    icon VARCHAR(50),
    couleur VARCHAR(20),
    description TEXT,
    actif INTEGER DEFAULT 1,
    ordre INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3.2 Statuts de publication
CREATE TABLE statut_publication (
    id VARCHAR(50) PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    icon VARCHAR(50),
    couleur VARCHAR(20),
    description TEXT,
    actif INTEGER DEFAULT 1,
    ordre INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3.3 Visibilité de publication
CREATE TABLE visibilite_publication (
    id VARCHAR(50) PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    icon VARCHAR(50),
    couleur VARCHAR(20),
    description TEXT,
    actif INTEGER DEFAULT 1,
    ordre INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3.4 Types de fichier
CREATE TABLE type_fichier (
    id VARCHAR(50) PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    icon VARCHAR(50),
    couleur VARCHAR(20),
    extensions_acceptees VARCHAR(200),
    taille_max_mo INTEGER,
    description TEXT,
    actif INTEGER DEFAULT 1,
    ordre INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3.5 Types de notification
CREATE TABLE type_notification (
    id VARCHAR(50) PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    icon VARCHAR(50),
    couleur VARCHAR(20),
    template_message TEXT,
    description TEXT,
    actif INTEGER DEFAULT 1,
    ordre INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3.6 Motifs de signalement
CREATE TABLE motif_signalement (
    id VARCHAR(50) PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    icon VARCHAR(50),
    couleur VARCHAR(20),
    gravite INTEGER,
    action_automatique VARCHAR(100),
    description TEXT,
    actif INTEGER DEFAULT 1,
    ordre INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3.7 Statuts de signalement
CREATE TABLE statut_signalement (
    id VARCHAR(50) PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    icon VARCHAR(50),
    couleur VARCHAR(20),
    description TEXT,
    actif INTEGER DEFAULT 1,
    ordre INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3.8 Rôles dans les groupes
CREATE TABLE role_groupe (
    id VARCHAR(50) PRIMARY KEY,
    libelle VARCHAR(100) NOT NULL,
    code VARCHAR(50) UNIQUE NOT NULL,
    icon VARCHAR(50),
    couleur VARCHAR(20),
    permissions TEXT,
    niveau_acces INTEGER,
    description TEXT,
    actif INTEGER DEFAULT 1,
    ordre INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 4. TABLE PRINCIPALE - POSTS
-- ============================================================================

CREATE TABLE posts (
    id VARCHAR(50) PRIMARY KEY,
    idutilisateur INTEGER NOT NULL REFERENCES utilisateur(refuser),
    idgroupe VARCHAR(50),
    idtypepublication VARCHAR(50) NOT NULL REFERENCES type_publication(id),
    idstatutpublication VARCHAR(50) NOT NULL REFERENCES statut_publication(id),
    idvisibilite VARCHAR(50) NOT NULL REFERENCES visibilite_publication(id),
    contenu TEXT NOT NULL,
    epingle INTEGER DEFAULT 0,
    supprime INTEGER DEFAULT 0,
    date_suppression TIMESTAMP,
    nb_likes INTEGER DEFAULT 0,
    nb_commentaires INTEGER DEFAULT 0,
    nb_partages INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    edited_at TIMESTAMP,
    edited_by INTEGER REFERENCES utilisateur(refuser)
);

-- ============================================================================
-- 5. TABLES DE DÉTAILS SPÉCIFIQUES PAR TYPE
-- ============================================================================

-- 5.1 Détails pour les stages
CREATE TABLE post_stage (
    post_id VARCHAR(50) PRIMARY KEY REFERENCES posts(id) ON DELETE CASCADE,
    entreprise VARCHAR(200) NOT NULL,
    localisation VARCHAR(200),
    duree VARCHAR(100),
    date_debut DATE,
    date_fin DATE,
    indemnite DECIMAL(10,2),
    niveau_etude_requis VARCHAR(100),
    competences_requises TEXT,
    convention_requise INTEGER DEFAULT 0,
    places_disponibles INTEGER,
    contact_email VARCHAR(200),
    contact_tel VARCHAR(50),
    lien_candidature VARCHAR(500)
);

-- 5.2 Détails pour les emplois
CREATE TABLE post_emploi (
    post_id VARCHAR(50) PRIMARY KEY REFERENCES posts(id) ON DELETE CASCADE,
    entreprise VARCHAR(200) NOT NULL,
    localisation VARCHAR(200),
    poste VARCHAR(200) NOT NULL,
    type_contrat VARCHAR(50),
    salaire_min DECIMAL(10,2),
    salaire_max DECIMAL(10,2),
    devise VARCHAR(10) DEFAULT 'MGA',
    experience_requise VARCHAR(100),
    competences_requises TEXT,
    niveau_etude_requis VARCHAR(100),
    teletravail_possible INTEGER DEFAULT 0,
    date_limite DATE,
    contact_email VARCHAR(200),
    contact_tel VARCHAR(50),
    lien_candidature VARCHAR(500)
);

-- 5.3 Détails pour les activités/événements
CREATE TABLE post_activite (
    post_id VARCHAR(50) PRIMARY KEY REFERENCES posts(id) ON DELETE CASCADE,
    titre VARCHAR(200) NOT NULL,
    categorie VARCHAR(100),
    lieu VARCHAR(200),
    adresse TEXT,
    date_debut TIMESTAMP,
    date_fin TIMESTAMP,
    prix DECIMAL(10,2),
    nombre_places INTEGER,
    places_restantes INTEGER,
    contact_email VARCHAR(200),
    contact_tel VARCHAR(50),
    lien_inscription VARCHAR(500),
    lien_externe VARCHAR(500)
);

-- ============================================================================
-- 6. TABLES D'INTERACTIONS
-- ============================================================================

-- 6.1 Likes
CREATE TABLE likes (
    id VARCHAR(50) PRIMARY KEY,
    idutilisateur INTEGER NOT NULL REFERENCES utilisateur(refuser),
    post_id VARCHAR(50) NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- 6.2 Commentaires
CREATE TABLE commentaires (
    id VARCHAR(50) PRIMARY KEY,
    idutilisateur INTEGER NOT NULL REFERENCES utilisateur(refuser),
    post_id VARCHAR(50) NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    parent_id VARCHAR(50) REFERENCES commentaires(id) ON DELETE CASCADE,
    contenu TEXT NOT NULL,
    supprime INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
    edited_at TIMESTAMP
);

-- 6.3 Partages
CREATE TABLE partages (
    id VARCHAR(50) PRIMARY KEY,
    idutilisateur INTEGER NOT NULL REFERENCES utilisateur(refuser),
    post_id VARCHAR(50) NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    commentaire TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- ============================================================================
-- 7. TABLES DE GROUPES
-- ============================================================================

-- 7.1 Groupes
CREATE TABLE groupes (
    id VARCHAR(50) PRIMARY KEY,
    nom VARCHAR(200) NOT NULL,
    description TEXT,
    photo_couverture VARCHAR(500),
    photo_profil VARCHAR(500),
    type_groupe VARCHAR(50) DEFAULT 'ouvert',
    created_by INTEGER NOT NULL REFERENCES utilisateur(refuser),
    actif INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- 7.2 Membres des groupes
CREATE TABLE groupe_membres (
    id VARCHAR(50) PRIMARY KEY,
    idutilisateur INTEGER NOT NULL REFERENCES utilisateur(refuser),
    idgroupe VARCHAR(50) NOT NULL REFERENCES groupes(id) ON DELETE CASCADE,
    idrole VARCHAR(50) NOT NULL REFERENCES role_groupe(id),
    statut VARCHAR(50) DEFAULT 'actif',
    joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- ============================================================================
-- 8. TABLES DE TOPICS / CENTRES D'INTÉRÊT
-- ============================================================================

-- 8.1 Topics
CREATE TABLE topics (
    id VARCHAR(50) PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    couleur VARCHAR(20),
    actif INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8.2 Centres d'intérêt des utilisateurs
CREATE TABLE utilisateur_interets (
    id VARCHAR(50) PRIMARY KEY,
    idutilisateur INTEGER NOT NULL REFERENCES utilisateur(refuser),
    topic_id VARCHAR(50) NOT NULL REFERENCES topics(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8.3 Tags des publications
CREATE TABLE post_topics (
    id VARCHAR(50) PRIMARY KEY,
    post_id VARCHAR(50) NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    topic_id VARCHAR(50) NOT NULL REFERENCES topics(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 9. TABLES DE NOTIFICATIONS
-- ============================================================================

CREATE TABLE notifications (
    id VARCHAR(50) PRIMARY KEY,
    idutilisateur INTEGER NOT NULL REFERENCES utilisateur(refuser),
    emetteur_id INTEGER REFERENCES utilisateur(refuser),
    idtypenotification VARCHAR(50) NOT NULL REFERENCES type_notification(id),
    post_id VARCHAR(50) REFERENCES posts(id) ON DELETE CASCADE,
    commentaire_id VARCHAR(50) REFERENCES commentaires(id) ON DELETE CASCADE,
    groupe_id VARCHAR(50) REFERENCES groupes(id) ON DELETE CASCADE,
    contenu TEXT,
    lien VARCHAR(500),
    vu INTEGER DEFAULT 0,
    lu_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- ============================================================================
-- 10. TABLES DE MODÉRATION
-- ============================================================================

CREATE TABLE signalements (
    id VARCHAR(50) PRIMARY KEY,
    idutilisateur INTEGER NOT NULL REFERENCES utilisateur(refuser),
    post_id VARCHAR(50) REFERENCES posts(id) ON DELETE CASCADE,
    commentaire_id VARCHAR(50) REFERENCES commentaires(id) ON DELETE CASCADE,
    idmotifsignalement VARCHAR(50) NOT NULL REFERENCES motif_signalement(id),
    idstatutsignalement VARCHAR(50) NOT NULL REFERENCES statut_signalement(id),
    description TEXT,
    traite_par INTEGER REFERENCES utilisateur(refuser),
    traite_at TIMESTAMP,
    decision TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- ============================================================================
-- 11. TABLE DES FICHIERS JOINTS
-- ============================================================================

CREATE TABLE post_fichiers (
    id VARCHAR(50) PRIMARY KEY,
    post_id VARCHAR(50) NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    idtypefichier VARCHAR(50) NOT NULL REFERENCES type_fichier(id),
    nom_fichier VARCHAR(200) NOT NULL,
    nom_original VARCHAR(200) NOT NULL,
    chemin VARCHAR(500) NOT NULL,
    taille_octets BIGINT,
    mime_type VARCHAR(100),
    ordre INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 12. INDEX POUR OPTIMISATION DES PERFORMANCES
-- ============================================================================

-- Index sur posts
CREATE INDEX idx_posts_user_date ON posts(idutilisateur, created_at DESC);
CREATE INDEX idx_posts_type_date ON posts(idtypepublication, created_at DESC);
CREATE INDEX idx_posts_statut_date ON posts(idstatutpublication, created_at DESC);
CREATE INDEX idx_posts_visibilite ON posts(idvisibilite, created_at DESC);
CREATE INDEX idx_posts_groupe ON posts(idgroupe);
CREATE INDEX idx_posts_date ON posts(created_at DESC);
CREATE INDEX idx_posts_supprime ON posts(supprime, created_at DESC);

-- Index sur likes
CREATE UNIQUE INDEX unique_user_like_post ON likes(idutilisateur, post_id);
CREATE INDEX idx_likes_post ON likes(post_id);
CREATE INDEX idx_likes_user ON likes(idutilisateur);

-- Index sur commentaires
CREATE INDEX idx_comments_post_date ON commentaires(post_id, created_at);
CREATE INDEX idx_comments_parent ON commentaires(parent_id, created_at);
CREATE INDEX idx_comments_user ON commentaires(idutilisateur);

-- Index sur partages
CREATE INDEX idx_partages_user_date ON partages(idutilisateur, created_at DESC);
CREATE INDEX idx_partages_post ON partages(post_id);

-- Index sur groupes
CREATE INDEX idx_groupes_nom ON groupes(nom);
CREATE INDEX idx_groupes_created_by ON groupes(created_by);
CREATE UNIQUE INDEX unique_user_group ON groupe_membres(idutilisateur, idgroupe);
CREATE INDEX idx_groupe_membres_group ON groupe_membres(idgroupe);
CREATE INDEX idx_groupe_membres_role ON groupe_membres(idrole);

-- Index sur topics
CREATE INDEX idx_topics_nom ON topics(nom);
CREATE UNIQUE INDEX unique_user_topic ON utilisateur_interets(idutilisateur, topic_id);
CREATE INDEX idx_user_interets_topic ON utilisateur_interets(topic_id);
CREATE UNIQUE INDEX unique_post_topic ON post_topics(post_id, topic_id);
CREATE INDEX idx_post_topics_topic ON post_topics(topic_id);

-- Index sur notifications
CREATE INDEX idx_notifs_user_vu_date ON notifications(idutilisateur, vu, created_at DESC);
CREATE INDEX idx_notifs_user_date ON notifications(idutilisateur, created_at DESC);
CREATE INDEX idx_notifs_type ON notifications(idtypenotification);

-- Index sur signalements
CREATE INDEX idx_signalements_statut_date ON signalements(idstatutsignalement, created_at DESC);
CREATE INDEX idx_signalements_user ON signalements(idutilisateur);
CREATE INDEX idx_signalements_motif ON signalements(idmotifsignalement);
CREATE INDEX idx_signalements_post ON signalements(post_id);

-- Index sur fichiers
CREATE INDEX idx_post_fichiers_post ON post_fichiers(post_id);
CREATE INDEX idx_post_fichiers_type ON post_fichiers(idtypefichier);

-- Index full-text search (optionnel, pour PostgreSQL)
CREATE INDEX idx_posts_contenu_fts ON posts USING gin(to_tsvector('french', contenu));
CREATE INDEX idx_post_stage_entreprise_fts ON post_stage USING gin(to_tsvector('french', entreprise));
CREATE INDEX idx_post_emploi_poste_fts ON post_emploi USING gin(to_tsvector('french', poste));

-- ============================================================================
-- 13. TRIGGERS POUR COMPTEURS AUTOMATIQUES
-- ============================================================================

-- 13.1 Triggers pour likes
CREATE OR REPLACE FUNCTION increment_likes() RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts SET nb_likes = nb_likes + 1 WHERE id = NEW.post_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_likes
AFTER INSERT ON likes
FOR EACH ROW
EXECUTE FUNCTION increment_likes();

CREATE OR REPLACE FUNCTION decrement_likes() RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts SET nb_likes = nb_likes - 1 WHERE id = OLD.post_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_decrement_likes
AFTER DELETE ON likes
FOR EACH ROW
EXECUTE FUNCTION decrement_likes();

-- 13.2 Triggers pour commentaires
CREATE OR REPLACE FUNCTION increment_commentaires() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.supprime = 0 THEN
        UPDATE posts SET nb_commentaires = nb_commentaires + 1 WHERE id = NEW.post_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_commentaires
AFTER INSERT ON commentaires
FOR EACH ROW
EXECUTE FUNCTION increment_commentaires();

CREATE OR REPLACE FUNCTION handle_commentaire_suppression() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.supprime = 1 AND OLD.supprime = 0 THEN
        UPDATE posts SET nb_commentaires = nb_commentaires - 1 WHERE id = NEW.post_id;
    ELSIF NEW.supprime = 0 AND OLD.supprime = 1 THEN
        UPDATE posts SET nb_commentaires = nb_commentaires + 1 WHERE id = NEW.post_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_handle_commentaire_suppression
AFTER UPDATE ON commentaires
FOR EACH ROW
EXECUTE FUNCTION handle_commentaire_suppression();

-- 13.3 Triggers pour partages
CREATE OR REPLACE FUNCTION increment_partages() RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts SET nb_partages = nb_partages + 1 WHERE id = NEW.post_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_partages
AFTER INSERT ON partages
FOR EACH ROW
EXECUTE FUNCTION increment_partages();

CREATE OR REPLACE FUNCTION decrement_partages() RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts SET nb_partages = nb_partages - 1 WHERE id = OLD.post_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_decrement_partages
AFTER DELETE ON partages
FOR EACH ROW
EXECUTE FUNCTION decrement_partages();

-- 13.4 Trigger pour copier places_restantes depuis nombre_places
CREATE OR REPLACE FUNCTION init_places_restantes() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.places_restantes IS NULL AND NEW.nombre_places IS NOT NULL THEN
        NEW.places_restantes := NEW.nombre_places;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_init_places_restantes
BEFORE INSERT ON post_activite
FOR EACH ROW
EXECUTE FUNCTION init_places_restantes();

-- ============================================================================
-- 14. VUES SQL POUR FACILITER LES REQUÊTES
-- ============================================================================

-- 14.1 Vue des posts complets avec toutes les informations
CREATE OR REPLACE VIEW v_posts_complets AS
SELECT 
    p.*,
    u.nomuser,
    u.prenom,
    u.photo as photo_auteur,
    tp.libelle as type_libelle,
    tp.code as type_code,
    tp.icon as type_icon,
    tp.couleur as type_couleur,
    sp.libelle as statut_libelle,
    sp.code as statut_code,
    vp.libelle as visibilite_libelle,
    vp.code as visibilite_code,
    g.nom as groupe_nom,
    (SELECT COUNT(*) FROM likes WHERE post_id = p.id) as nb_likes_reel,
    (SELECT COUNT(*) FROM commentaires WHERE post_id = p.id AND supprime = 0) as nb_commentaires_reel,
    (SELECT COUNT(*) FROM partages WHERE post_id = p.id) as nb_partages_reel,
    (SELECT COUNT(*) FROM post_fichiers WHERE post_id = p.id) as nb_fichiers
FROM posts p
LEFT JOIN utilisateur u ON u.refuser = p.idutilisateur
LEFT JOIN type_publication tp ON tp.id = p.idtypepublication
LEFT JOIN statut_publication sp ON sp.id = p.idstatutpublication
LEFT JOIN visibilite_publication vp ON vp.id = p.idvisibilite
LEFT JOIN groupes g ON g.id = p.idgroupe
WHERE p.supprime = 0;

-- 14.2 Vue des statistiques par type de publication
CREATE OR REPLACE VIEW v_statistiques_posts AS
SELECT 
    tp.libelle as type,
    sp.libelle as statut,
    COUNT(*) as nb_posts,
    SUM(p.nb_likes) as total_likes,
    SUM(p.nb_commentaires) as total_commentaires,
    SUM(p.nb_partages) as total_partages,
    COALESCE(AVG(p.nb_likes), 0) as moyenne_likes,
    MAX(p.created_at) as dernier_post
FROM posts p
INNER JOIN type_publication tp ON tp.id = p.idtypepublication
INNER JOIN statut_publication sp ON sp.id = p.idstatutpublication
WHERE p.supprime = 0
GROUP BY tp.libelle, sp.libelle
ORDER BY nb_posts DESC;

-- 14.3 Vue des top contributeurs
CREATE OR REPLACE VIEW v_top_contributeurs AS
SELECT 
    u.refuser,
    u.nomuser,
    u.prenom,
    u.photo,
    COUNT(DISTINCT p.id) as nb_posts,
    COUNT(DISTINCT c.id) as nb_commentaires,
    COALESCE(SUM(p.nb_likes), 0) as total_likes_recus,
    MAX(p.created_at) as dernier_post
FROM utilisateur u
LEFT JOIN posts p ON p.idutilisateur = u.refuser AND p.supprime = 0
LEFT JOIN commentaires c ON c.idutilisateur = u.refuser AND c.supprime = 0
GROUP BY u.refuser
HAVING COUNT(DISTINCT p.id) > 0 OR COUNT(DISTINCT c.id) > 0
ORDER BY (COUNT(DISTINCT p.id) * 10 + COUNT(DISTINCT c.id) + COALESCE(SUM(p.nb_likes), 0)) DESC;

-- ============================================================================
-- 15. DONNÉES INITIALES POUR LES RÉFÉRENTIELS
-- ============================================================================

-- 15.1 Types de publication
INSERT INTO type_publication (id, libelle, code, icon, couleur, actif, ordre) VALUES
('TYP00001', 'Stage', 'stage', 'fa-briefcase', '#3498db', 1, 1),
('TYP00002', 'Emploi', 'emploi', 'fa-suitcase', '#2ecc71', 1, 2),
('TYP00003', 'Activité', 'activite', 'fa-calendar', '#e74c3c', 1, 3),
('TYP00004', 'Projet', 'projet', 'fa-rocket', '#9b59b6', 1, 4),
('TYP00005', 'Discussion', 'discussion', 'fa-comments', '#34495e', 1, 5);

-- Mettre à jour la séquence
SELECT setval('seq_type_publication', 5, true);

-- 15.2 Statuts de publication
INSERT INTO statut_publication (id, libelle, code, icon, couleur, ordre) VALUES
('STAT00001', 'Brouillon', 'brouillon', 'fa-pencil', '#95a5a6', 1),
('STAT00002', 'Publié', 'publie', 'fa-check-circle', '#27ae60', 2),
('STAT00003', 'En modération', 'moderation', 'fa-clock-o', '#f39c12', 3),
('STAT00004', 'Archivé', 'archive', 'fa-archive', '#7f8c8d', 4),
('STAT00005', 'Supprimé', 'supprime', 'fa-trash', '#e74c3c', 5),
('STAT00006', 'Expiré', 'expire', 'fa-calendar-times-o', '#e67e22', 6);

SELECT setval('seq_statut_publication', 6, true);

-- 15.3 Visibilité de publication
INSERT INTO visibilite_publication (id, libelle, code, icon, couleur, ordre) VALUES
('VISI00001', 'Public', 'public', 'fa-globe', '#3498db', 1),
('VISI00002', 'Groupe', 'groupe', 'fa-users', '#9b59b6', 2),
('VISI00003', 'Privé', 'prive', 'fa-lock', '#e74c3c', 3),
('VISI00004', 'Promotion', 'promotion', 'fa-graduation-cap', '#f39c12', 4);

SELECT setval('seq_visibilite_publication', 4, true);

-- 15.4 Types de fichier
INSERT INTO type_fichier (id, libelle, code, icon, couleur, extensions_acceptees, taille_max_mo, ordre) VALUES
('TFIC00001', 'Image', 'image', 'fa-image', '#3498db', 'jpg,jpeg,png,gif,webp', 5, 1),
('TFIC00002', 'Document', 'document', 'fa-file-pdf-o', '#e74c3c', 'pdf,doc,docx,xls,xlsx,ppt,pptx', 10, 2),
('TFIC00003', 'Vidéo', 'video', 'fa-video-camera', '#9b59b6', 'mp4,avi,mov,wmv', 50, 3),
('TFIC00004', 'Lien', 'lien', 'fa-link', '#1abc9c', '', 0, 4);

SELECT setval('seq_type_fichier', 4, true);

-- 15.5 Types de notification
INSERT INTO type_notification (id, libelle, code, icon, couleur, template_message, ordre) VALUES
('TNOT00001', 'Like', 'like', 'fa-heart', '#e74c3c', '{user} a aimé votre publication', 1),
('TNOT00002', 'Commentaire', 'commentaire', 'fa-comment', '#3498db', '{user} a commenté votre publication', 2),
('TNOT00003', 'Partage', 'partage', 'fa-share', '#2ecc71', '{user} a partagé votre publication', 3),
('TNOT00004', 'Mention', 'mention', 'fa-at', '#f39c12', '{user} vous a mentionné dans un commentaire', 4),
('TNOT00005', 'Invitation groupe', 'invitation_groupe', 'fa-user-plus', '#9b59b6', '{user} vous a invité à rejoindre {groupe}', 5),
('TNOT00006', 'Nouveau post groupe', 'nouveau_post_groupe', 'fa-bell', '#1abc9c', 'Nouvelle publication dans {groupe}', 6),
('TNOT00007', 'Réponse commentaire', 'reponse_commentaire', 'fa-reply', '#34495e', '{user} a répondu à votre commentaire', 7);

SELECT setval('seq_type_notification', 7, true);

-- 15.6 Motifs de signalement
INSERT INTO motif_signalement (id, libelle, code, icon, couleur, gravite, action_automatique, ordre) VALUES
('MSIG00001', 'Spam', 'spam', 'fa-ban', '#e74c3c', 2, 'masquer_si_3_signalements', 1),
('MSIG00002', 'Contenu inapproprié', 'inapproprie', 'fa-exclamation-triangle', '#f39c12', 3, 'moderation_immediate', 2),
('MSIG00003', 'Harcèlement', 'harcelement', 'fa-user-times', '#c0392b', 5, 'blocage_temporaire', 3),
('MSIG00004', 'Fausse information', 'fausse_information', 'fa-info-circle', '#3498db', 2, 'ajouter_avertissement', 4),
('MSIG00005', 'Violation des règles', 'violation_regles', 'fa-gavel', '#9b59b6', 4, 'moderation_immediate', 5),
('MSIG00006', 'Autre', 'autre', 'fa-question-circle', '#95a5a6', 1, 'revue_manuelle', 6);

SELECT setval('seq_motif_signalement', 6, true);

-- 15.7 Statuts de signalement
INSERT INTO statut_signalement (id, libelle, code, icon, couleur, ordre) VALUES
('SSIG00001', 'En attente', 'en_attente', 'fa-clock-o', '#f39c12', 1),
('SSIG00002', 'En cours', 'en_cours', 'fa-spinner', '#3498db', 2),
('SSIG00003', 'Traité', 'traite', 'fa-check', '#27ae60', 3),
('SSIG00004', 'Rejeté', 'rejete', 'fa-times', '#95a5a6', 4),
('SSIG00005', 'Validé', 'valide', 'fa-check-circle', '#2ecc71', 5);

SELECT setval('seq_statut_signalement', 5, true);

-- 15.8 Rôles dans les groupes
INSERT INTO role_groupe (id, libelle, code, icon, couleur, permissions, niveau_acces, ordre) VALUES
('ROLE00001', 'Admin', 'admin', 'fa-crown', '#f39c12', '["all"]', 3, 1),
('ROLE00002', 'Modérateur', 'moderateur', 'fa-shield', '#3498db', '["moderate","post","comment","delete_others"]', 2, 2),
('ROLE00003', 'Membre', 'membre', 'fa-user', '#95a5a6', '["post","comment","like"]', 1, 3);

SELECT setval('seq_role_groupe', 3, true);

-- 15.9 Topics initiaux
INSERT INTO topics (id, nom, description, icon, couleur) VALUES
-- Domaines d'études
('TOP00001', 'Informatique', 'Technologies de l''information', 'fa-laptop', '#3498db'),
('TOP00002', 'Génie Civil', 'Bâtiment et travaux publics', 'fa-building', '#e67e22'),
('TOP00003', 'Télécommunications', 'Réseaux et communications', 'fa-wifi', '#9b59b6'),
('TOP00004', 'Électronique', 'Systèmes électroniques', 'fa-microchip', '#16a085'),
('TOP00005', 'Management', 'Gestion et administration', 'fa-briefcase', '#2c3e50'),

-- Types d'opportunités
('TOP00010', 'Stage', 'Offres de stage', 'fa-briefcase', '#2ecc71'),
('TOP00011', 'Emploi CDI', 'Emplois à durée indéterminée', 'fa-suitcase', '#27ae60'),
('TOP00012', 'Freelance', 'Missions indépendantes', 'fa-rocket', '#f39c12'),
('TOP00013', 'Alternance', 'Contrats en alternance', 'fa-graduation-cap', '#3498db'),

-- Thématiques
('TOP00020', 'Entrepreneuriat', 'Création d''entreprise', 'fa-lightbulb-o', '#e74c3c'),
('TOP00021', 'Startups', 'Culture startup', 'fa-rocket', '#e74c3c'),
('TOP00022', 'Événements', 'Conférences, ateliers', 'fa-calendar', '#1abc9c'),
('TOP00023', 'Formation', 'Formations et certifications', 'fa-book', '#9b59b6'),
('TOP00024', 'Networking', 'Réseautage professionnel', 'fa-users', '#34495e'),
('TOP00025', 'Innovation', 'Innovation et R&D', 'fa-flask', '#e67e22');

SELECT setval('seq_topics', 25, true);

-- ============================================================================
-- 16. COMMENTAIRES ET DOCUMENTATION
-- ============================================================================

COMMENT ON TABLE posts IS 'Table principale des publications alumni';
COMMENT ON TABLE post_stage IS 'Détails spécifiques pour les offres de stage';
COMMENT ON TABLE post_emploi IS 'Détails spécifiques pour les offres d''emploi';
COMMENT ON TABLE post_activite IS 'Détails spécifiques pour les activités/événements';
COMMENT ON TABLE likes IS 'Likes sur les publications';
COMMENT ON TABLE commentaires IS 'Commentaires avec support de réponses (parent_id)';
COMMENT ON TABLE partages IS 'Partages de publications avec commentaire optionnel';
COMMENT ON TABLE groupes IS 'Groupes d''utilisateurs (promotion, intérêts, etc.)';
COMMENT ON TABLE groupe_membres IS 'Membres des groupes avec rôles';
COMMENT ON TABLE topics IS 'Tags/centres d''intérêt pour classifier les publications';
COMMENT ON TABLE utilisateur_interets IS 'Centres d''intérêt sélectionnés par les utilisateurs';
COMMENT ON TABLE post_topics IS 'Association publications <-> topics pour filtrage/recommandations';
COMMENT ON TABLE notifications IS 'Notifications pour interactions (like, commentaire, etc.)';
COMMENT ON TABLE signalements IS 'Signalements de contenu inapproprié par les utilisateurs';
COMMENT ON TABLE post_fichiers IS 'Fichiers joints aux publications (images, documents, etc.)';

-- ============================================================================
-- FIN DU SCRIPT
-- ============================================================================

-- Vérification des tables créées
SELECT 'Script exécuté avec succès - ' || COUNT(*) || ' tables créées' 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN (
    'type_publication', 'statut_publication', 'visibilite_publication', 
    'type_fichier', 'type_notification', 'motif_signalement', 
    'statut_signalement', 'role_groupe', 'posts', 'post_stage', 
    'post_emploi', 'post_activite', 'likes', 'commentaires', 
    'partages', 'groupes', 'groupe_membres', 'topics', 
    'utilisateur_interets', 'post_topics', 'notifications', 
    'signalements', 'post_fichiers'
);
