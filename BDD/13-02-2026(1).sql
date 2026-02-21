CREATE TABLE HISTOIMPORT (
      id VARCHAR(30) PRIMARY KEY NOT NULL,
      daty DATE,
      refobject VARCHAR(100)
);

create sequence seqhistoimport
    minvalue 1
    maxvalue 999999999999
    start with 1
    increment by 1
    cache 20;


CREATE OR REPLACE FUNCTION GETSEQHISTOIMPORT()
    RETURNS integer
    LANGUAGE plpgsql
    AS
    $function$
BEGIN
RETURN (SELECT nextval('seqhistoimport'));
END
    $function$
;
