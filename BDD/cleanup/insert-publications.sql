-- ============================================================================
-- Script d'insertion de 40 publications avec détails par type
-- Date: 2026-02-27
-- Description: Publications variées (discussion, emploi, stage, activité, projet)
--              avec commentaires, likes et notifications
-- ============================================================================
-- Références :
--   Types pub:   TYP00001=Stage, TYP00002=Emploi, TYP00003=Activité, TYP00004=Projet, TYP00005=Discussion
--   Statut:      STAT00002=Publié
--   Visibilité:  VISI00001=Public, VISI00002=Groupe, VISI00003=Privé, VISI00004=Promotion
--   Utilisateurs: 201-220

-- ============================================================================
-- 1. POSTS (40 publications)
-- ============================================================================
INSERT INTO posts (id, idutilisateur, idgroupe, idtypepublication, idstatutpublication, idvisibilite, contenu, epingle, supprime, nb_likes, nb_commentaires, nb_partages, created_at)
VALUES
-- === DISCUSSIONS (10) ===
('POST100001', 201, NULL, 'TYP00005', 'STAT00002', 'VISI00001', 'Bonjour à tous les alumni ! Quelles sont les technologies que vous utilisez le plus en 2026 ? Personnellement, je suis passé à Rust pour le backend et c''est un vrai game changer.', 0, 0, 3, 2, 0, '2026-02-10 08:30:00'),
('POST100002', 203, NULL, 'TYP00005', 'STAT00002', 'VISI00001', 'Quelqu''un a des retours sur les bootcamps en Data Science à Madagascar ? Je cherche à me reconvertir après 3 ans en dev web.', 0, 0, 2, 1, 0, '2026-02-10 14:15:00'),
('POST100003', 209, NULL, 'TYP00005', 'STAT00002', 'VISI00004', 'Est-ce que les L3 de cette année ont déjà trouvé leur lieu de stage ? On pourrait s''organiser pour partager nos contacts.', 0, 0, 5, 3, 0, '2026-02-11 09:00:00'),
('POST100004', 217, NULL, 'TYP00005', 'STAT00002', 'VISI00001', 'Rappel : les inscriptions pour le concours national de programmation sont ouvertes jusqu''au 15 mars. N''hésitez pas à former vos équipes !', 1, 0, 8, 2, 0, '2026-02-12 07:45:00'),
('POST100005', 205, NULL, 'TYP00005', 'STAT00002', 'VISI00001', 'Retour d''expérience : après 5 ans chez Orange, je viens de lancer ma propre boîte spécialisée en cybersécurité. AMA !', 0, 0, 12, 4, 0, '2026-02-13 10:30:00'),
('POST100006', 210, NULL, 'TYP00005', 'STAT00002', 'VISI00004', 'Comment vous gérez le stress des examens ? J''ai du mal à jongler entre les projets et les partiels cette année.', 0, 0, 4, 2, 0, '2026-02-14 16:00:00'),
('POST100007', 207, NULL, 'TYP00005', 'STAT00002', 'VISI00001', 'Je viens de publier un article sur Medium à propos de l''IA générative appliquée à l''éducation à Madagascar. Lien dans les commentaires !', 0, 0, 6, 1, 0, '2026-02-15 11:20:00'),
('POST100008', 218, NULL, 'TYP00005', 'STAT00002', 'VISI00001', 'Nouveau cours disponible sur la plateforme : Introduction au Cloud Computing avec AWS. Ouvert à tous les étudiants et alumni.', 1, 0, 9, 3, 0, '2026-02-16 08:00:00'),
('POST100009', 213, NULL, 'TYP00005', 'STAT00002', 'VISI00001', 'Premier hackathon terminé ! Notre équipe a fini 2ème. L''expérience était incroyable, je recommande à tous de participer.', 0, 0, 7, 2, 0, '2026-02-17 19:30:00'),
('POST100010', 206, NULL, 'TYP00005', 'STAT00002', 'VISI00001', 'Qui serait intéressé par un meetup mensuel des alumni ITU à Tana ? On pourrait alterner présentations techniques et networking.', 0, 0, 10, 5, 0, '2026-02-18 13:00:00'),

-- === OFFRES D'EMPLOI (10) ===
('POST100011', 201, NULL, 'TYP00002', 'STAT00002', 'VISI00001', 'Notre entreprise recrute un développeur Java/Spring Boot confirmé. Expérience minimum 2 ans. Télétravail partiel possible.', 0, 0, 3, 1, 0, '2026-02-11 09:00:00'),
('POST100012', 204, NULL, 'TYP00002', 'STAT00002', 'VISI00001', 'Poste de Data Analyst ouvert chez BICI Madagascar. Maîtrise de Python et SQL requise. Salaire compétitif.', 0, 0, 5, 2, 0, '2026-02-12 10:00:00'),
('POST100013', 208, NULL, 'TYP00002', 'STAT00002', 'VISI00001', 'BNI Madagascar cherche un administrateur réseau senior. Certifications Cisco souhaitées.', 0, 0, 2, 0, 0, '2026-02-13 08:30:00'),
('POST100014', 205, NULL, 'TYP00002', 'STAT00002', 'VISI00001', 'Startup en cybersécurité recherche développeur fullstack. Stack : React + Node.js + PostgreSQL.', 0, 0, 7, 3, 0, '2026-02-14 11:00:00'),
('POST100015', 202, NULL, 'TYP00002', 'STAT00002', 'VISI00001', 'Orange Madagascar recrute un chef de projet IT. Management d''équipe de 5 personnes. CDI.', 0, 0, 4, 1, 0, '2026-02-15 09:30:00'),
('POST100016', 206, NULL, 'TYP00002', 'STAT00002', 'VISI00001', 'Recherche DevOps Engineer pour une mission longue durée. Docker, Kubernetes, CI/CD requis.', 0, 0, 6, 2, 0, '2026-02-16 14:00:00'),
('POST100017', 203, NULL, 'TYP00002', 'STAT00002', 'VISI00001', 'Yas Madagascar recrute un UX/UI Designer. Maîtrise de Figma obligatoire. Portfolio à fournir.', 0, 0, 3, 1, 0, '2026-02-17 10:00:00'),
('POST100018', 207, NULL, 'TYP00002', 'STAT00002', 'VISI00001', 'Poste de Tech Lead Mobile ouvert. Flutter ou React Native. Équipe dynamique et projets innovants.', 0, 0, 8, 2, 0, '2026-02-18 08:00:00'),
('POST100019', 201, NULL, 'TYP00002', 'STAT00002', 'VISI00001', 'Consultant ERP SAP recherché par un cabinet de conseil à Tana. Déplacements ponctuels en province.', 0, 0, 1, 0, 0, '2026-02-19 15:00:00'),
('POST100020', 208, NULL, 'TYP00002', 'STAT00002', 'VISI00001', 'Ingénieur Machine Learning chez une fintech malgache. TensorFlow/PyTorch requis. Remote possible.', 0, 0, 5, 1, 0, '2026-02-20 09:00:00'),

-- === OFFRES DE STAGE (8) ===
('POST100021', 217, NULL, 'TYP00001', 'STAT00002', 'VISI00001', 'Stage de 3 mois en développement web chez BICI. Formation assurée, indemnité incluse.', 0, 0, 6, 2, 0, '2026-02-12 08:00:00'),
('POST100022', 218, NULL, 'TYP00001', 'STAT00002', 'VISI00001', 'Stage PFE en Intelligence Artificielle. Sujet : détection de fraude par deep learning. Niveau Master requis.', 0, 0, 4, 1, 0, '2026-02-13 10:30:00'),
('POST100023', 204, NULL, 'TYP00001', 'STAT00002', 'VISI00001', 'BNI propose un stage de 6 mois en administration système. Les L3 et M1 sont les bienvenus.', 0, 0, 3, 1, 0, '2026-02-14 09:00:00'),
('POST100024', 219, NULL, 'TYP00001', 'STAT00002', 'VISI00001', 'Stage en Data Science chez Orange Madagascar. Python, pandas, scikit-learn requis. 4 mois.', 0, 0, 5, 2, 0, '2026-02-15 07:30:00'),
('POST100025', 202, NULL, 'TYP00001', 'STAT00002', 'VISI00001', 'Yas Madagascar offre un stage en développement mobile Flutter. Durée 3 mois, possibilité d''embauche.', 0, 0, 7, 3, 0, '2026-02-16 10:00:00'),
('POST100026', 205, NULL, 'TYP00001', 'STAT00002', 'VISI00001', 'Stage en cybersécurité : tests de pénétration et audit. Connaissances Linux et réseaux requises.', 0, 0, 2, 0, 0, '2026-02-17 08:00:00'),
('POST100027', 220, NULL, 'TYP00001', 'STAT00002', 'VISI00001', 'Stage cloud computing chez Telma. AWS/Azure, Terraform. Niveau M1 minimum. 6 places disponibles.', 0, 0, 4, 1, 0, '2026-02-18 11:00:00'),
('POST100028', 206, NULL, 'TYP00001', 'STAT00002', 'VISI00001', 'Stage backend Java/Spring chez une startup fintech. Microservices, API REST. 4 mois rémunérés.', 0, 0, 3, 1, 0, '2026-02-19 09:30:00'),

-- === ACTIVITÉS / ÉVÉNEMENTS (7) ===
('POST100029', 217, NULL, 'TYP00003', 'STAT00002', 'VISI00001', 'Grande conférence sur l''IA et son impact sur le marché du travail à Madagascar. Entrée gratuite !', 0, 0, 15, 4, 0, '2026-02-13 07:00:00'),
('POST100030', 206, NULL, 'TYP00003', 'STAT00002', 'VISI00001', 'Hackathon ITU 2026 : 48h pour innover ! Thème : solutions numériques pour l''éducation. Inscrivez-vous vite.', 1, 0, 20, 6, 0, '2026-02-14 08:00:00'),
('POST100031', 218, NULL, 'TYP00003', 'STAT00002', 'VISI00001', 'Atelier pratique : déployer une application sur AWS en 2 heures. Ouvert aux étudiants L3 et Master.', 0, 0, 8, 2, 0, '2026-02-16 10:00:00'),
('POST100032', 219, NULL, 'TYP00003', 'STAT00002', 'VISI00001', 'Séminaire sur la blockchain et ses applications en Afrique. Intervenants internationaux confirmés.', 0, 0, 6, 1, 0, '2026-02-18 09:00:00'),
('POST100033', 205, NULL, 'TYP00003', 'STAT00002', 'VISI00001', 'Rencontre alumni promotion Soa : retrouvailles et partage d''expériences. Resto La Varangue, 19h.', 0, 0, 11, 3, 0, '2026-02-20 12:00:00'),
('POST100034', 220, NULL, 'TYP00003', 'STAT00002', 'VISI00001', 'Compétition de programmation inter-universités. Prizes : stages chez Orange et BNI. Inscriptions ouvertes.', 0, 0, 9, 2, 0, '2026-02-22 08:00:00'),
('POST100035', 209, NULL, 'TYP00003', 'STAT00002', 'VISI00004', 'Sortie promotion Ravo : journée détente à Antsirabe le 8 mars. Participation : 20 000 Ar. Confirmez avant le 1er mars.', 0, 0, 13, 5, 0, '2026-02-23 14:00:00'),

-- === PROJETS (5) ===
('POST100036', 211, NULL, 'TYP00004', 'STAT00002', 'VISI00001', 'Projet open source : application de gestion scolaire pour les écoles rurales de Madagascar. Contributeurs bienvenus !', 0, 0, 9, 3, 0, '2026-02-15 10:00:00'),
('POST100037', 207, NULL, 'TYP00004', 'STAT00002', 'VISI00001', 'Lancement de notre projet de chatbot IA pour l''orientation universitaire. Stack : Python + Langchain + React.', 0, 0, 7, 2, 0, '2026-02-17 11:00:00'),
('POST100038', 212, NULL, 'TYP00004', 'STAT00002', 'VISI00001', 'Projet IoT : surveillance de la qualité de l''air à Tana avec des capteurs Arduino. Recherche partenaires techniques.', 0, 0, 5, 1, 0, '2026-02-19 14:00:00'),
('POST100039', 215, NULL, 'TYP00004', 'STAT00002', 'VISI00001', 'Application mobile e-santé pour le suivi des patients en zone rurale. Flutter + Firebase. Equipe de 4, cherche un designer.', 0, 0, 6, 2, 0, '2026-02-21 09:00:00'),
('POST100040', 214, NULL, 'TYP00004', 'STAT00002', 'VISI00001', 'Plateforme de covoiturage pour étudiants malgaches. En cours de développement, beta prévue en mars.', 0, 0, 4, 1, 0, '2026-02-23 16:00:00');

-- ============================================================================
-- 2. POST_EMPLOI (détails pour les 10 offres d'emploi)
-- ============================================================================
INSERT INTO post_emploi (post_id, entreprise, localisation, poste, type_contrat, salaire_min, salaire_max, devise, experience_requise, competences_requises, niveau_etude_requis, teletravail_possible, date_limite, contact_email, contact_tel, lien_candidature, identreprise)
VALUES
('POST100011', NULL, 'Antananarivo',    'Développeur Java/Spring Boot',  'CDI',  800000.00,  1500000.00, 'MGA', '2 ans minimum',           'Java, Spring Boot, PostgreSQL, REST API',  'DIPL0001', 1, '2026-03-15', 'rh@entreprise.mg',     '0341000001', 'https://jobs.mg/java-dev',        'ENT1'),
('POST100012', NULL, 'Antananarivo',    'Data Analyst',                  'CDI',  600000.00,  1200000.00, 'MGA', '1 an minimum',            'Python, SQL, Power BI, Excel avancé',      'DIPL0001', 0, '2026-03-20', 'recrutement@bici.mg',  '0341000004', 'https://bici.mg/careers',         'ENT1'),
('POST100013', NULL, 'Antananarivo',    'Administrateur Réseau Senior',  'CDI',  1000000.00, 2000000.00, 'MGA', '3 ans minimum',           'Cisco, Linux, Windows Server, Firewall',   'DIPL0002', 0, '2026-03-25', 'rh@bni.mg',           '0341000008', 'https://bni.mg/recrutement',      'ENT3'),
('POST100014', NULL, 'Antananarivo',    'Développeur Fullstack',         'CDI',  700000.00,  1400000.00, 'MGA', 'Junior accepté',          'React, Node.js, PostgreSQL, Git',          'DIPL0001', 1, '2026-03-18', 'jobs@cybersec.mg',     '0341000005', 'https://cybersec.mg/apply',       NULL),
('POST100015', NULL, 'Antananarivo',    'Chef de Projet IT',             'CDI',  1200000.00, 2500000.00, 'MGA', '4 ans minimum',           'Gestion de projet, Agile, JIRA',           'DIPL0002', 0, '2026-03-30', 'talent@orange.mg',     '0341000002', 'https://orange.mg/jobs',          'ENT4'),
('POST100016', NULL, 'Antananarivo',    'DevOps Engineer',               'CDD',  900000.00,  1800000.00, 'MGA', '2 ans minimum',           'Docker, Kubernetes, Jenkins, Terraform',   'DIPL0001', 1, '2026-03-22', 'devops@tech.mg',       '0341000006', 'https://tech.mg/devops',          NULL),
('POST100017', NULL, 'Antananarivo',    'UX/UI Designer',                'CDI',  500000.00,  1000000.00, 'MGA', '1 an minimum',            'Figma, Adobe XD, Design System',           'DIPL0001', 1, '2026-03-28', 'design@yas.mg',        '0341000003', 'https://yas.mg/careers',          'ENT2'),
('POST100018', NULL, 'Antananarivo',    'Tech Lead Mobile',              'CDI',  1000000.00, 2200000.00, 'MGA', '3 ans minimum',           'Flutter, React Native, Firebase',          'DIPL0002', 1, '2026-04-01', 'mobile@tech.mg',       '0341000007', 'https://tech.mg/mobile',          NULL),
('POST100019', NULL, 'Antananarivo',    'Consultant ERP SAP',            'CDI',  1500000.00, 3000000.00, 'MGA', '5 ans minimum',           'SAP ABAP, SAP HANA, Gestion de projet',   'DIPL0002', 0, '2026-04-10', 'sap@consulting.mg',    '0341000001', 'https://consulting.mg/sap',       NULL),
('POST100020', NULL, 'Antananarivo',    'Ingénieur Machine Learning',    'CDI',  800000.00,  1800000.00, 'MGA', '2 ans minimum',           'TensorFlow, PyTorch, Python, MLOps',       'DIPL0002', 1, '2026-04-05', 'ml@fintech.mg',        '0341000008', 'https://fintech.mg/ml-engineer',  NULL);

-- ============================================================================
-- 3. POST_STAGE (détails pour les 8 offres de stage)
-- ============================================================================
INSERT INTO post_stage (post_id, entreprise, localisation, duree, date_debut, date_fin, indemnite, niveau_etude_requis, competences_requises, convention_requise, places_disponibles, contact_email, contact_tel, lien_candidature, identreprise)
VALUES
('POST100021', NULL, 'Antananarivo', '3 mois',  '2026-04-01', '2026-06-30', 200000.00, 'DIPL0001', 'HTML, CSS, JavaScript, PHP',           1, 5,  'stage@bici.mg',       '0341000004', 'https://bici.mg/stages',          'ENT1'),
('POST100022', NULL, 'Antananarivo', '6 mois',  '2026-03-15', '2026-09-15', 300000.00, 'DIPL0002', 'Python, TensorFlow, Deep Learning',    1, 2,  'ia@research.mg',      '0341000017', 'https://research.mg/pfe',         NULL),
('POST100023', NULL, 'Antananarivo', '6 mois',  '2026-04-01', '2026-09-30', 250000.00, 'DIPL0001', 'Linux, Windows Server, Réseaux',       1, 3,  'stage@bni.mg',        '0341000008', 'https://bni.mg/stages',           'ENT3'),
('POST100024', NULL, 'Antananarivo', '4 mois',  '2026-04-15', '2026-08-15', 280000.00, 'DIPL0001', 'Python, pandas, scikit-learn, SQL',    1, 4,  'data@orange.mg',      '0341000018', 'https://orange.mg/stages',        'ENT4'),
('POST100025', NULL, 'Antananarivo', '3 mois',  '2026-05-01', '2026-07-31', 200000.00, 'DIPL0001', 'Flutter, Dart, Firebase',              0, 3,  'mobile@yas.mg',       '0341000002', 'https://yas.mg/stages',           'ENT2'),
('POST100026', NULL, 'Antananarivo', '4 mois',  '2026-04-01', '2026-07-31', 250000.00, 'DIPL0001', 'Linux, Kali, Wireshark, Pentesting',   1, 2,  'sec@cybersec.mg',     '0341000005', 'https://cybersec.mg/stage',       NULL),
('POST100027', NULL, 'Antananarivo', '6 mois',  '2026-04-01', '2026-09-30', 350000.00, 'DIPL0002', 'AWS, Azure, Terraform, Docker',        1, 6,  'cloud@telma.mg',      '0341000019', 'https://telma.mg/stages',         NULL),
('POST100028', NULL, 'Antananarivo', '4 mois',  '2026-05-01', '2026-08-31', 220000.00, 'DIPL0001', 'Java, Spring Boot, Microservices',     1, 3,  'dev@fintech-startup.mg','0341000006','https://fintech-startup.mg/stage', NULL);

-- ============================================================================
-- 4. POST_ACTIVITE (détails pour les 7 événements)
-- ============================================================================
INSERT INTO post_activite (post_id, titre, lieu, adresse, date_debut, date_fin, prix, nombre_places, places_restantes, contact_email, contact_tel, lien_inscription, lien_externe, idcategorie)
VALUES
('POST100029', 'Conférence IA et Emploi',             'ITU Andoharanofotsy',  'Andoharanofotsy, Antananarivo',           '2026-03-10 09:00:00', '2026-03-10 17:00:00', 0,     200, 200, 'conf@itu.mg',       '0341000017', 'https://itu.mg/conf-ia',      NULL, 'CATACT001'),
('POST100030', 'Hackathon ITU 2026',                  'ITU Andoharanofotsy',  'Andoharanofotsy, Antananarivo',           '2026-03-15 08:00:00', '2026-03-17 18:00:00', 15000, 100, 100, 'hackathon@itu.mg',  '0341000006', 'https://itu.mg/hackathon',    NULL, 'CATACT006'),
('POST100031', 'Atelier Déploiement AWS',             'Salle B12, ITU',       'Andoharanofotsy, Antananarivo',           '2026-03-20 14:00:00', '2026-03-20 16:00:00', 0,     30,  30,  'aws@itu.mg',        '0341000018', 'https://itu.mg/atelier-aws',  NULL, 'CATACT002'),
('POST100032', 'Séminaire Blockchain en Afrique',     'Hôtel Carlton',        'Anosy, Antananarivo',                     '2026-03-25 09:00:00', '2026-03-25 16:00:00', 25000, 150, 150, 'blockchain@tech.mg','0341000019', 'https://tech.mg/blockchain',  NULL, 'CATACT003'),
('POST100033', 'Retrouvailles Promotion Soa',         'La Varangue',          'Ambohijatovo, Antananarivo',              '2026-03-08 19:00:00', '2026-03-08 23:00:00', 30000, 50,  50,  'alumni.soa@itu.mg', '0341000005', NULL,                          NULL, 'CATACT005'),
('POST100034', 'Compétition Inter-Universités',       'ITU Andoharanofotsy',  'Andoharanofotsy, Antananarivo',           '2026-04-05 08:00:00', '2026-04-05 18:00:00', 0,     80,  80,  'competition@itu.mg','0341000020', 'https://itu.mg/competition',  NULL, 'CATACT006'),
('POST100035', 'Sortie Promotion Ravo - Antsirabe',   'Antsirabe',            'Antsirabe, Vakinankaratra',               '2026-03-08 07:00:00', '2026-03-08 19:00:00', 20000, 40,  40,  'ravo@itu.mg',       '0341000009', NULL,                          NULL, 'CATACT007');

-- ============================================================================
-- 5. POST_TOPICS (tags pour les publications)
-- ============================================================================
INSERT INTO post_topics (id, post_id, topic_id, created_at)
VALUES
('PTOP10001', 'POST100001', 'TOP00001', '2026-02-10 08:30:00'),
('PTOP10002', 'POST100002', 'TOP00004', '2026-02-10 14:15:00'),
('PTOP10003', 'POST100003', 'TOP00010', '2026-02-11 09:00:00'),
('PTOP10004', 'POST100004', 'TOP00001', '2026-02-12 07:45:00'),
('PTOP10005', 'POST100005', 'TOP00020', '2026-02-13 10:30:00'),
('PTOP10006', 'POST100009', 'TOP00001', '2026-02-17 19:30:00'),
('PTOP10007', 'POST100010', 'TOP00024', '2026-02-18 13:00:00'),
('PTOP10008', 'POST100011', 'TOP00011', '2026-02-11 09:00:00'),
('PTOP10009', 'POST100012', 'TOP00011', '2026-02-12 10:00:00'),
('PTOP10010', 'POST100014', 'TOP00011', '2026-02-14 11:00:00'),
('PTOP10011', 'POST100021', 'TOP00010', '2026-02-12 08:00:00'),
('PTOP10012', 'POST100022', 'TOP00010', '2026-02-13 10:30:00'),
('PTOP10013', 'POST100024', 'TOP00010', '2026-02-15 07:30:00'),
('PTOP10014', 'POST100029', 'TOP00022', '2026-02-13 07:00:00'),
('PTOP10015', 'POST100030', 'TOP00022', '2026-02-14 08:00:00'),
('PTOP10016', 'POST100036', 'TOP00025', '2026-02-15 10:00:00'),
('PTOP10017', 'POST100037', 'TOP00025', '2026-02-17 11:00:00'),
('PTOP10018', 'POST100039', 'TOP00025', '2026-02-21 09:00:00');

-- ============================================================================
-- 6. COMMENTAIRES (quelques commentaires sur les posts)
-- ============================================================================
INSERT INTO commentaires (id, idutilisateur, post_id, parent_id, contenu, supprime, created_at)
VALUES
-- Sur le post discussion technos (POST100001)
('COM100001', 209, 'POST100001', NULL,        'Super intéressant ! Moi je suis encore sur Python/Django mais Rust me tente aussi.', 0, '2026-02-10 09:15:00'),
('COM100002', 211, 'POST100001', 'COM100001', 'Django c''est très bien pour le prototypage rapide. Rust c''est mieux pour la performance.', 0, '2026-02-10 10:00:00'),

-- Sur bootcamp data science (POST100002)
('COM100003', 204, 'POST100002', NULL, 'J''ai fait un bootcamp chez DataCamp, c''était vraiment top. Je te recommande.', 0, '2026-02-10 15:30:00'),

-- Sur la recherche de stage L3 (POST100003)
('COM100004', 211, 'POST100003', NULL, 'Moi j''ai envoyé à Orange et BNI, toujours en attente de réponse.', 0, '2026-02-11 10:00:00'),
('COM100005', 212, 'POST100003', NULL, 'Essaye aussi les startups, elles recrutent beaucoup de stagiaires en ce moment.', 0, '2026-02-11 11:30:00'),
('COM100006', 214, 'POST100003', 'COM100004', 'Orange recrute pas mal en ce moment, tu devrais avoir une réponse bientôt.', 0, '2026-02-11 12:15:00'),

-- Sur le concours programmation (POST100004)
('COM100007', 213, 'POST100004', NULL, 'Trop bien ! On cherche un 3ème membre pour notre équipe, quelqu''un intéressé ?', 0, '2026-02-12 08:30:00'),
('COM100008', 215, 'POST100004', 'COM100007', 'Je suis partant ! Envoie-moi un message.', 0, '2026-02-12 09:00:00'),

-- Sur l'AMA cybersécurité (POST100005)
('COM100009', 202, 'POST100005', NULL, 'Félicitations ! Quels sont les plus gros défis quand on lance sa boîte à Madagascar ?', 0, '2026-02-13 11:00:00'),
('COM100010', 205, 'POST100005', 'COM100009', 'Merci ! Le plus dur c''est l''accès au financement et la confiance des clients locaux.', 0, '2026-02-13 11:45:00'),
('COM100011', 206, 'POST100005', NULL, 'Bravo Solo ! Tu embauches des juniors bientôt ?', 0, '2026-02-13 12:30:00'),
('COM100012', 205, 'POST100005', 'COM100011', 'Oui on prévoit de recruter 2 juniors au Q2. Restez connectés !', 0, '2026-02-13 13:00:00'),

-- Sur les examens (POST100006)
('COM100013', 213, 'POST100006', NULL, 'Pareil pour moi... Le planning de révision ça aide beaucoup.', 0, '2026-02-14 17:00:00'),
('COM100014', 216, 'POST100006', NULL, 'Courage ! N''hésite pas à demander de l''aide aux profs.', 0, '2026-02-14 18:00:00'),

-- Sur le post emploi fullstack (POST100014)
('COM100015', 209, 'POST100014', NULL, 'C''est exactement mon stack ! Comment postuler ?', 0, '2026-02-14 12:00:00'),
('COM100016', 211, 'POST100014', NULL, 'Le télétravail est possible à 100% ou partiel ?', 0, '2026-02-14 13:30:00'),
('COM100017', 205, 'POST100014', 'COM100015', 'Envoie ton CV à jobs@cybersec.mg avec ta lettre de motivation !', 0, '2026-02-14 14:00:00'),

-- Sur le meetup alumni (POST100010)
('COM100018', 201, 'POST100010', NULL, 'Excellente idée ! Je propose qu''on fixe le premier pour mi-mars.', 0, '2026-02-18 14:00:00'),
('COM100019', 203, 'POST100010', NULL, 'Je suis dispo ! On pourrait commencer par un talk sur le DevOps.', 0, '2026-02-18 14:30:00'),
('COM100020', 207, 'POST100010', 'COM100018', 'Mi-mars ça me va. Un samedi matin ce serait parfait pour tout le monde.', 0, '2026-02-18 15:00:00'),
('COM100021', 208, 'POST100010', NULL, 'Super initiative, comptez sur moi !', 0, '2026-02-18 16:00:00'),
('COM100022', 204, 'POST100010', 'COM100019', 'Un talk DevOps + un atelier pratique Docker ce serait top.', 0, '2026-02-18 17:00:00'),

-- Sur le hackathon (POST100030)
('COM100023', 209, 'POST100030', NULL, 'On s''inscrit avec mon équipe ! C''est le thème parfait pour nous.', 0, '2026-02-14 09:00:00'),
('COM100024', 213, 'POST100030', NULL, 'Trop hâte ! On a déjà une idée de projet.', 0, '2026-02-14 10:00:00'),
('COM100025', 210, 'POST100030', NULL, 'Est-ce que les équipes mixtes étudiants-alumni sont autorisées ?', 0, '2026-02-14 11:00:00'),
('COM100026', 206, 'POST100030', 'COM100025', 'Oui, les équipes mixtes sont encouragées ! Max 5 personnes par équipe.', 0, '2026-02-14 11:30:00'),
('COM100027', 215, 'POST100030', NULL, 'Je cherche une équipe, quelqu''un veut bien de moi ?', 0, '2026-02-14 12:00:00'),
('COM100028', 214, 'POST100030', 'COM100027', 'Viens avec nous ! On est 3 pour l''instant.', 0, '2026-02-14 12:30:00'),

-- Sur le projet open source (POST100036)
('COM100029', 209, 'POST100036', NULL, 'Projet très utile ! C''est quel langage/framework ?', 0, '2026-02-15 11:00:00'),
('COM100030', 211, 'POST100036', 'COM100029', 'On utilise React + Express + PostgreSQL. Le repo est sur GitHub.', 0, '2026-02-15 11:30:00'),
('COM100031', 207, 'POST100036', NULL, 'Je voudrais contribuer à la partie UX. Comment rejoindre ?', 0, '2026-02-15 12:00:00');

-- ============================================================================
-- 7. LIKES (répartis sur plusieurs posts)
-- ============================================================================
INSERT INTO likes (id, idutilisateur, post_id, created_at)
VALUES
-- Likes sur POST100001 (discussion technos)
('LIK100001', 203, 'POST100001', '2026-02-10 09:00:00'),
('LIK100002', 209, 'POST100001', '2026-02-10 09:15:00'),
('LIK100003', 211, 'POST100001', '2026-02-10 10:05:00'),

-- Likes sur POST100005 (AMA cybersécurité)
('LIK100004', 201, 'POST100005', '2026-02-13 10:45:00'),
('LIK100005', 202, 'POST100005', '2026-02-13 11:00:00'),
('LIK100006', 203, 'POST100005', '2026-02-13 11:30:00'),
('LIK100007', 206, 'POST100005', '2026-02-13 12:00:00'),
('LIK100008', 207, 'POST100005', '2026-02-13 12:30:00'),
('LIK100009', 208, 'POST100005', '2026-02-13 13:00:00'),
('LIK100010', 209, 'POST100005', '2026-02-13 13:30:00'),
('LIK100011', 210, 'POST100005', '2026-02-13 14:00:00'),
('LIK100012', 211, 'POST100005', '2026-02-13 14:30:00'),
('LIK100013', 213, 'POST100005', '2026-02-13 15:00:00'),
('LIK100014', 215, 'POST100005', '2026-02-13 15:30:00'),
('LIK100015', 217, 'POST100005', '2026-02-13 16:00:00'),

-- Likes sur POST100010 (meetup alumni)
('LIK100016', 201, 'POST100010', '2026-02-18 13:30:00'),
('LIK100017', 202, 'POST100010', '2026-02-18 13:45:00'),
('LIK100018', 203, 'POST100010', '2026-02-18 14:00:00'),
('LIK100019', 204, 'POST100010', '2026-02-18 14:15:00'),
('LIK100020', 205, 'POST100010', '2026-02-18 14:30:00'),
('LIK100021', 207, 'POST100010', '2026-02-18 15:00:00'),
('LIK100022', 208, 'POST100010', '2026-02-18 15:30:00'),
('LIK100023', 209, 'POST100010', '2026-02-18 16:00:00'),
('LIK100024', 213, 'POST100010', '2026-02-18 16:30:00'),
('LIK100025', 218, 'POST100010', '2026-02-18 17:00:00'),

-- Likes sur POST100030 (hackathon)
('LIK100026', 201, 'POST100030', '2026-02-14 08:30:00'),
('LIK100027', 202, 'POST100030', '2026-02-14 08:45:00'),
('LIK100028', 203, 'POST100030', '2026-02-14 09:00:00'),
('LIK100029', 205, 'POST100030', '2026-02-14 09:15:00'),
('LIK100030', 207, 'POST100030', '2026-02-14 09:30:00'),
('LIK100031', 208, 'POST100030', '2026-02-14 09:45:00'),
('LIK100032', 209, 'POST100030', '2026-02-14 10:00:00'),
('LIK100033', 210, 'POST100030', '2026-02-14 10:15:00'),
('LIK100034', 211, 'POST100030', '2026-02-14 10:30:00'),
('LIK100035', 212, 'POST100030', '2026-02-14 10:45:00'),
('LIK100036', 213, 'POST100030', '2026-02-14 11:00:00'),
('LIK100037', 214, 'POST100030', '2026-02-14 11:15:00'),
('LIK100038', 215, 'POST100030', '2026-02-14 11:30:00'),
('LIK100039', 216, 'POST100030', '2026-02-14 11:45:00'),
('LIK100040', 217, 'POST100030', '2026-02-14 12:00:00'),
('LIK100041', 218, 'POST100030', '2026-02-14 12:15:00'),
('LIK100042', 219, 'POST100030', '2026-02-14 12:30:00'),
('LIK100043', 220, 'POST100030', '2026-02-14 12:45:00'),

-- Likes sur divers posts
('LIK100044', 210, 'POST100004', '2026-02-12 08:00:00'),
('LIK100045', 211, 'POST100004', '2026-02-12 08:30:00'),
('LIK100046', 213, 'POST100004', '2026-02-12 09:00:00'),
('LIK100047', 215, 'POST100004', '2026-02-12 09:30:00'),
('LIK100048', 201, 'POST100014', '2026-02-14 11:30:00'),
('LIK100049', 203, 'POST100014', '2026-02-14 12:00:00'),
('LIK100050', 209, 'POST100014', '2026-02-14 12:30:00'),
('LIK100051', 212, 'POST100036', '2026-02-15 10:30:00'),
('LIK100052', 213, 'POST100036', '2026-02-15 11:00:00'),
('LIK100053', 215, 'POST100036', '2026-02-15 11:30:00'),
('LIK100054', 209, 'POST100025', '2026-02-16 10:30:00'),
('LIK100055', 210, 'POST100025', '2026-02-16 11:00:00'),
('LIK100056', 213, 'POST100025', '2026-02-16 11:30:00'),
('LIK100057', 214, 'POST100025', '2026-02-16 12:00:00'),
('LIK100058', 216, 'POST100035', '2026-02-23 14:30:00'),
('LIK100059', 210, 'POST100035', '2026-02-23 15:00:00'),
('LIK100060', 212, 'POST100035', '2026-02-23 15:30:00');

-- ============================================================================
-- 8. NOTIFICATIONS (quelques notifications liées aux likes et commentaires)
-- ============================================================================
INSERT INTO notifications (id, idutilisateur, emetteur_id, idtypenotification, post_id, commentaire_id, contenu, lien, vu, created_at)
VALUES
-- Likes sur POST100001 → notif à l'auteur (201)
('NOT100001', 201, 203, 'TNOT00001', 'POST100001', NULL, 'RANDRIA Tiana a aimé votre publication',               '/post/POST100001', 0, '2026-02-10 09:00:00'),
('NOT100002', 201, 209, 'TNOT00001', 'POST100001', NULL, 'MAHEFA Aina a aimé votre publication',                 '/post/POST100001', 0, '2026-02-10 09:15:00'),

-- Commentaires sur POST100001 → notif à l'auteur (201)
('NOT100003', 201, 209, 'TNOT00002', 'POST100001', 'COM100001', 'MAHEFA Aina a commenté votre publication',      '/post/POST100001', 1, '2026-02-10 09:15:00'),
('NOT100004', 201, 211, 'TNOT00002', 'POST100001', 'COM100002', 'HASINA Miora a commenté votre publication',     '/post/POST100001', 0, '2026-02-10 10:00:00'),

-- Commentaire sur POST100005 → notif à l'auteur (205)
('NOT100005', 205, 202, 'TNOT00002', 'POST100005', 'COM100009', 'RABE Hery a commenté votre publication',        '/post/POST100005', 1, '2026-02-13 11:00:00'),
('NOT100006', 205, 206, 'TNOT00002', 'POST100005', 'COM100011', 'RAZAFY Nomena a commenté votre publication',    '/post/POST100005', 0, '2026-02-13 12:30:00'),

-- Réponse commentaire → notif à l'auteur du commentaire parent
('NOT100007', 209, 211, 'TNOT00007', 'POST100001', 'COM100002', 'HASINA Miora a répondu à votre commentaire',    '/post/POST100001', 0, '2026-02-10 10:00:00'),
('NOT100008', 202, 205, 'TNOT00007', 'POST100005', 'COM100010', 'ANDRIAMAHEFA Solo a répondu à votre commentaire', '/post/POST100005', 1, '2026-02-13 11:45:00'),

-- Likes hackathon → notif à l'auteur (206)
('NOT100009', 206, 201, 'TNOT00001', 'POST100030', NULL, 'RAKOTO Jean a aimé votre publication',                  '/post/POST100030', 1, '2026-02-14 08:30:00'),
('NOT100010', 206, 209, 'TNOT00001', 'POST100030', NULL, 'MAHEFA Aina a aimé votre publication',                  '/post/POST100030', 0, '2026-02-14 10:00:00'),

-- Commentaires hackathon → notif à l'auteur (206)
('NOT100011', 206, 209, 'TNOT00002', 'POST100030', 'COM100023', 'MAHEFA Aina a commenté votre publication',       '/post/POST100030', 1, '2026-02-14 09:00:00'),
('NOT100012', 206, 213, 'TNOT00002', 'POST100030', 'COM100024', 'MANOA Nirina a commenté votre publication',      '/post/POST100030', 0, '2026-02-14 10:00:00');
