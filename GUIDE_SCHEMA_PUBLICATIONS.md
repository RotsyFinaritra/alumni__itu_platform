# Guide du Schéma de Base de Données - Plateforme Publications Alumni

**Version:** 1.0  
**Date:** 24 février 2026  
**Projet:** Plateforme Alumni ITU - Module Publications

---

## Table des matières

1. [Vue d'ensemble](#vue-densemble)
2. [Tables de référentiel](#tables-de-référentiel)
3. [Tables principales](#tables-principales)
4. [Tables de détails spécifiques](#tables-de-détails-spécifiques)
5. [Tables d'interactions](#tables-dinteractions)
6. [Tables de groupes](#tables-de-groupes)
7. [Tables de centres d'intérêt](#tables-de-centres-dintérêt)
8. [Tables de notifications](#tables-de-notifications)
9. [Tables de modération](#tables-de-modération)
10. [Vues SQL recommandées](#vues-sql-recommandées)
11. [Index et performances](#index-et-performances)
12. [Exemples de requêtes](#exemples-de-requêtes)
13. [Bonnes pratiques](#bonnes-pratiques)

---

## 1. Vue d'ensemble

### Architecture générale

Le système de publications est conçu autour d'une **architecture modulaire** permettant de gérer différents types de contenus (stages, emplois, activités) avec des métadonnées spécifiques.

```
┌─────────────────────────────────────────────────────────┐
│                    RÉFÉRENTIELS                         │
│  (type_publication, statut_publication, topics, etc.)   │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                  TABLE PRINCIPALE                       │
│                      posts                              │
└─────────────────────────────────────────────────────────┘
            │                    │                    │
            ▼                    ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│ post_stage   │    │ post_emploi  │    │ post_activite│
└──────────────┘    └──────────────┘    └──────────────┘
                            │
            ┌───────────────┴───────────────┐
            ▼                               ▼
┌─────────────────────┐        ┌─────────────────────┐
│   INTERACTIONS      │        │     MÉDIAS          │
│ (likes, comments,   │        │  (post_fichiers)    │
│     partages)       │        │                     │
└─────────────────────┘        └─────────────────────┘
```

### Principes de conception

1. **Tables de référentiel** : Toutes les énumérations sont des tables pour flexibilité
2. **Soft delete** : Champ `supprime` au lieu de DELETE physique
3. **Compteurs dénormalisés** : `nb_likes`, `nb_commentaires` pour performance
4. **Audit trail** : `created_at`, `edited_at`, `edited_by` partout
5. **Intégration existante** : Référence à `utilisateur_acade.refuser`

---

## 2. Tables de référentiel

Les tables de référentiel définissent les **métadonnées configurables** sans modification de code.

### 2.1 `type_publication`

Définit les types de publications possibles (stage, emploi, activité, etc.).

**Structure :**
```sql
CREATE TABLE type_publication (
  id VARCHAR(50) PRIMARY KEY,              -- 'TYP00001'
  libelle VARCHAR(100) NOT NULL,           -- "Stage en entreprise"
  code VARCHAR(50) UNIQUE NOT NULL,        -- "stage"
  icon VARCHAR(50),                        -- "fa-briefcase"
  couleur VARCHAR(20),                     -- "#3498db"
  description TEXT,
  actif BOOLEAN DEFAULT true,
  ordre INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Données initiales :**
```sql
INSERT INTO type_publication (id, libelle, code, icon, couleur, actif, ordre) VALUES
('TYP00001', 'Stage', 'stage', 'fa-briefcase', '#3498db', true, 1),
('TYP00002', 'Emploi', 'emploi', 'fa-suitcase', '#2ecc71', true, 2),
('TYP00003', 'Activité', 'activite', 'fa-calendar', '#e74c3c', true, 3),
('TYP00004', 'Projet', 'projet', 'fa-rocket', '#9b59b6', true, 4),
('TYP00005', 'Discussion', 'discussion', 'fa-comments', '#34495e', true, 5);
```

**Cas d'usage :**
```java
// Récupérer tous les types actifs
TypePublication filtre = new TypePublication();
filtre.setActif(true);
Object[] types = CGenUtil.rechercher(filtre, null, null, " AND actif = true ORDER BY ordre");

// Affichage dynamique
for (Object o : types) {
    TypePublication t = (TypePublication) o;
    out.println("<option value='" + t.getId() + "' style='color:" + t.getCouleur() + "'>");
    out.println("  <i class='" + t.getIcon() + "'></i> " + t.getLibelle());
    out.println("</option>");
}
```

---

### 2.2 `statut_publication`

Gère le cycle de vie des publications (brouillon → publié → archivé).

**Structure :**
```sql
CREATE TABLE statut_publication (
  id VARCHAR(50) PRIMARY KEY,
  libelle VARCHAR(100) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  icon VARCHAR(50),
  couleur VARCHAR(20),
  description TEXT,
  actif BOOLEAN DEFAULT true,
  ordre INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Données initiales :**
```sql
INSERT INTO statut_publication (id, libelle, code, icon, couleur, ordre) VALUES
('STAT00001', 'Brouillon', 'brouillon', 'fa-pencil', '#95a5a6', 1),
('STAT00002', 'Publié', 'publie', 'fa-check-circle', '#27ae60', 2),
('STAT00003', 'En modération', 'moderation', 'fa-clock-o', '#f39c12', 3),
('STAT00004', 'Archivé', 'archive', 'fa-archive', '#7f8c8d', 4),
('STAT00005', 'Supprimé', 'supprime', 'fa-trash', '#e74c3c', 5),
('STAT00006', 'Expiré', 'expire', 'fa-calendar-times-o', '#e67e22', 6);
```

**Workflow recommandé :**
```
Brouillon → Publié → Archivé
              ↓
         Modération → Publié / Supprimé
              ↓
        Expiré (automatique si date_limite dépassée)
```

---

### 2.3 `visibilite_publication`

Contrôle qui peut voir une publication.

**Structure :**
```sql
CREATE TABLE visibilite_publication (
  id VARCHAR(50) PRIMARY KEY,
  libelle VARCHAR(100) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  icon VARCHAR(50),
  couleur VARCHAR(20),
  description TEXT,
  actif BOOLEAN DEFAULT true,
  ordre INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Données initiales :**
```sql
INSERT INTO visibilite_publication (id, libelle, code, icon, couleur, ordre) VALUES
('VISI00001', 'Public', 'public', 'fa-globe', '#3498db', 1),
('VISI00002', 'Groupe', 'groupe', 'fa-users', '#9b59b6', 2),
('VISI00003', 'Privé', 'prive', 'fa-lock', '#e74c3c', 3),
('VISI00004', 'Promotion', 'promotion', 'fa-graduation-cap', '#f39c12', 4);
```

**Logique de filtrage :**
```java
// Afficher les posts visibles pour un utilisateur
public Object[] getPostsVisibles(int idutilisateur) throws Exception {
    String awhere = " AND (";
    awhere += "    idvisibilite = 'VISI00001'";  // Public
    awhere += " OR idutilisateur = " + idutilisateur;  // Ses propres posts
    awhere += " OR (idvisibilite = 'VISI00002' AND idgroupe IN (";
    awhere += "      SELECT idgroupe FROM groupe_membres WHERE idutilisateur = " + idutilisateur;
    awhere += "    ))";  // Posts de ses groupes
    awhere += ")";
    return CGenUtil.rechercher(new Post(), null, null, awhere);
}
```

---

### 2.4 `type_fichier`

Définit les types de fichiers autorisés en upload.

**Structure :**
```sql
CREATE TABLE type_fichier (
  id VARCHAR(50) PRIMARY KEY,
  libelle VARCHAR(100) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  icon VARCHAR(50),
  couleur VARCHAR(20),
  extensions_acceptees VARCHAR(200),        -- "jpg,png,gif,webp"
  taille_max_mo INTEGER,                    -- Taille maximale en Mo
  description TEXT,
  actif BOOLEAN DEFAULT true,
  ordre INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Données initiales :**
```sql
INSERT INTO type_fichier (id, libelle, code, icon, couleur, extensions_acceptees, taille_max_mo, ordre) VALUES
('TFIC00001', 'Image', 'image', 'fa-image', '#3498db', 'jpg,jpeg,png,gif,webp', 5, 1),
('TFIC00002', 'Document', 'document', 'fa-file-pdf-o', '#e74c3c', 'pdf,doc,docx,xls,xlsx,ppt,pptx', 10, 2),
('TFIC00003', 'Vidéo', 'video', 'fa-video-camera', '#9b59b6', 'mp4,avi,mov,wmv', 50, 3),
('TFIC00004', 'Lien', 'lien', 'fa-link', '#1abc9c', '', 0, 4);
```

**Validation d'upload :**
```java
public boolean validerFichier(Part filePart, String idTypeFichier) throws Exception {
    TypeFichier type = (TypeFichier) CGenUtil.rechercher(
        new TypeFichier(), null, null, " AND id = '" + idTypeFichier + "'"
    )[0];
    
    // Vérifier extension
    String fileName = getFileName(filePart);
    String extension = fileName.substring(fileName.lastIndexOf(".") + 1);
    String[] extensionsAutorisees = type.getExtensions_acceptees().split(",");
    
    if (!Arrays.asList(extensionsAutorisees).contains(extension.toLowerCase())) {
        throw new Exception("Extension ." + extension + " non autorisée");
    }
    
    // Vérifier taille
    long tailleMaxBytes = (long) type.getTaille_max_mo() * 1024 * 1024;
    if (filePart.getSize() > tailleMaxBytes) {
        throw new Exception("Fichier trop volumineux (max " + type.getTaille_max_mo() + " Mo)");
    }
    
    return true;
}
```

---

### 2.5 `type_notification`

Définit les types de notifications envoyées aux utilisateurs.

**Structure :**
```sql
CREATE TABLE type_notification (
  id VARCHAR(50) PRIMARY KEY,
  libelle VARCHAR(100) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  icon VARCHAR(50),
  couleur VARCHAR(20),
  template_message TEXT,                    -- Template avec variables {user}, {post}...
  description TEXT,
  actif BOOLEAN DEFAULT true,
  ordre INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Données initiales :**
```sql
INSERT INTO type_notification (id, libelle, code, icon, couleur, template_message, ordre) VALUES
('TNOT00001', 'Like', 'like', 'fa-heart', '#e74c3c', '{user} a aimé votre publication', 1),
('TNOT00002', 'Commentaire', 'commentaire', 'fa-comment', '#3498db', '{user} a commenté votre publication', 2),
('TNOT00003', 'Partage', 'partage', 'fa-share', '#2ecc71', '{user} a partagé votre publication', 3),
('TNOT00004', 'Mention', 'mention', 'fa-at', '#f39c12', '{user} vous a mentionné dans un commentaire', 4),
('TNOT00005', 'Invitation groupe', 'invitation_groupe', 'fa-user-plus', '#9b59b6', '{user} vous a invité à rejoindre {groupe}', 5),
('TNOT00006', 'Nouveau post groupe', 'nouveau_post_groupe', 'fa-bell', '#1abc9c', 'Nouvelle publication dans {groupe}', 6),
('TNOT00007', 'Réponse commentaire', 'reponse_commentaire', 'fa-reply', '#34495e', '{user} a répondu à votre commentaire', 7);
```

**Génération de notification :**
```java
public void notifierLike(int idUtilisateurEmetteur, String postId) throws Exception {
    Post post = (Post) CGenUtil.rechercher(new Post(), null, null, " AND id = '" + postId + "'")[0];
    TypeNotification typeNotif = getTypeNotificationByCode("like");
    
    Notification notif = new Notification();
    notif.construirePK(conn);
    notif.setIdutilisateur(post.getIdutilisateur());  // Destinataire = auteur du post
    notif.setEmetteur_id(idUtilisateurEmetteur);
    notif.setIdtypenotification(typeNotif.getId());
    notif.setPost_id(postId);
    notif.setVu(false);
    
    // Générer le message depuis le template
    String message = typeNotif.getTemplate_message();
    message = message.replace("{user}", getNomUtilisateur(idUtilisateurEmetteur));
    notif.setContenu(message);
    
    CGenUtil.save(notif);
}
```

---

### 2.6 `motif_signalement`

Catégories de signalements de contenu inapproprié.

**Structure :**
```sql
CREATE TABLE motif_signalement (
  id VARCHAR(50) PRIMARY KEY,
  libelle VARCHAR(100) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  icon VARCHAR(50),
  couleur VARCHAR(20),
  gravite INTEGER,                          -- 1 (faible) à 5 (critique)
  action_automatique VARCHAR(100),          -- Action déclenchée automatiquement
  description TEXT,
  actif BOOLEAN DEFAULT true,
  ordre INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Données initiales :**
```sql
INSERT INTO motif_signalement (id, libelle, code, icon, couleur, gravite, action_automatique, ordre) VALUES
('MSIG00001', 'Spam', 'spam', 'fa-ban', '#e74c3c', 2, 'masquer_si_3_signalements', 1),
('MSIG00002', 'Contenu inapproprié', 'inapproprie', 'fa-exclamation-triangle', '#f39c12', 3, 'moderation_immediate', 2),
('MSIG00003', 'Harcèlement', 'harcelement', 'fa-user-times', '#c0392b', 5, 'blocage_temporaire', 3),
('MSIG00004', 'Fausse information', 'fausse_information', 'fa-info-circle', '#3498db', 2, 'ajouter_avertissement', 4),
('MSIG00005', 'Violation des règles', 'violation_regles', 'fa-gavel', '#9b59b6', 4, 'moderation_immediate', 5),
('MSIG00006', 'Autre', 'autre', 'fa-question-circle', '#95a5a6', 1, 'revue_manuelle', 6);
```

**Actions automatiques :**
```java
public void traiterSignalementAutomatique(String idSignalement) throws Exception {
    Signalement sig = getSignalement(idSignalement);
    MotifSignalement motif = getMotifSignalement(sig.getIdmotifsignalement());
    
    switch (motif.getAction_automatique()) {
        case "masquer_si_3_signalements":
            int nbSignalements = compterSignalements(sig.getPost_id());
            if (nbSignalements >= 3) {
                masquerPost(sig.getPost_id());
            }
            break;
            
        case "moderation_immediate":
            changerStatutPost(sig.getPost_id(), "STAT00003"); // En modération
            notifierModerateurs(sig);
            break;
            
        case "blocage_temporaire":
            bloquerUtilisateur(sig.getPost_id(), 24); // 24h
            notifierModerateurs(sig);
            break;
            
        case "revue_manuelle":
            // Rien d'automatique, juste notifier
            notifierModerateurs(sig);
            break;
    }
}
```

---

### 2.7 `statut_signalement`

États du traitement d'un signalement.

**Structure :**
```sql
CREATE TABLE statut_signalement (
  id VARCHAR(50) PRIMARY KEY,
  libelle VARCHAR(100) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  icon VARCHAR(50),
  couleur VARCHAR(20),
  description TEXT,
  actif BOOLEAN DEFAULT true,
  ordre INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Données initiales :**
```sql
INSERT INTO statut_signalement (id, libelle, code, icon, couleur, ordre) VALUES
('SSIG00001', 'En attente', 'en_attente', 'fa-clock-o', '#f39c12', 1),
('SSIG00002', 'En cours', 'en_cours', 'fa-spinner', '#3498db', 2),
('SSIG00003', 'Traité', 'traite', 'fa-check', '#27ae60', 3),
('SSIG00004', 'Rejeté', 'rejete', 'fa-times', '#95a5a6', 4),
('SSIG00005', 'Validé', 'valide', 'fa-check-circle', '#2ecc71', 5);
```

---

### 2.8 `role_groupe`

Rôles et permissions dans les groupes.

**Structure :**
```sql
CREATE TABLE role_groupe (
  id VARCHAR(50) PRIMARY KEY,
  libelle VARCHAR(100) NOT NULL,
  code VARCHAR(50) UNIQUE NOT NULL,
  icon VARCHAR(50),
  couleur VARCHAR(20),
  permissions TEXT,                         -- JSON des permissions
  niveau_acces INTEGER,                     -- 1 (membre) à 3 (admin)
  description TEXT,
  actif BOOLEAN DEFAULT true,
  ordre INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Données initiales :**
```sql
INSERT INTO role_groupe (id, libelle, code, icon, couleur, permissions, niveau_acces, ordre) VALUES
('ROLE00001', 'Admin', 'admin', 'fa-crown', '#f39c12', '["all"]', 3, 1),
('ROLE00002', 'Modérateur', 'moderateur', 'fa-shield', '#3498db', '["moderate","post","comment","delete_others"]', 2, 2),
('ROLE00003', 'Membre', 'membre', 'fa-user', '#95a5a6', '["post","comment","like"]', 1, 3);
```

**Vérification de permission :**
```java
public boolean aPermission(int idUtilisateur, String idGroupe, String permission) throws Exception {
    GroupeMembre[] membres = (GroupeMembre[]) CGenUtil.rechercher(
        new GroupeMembre(), null, null,
        " AND idutilisateur = " + idUtilisateur + " AND idgroupe = '" + idGroupe + "'"
    );
    
    if (membres.length == 0) return false;
    
    RoleGroupe role = getRoleGroupe(membres[0].getIdrole());
    
    // Admin a toutes les permissions
    if ("admin".equals(role.getCode())) return true;
    
    // Parser les permissions JSON
    JSONArray perms = new JSONArray(role.getPermissions());
    for (int i = 0; i < perms.length(); i++) {
        if (perms.getString(i).equals(permission)) return true;
    }
    
    return false;
}
```

---

### 2.9 `topics`

Centres d'intérêt / Tags pour les publications.

**Structure :**
```sql
CREATE TABLE topics (
  id VARCHAR(50) PRIMARY KEY,
  nom VARCHAR(100) NOT NULL,
  description TEXT,
  icon VARCHAR(50),
  couleur VARCHAR(20),
  actif BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Exemples de topics :**
```sql
INSERT INTO topics (id, nom, description, icon, couleur) VALUES
-- Domaines d'études
('TOP00001', 'Informatique', 'Technologies de l''information', 'fa-laptop', '#3498db'),
('TOP00002', 'Génie Civil', 'Bâtiment et travaux publics', 'fa-building', '#e67e22'),
('TOP00003', 'Télécommunications', 'Réseaux et communications', 'fa-wifi', '#9b59b6'),

-- Types d'opportunités
('TOP00010', 'Stage', 'Offres de stage', 'fa-briefcase', '#2ecc71'),
('TOP00011', 'Emploi CDI', 'Emplois à durée indéterminée', 'fa-suitcase', '#27ae60'),
('TOP00012', 'Freelance', 'Missions indépendantes', 'fa-rocket', '#f39c12'),

-- Thématiques
('TOP00020', 'Entrepreneuriat', 'Création d''entreprise', 'fa-lightbulb-o', '#e74c3c'),
('TOP00021', 'Startups', 'Culture startup', 'fa-rocket', '#e74c3c'),
('TOP00022', 'Événements', 'Conférences, ateliers', 'fa-calendar', '#1abc9c');
```

---

## 3. Tables principales

### 3.1 `posts`

Table centrale contenant toutes les publications.

**Structure complète :**
```sql
CREATE TABLE posts (
  id VARCHAR(50) PRIMARY KEY,
  idutilisateur INTEGER NOT NULL REFERENCES utilisateur_acade(refuser),
  idgroupe VARCHAR(50) REFERENCES groupes(id),
  idtypepublication VARCHAR(50) NOT NULL REFERENCES type_publication(id),
  idstatutpublication VARCHAR(50) NOT NULL REFERENCES statut_publication(id),
  idvisibilite VARCHAR(50) NOT NULL REFERENCES visibilite_publication(id),
  contenu TEXT NOT NULL,
  epingle BOOLEAN DEFAULT false,
  supprime BOOLEAN DEFAULT false,
  date_suppression TIMESTAMP,
  nb_likes INTEGER DEFAULT 0,
  nb_commentaires INTEGER DEFAULT 0,
  nb_partages INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  edited_at TIMESTAMP,
  edited_by INTEGER REFERENCES utilisateur_acade(refuser)
);

CREATE INDEX idx_posts_user_date ON posts(idutilisateur, created_at);
CREATE INDEX idx_posts_type_date ON posts(idtypepublication, created_at);
CREATE INDEX idx_posts_statut_date ON posts(idstatutpublication, created_at);
CREATE INDEX idx_posts_visibilite ON posts(idvisibilite, created_at);
CREATE INDEX idx_posts_date ON posts(created_at DESC);
```

**Séquence pour PK :**
```sql
CREATE SEQUENCE seq_posts START WITH 1;

CREATE OR REPLACE FUNCTION getseqposts() RETURNS VARCHAR AS $$
DECLARE
    next_val INTEGER;
BEGIN
    next_val := nextval('seq_posts');
    RETURN 'POST' || LPAD(next_val::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;
```

**Classe Java Bean :**
```java
package bean;

import java.sql.Connection;
import java.sql.Timestamp;

public class Post extends ClassMAPTable {
    private String id;
    private int idutilisateur;
    private String idgroupe;
    private String idtypepublication;
    private String idstatutpublication;
    private String idvisibilite;
    private String contenu;
    private boolean epingle;
    private boolean supprime;
    private Timestamp date_suppression;
    private int nb_likes;
    private int nb_commentaires;
    private int nb_partages;
    private Timestamp created_at;
    private Timestamp edited_at;
    private Integer edited_by;
    
    public Post() {
        super.setNomTable("posts");
    }
    
    @Override
    public String getTuppleID() { return this.id; }
    
    @Override
    public String getAttributIDName() { return "id"; }
    
    public void construirePK(Connection c) throws Exception {
        super.setNomTable("posts");
        this.preparePk("POST", "getseqposts");
        this.setId(makePK(c));
    }
    
    // Getters et setters...
}
```

**Exemples d'utilisation :**

1. **Créer une publication :**
```java
Post post = new Post();
post.construirePK(conn);
post.setIdutilisateur(currentUser.getRefuser());
post.setIdtypepublication("TYP00001"); // Stage
post.setIdstatutpublication("STAT00002"); // Publié
post.setIdvisibilite("VISI00001"); // Public
post.setContenu("Recherche stagiaire développeur Java...");
post.setEpingle(false);
post.setSupprime(false);

CGenUtil.save(post);
```

2. **Récupérer le fil d'actualité :**
```java
// Posts publics + posts de mes groupes, non supprimés, publiés, triés par date
String awhere = " AND supprime = false";
awhere += " AND idstatutpublication = 'STAT00002'"; // Publié
awhere += " AND (idvisibilite = 'VISI00001'"; // Public
awhere += "  OR idgroupe IN (";
awhere += "    SELECT idgroupe FROM groupe_membres WHERE idutilisateur = " + userId;
awhere += "  ))";
awhere += " ORDER BY epingle DESC, created_at DESC";

Object[] posts = CGenUtil.rechercher(new Post(), null, null, awhere);
```

3. **Soft delete :**
```java
Post post = getPost(postId);
post.setSupprime(true);
post.setDate_suppression(new Timestamp(System.currentTimeMillis()));
CGenUtil.update(post);
```

---

## 4. Tables de détails spécifiques

Chaque type de publication a sa propre table de détails en **relation 1-1** avec `posts`.

### 4.1 `post_stage`

Détails spécifiques pour les offres de stage.

**Structure :**
```sql
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
  convention_requise BOOLEAN DEFAULT false,
  places_disponibles INTEGER,
  contact_email VARCHAR(200),
  contact_tel VARCHAR(50),
  lien_candidature VARCHAR(500)
);
```

**Classe Java :**
```java
public class PostStage extends ClassMAPTable {
    private String post_id;
    private String entreprise;
    private String localisation;
    private String duree;
    private Date date_debut;
    private Date date_fin;
    private BigDecimal indemnite;
    private String niveau_etude_requis;
    private String competences_requises;
    private boolean convention_requise;
    private Integer places_disponibles;
    private String contact_email;
    private String contact_tel;
    private String lien_candidature;
    
    public PostStage() {
        super.setNomTable("post_stage");
    }
    
    @Override
    public String getTuppleID() { return this.post_id; }
    
    @Override
    public String getAttributIDName() { return "post_id"; }
    
    // PAS de construirePK() car la clé = post_id (fournie depuis posts)
}
```

**Création complète stage + post :**
```java
public String creerOffreStage(OffreStageDTO dto, int idUtilisateur) throws Exception {
    Connection conn = new UtilDB().GetConn();
    try {
        conn.setAutoCommit(false);
        
        // 1. Créer le post
        Post post = new Post();
        post.construirePK(conn);
        post.setIdutilisateur(idUtilisateur);
        post.setIdtypepublication("TYP00001"); // Stage
        post.setIdstatutpublication("STAT00002"); // Publié
        post.setIdvisibilite("VISI00001"); // Public
        post.setContenu(dto.getDescription());
        CGenUtil.save(post, conn);
        
        // 2. Créer les détails stage
        PostStage stage = new PostStage();
        stage.setPost_id(post.getId());
        stage.setEntreprise(dto.getEntreprise());
        stage.setLocalisation(dto.getLocalisation());
        stage.setDuree(dto.getDuree());
        stage.setDate_debut(dto.getDateDebut());
        stage.setDate_fin(dto.getDateFin());
        stage.setIndemnite(dto.getIndemnite());
        stage.setNiveau_etude_requis(dto.getNiveauEtude());
        stage.setCompetences_requises(dto.getCompetences());
        stage.setConvention_requise(dto.isConventionRequise());
        stage.setPlaces_disponibles(dto.getPlaces());
        stage.setContact_email(dto.getEmail());
        stage.setContact_tel(dto.getTel());
        stage.setLien_candidature(dto.getLienCandidature());
        CGenUtil.save(stage, conn);
        
        conn.commit();
        return post.getId();
        
    } catch (Exception e) {
        conn.rollback();
        throw e;
    } finally {
        conn.close();
    }
}
```

---

### 4.2 `post_emploi`

Détails spécifiques pour les offres d'emploi.

**Structure :**
```sql
CREATE TABLE post_emploi (
  post_id VARCHAR(50) PRIMARY KEY REFERENCES posts(id) ON DELETE CASCADE,
  entreprise VARCHAR(200) NOT NULL,
  localisation VARCHAR(200),
  poste VARCHAR(200) NOT NULL,
  type_contrat VARCHAR(50),                 -- CDI, CDD, Freelance, Alternance
  salaire_min DECIMAL(10,2),
  salaire_max DECIMAL(10,2),
  devise VARCHAR(10) DEFAULT 'MGA',
  experience_requise VARCHAR(100),
  competences_requises TEXT,
  niveau_etude_requis VARCHAR(100),
  teletravail_possible BOOLEAN DEFAULT false,
  date_limite DATE,
  contact_email VARCHAR(200),
  contact_tel VARCHAR(50),
  lien_candidature VARCHAR(500)
);
```

**Recherche avancée emplois :**
```jsp
<%
String awhere = " AND p.idtypepublication = 'TYP00002'"; // Emploi
awhere += " AND p.supprime = false";
awhere += " AND p.idstatutpublication = 'STAT00002'";

// Filtres
String localisation = request.getParameter("localisation");
if (localisation != null && !localisation.isEmpty()) {
    awhere += " AND pe.localisation ILIKE '%" + localisation + "%'";
}

String typeContrat = request.getParameter("type_contrat");
if (typeContrat != null && !typeContrat.isEmpty()) {
    awhere += " AND pe.type_contrat = '" + typeContrat + "'";
}

String salaireMin = request.getParameter("salaire_min");
if (salaireMin != null && !salaireMin.isEmpty()) {
    awhere += " AND pe.salaire_max >= " + salaireMin;
}

// Requête avec JOIN
String sql = "SELECT p.*, pe.* FROM posts p ";
sql += "INNER JOIN post_emploi pe ON pe.post_id = p.id ";
sql += "WHERE 1=1 " + awhere;
sql += " ORDER BY p.created_at DESC";
// Exécuter avec JDBC ou adapter pour CGenUtil
%>
```

---

### 4.3 `post_activite`

Détails spécifiques pour les activités/événements.

**Structure :**
```sql
CREATE TABLE post_activite (
  post_id VARCHAR(50) PRIMARY KEY REFERENCES posts(id) ON DELETE CASCADE,
  titre VARCHAR(200) NOT NULL,
  categorie VARCHAR(100),                   -- Conférence, Atelier, Meetup, Formation
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
```

**Gestion des inscriptions :**
```java
public boolean inscrireActivite(String postId, int idUtilisateur) throws Exception {
    PostActivite activite = getPostActivite(postId);
    
    // Vérifier places disponibles
    if (activite.getPlaces_restantes() <= 0) {
        throw new Exception("Plus de places disponibles");
    }
    
    // Vérifier date
    if (activite.getDate_debut().before(new Timestamp(System.currentTimeMillis()))) {
        throw new Exception("L'événement est déjà commencé");
    }
    
    // Créer inscription (table à créer : inscriptions_activite)
    InscriptionActivite inscription = new InscriptionActivite();
    inscription.construirePK(conn);
    inscription.setPost_id(postId);
    inscription.setIdutilisateur(idUtilisateur);
    inscription.setDate_inscription(new Timestamp(System.currentTimeMillis()));
    CGenUtil.save(inscription);
    
    // Décrémenter places
    activite.setPlaces_restantes(activite.getPlaces_restantes() - 1);
    CGenUtil.update(activite);
    
    return true;
}
```

---

## 5. Tables d'interactions

### 5.1 `likes`

**Structure :**
```sql
CREATE TABLE likes (
  id VARCHAR(50) PRIMARY KEY,
  idutilisateur INTEGER NOT NULL REFERENCES utilisateur_acade(refuser),
  post_id VARCHAR(50) NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE UNIQUE INDEX unique_user_like_post ON likes(idutilisateur, post_id);
CREATE INDEX idx_likes_post ON likes(post_id);
CREATE INDEX idx_likes_user ON likes(idutilisateur);
```

**Séquence :**
```sql
CREATE SEQUENCE seq_likes START WITH 1;
CREATE OR REPLACE FUNCTION getseqlikes() RETURNS VARCHAR AS $$
BEGIN
    RETURN 'LIKE' || LPAD(nextval('seq_likes')::TEXT, 5, '0');
END;
$$ LANGUAGE plpgsql;
```

**Toggle like (like/unlike) :**
```java
public void toggleLike(int idUtilisateur, String postId) throws Exception {
    Connection conn = new UtilDB().GetConn();
    try {
        conn.setAutoCommit(false);
        
        // Vérifier si déjà liké
        Like filtre = new Like();
        filtre.setIdutilisateur(idUtilisateur);
        filtre.setPost_id(postId);
        Object[] existing = CGenUtil.rechercher(filtre, null, null, 
            " AND idutilisateur = " + idUtilisateur + " AND post_id = '" + postId + "'", conn);
        
        if (existing != null && existing.length > 0) {
            // Unlike
            CGenUtil.delete((Like) existing[0], conn);
            
            // Décrémenter compteur
            Post post = getPost(postId, conn);
            post.setNb_likes(post.getNb_likes() - 1);
            CGenUtil.update(post, conn);
            
        } else {
            // Like
            Like like = new Like();
            like.construirePK(conn);
            like.setIdutilisateur(idUtilisateur);
            like.setPost_id(postId);
            CGenUtil.save(like, conn);
            
            // Incrémenter compteur
            Post post = getPost(postId, conn);
            post.setNb_likes(post.getNb_likes() + 1);
            CGenUtil.update(post, conn);
            
            // Créer notification
            notifierLike(idUtilisateur, postId, conn);
        }
        
        conn.commit();
    } catch (Exception e) {
        conn.rollback();
        throw e;
    } finally {
        conn.close();
    }
}
```

**Vérifier si un utilisateur a liké :**
```java
public boolean aLike(int idUtilisateur, String postId) throws Exception {
    Object[] likes = CGenUtil.rechercher(new Like(), null, null,
        " AND idutilisateur = " + idUtilisateur + " AND post_id = '" + postId + "'");
    return likes != null && likes.length > 0;
}
```

---

### 5.2 `commentaires`

**Structure :**
```sql
CREATE TABLE commentaires (
  id VARCHAR(50) PRIMARY KEY,
  idutilisateur INTEGER NOT NULL REFERENCES utilisateur_acade(refuser),
  post_id VARCHAR(50) NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  parent_id VARCHAR(50) REFERENCES commentaires(id) ON DELETE CASCADE,
  contenu TEXT NOT NULL,
  supprime BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL,
  edited_at TIMESTAMP
);

CREATE INDEX idx_comments_post_date ON commentaires(post_id, created_at);
CREATE INDEX idx_comments_parent ON commentaires(parent_id, created_at);
CREATE INDEX idx_comments_user ON commentaires(idutilisateur);
```

**Commentaires imbriqués (réponses) :**
```java
/**
 * Récupère les commentaires d'un post avec structure hiérarchique
 */
public List<CommentaireDTO> getCommentairesWithReplies(String postId) throws Exception {
    // 1. Récupérer tous les commentaires du post
    Object[] all = CGenUtil.rechercher(new Commentaire(), null, null,
        " AND post_id = '" + postId + "' AND supprime = false ORDER BY created_at ASC");
    
    Map<String, CommentaireDTO> map = new HashMap<>();
    List<CommentaireDTO> roots = new ArrayList<>();
    
    // 2. Créer les DTOs
    for (Object o : all) {
        Commentaire c = (Commentaire) o;
        CommentaireDTO dto = new CommentaireDTO(c);
        dto.setAuteur(getUtilisateur(c.getIdutilisateur()));
        dto.setReplies(new ArrayList<>());
        map.put(c.getId(), dto);
    }
    
    // 3. Construire la hiérarchie
    for (CommentaireDTO dto : map.values()) {
        if (dto.getParent_id() == null) {
            roots.add(dto);
        } else {
            CommentaireDTO parent = map.get(dto.getParent_id());
            if (parent != null) {
                parent.getReplies().add(dto);
            }
        }
    }
    
    return roots;
}
```

**Affichage JSP récursif :**
```jsp
<%!
void afficherCommentaire(CommentaireDTO comment, JspWriter out, int niveau) throws Exception {
    String indent = "margin-left: " + (niveau * 30) + "px";
    out.println("<div class='commentaire' style='" + indent + "'>");
    out.println("  <div class='comment-header'>");
    out.println("    <img src='" + comment.getAuteur().getPhoto() + "' />");
    out.println("    <strong>" + comment.getAuteur().getNomComplet() + "</strong>");
    out.println("    <span class='date'>" + formatDate(comment.getCreated_at()) + "</span>");
    out.println("  </div>");
    out.println("  <p>" + escapeHtml(comment.getContenu()) + "</p>");
    out.println("  <a href='#' onclick='repondre(\"" + comment.getId() + "\")'>Répondre</a>");
    
    // Afficher les réponses récursivement
    for (CommentaireDTO reply : comment.getReplies()) {
        afficherCommentaire(reply, out, niveau + 1);
    }
    
    out.println("</div>");
}
%>

<%
List<CommentaireDTO> commentaires = getCommentairesWithReplies(postId);
for (CommentaireDTO comment : commentaires) {
    afficherCommentaire(comment, out, 0);
}
%>
```

---

### 5.3 `partages`

**Structure :**
```sql
CREATE TABLE partages (
  id VARCHAR(50) PRIMARY KEY,
  idutilisateur INTEGER NOT NULL REFERENCES utilisateur_acade(refuser),
  post_id VARCHAR(50) NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  commentaire TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX idx_partages_user_date ON partages(idutilisateur, created_at);
CREATE INDEX idx_partages_post ON partages(post_id);
```

**Partager un post :**
```java
public String partagerPost(int idUtilisateur, String postId, String commentaire) throws Exception {
    Connection conn = new UtilDB().GetConn();
    try {
        conn.setAutoCommit(false);
        
        // Créer le partage
        Partage partage = new Partage();
        partage.construirePK(conn);
        partage.setIdutilisateur(idUtilisateur);
        partage.setPost_id(postId);
        partage.setCommentaire(commentaire);
        CGenUtil.save(partage, conn);
        
        // Incrémenter compteur
        Post post = getPost(postId, conn);
        post.setNb_partages(post.getNb_partages() + 1);
        CGenUtil.update(post, conn);
        
        // Notification
        notifierPartage(idUtilisateur, postId, conn);
        
        conn.commit();
        return partage.getId();
        
    } catch (Exception e) {
        conn.rollback();
        throw e;
    } finally {
        conn.close();
    }
}
```

---

## 6. Tables de groupes

### 6.1 `groupes`

**Structure :**
```sql
CREATE TABLE groupes (
  id VARCHAR(50) PRIMARY KEY,
  nom VARCHAR(200) NOT NULL,
  description TEXT,
  photo_couverture VARCHAR(500),
  photo_profil VARCHAR(500),
  type_groupe VARCHAR(50) DEFAULT 'ouvert',  -- ouvert, ferme, prive
  created_by INTEGER NOT NULL REFERENCES utilisateur_acade(refuser),
  actif BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX idx_groupes_nom ON groupes(nom);
CREATE INDEX idx_groupes_created_by ON groupes(created_by);
```

**Créer un groupe :**
```java
public String creerGroupe(String nom, String description, int createdBy) throws Exception {
    Connection conn = new UtilDB().GetConn();
    try {
        conn.setAutoCommit(false);
        
        // 1. Créer le groupe
        Groupe groupe = new Groupe();
        groupe.construirePK(conn);
        groupe.setNom(nom);
        groupe.setDescription(description);
        groupe.setType_groupe("ouvert");
        groupe.setCreated_by(createdBy);
        groupe.setActif(true);
        CGenUtil.save(groupe, conn);
        
        // 2. Ajouter le créateur comme admin
        GroupeMembre membre = new GroupeMembre();
        membre.construirePK(conn);
        membre.setIdutilisateur(createdBy);
        membre.setIdgroupe(groupe.getId());
        membre.setIdrole("ROLE00001"); // Admin
        membre.setStatut("actif");
        CGenUtil.save(membre, conn);
        
        conn.commit();
        return groupe.getId();
        
    } catch (Exception e) {
        conn.rollback();
        throw e;
    } finally {
        conn.close();
    }
}
```

---

### 6.2 `groupe_membres`

**Structure :**
```sql
CREATE TABLE groupe_membres (
  id VARCHAR(50) PRIMARY KEY,
  idutilisateur INTEGER NOT NULL REFERENCES utilisateur_acade(refuser),
  idgroupe VARCHAR(50) NOT NULL REFERENCES groupes(id) ON DELETE CASCADE,
  idrole VARCHAR(50) NOT NULL REFERENCES role_groupe(id),
  statut VARCHAR(50) DEFAULT 'actif',        -- actif, suspendu, banni
  joined_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE UNIQUE INDEX unique_user_group ON groupe_membres(idutilisateur, idgroupe);
CREATE INDEX idx_groupe_membres_group ON groupe_membres(idgroupe);
CREATE INDEX idx_groupe_membres_role ON groupe_membres(idrole);
```

**Rejoindre un groupe :**
```java
public void rejoindreGroupe(int idUtilisateur, String idGroupe) throws Exception {
    Groupe groupe = getGroupe(idGroupe);
    
    // Vérifier type de groupe
    if ("prive".equals(groupe.getType_groupe())) {
        throw new Exception("Ce groupe est privé, invitation requise");
    }
    
    if ("ferme".equals(groupe.getType_groupe())) {
        // Créer demande d'adhésion
        creerDemandeAdhesion(idUtilisateur, idGroupe);
        return;
    }
    
    // Groupe ouvert : adhésion directe
    GroupeMembre membre = new GroupeMembre();
    membre.construirePK(conn);
    membre.setIdutilisateur(idUtilisateur);
    membre.setIdgroupe(idGroupe);
    membre.setIdrole("ROLE00003"); // Membre
    membre.setStatut("actif");
    CGenUtil.save(membre);
}
```

---

## 7. Tables de centres d'intérêt

### 7.1 `utilisateur_interets`

Centres d'intérêt sélectionnés par les utilisateurs.

**Structure :**
```sql
CREATE TABLE utilisateur_interets (
  id VARCHAR(50) PRIMARY KEY,
  idutilisateur INTEGER NOT NULL REFERENCES utilisateur_acade(refuser),
  topic_id VARCHAR(50) NOT NULL REFERENCES topics(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX unique_user_topic ON utilisateur_interets(idutilisateur, topic_id);
CREATE INDEX idx_user_interets_topic ON utilisateur_interets(topic_id);
```

**Algorithme de recommandation simple :**
```java
/**
 * Recommande des posts basés sur les centres d'intérêt
 */
public Object[] getPostsRecommandes(int idUtilisateur, int limite) throws Exception {
    String sql = "SELECT DISTINCT p.* FROM posts p ";
    sql += "INNER JOIN post_topics pt ON pt.post_id = p.id ";
    sql += "INNER JOIN utilisateur_interets ui ON ui.topic_id = pt.topic_id ";
    sql += "WHERE ui.idutilisateur = " + idUtilisateur;
    sql += " AND p.supprime = false";
    sql += " AND p.idstatutpublication = 'STAT00002'";
    sql += " AND p.idutilisateur != " + idUtilisateur; // Pas ses propres posts
    sql += " ORDER BY p.created_at DESC";
    sql += " LIMIT " + limite;
    
    // Exécuter avec JDBC ou adapter
    return executeQuery(sql);
}
```

---

### 7.2 `post_topics`

Tags associés aux publications.

**Structure :**
```sql
CREATE TABLE post_topics (
  id VARCHAR(50) PRIMARY KEY,
  post_id VARCHAR(50) NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  topic_id VARCHAR(50) NOT NULL REFERENCES topics(id),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE UNIQUE INDEX unique_post_topic ON post_topics(post_id, topic_id);
CREATE INDEX idx_post_topics_topic ON post_topics(topic_id);
```

**Auto-tagging intelligent (optionnel) :**
```java
/**
 * Suggère automatiquement des tags basés sur le contenu
 */
public List<Topic> suggestTags(String contenu, String typePublication) throws Exception {
    List<Topic> suggestions = new ArrayList<>();
    contenu = contenu.toLowerCase();
    
    // Récupérer tous les topics actifs
    Object[] allTopics = CGenUtil.rechercher(new Topic(), null, null, " AND actif = true");
    
    for (Object o : allTopics) {
        Topic topic = (Topic) o;
        String[] keywords = topic.getNom().toLowerCase().split(" ");
        
        // Vérifier si le topic apparaît dans le contenu
        for (String keyword : keywords) {
            if (contenu.contains(keyword)) {
                suggestions.add(topic);
                break;
            }
        }
    }
    
    // Ajouter le topic correspondant au type
    if ("TYP00001".equals(typePublication)) {
        suggestions.add(getTopicByCode("stage"));
    } else if ("TYP00002".equals(typePublication)) {
        suggestions.add(getTopicByCode("emploi"));
    }
    
    return suggestions;
}
```

---

## 8. Tables de notifications

### 8.1 `notifications`

**Structure :**
```sql
CREATE TABLE notifications (
  id VARCHAR(50) PRIMARY KEY,
  idutilisateur INTEGER NOT NULL REFERENCES utilisateur_acade(refuser),
  emetteur_id INTEGER REFERENCES utilisateur_acade(refuser),
  idtypenotification VARCHAR(50) NOT NULL REFERENCES type_notification(id),
  post_id VARCHAR(50) REFERENCES posts(id) ON DELETE CASCADE,
  commentaire_id VARCHAR(50) REFERENCES commentaires(id) ON DELETE CASCADE,
  groupe_id VARCHAR(50) REFERENCES groupes(id) ON DELETE CASCADE,
  contenu TEXT,
  lien VARCHAR(500),
  vu BOOLEAN DEFAULT false,
  lu_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX idx_notifs_user_vu_date ON notifications(idutilisateur, vu, created_at);
CREATE INDEX idx_notifs_user_date ON notifications(idutilisateur, created_at);
CREATE INDEX idx_notifs_type ON notifications(idtypenotification);
```

**Marquer comme lu :**
```java
public void marquerNotificationsLues(int idUtilisateur) throws Exception {
    // Via JDBC car CGenUtil.update() met à jour 1 seul objet
    Connection conn = new UtilDB().GetConn();
    PreparedStatement ps = null;
    try {
        String sql = "UPDATE notifications SET vu = true, lu_at = NOW() ";
        sql += "WHERE idutilisateur = ? AND vu = false";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, idUtilisateur);
        ps.executeUpdate();
    } finally {
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
}
```

**Compteur de notifications non lues :**
```java
public int getNbNotificationsNonLues(int idUtilisateur) throws Exception {
    Connection conn = new UtilDB().GetConn();
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        String sql = "SELECT COUNT(*) FROM notifications ";
        sql += "WHERE idutilisateur = ? AND vu = false";
        ps = conn.prepareStatement(sql);
        ps.setInt(1, idUtilisateur);
        rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1);
        }
        return 0;
    } finally {
        if (rs != null) rs.close();
        if (ps != null) ps.close();
        if (conn != null) conn.close();
    }
}
```

**Affichage JSP :**
```jsp
<div class="notifications-dropdown">
    <a href="#" class="dropdown-toggle">
        <i class="fa fa-bell"></i>
        <span class="badge"><%= getNbNotificationsNonLues(u.getUser().getRefuser()) %></span>
    </a>
    <ul class="dropdown-menu">
        <%
        Object[] notifs = CGenUtil.rechercher(new Notification(), null, null,
            " AND idutilisateur = " + u.getUser().getRefuser() +
            " ORDER BY created_at DESC LIMIT 10");
        
        for (Object o : notifs) {
            Notification notif = (Notification) o;
            TypeNotification type = getTypeNotification(notif.getIdtypenotification());
            String cssClass = notif.getVu() ? "read" : "unread";
        %>
            <li class="<%= cssClass %>">
                <a href="<%= notif.getLien() %>">
                    <i class="<%= type.getIcon() %>" style="color:<%= type.getCouleur() %>"></i>
                    <%= notif.getContenu() %>
                    <span class="time"><%= timeAgo(notif.getCreated_at()) %></span>
                </a>
            </li>
        <% } %>
    </ul>
</div>
```

---

## 9. Tables de modération

### 9.1 `signalements`

**Structure :**
```sql
CREATE TABLE signalements (
  id VARCHAR(50) PRIMARY KEY,
  idutilisateur INTEGER NOT NULL REFERENCES utilisateur_acade(refuser),
  post_id VARCHAR(50) REFERENCES posts(id) ON DELETE CASCADE,
  commentaire_id VARCHAR(50) REFERENCES commentaires(id) ON DELETE CASCADE,
  idmotifsignalement VARCHAR(50) NOT NULL REFERENCES motif_signalement(id),
  idstatutsignalement VARCHAR(50) NOT NULL REFERENCES statut_signalement(id),
  description TEXT,
  traite_par INTEGER REFERENCES utilisateur_acade(refuser),
  traite_at TIMESTAMP,
  decision TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE INDEX idx_signalements_statut_date ON signalements(idstatutsignalement, created_at);
CREATE INDEX idx_signalements_user ON signalements(idutilisateur);
CREATE INDEX idx_signalements_motif ON signalements(idmotifsignalement);
```

**Dashboard modération :**
```jsp
<h2>Signalements en attente</h2>
<table class="table">
    <thead>
        <tr>
            <th>Date</th>
            <th>Contenu</th>
            <th>Motif</th>
            <th>Signalé par</th>
            <th>Actions</th>
        </tr>
    </thead>
    <tbody>
    <%
    Object[] signalements = CGenUtil.rechercher(new Signalement(), null, null,
        " AND idstatutsignalement = 'SSIG00001' ORDER BY created_at DESC");
    
    for (Object o : signalements) {
        Signalement sig = (Signalement) o;
        MotifSignalement motif = getMotifSignalement(sig.getIdmotifsignalement());
        UtilisateurAcade auteur = getUtilisateur(sig.getIdutilisateur());
    %>
        <tr>
            <td><%= formatDate(sig.getCreated_at()) %></td>
            <td>
                <% if (sig.getPost_id() != null) { %>
                    <a href="?but=posts/post-fiche.jsp&id=<%= sig.getPost_id() %>">Voir le post</a>
                <% } else { %>
                    <a href="?but=comments/comment-fiche.jsp&id=<%= sig.getCommentaire_id() %>">Voir le commentaire</a>
                <% } %>
            </td>
            <td>
                <span class="badge" style="background:<%= motif.getCouleur() %>">
                    <%= motif.getLibelle() %>
                </span>
            </td>
            <td><%= auteur.getNomComplet() %></td>
            <td>
                <a href="?but=moderation/traiter-signalement.jsp&id=<%= sig.getId() %>" class="btn btn-primary btn-sm">
                    Traiter
                </a>
            </td>
        </tr>
    <% } %>
    </tbody>
</table>
```

---

## 10. Vues SQL recommandées

### 10.1 Vue `v_posts_complets`

Vue enrichie avec toutes les statistiques et infos utilisateur.

```sql
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
    COUNT(DISTINCT l.id) as nb_likes_reel,
    COUNT(DISTINCT c.id) as nb_commentaires_reel,
    COUNT(DISTINCT pt.id) as nb_partages_reel,
    COUNT(DISTINCT pf.id) as nb_fichiers
FROM posts p
LEFT JOIN utilisateur_acade u ON u.refuser = p.idutilisateur
LEFT JOIN type_publication tp ON tp.id = p.idtypepublication
LEFT JOIN statut_publication sp ON sp.id = p.idstatutpublication
LEFT JOIN visibilite_publication vp ON vp.id = p.idvisibilite
LEFT JOIN groupes g ON g.id = p.idgroupe
LEFT JOIN likes l ON l.post_id = p.id
LEFT JOIN commentaires c ON c.post_id = p.id AND c.supprime = false
LEFT JOIN partages pt ON pt.post_id = p.id
LEFT JOIN post_fichiers pf ON pf.post_id = p.id
WHERE p.supprime = false
GROUP BY p.id, u.refuser, tp.id, sp.id, vp.id, g.id;
```

**Utilisation (JDBC) :**
```java
public List<PostCompletDTO> getPostsComplets(String awhere, int limit) throws Exception {
    Connection conn = new UtilDB().GetConn();
    Statement stmt = null;
    ResultSet rs = null;
    List<PostCompletDTO> posts = new ArrayList<>();
    
    try {
        String sql = "SELECT * FROM v_posts_complets WHERE 1=1 " + awhere;
        sql += " ORDER BY created_at DESC LIMIT " + limit;
        
        stmt = conn.createStatement();
        rs = stmt.executeQuery(sql);
        
        while (rs.next()) {
            PostCompletDTO dto = new PostCompletDTO();
            dto.setId(rs.getString("id"));
            dto.setContenu(rs.getString("contenu"));
            dto.setAuteurNom(rs.getString("nomuser") + " " + rs.getString("prenom"));
            dto.setAuteurPhoto(rs.getString("photo_auteur"));
            dto.setTypeLibelle(rs.getString("type_libelle"));
            dto.setTypeIcon(rs.getString("type_icon"));
            dto.setTypeCouleur(rs.getString("type_couleur"));
            dto.setNbLikes(rs.getInt("nb_likes_reel"));
            dto.setNbCommentaires(rs.getInt("nb_commentaires_reel"));
            dto.setNbPartages(rs.getInt("nb_partages_reel"));
            dto.setNbFichiers(rs.getInt("nb_fichiers"));
            dto.setCreatedAt(rs.getTimestamp("created_at"));
            posts.add(dto);
        }
        
        return posts;
    } finally {
        if (rs != null) rs.close();
        if (stmt != null) stmt.close();
        if (conn != null) conn.close();
    }
}
```

---

### 10.2 Vue `v_feed_personnalise`

Fil d'actualité personnalisé basé sur les intérêts et groupes.

```sql
CREATE OR REPLACE VIEW v_feed_personnalise AS
-- Posts publics de mes centres d'intérêt
SELECT DISTINCT
    p.id,
    p.idutilisateur,
    p.contenu,
    p.created_at,
    ui.idutilisateur as pour_utilisateur,
    'interet' as source,
    t.nom as source_nom
FROM posts p
INNER JOIN post_topics ptp ON ptp.post_id = p.id
INNER JOIN utilisateur_interets ui ON ui.topic_id = ptp.topic_id
INNER JOIN topics t ON t.id = ptp.topic_id
WHERE p.supprime = false
  AND p.idstatutpublication = 'STAT00002'
  AND p.idvisibilite = 'VISI00001'

UNION

-- Posts de mes groupes
SELECT DISTINCT
    p.id,
    p.idutilisateur,
    p.contenu,
    p.created_at,
    gm.idutilisateur as pour_utilisateur,
    'groupe' as source,
    g.nom as source_nom
FROM posts p
INNER JOIN groupes g ON g.id = p.idgroupe
INNER JOIN groupe_membres gm ON gm.idgroupe = g.id
WHERE p.supprime = false
  AND p.idstatutpublication = 'STAT00002'
  AND p.idgroupe IS NOT NULL;
```

**Utilisation :**
```sql
-- Feed pour l'utilisateur 42
SELECT * FROM v_feed_personnalise
WHERE pour_utilisateur = 42
ORDER BY created_at DESC
LIMIT 20;
```

---

### 10.3 Vue `v_statistiques_posts`

Statistiques globales par type et statut.

```sql
CREATE OR REPLACE VIEW v_statistiques_posts AS
SELECT 
    tp.libelle as type,
    sp.libelle as statut,
    COUNT(*) as nb_posts,
    SUM(p.nb_likes) as total_likes,
    SUM(p.nb_commentaires) as total_commentaires,
    SUM(p.nb_partages) as total_partages,
    AVG(p.nb_likes) as moyenne_likes,
    MAX(p.created_at) as dernier_post
FROM posts p
INNER JOIN type_publication tp ON tp.id = p.idtypepublication
INNER JOIN statut_publication sp ON sp.id = p.idstatutpublication
WHERE p.supprime = false
GROUP BY tp.libelle, sp.libelle
ORDER BY nb_posts DESC;
```

---

## 11. Index et performances

### 11.1 Index essentiels

```sql
-- Posts : recherches fréquentes
CREATE INDEX idx_posts_user_date ON posts(idutilisateur, created_at DESC);
CREATE INDEX idx_posts_type_date ON posts(idtypepublication, created_at DESC);
CREATE INDEX idx_posts_statut_date ON posts(idstatutpublication, created_at DESC);
CREATE INDEX idx_posts_groupe ON posts(idgroupe);
CREATE INDEX idx_posts_date ON posts(created_at DESC);

-- Likes : vérification rapide
CREATE UNIQUE INDEX unique_user_like_post ON likes(idutilisateur, post_id);
CREATE INDEX idx_likes_post ON likes(post_id);

-- Commentaires : tri chronologique
CREATE INDEX idx_comments_post_date ON commentaires(post_id, created_at);
CREATE INDEX idx_comments_parent ON commentaires(parent_id);

-- Notifications : non lues en premier
CREATE INDEX idx_notifs_user_vu_date ON notifications(idutilisateur, vu, created_at DESC);

-- Groupes : membres actifs
CREATE UNIQUE INDEX unique_user_group ON groupe_membres(idutilisateur, idgroupe);
CREATE INDEX idx_groupe_membres_group ON groupe_membres(idgroupe);

-- Topics : recherche et filtrage
CREATE INDEX idx_post_topics_post ON post_topics(post_id);
CREATE INDEX idx_post_topics_topic ON post_topics(topic_id);
CREATE INDEX idx_user_interets_user ON utilisateur_interets(idutilisateur);
CREATE INDEX idx_user_interets_topic ON utilisateur_interets(topic_id);
```

---

### 11.2 Triggers pour compteurs dénormalisés

**Trigger pour likes :**
```sql
-- Incrémenter nb_likes
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

-- Décrémenter nb_likes
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
```

**Trigger pour commentaires :**
```sql
CREATE OR REPLACE FUNCTION increment_commentaires() RETURNS TRIGGER AS $$
BEGIN
    UPDATE posts SET nb_commentaires = nb_commentaires + 1 WHERE id = NEW.post_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_increment_commentaires
AFTER INSERT ON commentaires
FOR EACH ROW
EXECUTE FUNCTION increment_commentaires();

-- Gérer le soft delete
CREATE OR REPLACE FUNCTION handle_commentaire_suppression() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.supprime = true AND OLD.supprime = false THEN
        UPDATE posts SET nb_commentaires = nb_commentaires - 1 WHERE id = NEW.post_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_handle_commentaire_suppression
AFTER UPDATE ON commentaires
FOR EACH ROW
EXECUTE FUNCTION handle_commentaire_suppression();
```

**Trigger pour partages :**
```sql
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
```

---

### 11.3 Optimisations de requêtes

**1. Pagination efficace :**
```sql
-- ❌ LENT : OFFSET augmente avec la page
SELECT * FROM posts
ORDER BY created_at DESC
LIMIT 20 OFFSET 1000;  -- Lit 1020 lignes pour en retourner 20

-- ✅ RAPIDE : Utiliser un curseur
SELECT * FROM posts
WHERE created_at < ?  -- Timestamp de la dernière ligne de la page précédente
ORDER BY created_at DESC
LIMIT 20;
```

**Implémentation Java :**
```java
public Object[] getPostsPagines(Timestamp lastPostDate, int limit) throws Exception {
    String awhere = " AND supprime = false AND idstatutpublication = 'STAT00002'";
    if (lastPostDate != null) {
        awhere += " AND created_at < '" + lastPostDate + "'";
    }
    awhere += " ORDER BY created_at DESC LIMIT " + limit;
    return CGenUtil.rechercher(new Post(), null, null, awhere);
}
```

**2. Éviter N+1 queries :**
```java
// ❌ LENT : 1 requête par post pour récupérer l'auteur
for (Object o : posts) {
    Post p = (Post) o;
    UtilisateurAcade auteur = getUtilisateur(p.getIdutilisateur());  // Requête BDD !
}

// ✅ RAPIDE : 1 seule requête avec JOIN (via JDBC)
String sql = "SELECT p.*, u.nomuser, u.prenom, u.photo ";
sql += "FROM posts p ";
sql += "INNER JOIN utilisateur_acade u ON u.refuser = p.idutilisateur ";
sql += "WHERE p.supprime = false ORDER BY p.created_at DESC LIMIT 20";
// Exécuter et mapper vers DTO
```

**3. Caching en mémoire (optionnel) :**
```java
// Cache des référentiels (rarement modifiés)
private static Map<String, TypePublication> cacheTypesPublication = new HashMap<>();

public TypePublication getTypePublication(String id) throws Exception {
    if (!cacheTypesPublication.containsKey(id)) {
        Object[] result = CGenUtil.rechercher(new TypePublication(), null, null, " AND id = '" + id + "'");
        if (result.length > 0) {
            cacheTypesPublication.put(id, (TypePublication) result[0]);
        }
    }
    return cacheTypesPublication.get(id);
}

// Invalider le cache lors d'un UPDATE
public void updateTypePublication(TypePublication type) throws Exception {
    CGenUtil.update(type);
    cacheTypesPublication.remove(type.getId());
}
```

---

## 12. Exemples de requêtes

### 12.1 Fil d'actualité complet

```java
/**
 * Récupère le fil d'actualité avec tous les filtres
 */
public List<PostCompletDTO> getFeed(int idUtilisateur, FeedFilters filters) throws Exception {
    String sql = "SELECT p.*, u.nomuser, u.prenom, u.photo, ";
    sql += "tp.libelle as type_libelle, tp.icon as type_icon, ";
    sql += "COUNT(DISTINCT l.id) as nb_likes_reel ";
    sql += "FROM posts p ";
    sql += "INNER JOIN utilisateur_acade u ON u.refuser = p.idutilisateur ";
    sql += "INNER JOIN type_publication tp ON tp.id = p.idtypepublication ";
    sql += "LEFT JOIN likes l ON l.post_id = p.id ";
    sql += "WHERE p.supprime = false ";
    sql += "AND p.idstatutpublication = 'STAT00002' "; // Publié
    
    // Visibilité
    sql += "AND (p.idvisibilite = 'VISI00001' "; // Public
    sql += "OR p.idutilisateur = " + idUtilisateur; // Ses posts
    sql += "OR p.idgroupe IN (";
    sql += "  SELECT idgroupe FROM groupe_membres WHERE idutilisateur = " + idUtilisateur;
    sql += ")) ";
    
    // Filtres optionnels
    if (filters.getTypePublication() != null) {
        sql += "AND p.idtypepublication = '" + filters.getTypePublication() + "' ";
    }
    
    if (filters.getIdGroupe() != null) {
        sql += "AND p.idgroupe = '" + filters.getIdGroupe() + "' ";
    }
    
    if (filters.getTopics() != null && !filters.getTopics().isEmpty()) {
        sql += "AND EXISTS (";
        sql += "  SELECT 1 FROM post_topics pt ";
        sql += "  WHERE pt.post_id = p.id AND pt.topic_id IN (";
        sql += String.join(",", filters.getTopics().stream().map(t -> "'" + t + "'").toArray(String[]::new));
        sql += "))";
    }
    
    sql += "GROUP BY p.id, u.refuser, tp.id ";
    sql += "ORDER BY p.epingle DESC, p.created_at DESC ";
    sql += "LIMIT " + filters.getLimit();
    
    return executeQueryToDTO(sql);
}
```

---

### 12.2 Recherche globale

```java
/**
 * Recherche full-text dans posts, stages, emplois
 */
public List<PostCompletDTO> rechercherGlobal(String query, String typeRecherche) throws Exception {
    String sql = "SELECT DISTINCT p.*, ";
    sql += "ts_rank(to_tsvector('french', p.contenu), plainto_tsquery('french', ?)) as rank ";
    sql += "FROM posts p ";
    
    if ("stage".equals(typeRecherche)) {
        sql += "LEFT JOIN post_stage ps ON ps.post_id = p.id ";
        sql += "WHERE (to_tsvector('french', p.contenu) @@ plainto_tsquery('french', ?) ";
        sql += "OR to_tsvector('french', ps.entreprise) @@ plainto_tsquery('french', ?) ";
        sql += "OR to_tsvector('french', ps.competences_requises) @@ plainto_tsquery('french', ?)) ";
        sql += "AND p.idtypepublication = 'TYP00001' ";
    } else if ("emploi".equals(typeRecherche)) {
        sql += "LEFT JOIN post_emploi pe ON pe.post_id = p.id ";
        sql += "WHERE (to_tsvector('french', p.contenu) @@ plainto_tsquery('french', ?) ";
        sql += "OR to_tsvector('french', pe.entreprise) @@ plainto_tsquery('french', ?) ";
        sql += "OR to_tsvector('french', pe.poste) @@ plainto_tsquery('french', ?) ";
        sql += "OR to_tsvector('french', pe.competences_requises) @@ plainto_tsquery('french', ?)) ";
        sql += "AND p.idtypepublication = 'TYP00002' ";
    } else {
        sql += "WHERE to_tsvector('french', p.contenu) @@ plainto_tsquery('french', ?) ";
    }
    
    sql += "AND p.supprime = false ";
    sql += "AND p.idstatutpublication = 'STAT00002' ";
    sql += "ORDER BY rank DESC, p.created_at DESC ";
    sql += "LIMIT 50";
    
    // Exécuter avec PreparedStatement
    Connection conn = new UtilDB().GetConn();
    PreparedStatement ps = conn.prepareStatement(sql);
    
    // Remplir les ? selon le type
    if ("stage".equals(typeRecherche) || "emploi".equals(typeRecherche)) {
        ps.setString(1, query);
        ps.setString(2, query);
        ps.setString(3, query);
        if ("emploi".equals(typeRecherche)) ps.setString(4, query);
    } else {
        ps.setString(1, query);
    }
    
    ResultSet rs = ps.executeQuery();
    // Mapper vers DTO...
}
```

**Index pour full-text search :**
```sql
CREATE INDEX idx_posts_contenu_fts ON posts USING gin(to_tsvector('french', contenu));
CREATE INDEX idx_post_stage_entreprise_fts ON post_stage USING gin(to_tsvector('french', entreprise));
CREATE INDEX idx_post_emploi_poste_fts ON post_emploi USING gin(to_tsvector('french', poste));
```

---

### 12.3 Top contributeurs

```sql
CREATE OR REPLACE VIEW v_top_contributeurs AS
SELECT 
    u.refuser,
    u.nomuser,
    u.prenom,
    u.photo,
    COUNT(DISTINCT p.id) as nb_posts,
    COUNT(DISTINCT c.id) as nb_commentaires,
    SUM(p.nb_likes) as total_likes_recus,
    MAX(p.created_at) as dernier_post
FROM utilisateur_acade u
LEFT JOIN posts p ON p.idutilisateur = u.refuser AND p.supprime = false
LEFT JOIN commentaires c ON c.idutilisateur = u.refuser AND c.supprime = false
GROUP BY u.refuser
HAVING COUNT(DISTINCT p.id) > 0 OR COUNT(DISTINCT c.id) > 0
ORDER BY 
    (COUNT(DISTINCT p.id) * 10 + COUNT(DISTINCT c.id) + COALESCE(SUM(p.nb_likes), 0)) DESC;
```

---

### 12.4 Posts tendances (trending)

```java
/**
 * Algorithme simple de trending : likes + commentaires récents
 */
public List<PostCompletDTO> getPostsTendances(int heuresRecentes, int limit) throws Exception {
    String sql = "SELECT p.*, ";
    sql += "(COUNT(DISTINCT l.id) * 3 + COUNT(DISTINCT c.id) * 2 + COUNT(DISTINCT pt.id)) as score ";
    sql += "FROM posts p ";
    sql += "LEFT JOIN likes l ON l.post_id = p.id AND l.created_at >= NOW() - INTERVAL '" + heuresRecentes + " hours' ";
    sql += "LEFT JOIN commentaires c ON c.post_id = p.id AND c.created_at >= NOW() - INTERVAL '" + heuresRecentes + " hours' ";
    sql += "LEFT JOIN partages pt ON pt.post_id = p.id AND pt.created_at >= NOW() - INTERVAL '" + heuresRecentes + " hours' ";
    sql += "WHERE p.supprime = false ";
    sql += "AND p.idstatutpublication = 'STAT00002' ";
    sql += "AND p.idvisibilite = 'VISI00001' ";
    sql += "AND p.created_at >= NOW() - INTERVAL '7 days' ";
    sql += "GROUP BY p.id ";
    sql += "HAVING (COUNT(DISTINCT l.id) + COUNT(DISTINCT c.id) + COUNT(DISTINCT pt.id)) > 0 ";
    sql += "ORDER BY score DESC ";
    sql += "LIMIT " + limit;
    
    return executeQueryToDTO(sql);
}
```

---

## 13. Bonnes pratiques

### 13.1 Sécurité

**1. Validation des inputs**
```java
public void validerContenuPost(String contenu) throws Exception {
    // Longueur minimale/maximale
    if (contenu == null || contenu.trim().length() < 10) {
        throw new Exception("Le contenu doit contenir au moins 10 caractères");
    }
    if (contenu.length() > 5000) {
        throw new Exception("Le contenu ne peut dépasser 5000 caractères");
    }
    
    // Filtrer HTML dangereux
    contenu = Sanitizer.sanitizeHtml(contenu);
    
    // Détecter spam (mots-clés interdits)
    String[] motsInterdits = {"viagra", "casino", "click here"};
    for (String mot : motsInterdits) {
        if (contenu.toLowerCase().contains(mot)) {
            throw new Exception("Contenu suspect détecté");
        }
    }
}
```

**2. Permissions d'édition**
```java
public boolean peutEditerPost(int idUtilisateur, String postId) throws Exception {
    Post post = getPost(postId);
    
    // Auteur peut éditer
    if (post.getIdutilisateur() == idUtilisateur) {
        return true;
    }
    
    // Admin/modérateur du groupe peut éditer
    if (post.getIdgroupe() != null) {
        return aPermission(idUtilisateur, post.getIdgroupe(), "moderate");
    }
    
    // Super-admin peut éditer
    return isSuperAdmin(idUtilisateur);
}
```

**3. Rate limiting**
```java
private static Map<Integer, List<Long>> publicationsRecentes = new ConcurrentHashMap<>();

public void verifierRateLimit(int idUtilisateur) throws Exception {
    long maintenant = System.currentTimeMillis();
    List<Long> timestamps = publicationsRecentes.getOrDefault(idUtilisateur, new ArrayList<>());
    
    // Nettoyer les timestamps > 1h
    timestamps.removeIf(ts -> maintenant - ts > 3600000);
    
    // Max 10 posts par heure
    if (timestamps.size() >= 10) {
        throw new Exception("Limite de publications atteinte. Réessayez dans 1 heure.");
    }
    
    timestamps.add(maintenant);
    publicationsRecentes.put(idUtilisateur, timestamps);
}
```

---

### 13.2 Performance

**1. Lazy loading des détails**
```java
// Charger uniquement les champs nécessaires
public List<PostListeDTO> getPostsListe() throws Exception {
    // DTO minimaliste pour la liste
    String sql = "SELECT p.id, p.idutilisateur, p.contenu, p.created_at, ";
    sql += "u.nomuser, u.prenom, u.photo, ";
    sql += "p.nb_likes, p.nb_commentaires ";
    sql += "FROM posts p ";
    sql += "INNER JOIN utilisateur_acade u ON u.refuser = p.idutilisateur ";
    sql += "WHERE p.supprime = false ";
    sql += "ORDER BY p.created_at DESC LIMIT 20";
    
    // Pas de JOIN sur post_stage/emploi ni fichiers
    return executeQueryToListeDTO(sql);
}

// Charger les détails seulement au clic
public PostDetailDTO getPostDetail(String postId) throws Exception {
    // Ici on charge tout : détails spécifiques, fichiers, topics, etc.
}
```

**2. Batch operations**
```java
// ❌ LENT : Insérer les topics un par un
for (String topicId : selectedTopics) {
    PostTopic pt = new PostTopic();
    pt.construirePK(conn);
    pt.setPost_id(postId);
    pt.setTopic_id(topicId);
    CGenUtil.save(pt, conn);  // 1 requête par topic
}

// ✅ RAPIDE : Batch insert JDBC
String sql = "INSERT INTO post_topics (id, post_id, topic_id) VALUES (?, ?, ?)";
PreparedStatement ps = conn.prepareStatement(sql);
for (String topicId : selectedTopics) {
    ps.setString(1, genererIdPostTopic());
    ps.setString(2, postId);
    ps.setString(3, topicId);
    ps.addBatch();
}
ps.executeBatch();
```

---

### 13.3 Maintenance

**1. Nettoyage périodique**
```sql
-- Supprimer définitivement les posts soft-deleted > 30 jours
DELETE FROM posts
WHERE supprime = true
  AND date_suppression < NOW() - INTERVAL '30 days';

-- Archiver les notifications lues > 90 jours
INSERT INTO notifications_archive
SELECT * FROM notifications
WHERE vu = true AND lu_at < NOW() - INTERVAL '90 days';

DELETE FROM notifications
WHERE vu = true AND lu_at < NOW() - INTERVAL '90 days';
```

**2. Recalcul des compteurs (si désynchronisation)**
```sql
-- Recalculer nb_likes
UPDATE posts p
SET nb_likes = (SELECT COUNT(*) FROM likes WHERE post_id = p.id)
WHERE p.nb_likes != (SELECT COUNT(*) FROM likes WHERE post_id = p.id);

-- Recalculer nb_commentaires
UPDATE posts p
SET nb_commentaires = (
    SELECT COUNT(*) FROM commentaires 
    WHERE post_id = p.id AND supprime = false
)
WHERE p.nb_commentaires != (
    SELECT COUNT(*) FROM commentaires 
    WHERE post_id = p.id AND supprime = false
);
```

**3. Monitoring**
```sql
-- Posts sans statut valide (intégrité)
SELECT * FROM posts 
WHERE idstatutpublication NOT IN (SELECT id FROM statut_publication);

-- Fichiers orphelins
SELECT * FROM post_fichiers pf
WHERE NOT EXISTS (SELECT 1 FROM posts WHERE id = pf.post_id);

-- Notifications obsolètes (post supprimé)
SELECT * FROM notifications n
WHERE n.post_id IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM posts WHERE id = n.post_id);
```

---

## Conclusion

Ce schéma de base de données offre une **architecture complète et évolutive** pour un système de publications alumni avec :

✅ **Flexibilité** : Tous les référentiels en tables  
✅ **Performance** : Compteurs dénormalisés + index optimisés  
✅ **Maintenabilité** : Soft delete, audit trail, vues  
✅ **Extensibilité** : Facile d'ajouter de nouveaux types/statuts  
✅ **Sécurité** : Permissions, modération, signalements  
✅ **UX** : Notifications, recommandations, recherche  

**Prochaines étapes recommandées :**
1. Générer les classes Java Bean
2. Créer les services métier
3. Développer les pages JSP
4. Implémenter les tests unitaires
5. Ajouter le système de notifications en temps réel (WebSocket)
6. Optimiser avec cache Redis (optionnel)

---

**Fin du guide** 🚀
