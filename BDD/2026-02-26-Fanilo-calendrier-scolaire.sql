-- Calendrier scolaire : table, séquence, fonction PK
-- Date : 2026-02-26

CREATE TABLE calendrier_scolaire (
    id VARCHAR(10) PRIMARY KEY,
    titre VARCHAR(200) NOT NULL,
    description TEXT,
    date_debut DATE NOT NULL,
    date_fin DATE,
    heure_debut VARCHAR(10),
    heure_fin VARCHAR(10),
    couleur VARCHAR(20) DEFAULT '#0095DA',
    idpromotion VARCHAR(10),
    created_by INT REFERENCES utilisateur(refuser),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE seq_calendrier_scolaire START WITH 1 INCREMENT BY 1;

CREATE OR REPLACE FUNCTION getseqcalendrierscolaire() RETURNS INTEGER AS $$
BEGIN
    RETURN nextval('seq_calendrier_scolaire');
END;
$$ LANGUAGE plpgsql;

-- Menu Calendrier Scolaire (visible par tous)
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN007', 'Calendrier', 'calendar_today', '#', 5, 1, NULL);

INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN007-1', 'Calendrier scolaire', 'event', 'module.jsp?but=calendrier/calendrier-scolaire.jsp', 1, 2, 'MENDYN007');

-- Sous-menu admin uniquement : gérer les événements
INSERT INTO menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MENDYN007-2', 'Gérer événements', 'edit_calendar', 'module.jsp?but=calendrier/evenement-liste.jsp', 2, 2, 'MENDYN007');

-- Usermenu : calendrier visible par tous
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM_CAL_ALL', '*', 'MENDYN007', NULL, NULL, NULL, 0);

INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM_CAL_ALL_1', '*', 'MENDYN007-1', NULL, NULL, NULL, 0);

-- Gérer événements : admin uniquement
INSERT INTO usermenu (id, refuser, idmenu, idrole, codeservice, codedir, interdit)
VALUES ('USRM_CAL_ADMIN', NULL, 'MENDYN007-2', 'admin', NULL, NULL, 0);

COMMIT;
