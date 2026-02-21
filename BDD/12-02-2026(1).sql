CREATE TABLE donation (
      id VARCHAR(30) PRIMARY KEY NOT NULL,
      daty DATE,
      nom VARCHAR(100),
      montant NUMERIC(30,2),
      desce VARCHAR(255),
      idcategorie VARCHAR(255) REFERENCES categorie(id),
      qte NUMERIC(10,2),
      idcategoriedonateur VARCHAR(255) REFERENCES categorieDonateur(id),
      idprojet VARCHAR(255) REFERENCES projet(id)
);

create sequence seqdonation
    minvalue 1
    maxvalue 999999999999
    start with 1
    increment by 1
    cache 20;


CREATE OR REPLACE FUNCTION getsequdonation()
    RETURNS integer
    LANGUAGE plpgsql
    AS
    $function$
BEGIN
RETURN (SELECT nextval('seqdonation'));
END
    $function$
;


create table projet(
    id varchar(255) primary key NOT NULL,
    val varchar(255),
    desce varchar(255)
);

create table categorie(
    id varchar(255) primary key NOT NULL,
    val varchar(255),
    desce varchar(255)
);

create table categorieDonateur(
    id varchar(255) primary key NOT NULL,
    val varchar(255),
    desce varchar(255)
);

create or replace view donationlibcpl as
select d.*, c.val as idcategorielib, cd.val as idcategoriedonateurlib, p.val as idprojetlib from donation d
left join categorie c on c.id = d.idcategorie
left join categoriedonateur cd on cd.id = d.idcategoriedonateur
left join projet p on p.id = d.idprojet;