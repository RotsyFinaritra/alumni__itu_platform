-- ============================================================================
-- Script d'insertion de 20 utilisateurs
-- Date: 2026-02-27
-- Description: Ajoute 20 utilisateurs avec des profils variés
-- ============================================================================
-- Rôles : admin, alumni, etudiant, enseignant
-- Types : TU0000001 (Alumni), TU0000002 (Étudiant), TU0000003 (Enseignant)
-- Promotions : P1-P19 (Licence), D1-D6 (Master)

INSERT INTO utilisateur (refuser, loginuser, pwduser, nomuser, adruser, teluser, idrole, rang, prenom, etu, mail, photo, idtypeutilisateur, idpromotion)
VALUES
(201, 'rakoto.jean',     'alumni2026', 'RAKOTO',       'Analakely',         '0341000001', 'alumni',    0, 'Jean',       '2001', 'jean.rakoto@gmail.com',       '', 'TU0000001', 'P5'),
(202, 'rabe.hery',       'alumni2026', 'RABE',         'Ankorondrano',      '0341000002', 'alumni',    0, 'Hery',       '2002', 'hery.rabe@gmail.com',         '', 'TU0000001', 'P7'),
(203, 'randria.tiana',   'alumni2026', 'RANDRIA',      'Ivandry',           '0341000003', 'alumni',    0, 'Tiana',      '2003', 'tiana.randria@gmail.com',     '', 'TU0000001', 'P3'),
(204, 'ravelo.haja',     'alumni2026', 'RAVELO',       'Ambatobe',          '0341000004', 'alumni',    0, 'Haja',       '2004', 'haja.ravelo@gmail.com',       '', 'TU0000001', 'P10'),
(205, 'andria.solo',     'alumni2026', 'ANDRIAMAHEFA', 'Ambohijatovo',      '0341000005', 'alumni',    0, 'Solo',       '2005', 'solo.andria@gmail.com',       '', 'TU0000001', 'P1'),
(206, 'razafy.nomena',   'alumni2026', 'RAZAFY',       'Mahamasina',        '0341000006', 'alumni',    0, 'Nomena',     '2006', 'nomena.razafy@gmail.com',     '', 'TU0000001', 'P12'),
(207, 'rahari.vonjy',    'alumni2026', 'RAHARISON',    'Ampefiloha',        '0341000007', 'alumni',    0, 'Vonjy',      '2007', 'vonjy.rahari@gmail.com',      '', 'TU0000001', 'D2'),
(208, 'ratsima.feno',    'alumni2026', 'RATSIMA',      'Antanimena',        '0341000008', 'alumni',    0, 'Feno',       '2008', 'feno.ratsima@gmail.com',      '', 'TU0000001', 'D4'),

(209, 'mahefa.aina',     'etudiant2026', 'MAHEFA',       'Ankatso',           '0341000009', 'etudiant',  0, 'Aina',       '3001', 'aina.mahefa@itu.mg',          '', 'TU0000002', 'P17'),
(210, 'fitia.lalaina',   'etudiant2026', 'FITIA',        'Ambohipo',          '0341000010', 'etudiant',  0, 'Lalaina',    '3002', 'lalaina.fitia@itu.mg',        '', 'TU0000002', 'P17'),
(211, 'hasina.miora',    'etudiant2026', 'HASINA',       'Andravoahangy',     '0341000011', 'etudiant',  0, 'Miora',      '3003', 'miora.hasina@itu.mg',         '', 'TU0000002', 'P16'),
(212, 'tsiry.rado',      'etudiant2026', 'TSIRINIAINA',  'Amboditsiry',       '0341000012', 'etudiant',  0, 'Rado',       '3004', 'rado.tsiry@itu.mg',           '', 'TU0000002', 'P16'),
(213, 'manoa.nirina',    'etudiant2026', 'MANOA',        'Ankadifotsy',       '0341000013', 'etudiant',  0, 'Nirina',     '3005', 'nirina.manoa@itu.mg',         '', 'TU0000002', 'P15'),
(214, 'faniry.ando',     'etudiant2026', 'FANIRY',       'Behoririka',        '0341000014', 'etudiant',  0, 'Ando',       '3006', 'ando.faniry@itu.mg',          '', 'TU0000002', 'P15'),
(215, 'mamitiana.lova',  'etudiant2026', 'MAMITIANA',    'Anosibe',           '0341000015', 'etudiant',  0, 'Lova',       '3007', 'lova.mamitiana@itu.mg',       '', 'TU0000002', 'D5'),
(216, 'iary.tahina',     'etudiant2026', 'IARY',         'Isotry',            '0341000016', 'etudiant',  0, 'Tahina',     '3008', 'tahina.iary@itu.mg',          '', 'TU0000002', 'D5'),

(217, 'ramana.bodo',     'enseignant2026', 'RAMANANTOANINA', 'Ivato',           '0341000017', 'enseignant', 0, 'Bodo',      '',     'bodo.ramana@itu.mg',          '', 'TU0000003', NULL),
(218, 'rajao.lanto',     'enseignant2026', 'RAJAONARISON',   'Ambohidratrimo',  '0341000018', 'enseignant', 0, 'Lanto',     '',     'lanto.rajao@itu.mg',          '', 'TU0000003', NULL),
(219, 'rako.mamy',       'enseignant2026', 'RAKOTOMALALA',   'Tanjombato',      '0341000019', 'enseignant', 0, 'Mamy',      '',     'mamy.rako@itu.mg',            '', 'TU0000003', NULL),
(220, 'rava.seth',       'enseignant2026', 'RAVALISON',      'Ambanidia',       '0341000020', 'enseignant', 0, 'Seth',      '',     'seth.rava@itu.mg',            '', 'TU0000003', NULL);

-- Mise à jour de la séquence pour les futurs inserts
SELECT setval('utilisateur_refuser_seq', (SELECT MAX(refuser) FROM utilisateur));
