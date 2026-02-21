create view donationlibcpl_mobilemoney as
select * from donationlibcpl where idcategorie='CAT0002' or idcategorie='CAT0003';

create view donationlibcpl_materiel as
select * from donationlibcpl where idcategorie='CAT0004' or idcategorie='CAT0005';