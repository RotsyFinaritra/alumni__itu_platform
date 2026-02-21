UPDATE public.categorie
SET val   = 'Argent',
    desce = 'Argent'
WHERE id = 'CAT0003';

INSERT INTO public.categorie (id, val, desce)
VALUES ('CAT0004', 'VIVRE', 'VIVRE');

INSERT INTO public.categorie (id, val, desce)
VALUES ('CAT0005', 'NON VIVRE', 'NON VIVRE');

DELETE
FROM public.categorie
WHERE id = 'CAT0001';

INSERT INTO public.categoriedonateur (id, val, desce)
VALUES ('CATDON0007', 'Association', 'Association');

UPDATE public.menudynamique
SET rang = 5
WHERE id = 'MEN0082';

UPDATE public.menudynamique
SET libelle = 'Liste des dons en argent'
WHERE id = 'MEN0080';

UPDATE public.menudynamique
SET rang = 4
WHERE id = 'MEN0081';

INSERT INTO public.menudynamique (id, libelle, icone, href, rang, niveau, id_pere)
VALUES ('MEN0083', 'Liste des dons matériels', 'list_alt', 'module.jsp?but=donation/donation-liste-tous.jsp', 3, 2,
        'MEN0019');

