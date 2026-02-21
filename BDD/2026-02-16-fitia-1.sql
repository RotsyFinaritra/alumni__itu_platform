create table recepteur (
    id varchar(255) primary key ,
    val varchar(255),
    desce varchar(255)
);

INSERT INTO recepteur (id, val, desce) VALUES ('RG00001', 'Entreprise ANALAMANGA', 'Bureau National de Gestion des Risques et Catastrophes - Région Analamanga');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00002', 'Entreprise VAKINANKARATRA', 'Entreprise - Région Vakinankaratra');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00003', 'Entreprise ITASY', 'Entreprise - Région Itasy');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00004', 'Entreprise BONGOLAVA', 'Entreprise - Région Bongolava');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00005', 'Entreprise DIANA', 'Entreprise - Région Diana');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00006', 'Entreprise SAVA', 'Entreprise - Région SAVA');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00007', 'Entreprise SOFIA', 'Entreprise - Région Sofia');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00008', 'Entreprise BOENY', 'Entreprise - Région Boeny');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00009', 'Entreprise MELAKY', 'Entreprise - Région Melaky');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00010', 'Entreprise ATSIMO ANDREFANA', 'Entreprise - Région Atsimo Andrefana');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00011', 'Entreprise ANDROY', 'Entreprise - Région Androy');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00012', 'Entreprise ANOSY', 'Entreprise - Région Anosy');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00013', 'Entreprise IHOROMBE', 'Entreprise - Région Ihorombe');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00014', 'Entreprise HAUTE MATSIATRA', 'Entreprise - Région Haute Matsiatra');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00015', 'Entreprise VATOVAVY', 'Entreprise - Région Vatovavy');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00016', 'Entreprise FITOVINANY', 'Entreprise - Région Fitovinany');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00017', 'Entreprise ATSIMO ATSINANANA', 'Entreprise - Région Atsimo Atsinanana');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00018', 'Entreprise ATSINANANA', 'Entreprise - Région Atsinanana');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00019', 'Entreprise ALAOTRA MANGORO', 'Entreprise - Région Alaotra Mangoro');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00020', 'Entreprise ANALANJIROFO', 'Entreprise - Région Analanjirofo');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00021', 'Entreprise AMORON I MANIA', 'Entreprise - Région Amoron’i Mania');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00022', 'Entreprise MENABE', 'Entreprise - Région Menabe');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00023', 'Entreprise BETSIBOKA', 'Entreprise - Région Betsiboka');

INSERT INTO recepteur (id, val, desce) VALUES ('RG00024', 'MINISTERE', 'Ministère concerné (référence table ministere)');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00025', 'CROIX ROUGE MALAGASY', 'Croix Rouge Malagasy');
INSERT INTO recepteur (id, val, desce) VALUES ('RG00026', 'AUTRE', 'Autre organisme ou bénéficiaire');

create table entiteDonateur (
    id varchar(255) primary key ,
    val varchar(255),
    desce varchar(255)
);

-- Fichier complet entiteDonateur (195 pays reconnus ONU)

INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00001','AFGHANISTAN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00002','AFRIQUE DU SUD','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00003','ALBANIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00004','ALGERIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00005','ALLEMAGNE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00006','ANDORRE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00007','ANGOLA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00008','ANTIGUA-ET-BARBUDA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00009','ARABIE SAOUDITE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00010','ARGENTINE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00011','ARMENIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00012','AUSTRALIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00013','AUTRICHE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00014','AZERBAIDJAN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00015','BAHAMAS','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00016','BAHREIN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00017','BANGLADESH','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00018','BARBADE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00019','BELGIQUE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00020','BELIZE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00021','BENIN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00022','BHOUTAN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00023','BIELORUSSIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00024','BIRMANIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00025','BOLIVIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00026','BOSNIE-HERZEGOVINE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00027','BOTSWANA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00028','BRESIL','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00029','BRUNEI','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00030','BULGARIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00031','BURKINA FASO','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00032','BURUNDI','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00033','CAMBODGE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00034','CAMEROUN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00035','CANADA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00036','CAP-VERT','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00037','CENTRAFRIQUE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00038','CHILI','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00039','CHINE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00040','CHYPRE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00041','COLOMBIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00042','COMORES','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00043','CONGO','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00044','CONGO (RDC)','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00045','COREE DU NORD','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00046','COREE DU SUD','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00047','COSTA RICA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00048','COTE D IVOIRE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00049','CROATIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00050','CUBA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00051','DANEMARK','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00052','DJIBOUTI','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00053','DOMINIQUE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00054','EGYPTE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00055','EMIRATS ARABES UNIS','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00056','EQUATEUR','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00057','ERYTHREE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00058','ESPAGNE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00059','ESTONIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00060','ESWATINI','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00061','ETATS-UNIS','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00062','ETHIOPIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00063','FIDJI','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00064','FINLANDE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00065','FRANCE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00066','GABON','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00067','GAMBIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00068','GEORGIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00069','GHANA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00070','GRECE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00071','GRENADE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00072','GUATEMALA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00073','GUINEE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00074','GUINEE-BISSAU','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00075','GUINEE EQUATORIALE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00076','GUYANA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00077','HAITI','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00078','HONDURAS','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00079','HONGRIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00080','ILES MARSHALL','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00081','ILES SALOMON','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00082','INDE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00083','INDONESIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00084','IRAK','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00085','IRAN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00086','IRLANDE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00087','ISLANDE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00088','ISRAEL','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00089','ITALIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00090','JAMAIQUE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00091','JAPON','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00092','JORDANIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00093','KAZAKHSTAN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00094','KENYA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00095','KIRGHIZISTAN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00096','KIRIBATI','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00097','KOWEIT','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00098','LAOS','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00099','LESOTHO','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00100','LETTONIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00101','LIBAN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00102','LIBERIA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00103','LIBYE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00104','LIECHTENSTEIN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00105','LITUANIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00106','LUXEMBOURG','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00107','MACEDOINE DU NORD','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00108','MADAGASCAR','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00109','MALAISIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00110','MALAWI','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00111','MALDIVES','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00112','MALI','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00113','MALTE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00114','MAROC','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00115','MAURICE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00116','MAURITANIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00117','MEXIQUE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00118','MICRONESIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00119','MOLDAVIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00120','MONACO','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00121','MONGOLIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00122','MONTENEGRO','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00123','MOZAMBIQUE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00124','NAMIBIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00125','NAURU','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00126','NEPAL','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00127','NICARAGUA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00128','NIGER','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00129','NIGERIA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00130','NORVEGE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00131','NOUVELLE-ZELANDE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00132','OMAN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00133','OUGANDA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00134','OUZBEKISTAN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00135','PAKISTAN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00136','PALAOS','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00137','PANAMA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00138','PAPOUASIE-NOUVELLE-GUINEE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00139','PARAGUAY','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00140','PAYS-BAS','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00141','PEROU','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00142','PHILIPPINES','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00143','POLOGNE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00144','PORTUGAL','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00145','QATAR','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00146','REPUBLIQUE DOMINICAINE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00147','REPUBLIQUE TCHEQUE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00148','ROUMANIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00149','ROYAUME-UNI','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00150','RUSSIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00151','RWANDA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00152','SAINT-CHRISTOPHE-ET-NIEVES','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00153','SAINT-MARIN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00154','SAINT-VINCENT-ET-LES-GRENADINES','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00155','SAINTE-LUCIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00156','SALVADOR','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00157','SAMOA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00158','SAO TOME-ET-PRINCIPE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00159','SENEGAL','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00160','SERBIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00161','SEYCHELLES','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00162','SIERRA LEONE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00163','SINGAPOUR','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00164','SLOVAQUIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00165','SLOVENIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00166','SOMALIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00167','SOUDAN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00168','SOUDAN DU SUD','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00169','SRI LANKA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00170','SUEDE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00171','SUISSE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00172','SURINAME','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00173','SYRIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00174','TADJIKISTAN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00175','TANZANIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00176','TCHAD','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00177','THAILANDE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00178','TIMOR ORIENTAL','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00179','TOGO','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00180','TONGA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00181','TRINITE-ET-TOBAGO','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00182','TUNISIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00183','TURKMENISTAN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00184','TURQUIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00185','TUVALU','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00186','UKRAINE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00187','URUGUAY','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00188','VANUATU','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00189','VATICAN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00190','VENEZUELA','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00191','VIETNAM','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00192','YEMEN','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00193','ZAMBIE','Etat souverain');
INSERT INTO entiteDonateur (id, val, desce) VALUES ('DN00194','ZIMBABWE','Etat souverain');

INSERT INTO entiteDonateur (id, val, desce)
VALUES ('DN00195', 'BANQUE MONDIALE', 'Groupe de la Banque mondiale');

INSERT INTO entiteDonateur (id, val, desce)
VALUES ('DN00196', 'UNION EUROPEENNE', 'Union Européenne (UE)');

INSERT INTO entiteDonateur (id, val, desce)
VALUES ('DN00197', 'NATIONS UNIES', 'Organisation des Nations Unies (ONU)');

INSERT INTO entiteDonateur (id, val, desce)
VALUES ('DN00198', 'UNION AFRICAINE', 'Union Africaine (UA)');



alter table donation add idRecepteur varchar(255);
alter table donation add numeroPiece varchar(255);
alter table donation add idEntiteDonateur varchar(255);


drop view donationlibcpl;
create or replace view donationlibcpl
as
SELECT d.id,
       d.daty,
       d.nom,
       d.montant,
       d.desce,
       d.idcategorie,
       d.qte,
       d.idcategoriedonateur,
       d.idprojet,
       c.val                                                                                                         AS idcategorielib,
       cd.val                                                                                                        AS idcategoriedonateurlib,
       p.val                                                                                                         AS idprojetlib,
       (d.montant * d.qte)::numeric(30, 2)                                                                           AS total,
       d.idEntiteDonateur,
       e.val as idEntiteDonateurLib,
       d.idRecepteur,
       r.val as idRecepteurLib,
       (((((((COALESCE(d.nom, ''::character varying)::text || ' '::text) ||
             COALESCE(d.desce, ''::character varying)::text) || ' '::text) ||
           COALESCE(cd.val, ''::character varying)::text) || ' '::text) ||
         COALESCE(p.val, ''::character varying)::text) || ' '::text) ||
       COALESCE(c.val, ''::character varying)::text                                                                  AS motsclesss
FROM donation d
         LEFT JOIN categorie c ON c.id::text = d.idcategorie::text
         LEFT JOIN categoriedonateur cd ON cd.id::text = d.idcategoriedonateur::text
         LEFT JOIN projet p ON p.id::text = d.idprojet::text
         left join entiteDonateur e on e.id=d.idEntiteDonateur
         left join recepteur r on r.id=d.idRecepteur;
