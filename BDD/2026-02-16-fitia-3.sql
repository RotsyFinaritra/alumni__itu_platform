create view donationlibcpl_vivre as
select * from donationlibcpl where idcategorie='CAT0004';

create view donationlibcpl_nonvivre as
select * from donationlibcpl where idcategorie='CAT0005';