-- Script de création des promotions au format P11, P17, etc.
-- A exécuter manuellement dans PostgreSQL

-- Vérifier si les promotions existent déjà avant d'insérer
INSERT INTO promotion (id, libelle, annee) 
SELECT 'P11', 'Promotion 2011', 2011
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P11');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P12', 'Promotion 2012', 2012
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P12');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P13', 'Promotion 2013', 2013
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P13');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P14', 'Promotion 2014', 2014
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P14');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P15', 'Promotion 2015', 2015
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P15');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P16', 'Promotion 2016', 2016
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P16');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P17', 'Promotion 2017', 2017
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P17');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P18', 'Promotion 2018', 2018
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P18');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P19', 'Promotion 2019', 2019
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P19');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P20', 'Promotion 2020', 2020
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P20');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P21', 'Promotion 2021', 2021
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P21');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P22', 'Promotion 2022', 2022
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P22');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P23', 'Promotion 2023', 2023
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P23');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P24', 'Promotion 2024', 2024
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P24');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P25', 'Promotion 2025', 2025
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P25');

INSERT INTO promotion (id, libelle, annee) 
SELECT 'P26', 'Promotion 2026', 2026
WHERE NOT EXISTS (SELECT 1 FROM promotion WHERE id = 'P26');

-- Afficher le résultat
SELECT * FROM promotion WHERE id LIKE 'P%' ORDER BY annee;
