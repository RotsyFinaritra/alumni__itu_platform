CREATE TABLE promesse (
                          id                  VARCHAR(50) PRIMARY KEY,
                          daty                DATE,

                          idCategorieDonateur  VARCHAR(50),
                          idEntiteDonateur     VARCHAR(50),
                          idRecepteur          VARCHAR(50),
                          idProjet             VARCHAR(50),

                          description          TEXT,
                          materiel             TEXT,

                          qte                 INTEGER,

                          montant              DOUBLE PRECISION,
                          idDevise             VARCHAR(50),
                          tauxDeChange         DOUBLE PRECISION,
                          montantMga           DOUBLE PRECISION
);

create sequence seqpromesse
    minvalue 1
    maxvalue 999999999999
    start with 1
    increment by 1
    cache 20;


CREATE OR REPLACE FUNCTION getseqpromesse()
    RETURNS integer
    LANGUAGE plpgsql
AS
$function$
BEGIN
RETURN (SELECT nextval('seqpromesse'));
END
$function$
;

