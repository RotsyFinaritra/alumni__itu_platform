-- =====================================================
-- Migration 2026-02-23 : Fiche Étudiant - Profil
-- Correctif des chemins de menu + ajout page visibilité
-- =====================================================

-- Correction des hrefs du menu profil (suppression du préfixe "pages/")
-- Le module.jsp inclut les JSP relativement à pages/, donc le "pages/" doit être omis
UPDATE menudynamique
SET href = 'module.jsp?but=profil/mon-profil.jsp'
WHERE id = 'MENDYN001-1';

UPDATE menudynamique
SET href = 'module.jsp?but=profil/competence-saisie.jsp', libelle = 'Mes compétences'
WHERE id = 'MENDYN001-2';

-- Correction des hrefs annuaire également
UPDATE menudynamique
SET href = 'module.jsp?but=annuaire/recherche.jsp'
WHERE id = 'MENDYN002-1';

UPDATE menudynamique
SET href = 'module.jsp?but=annuaire/promotions.jsp'
WHERE id = 'MENDYN002-2';

-- Ajout du sous-menu "Confidentialité" sous Profil
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN001-3', 'Confidentialité', 'fa-lock', 'module.jsp?but=profil/visibilite.jsp', 3, 2, 'MENDYN001')
ON CONFLICT (id) DO NOTHING;

-- Assignation du nouveau menu à tous les utilisateurs
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM003', '*', 'MENDYN001-3', NULL, NULL, NULL, 0)
ON CONFLICT (id) DO NOTHING;

-- =====================================================
-- Données de référence (exemples)
-- =====================================================

-- Types d'emploi
INSERT INTO type_emploie (id, libelle) VALUES ('TEMPL0001', 'CDI') ON CONFLICT (id) DO NOTHING;
INSERT INTO type_emploie (id, libelle) VALUES ('TEMPL0002', 'CDD') ON CONFLICT (id) DO NOTHING;
INSERT INTO type_emploie (id, libelle) VALUES ('TEMPL0003', 'Stage') ON CONFLICT (id) DO NOTHING;
INSERT INTO type_emploie (id, libelle) VALUES ('TEMPL0004', 'Alternance') ON CONFLICT (id) DO NOTHING;
INSERT INTO type_emploie (id, libelle) VALUES ('TEMPL0005', 'Freelance') ON CONFLICT (id) DO NOTHING;

-- Diplômes
INSERT INTO diplome (id, libelle) VALUES ('DIPL0001', 'Licence') ON CONFLICT (id) DO NOTHING;
INSERT INTO diplome (id, libelle) VALUES ('DIPL0002', 'Master') ON CONFLICT (id) DO NOTHING;
INSERT INTO diplome (id, libelle) VALUES ('DIPL0003', 'Doctorat') ON CONFLICT (id) DO NOTHING;
INSERT INTO diplome (id, libelle) VALUES ('DIPL0004', 'BTS') ON CONFLICT (id) DO NOTHING;
INSERT INTO diplome (id, libelle) VALUES ('DIPL0005', 'Ingénieur') ON CONFLICT (id) DO NOTHING;
INSERT INTO diplome (id, libelle) VALUES ('DIPL0006', 'DUT') ON CONFLICT (id) DO NOTHING;

-- Domaines
INSERT INTO domaine (id, libelle, idpere) VALUES ('DOM00001', 'Informatique', NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO domaine (id, libelle, idpere) VALUES ('DOM00002', 'Télécommunications', NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO domaine (id, libelle, idpere) VALUES ('DOM00003', 'Réseaux', 'DOM00001') ON CONFLICT (id) DO NOTHING;
INSERT INTO domaine (id, libelle, idpere) VALUES ('DOM00004', 'Génie Logiciel', 'DOM00001') ON CONFLICT (id) DO NOTHING;
INSERT INTO domaine (id, libelle, idpere) VALUES ('DOM00005', 'Intelligence Artificielle', 'DOM00001') ON CONFLICT (id) DO NOTHING;
INSERT INTO domaine (id, libelle, idpere) VALUES ('DOM00006', 'Gestion de Projet', NULL) ON CONFLICT (id) DO NOTHING;
INSERT INTO domaine (id, libelle, idpere) VALUES ('DOM00007', 'Sciences des Données', 'DOM00001') ON CONFLICT (id) DO NOTHING;

-- Pays
INSERT INTO pays (id, libelle) VALUES ('PAYS0001', 'Madagascar') ON CONFLICT (id) DO NOTHING;
INSERT INTO pays (id, libelle) VALUES ('PAYS0002', 'France') ON CONFLICT (id) DO NOTHING;
INSERT INTO pays (id, libelle) VALUES ('PAYS0003', 'Maurice') ON CONFLICT (id) DO NOTHING;

-- Villes
INSERT INTO ville (id, libelle, idpays) VALUES ('VILL0001', 'Antananarivo', 'PAYS0001') ON CONFLICT (id) DO NOTHING;
INSERT INTO ville (id, libelle, idpays) VALUES ('VILL0002', 'Toamasina', 'PAYS0001') ON CONFLICT (id) DO NOTHING;
INSERT INTO ville (id, libelle, idpays) VALUES ('VILL0003', 'Paris', 'PAYS0002') ON CONFLICT (id) DO NOTHING;
INSERT INTO ville (id, libelle, idpays) VALUES ('VILL0004', 'Port-Louis', 'PAYS0003') ON CONFLICT (id) DO NOTHING;

-- Spécialités
INSERT INTO specialite (id, libelle) VALUES ('SPEC0001', 'Développement Web') ON CONFLICT (id) DO NOTHING;
INSERT INTO specialite (id, libelle) VALUES ('SPEC0002', 'Développement Mobile') ON CONFLICT (id) DO NOTHING;
INSERT INTO specialite (id, libelle) VALUES ('SPEC0003', 'DevOps') ON CONFLICT (id) DO NOTHING;
INSERT INTO specialite (id, libelle) VALUES ('SPEC0004', 'Data Science') ON CONFLICT (id) DO NOTHING;
INSERT INTO specialite (id, libelle) VALUES ('SPEC0005', 'Cybersécurité') ON CONFLICT (id) DO NOTHING;
INSERT INTO specialite (id, libelle) VALUES ('SPEC0006', 'Cloud Computing') ON CONFLICT (id) DO NOTHING;
INSERT INTO specialite (id, libelle) VALUES ('SPEC0007', 'Intelligence Artificielle') ON CONFLICT (id) DO NOTHING;
INSERT INTO specialite (id, libelle) VALUES ('SPEC0008', 'Administration Réseaux') ON CONFLICT (id) DO NOTHING;

-- Compétences
INSERT INTO competence (id, libelle) VALUES ('COMP0001', 'Java') ON CONFLICT (id) DO NOTHING;
INSERT INTO competence (id, libelle) VALUES ('COMP0002', 'Python') ON CONFLICT (id) DO NOTHING;
INSERT INTO competence (id, libelle) VALUES ('COMP0003', 'JavaScript') ON CONFLICT (id) DO NOTHING;
INSERT INTO competence (id, libelle) VALUES ('COMP0004', 'PHP') ON CONFLICT (id) DO NOTHING;
INSERT INTO competence (id, libelle) VALUES ('COMP0005', 'SQL / PostgreSQL') ON CONFLICT (id) DO NOTHING;
INSERT INTO competence (id, libelle) VALUES ('COMP0006', 'React') ON CONFLICT (id) DO NOTHING;
INSERT INTO competence (id, libelle) VALUES ('COMP0007', 'Spring Boot') ON CONFLICT (id) DO NOTHING;
INSERT INTO competence (id, libelle) VALUES ('COMP0008', 'Docker / Kubernetes') ON CONFLICT (id) DO NOTHING;
INSERT INTO competence (id, libelle) VALUES ('COMP0009', 'Git') ON CONFLICT (id) DO NOTHING;
INSERT INTO competence (id, libelle) VALUES ('COMP0010', 'Machine Learning') ON CONFLICT (id) DO NOTHING;
INSERT INTO competence (id, libelle) VALUES ('COMP0011', 'Android / Kotlin') ON CONFLICT (id) DO NOTHING;
INSERT INTO competence (id, libelle) VALUES ('COMP0012', 'Flutter') ON CONFLICT (id) DO NOTHING;

-- Réseaux sociaux
INSERT INTO reseaux_sociaux (id, libelle, icone) VALUES ('RSX00001', 'LinkedIn', 'fa-linkedin') ON CONFLICT (id) DO NOTHING;
INSERT INTO reseaux_sociaux (id, libelle, icone) VALUES ('RSX00002', 'GitHub', 'fa-github') ON CONFLICT (id) DO NOTHING;
INSERT INTO reseaux_sociaux (id, libelle, icone) VALUES ('RSX00003', 'Twitter / X', 'fa-twitter') ON CONFLICT (id) DO NOTHING;
INSERT INTO reseaux_sociaux (id, libelle, icone) VALUES ('RSX00004', 'Facebook', 'fa-facebook') ON CONFLICT (id) DO NOTHING;
INSERT INTO reseaux_sociaux (id, libelle, icone) VALUES ('RSX00005', 'Portfolio personnel', 'fa-globe') ON CONFLICT (id) DO NOTHING;

-- Exemples d'écoles
INSERT INTO ecole (id, libelle) VALUES ('ECOL0001', 'ITU (Information Technology University)') ON CONFLICT (id) DO NOTHING;
INSERT INTO ecole (id, libelle) VALUES ('ECOL0002', 'ENS') ON CONFLICT (id) DO NOTHING;
INSERT INTO ecole (id, libelle) VALUES ('ECOL0003', 'Université d''Antananarivo') ON CONFLICT (id) DO NOTHING;
INSERT INTO ecole (id, libelle) VALUES ('ECOL0004', 'ISPM') ON CONFLICT (id) DO NOTHING;
