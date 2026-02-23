-- Insertion de données d'entreprises pour le système Alumni ITU
-- Date: 2026-02-23
-- Auteur: Copilot

-- Remise à zéro de la séquence des entreprises (optionnel)
-- SELECT setval('seqentreprise', 1, false);

-- Entreprises technologiques Madagascar
INSERT INTO entreprise (id, libelle, idville, description) 
VALUES 
('ENT000001', 'NextMada Technologies', NULL, 'Entreprise leader en développement de solutions digitales à Madagascar'),
('ENT000002', 'Digital Mada', NULL, 'Agence web et mobile spécialisée en e-commerce'),
('ENT000003', 'ITU Innovation Lab', NULL, 'Laboratoire de recherche et développement de l''ITU'),
('ENT000004', 'Telma Madagascar', NULL, 'Opérateur de télécommunications leader à Madagascar'),
('ENT000005', 'Orange Madagascar', NULL, 'Opérateur mobile et fournisseur de services internet'),
('ENT000006', 'Airtel Madagascar', NULL, 'Opérateur de télécommunications mobile');

-- Entreprises internationales tech
INSERT INTO entreprise (id, libelle, idville, description)
VALUES
('ENT000007', 'Google', NULL, 'Géant technologique américain spécialisé dans les services internet'),
('ENT000008', 'Microsoft', NULL, 'Leader mondial en logiciels, cloud computing et intelligence artificielle'),
('ENT000009', 'Amazon', NULL, 'E-commerce, cloud computing (AWS) et technologies diverses'),
('ENT000010', 'Meta (Facebook)', NULL, 'Réseaux sociaux, réalité virtuelle et métaverse'),
('ENT000011', 'Apple', NULL, 'Conception et développement de produits électroniques et logiciels'),
('ENT000012', 'IBM', NULL, 'Solutions d''entreprise, cloud et intelligence artificielle');

-- Startups et PME Madagascar
INSERT INTO entreprise (id, libelle, idville, description)
VALUES
('ENT000013', 'Habaka', NULL, 'Plateforme de réservation en ligne Madagascar'),
('ENT000014', 'Paositra Money', NULL, 'Service de mobile money de la Poste Malagasy'),
('ENT000015', 'GasyNet', NULL, 'Société de services informatiques et réseaux'),
('ENT000016', 'SmartMada', NULL, 'Solutions IoT et Smart City pour Madagascar'),
('ENT000017', 'CodeMada Academy', NULL, 'Centre de formation en programmation et développement web'),
('ENT000018', 'Jovena', NULL, 'Solutions RH et recrutement en ligne');

-- Entreprises consulting et services
INSERT INTO entreprise (id, libelle, idville, description)
VALUES
('ENT000019', 'Accenture', NULL, 'Cabinet de conseil en management et technologies'),
('ENT000020', 'Deloitte Digital', NULL, 'Conseil en transformation digitale'),
('ENT000021', 'Capgemini', NULL, 'Services de conseil, technologies et transformation numérique'),
('ENT000022', 'Sopra Steria', NULL, 'ESN européenne spécialisée dans la transformation digitale'),
('ENT000023', 'CGI', NULL, 'Société de conseil en technologies de l''information');

-- Banques et institutions financières Madagascar
INSERT INTO entreprise (id, libelle, idville, description)
VALUES
('ENT000024', 'BNI Madagascar', NULL, 'Banque Nationale pour l''Industrie - Services bancaires'),
('ENT000025', 'BOA Madagascar', NULL, 'Bank Of Africa - Services bancaires et financiers'),
('ENT000026', 'BFV-SG', NULL, 'Banque malgache du groupe Société Générale'),
('ENT000027', 'Sipem Banque', NULL, 'Banque commerciale malgache'),
('ENT000028', 'Mvola', NULL, 'Service de mobile banking de Telma');

-- E-commerce et retail tech
INSERT INTO entreprise (id, libelle, idville, description)
VALUES
('ENT000029', 'Jumia Madagascar', NULL, 'Plateforme e-commerce leader en Afrique'),
('ENT000030', 'Shopify', NULL, 'Plateforme e-commerce internationale'),
('ENT000031', 'Alibaba', NULL, 'Géant chinois du e-commerce B2B et B2C'),
('ENT000032', 'Salesforce', NULL, 'Leader mondial en CRM cloud');

-- Entreprises données supplémentaires
INSERT INTO entreprise (id, libelle, idville, description)
VALUES
('ENT000033', 'Freelance / Indépendant', NULL, 'Travail en freelance ou consultant indépendant'),
('ENT000034', 'Startup personnelle', NULL, 'Entrepreneur - Création de sa propre startup'),
('ENT000035', 'ONG / Association', NULL, 'Organisation non gouvernementale ou association'),
('ENT000036', 'Fonction publique', NULL, 'Administration publique malgache'),
('ENT000037', 'Enseignement / Recherche', NULL, 'Université, école ou centre de recherche');

-- Mise à jour de la séquence pour qu'elle continue après ENT000037
SELECT setval('seqentreprise', 37, true);

-- Vérification
SELECT COUNT(*) as nombre_entreprises FROM entreprise;
