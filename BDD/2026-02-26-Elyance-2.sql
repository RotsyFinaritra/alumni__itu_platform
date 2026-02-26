-- Migration des rôles : utilisateur générique → rôles spécifiques
-- PostgreSQL syntax

-- Désactiver temporairement les contraintes FK
SET session_replication_role = 'replica';

-- Nettoyer les tables dépendantes
DELETE FROM usermenu;
DELETE FROM roles;

-- Recréer les rôles spécifiques
INSERT INTO roles (idrole, descrole, rang) VALUES ('admin', 'Administrateur', 1) ON CONFLICT (idrole) DO NOTHING;
INSERT INTO roles (idrole, descrole, rang) VALUES ('alumni', 'Ancien étudiant', 2) ON CONFLICT (idrole) DO NOTHING;
INSERT INTO roles (idrole, descrole, rang) VALUES ('etudiant', 'Étudiant actuel', 3) ON CONFLICT (idrole) DO NOTHING;
INSERT INTO roles (idrole, descrole, rang) VALUES ('enseignant', 'Enseignant', 4) ON CONFLICT (idrole) DO NOTHING;

-- Mettre à jour les utilisateurs existants (ceux avec 'utilisateur' → 'alumni' par défaut)
UPDATE utilisateur SET idrole = 'alumni' WHERE idrole = 'utilisateur' OR idrole IS NULL;

-- Réactiver les contraintes FK
SET session_replication_role = 'origin';