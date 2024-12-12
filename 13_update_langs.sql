-- both lang and pk are set as unique
UPDATE public.langs 
SET lang = 'gd' WHERE pk = 'gla';
UPDATE public.langs 
SET lang = 'nv' WHERE pk = 'nav';
UPDATE public.langs
SET lang = 'oj' WHERE pk = 'oji';

-- add new rows
INSERT INTO public.langs (pk, lang)
VALUES 
    ('gd', 'Gaelic, Scottish'),
    ('oj', 'Ojibwa'),
    ('nv', 'Navajo');

-- update the many2many table
UPDATE public.mn_books_langs
SET fk_langs = 'gd' WHERE fk_langs = 'gla';
UPDATE public.mn_books_langs
SET fk_langs = 'nv' WHERE fk_langs = 'nav';
UPDATE public.mn_books_langs
SET fk_langs = 'oj' WHERE fk_langs = 'oji';

-- update the attributes table
UPDATE public.attributes
SET fk_langs = 'gd' WHERE fk_langs = 'gla';
UPDATE public.attributes
SET fk_langs = 'nv' WHERE fk_langs = 'nav';
UPDATE public.attributes
SET fk_langs = 'oj' WHERE fk_langs = 'oji';

-- remove the deprecated languages
DELETE from public.langs
WHERE pk in ('gla', 'nav', 'oji');
