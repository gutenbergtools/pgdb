--
-- change functions so 245 attribute is used as book.title when present
--

CREATE OR REPLACE FUNCTION public.books_title_update(_fk_books integer)
 RETURNS text
 LANGUAGE sql
AS $_$
    -- helper
    -- calculates book title from attributes table
    SELECT ltrim (substring (attributes.text FROM attributes.nonfiling))
       FROM attributes
       WHERE attributes.fk_books = $1
       AND attributes.fk_attriblist = ANY (ARRAY[240, 245, 246])
       -- take 245 first, the others if there is no 245 for this book.
       ORDER BY 
              CASE WHEN attributes.fk_attriblist = 245
              THEN 1
              ELSE attributes.fk_attriblist
              END       
       LIMIT 1;
$_$;


CREATE OR REPLACE FUNCTION public._books_title(r public.books) RETURNS record
    LANGUAGE plpgsql
    AS $$
    -- helper
    -- calculates book title from attributes table
DECLARE
r2 RECORD;
BEGIN
FOR r2 IN SELECT attributes.text, attributes.nonfiling
       FROM attributes
       WHERE attributes.fk_books = r.pk
       AND attributes.fk_attriblist = ANY (ARRAY[240, 245, 246])
       ORDER BY 
              CASE WHEN attributes.fk_attriblist = 245
              THEN 1
              ELSE attributes.fk_attriblist
              END       
       LIMIT 1 LOOP
       RETURN r2;
END LOOP;

r2.text := NULL;
r2.nonfiling := 0;
RETURN r2;
END;
$$;

-- apply the updated function

UPDATE books
    SET title = NULL
	FROM public.attributes 
	WHERE attributes.fk_books = books.pk
	    AND attributes.fk_attriblist = 240 ; 

