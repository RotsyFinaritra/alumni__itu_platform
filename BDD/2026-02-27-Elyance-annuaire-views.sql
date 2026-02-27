-- Views pour l'autocomplete avec format id-libelle dans l'annuaire
-- Date: 2026-02-27
-- Auteur: Elyance

-- Vue Promotion avec affichage id-libelle
CREATE OR REPLACE VIEW v_promotion_aff AS
SELECT id, libelle, annee, id_option, id || ' - ' || libelle AS aff
FROM promotion;

-- Vue Pays avec affichage id-libelle
CREATE OR REPLACE VIEW v_pays_aff AS
SELECT id, libelle, id || ' - ' || libelle AS aff
FROM pays;

-- Vue Ville avec affichage id-libelle (inclut idpays pour filtrage dépendant)
CREATE OR REPLACE VIEW v_ville_aff AS
SELECT id, libelle, idpays, id || ' - ' || libelle AS aff
FROM ville;

-- Vue Type Utilisateur avec affichage id-libelle
CREATE OR REPLACE VIEW v_type_utilisateur_aff AS
SELECT id, libelle, id || ' - ' || libelle AS aff
FROM type_utilisateur;

-- Vue Compétence avec affichage id-libelle
CREATE OR REPLACE VIEW v_competence_aff AS
SELECT id, libelle, id || ' - ' || libelle AS aff
FROM competence;

-- Vue Entreprise avec affichage id-libelle
CREATE OR REPLACE VIEW v_entreprise_aff AS
SELECT id, libelle, idville, description, id || ' - ' || libelle AS aff
FROM entreprise;
