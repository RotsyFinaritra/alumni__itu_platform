
-- 2026-02-23-Elyance-1.sql

-- 1. Création de la table option
CREATE TABLE option (
    id VARCHAR(30) PRIMARY KEY NOT NULL,
    libelle VARCHAR(50) NOT NULL
);

CREATE SEQUENCE seqoption MINVALUE 1 MAXVALUE 999999999999 START WITH 1 INCREMENT BY 1 CACHE 20;
CREATE OR REPLACE FUNCTION getseqoption() RETURNS integer LANGUAGE plpgsql AS $$ BEGIN RETURN (SELECT nextval('seqoption')); END $$;

-- 2. Ajout des données dans option
INSERT INTO option (id, libelle) VALUES ('OP0000001', 'Design'), ('OP0000002', 'Info');

-- 3. Ajout de la colonne id_option dans promotion (avec clé étrangère)
ALTER TABLE promotion ADD COLUMN id_option VARCHAR(30);
ALTER TABLE promotion ADD CONSTRAINT fk_option FOREIGN KEY (id_option) REFERENCES option(id);

INSERT INTO promotion (id, libelle, annee, id_option) VALUES
('P1', 'Faneva', 2026, 'OP0000002'),
('P2', 'Miritsoka', 2026, 'OP0000002'),
('P3', 'Mampionona', 2026, 'OP0000002'),
('P4', 'Harena', 2026, 'OP0000002'),
('P5', 'Soa', 2026, 'OP0000002'),
('P6', 'Tsiky', 2026, 'OP0000002'),
('P7', 'Aina', 2026, 'OP0000002'),
('P8', 'Miaraka', 2026, 'OP0000002'),
('P9', 'Fanilo', 2026, 'OP0000002'),
('P10', 'Hery', 2026, 'OP0000002'),
('P11', 'Tiana', 2026, 'OP0000002'),
('P12', 'Malala', 2026, 'OP0000002'),
('P13', 'Mamy', 2026, 'OP0000002'),
('P14', 'Sitraka', 2026, 'OP0000002'),
('P15', 'Fitiavana', 2026, 'OP0000002'),
('P16', 'Hasina', 2026, 'OP0000002'),
('P17', 'Ravo', 2026, 'OP0000002'),
('P18', 'Fetra', 2026, 'OP0000002'),
('P19', 'Tovo', 2026, 'OP0000002');

-- Design : D1 à D6
INSERT INTO promotion (id, libelle, annee, id_option) VALUES
('D1', 'Faneva', 2026, 'OP0000001'),
('D2', 'Miritsoka', 2026, 'OP0000001'),
('D3', 'Mampionona', 2026, 'OP0000001'),
('D4', 'Harena', 2026, 'OP0000001'),
('D5', 'Soa', 2026, 'OP0000001'),
('D6', 'Tsiky', 2026, 'OP0000001');
