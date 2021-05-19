--
-- PostgreSQL database dump
--

-- Dumped from database version 10.15
-- Dumped by pg_dump version 10.15

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: gtrgm; Type: SHELL TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.gtrgm;


--
-- Name: gtrgm_in(cstring); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gtrgm_in(cstring) RETURNS public.gtrgm
    LANGUAGE c STRICT
    AS '$libdir/pg_trgm', 'gtrgm_in';


ALTER FUNCTION public.gtrgm_in(cstring) OWNER TO postgres;

--
-- Name: gtrgm_out(public.gtrgm); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gtrgm_out(public.gtrgm) RETURNS cstring
    LANGUAGE c STRICT
    AS '$libdir/pg_trgm', 'gtrgm_out';


ALTER FUNCTION public.gtrgm_out(public.gtrgm) OWNER TO postgres;

--
-- Name: gtrgm; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.gtrgm (
    INTERNALLENGTH = variable,
    INPUT = public.gtrgm_in,
    OUTPUT = public.gtrgm_out,
    ALIGNMENT = int4,
    STORAGE = plain
);


ALTER TYPE public.gtrgm OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = true;

--
-- Name: attributes; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.attributes (
    pk integer DEFAULT nextval(('public.attributes_pk_seq'::text)::regclass) NOT NULL,
    fk_books integer NOT NULL,
    fk_attriblist integer NOT NULL,
    fk_langs character varying(10),
    text text NOT NULL,
    nonfiling integer DEFAULT 0 NOT NULL,
    indicators character varying(2) DEFAULT '  '::character varying,
    tsvec tsvector,
    CONSTRAINT attributes_text CHECK ((text <> ''::text))
);


ALTER TABLE public.attributes OWNER TO gutenberg;

--
-- Name: _attributes_tsvec(public.attributes); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public._attributes_tsvec(r public.attributes) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
	-- creates tsvector from attributes record
BEGIN
	IF r.fk_attriblist IN (240, 245, 246, 440, 505) THEN
	        -- titles
		RETURN setweight (px ('t', r.text), 'B');
 	ELSIF r.fk_attriblist < 900 THEN		      
		-- other attributes we want to search
		RETURN to_tsvector ('pg_catalog.english', r.text);
	END IF;

	RETURN NULL;
END;
$$;


ALTER FUNCTION public._attributes_tsvec(r public.attributes) OWNER TO gutenberg;

--
-- Name: _attributes_tsvec_update(public.attributes); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public._attributes_tsvec_update(r public.attributes) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
-- creates tsvector from attributes record
DECLARE
tsv TSVECTOR := NULL;
BEGIN
IF r.fk_attriblist IN (240, 245, 246, 440, 505) THEN
        -- title
tsv := setweight (to_tsvector (
             'pg_catalog.english', pf2 ('tx', r.text)), 'B');
 ELSIF r.fk_attriblist < 900 THEN      
-- other attributes we want to search
tsv := setweight (to_tsvector ('pg_catalog.english', r.text), 'C');
END IF;

RETURN tsv;
END;
$$;


ALTER FUNCTION public._attributes_tsvec_update(r public.attributes) OWNER TO gutenberg;

--
-- Name: authors; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.authors (
    pk integer DEFAULT nextval(('public.authors_pk_seq'::text)::regclass) NOT NULL,
    author character varying(240) NOT NULL,
    born_floor integer,
    died_floor integer,
    born_ceil integer,
    died_ceil integer,
    note text,
    downloads integer DEFAULT 0 NOT NULL,
    release_date date DEFAULT '1970-01-01'::date NOT NULL,
    tsvec tsvector,
    CONSTRAINT authors_author CHECK (((author)::text <> (''::character varying)::text))
);


ALTER TABLE public.authors OWNER TO gutenberg;

--
-- Name: _authors_tsvec(public.authors); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public._authors_tsvec(r public.authors) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
	-- creates tsvector from author and alias records
DECLARE
	tsv TSVECTOR;
	r2 RECORD;
BEGIN
	-- authors
	tsv := setweight (px ('a', r.author), 'A');

	tsv := tsv || to_tsvector ('pg_catalog.simple', 
	    COALESCE ('' || r.born_floor, '') || COALESCE (' ' || r.died_floor, ''));

	-- aliases
	FOR r2 IN SELECT "alias" FROM aliases WHERE aliases.fk_authors = r.pk LOOP
		tsv := tsv || setweight (px ('a', r2.alias), 'A');
	END LOOP;

	RETURN tsv;
END;
$$;


ALTER FUNCTION public._authors_tsvec(r public.authors) OWNER TO gutenberg;

--
-- Name: _authors_tsvec_update(public.authors); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public._authors_tsvec_update(r public.authors) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
        -- after row trigger for alias table
-- creates full tsvector from author and alias records
DECLARE
tsv TSVECTOR;
r2 RECORD;
BEGIN
-- authors
tsv :=        to_tsvector ('pg_catalog.simple', pf ('a.', r.author));
tsv := tsv || to_tsvector ('pg_catalog.simple', r.author);
tsv := tsv || to_tsvector ('pg_catalog.english', r.author);
IF r.born_floor IS NOT NULL THEN
    tsv := tsv || to_tsvector ('pg_catalog.simple', CAST (r.born_floor AS text));
END IF;
IF r.died_floor IS NOT NULL THEN
    tsv := tsv || to_tsvector ('pg_catalog.simple', CAST (r.died_floor AS text));
END IF;

-- aliases
FOR r2 IN SELECT "alias" FROM aliases
          WHERE aliases.fk_authors = r.pk
        LOOP
tsv := tsv || to_tsvector ('pg_catalog.simple', pf ('a.', r2.alias));
tsv := tsv || to_tsvector ('pg_catalog.simple', r2.alias);
tsv := tsv || to_tsvector ('pg_catalog.english', r2.alias);
END LOOP;

RETURN tsv;
END;
$$;


ALTER FUNCTION public._authors_tsvec_update(r public.authors) OWNER TO gutenberg;

--
-- Name: books; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.books (
    pk integer NOT NULL,
    copyrighted integer DEFAULT 0 NOT NULL,
    updatemode integer DEFAULT 0 NOT NULL,
    release_date date DEFAULT ('now'::text)::date NOT NULL,
    filemask character varying(240),
    gutindex text,
    downloads integer DEFAULT 0 NOT NULL,
    title text,
    tsvec tsvector,
    nonfiling integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.books OWNER TO gutenberg;

--
-- Name: _books_title(public.books); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public._books_title(r public.books) RETURNS record
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
       ORDER BY attributes.fk_attriblist LIMIT 1 LOOP
       RETURN r2;
END LOOP;

r2.text := NULL;
r2.nonfiling := 0;
RETURN r2;
END;
$$;


ALTER FUNCTION public._books_title(r public.books) OWNER TO gutenberg;

--
-- Name: _books_tsvec(public.books); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public._books_tsvec(r public.books) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
	-- creates tsvector for books from authors, title, subjects, bookshelves, ...
DECLARE
	tsv TSVECTOR;
	r2 RECORD;
BEGIN
	-- ebook no.
	tsv := setweight (to_tsvector ('pg_catalog.simple', pf2 ('no.', '' || r.pk)), 'A');

	-- authors
	FOR r2 IN SELECT tsvec FROM authors, mn_books_authors AS mn 
	         WHERE authors.pk = mn.fk_authors AND mn.fk_books = r.pk 
		 AND tsvec IS NOT NULL LOOP
		tsv := tsv || r2.tsvec;
	END LOOP;

	-- attributes (title, etc.)
	FOR r2 IN SELECT tsvec FROM attributes WHERE tsvec IS NOT NULL 
		 AND fk_attriblist < 900 AND attributes.fk_books = r.pk LOOP
		tsv := tsv || r2.tsvec;
	END LOOP;

	-- subjects
	FOR r2 IN SELECT tsvec FROM subjects, mn_books_subjects AS mn 
	         WHERE subjects.pk = mn.fk_subjects AND mn.fk_books = r.pk 
		 AND tsvec IS NOT NULL LOOP
		tsv := tsv || r2.tsvec;
	END LOOP;

	-- bookshelves
	FOR r2 IN SELECT tsvec FROM bookshelves, mn_books_bookshelves AS mn 
    	         WHERE bookshelves.pk = mn.fk_bookshelves AND mn.fk_books = r.pk 
		 AND tsvec IS NOT NULL LOOP
		tsv := tsv || r2.tsvec;
	END LOOP;

	-- categories
	FOR r2 IN SELECT category FROM categories, mn_books_categories AS mn 
	         WHERE categories.pk = mn.fk_categories AND mn.fk_books = r.pk LOOP
		tsv := tsv || to_tsvector ('pg_catalog.simple', pf ('cat0', r2.category));
	END LOOP;

	-- loccs
	FOR r2 IN SELECT locc, fk_loccs FROM loccs, mn_books_loccs AS mn 
	         WHERE loccs.pk = mn.fk_loccs AND mn.fk_books = r.pk LOOP
		tsv := tsv || to_tsvector ('pg_catalog.english',  pf ('lcnx', r2.locc));
		tsv := tsv || to_tsvector ('pg_catalog.simple',  'lcc0' || r2.fk_loccs);
	END LOOP;

	-- languages
	FOR r2 IN SELECT lang, fk_langs FROM langs, mn_books_langs AS mn 
	         WHERE langs.pk = mn.fk_langs AND mn.fk_books = r.pk LOOP
		tsv := tsv || to_tsvector (
		       	      'pg_catalog.simple', pf ('l0', r2.lang || ' ' || r2.fk_langs));
	END LOOP;

	-- filetypes
	SELECT array_to_string (array_agg ('y0' || fk_filetypes), ' ') AS a INTO r2 
	       FROM (SELECT DISTINCT fk_filetypes FROM files 
	       	     WHERE diskstatus = 0 AND files.fk_books = r.pk) AS foo;
	tsv := tsv || to_tsvector ('pg_catalog.simple', replace (r2.a, '-8', ''));

	RETURN tsv;
END;
$$;


ALTER FUNCTION public._books_tsvec(r public.books) OWNER TO gutenberg;

SET default_with_oids = false;

--
-- Name: bookshelves; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.bookshelves (
    pk integer NOT NULL,
    bookshelf text NOT NULL,
    downloads integer DEFAULT 0 NOT NULL,
    release_date date DEFAULT '1970-01-01'::date NOT NULL,
    tsvec tsvector,
    CONSTRAINT bookshelves_bookshelf_check CHECK ((bookshelf <> ''::text))
);


ALTER TABLE public.bookshelves OWNER TO gutenberg;

--
-- Name: _bookshelves_tsvec(public.bookshelves); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public._bookshelves_tsvec(r public.bookshelves) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
	-- creates tsvector from bookshelves record
BEGIN
	RETURN px ('bs', r.bookshelf);
END;
$$;


ALTER FUNCTION public._bookshelves_tsvec(r public.bookshelves) OWNER TO gutenberg;

SET default_with_oids = true;

--
-- Name: subjects; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.subjects (
    pk integer DEFAULT nextval(('public.subjects_pk_seq'::text)::regclass) NOT NULL,
    subject character varying(240) NOT NULL,
    downloads integer DEFAULT 0 NOT NULL,
    release_date date DEFAULT '1970-01-01'::date NOT NULL,
    tsvec tsvector,
    CONSTRAINT subjects_subject CHECK (((subject)::text <> (''::character varying)::text))
);


ALTER TABLE public.subjects OWNER TO gutenberg;

--
-- Name: _subjects_tsvec(public.subjects); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public._subjects_tsvec(r public.subjects) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
	-- creates tsvector from subjects record
BEGIN
	RETURN setweight (px ('s', r.subject), 'C');
END;
$$;


ALTER FUNCTION public._subjects_tsvec(r public.subjects) OWNER TO gutenberg;

--
-- Name: attributes_tsvec(integer); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.attributes_tsvec(fk_attributes integer) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
        -- for manual updates of attributes.tsvec
DECLARE
	r attributes;
BEGIN
	SELECT * INTO STRICT r FROM attributes WHERE attributes.pk = fk_attributes;
	RETURN _attributes_tsvec (r);
END;
$$;


ALTER FUNCTION public.attributes_tsvec(fk_attributes integer) OWNER TO gutenberg;

--
-- Name: attributes_tsvec_triggerfunc(); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.attributes_tsvec_triggerfunc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        -- before row trigger for attributes table
BEGIN
	IF TG_TABLE_NAME = 'attributes' THEN
	    NEW.tsvec := _attributes_tsvec (NEW);
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.attributes_tsvec_triggerfunc() OWNER TO gutenberg;

--
-- Name: attributes_tsvec_update(integer); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.attributes_tsvec_update(fk_attributes integer) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
        -- for manual updates of attributes.tsvec
DECLARE
r attributes;
BEGIN
IF fk_attributes IS NULL THEN
    RETURN NULL;
END IF;

SELECT * INTO r FROM attributes WHERE attributes.pk = fk_attributes;
RETURN _attributes_tsvec_update (r);
END;
$$;


ALTER FUNCTION public.attributes_tsvec_update(fk_attributes integer) OWNER TO gutenberg;

--
-- Name: authors_tsvec(integer); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.authors_tsvec(fk_authors integer) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
        -- for manual updates of authors.tsvec
DECLARE
	r authors;
BEGIN
	SELECT * INTO STRICT r FROM authors WHERE authors.pk = fk_authors;
	RETURN _authors_tsvec (r);
END;
$$;


ALTER FUNCTION public.authors_tsvec(fk_authors integer) OWNER TO gutenberg;

--
-- Name: authors_tsvec_alias_triggerfunc(); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.authors_tsvec_alias_triggerfunc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        -- after row trigger for aliases table
BEGIN
	IF (TG_OP = 'DELETE') THEN
	    	UPDATE authors SET tsvec = NULL WHERE authors.pk = OLD.fk_authors;
	        RETURN OLD;
        ELSE
	    	UPDATE authors SET tsvec = NULL WHERE authors.pk = NEW.fk_authors;
	        RETURN NEW;
	END IF;
END;
$$;


ALTER FUNCTION public.authors_tsvec_alias_triggerfunc() OWNER TO gutenberg;

--
-- Name: authors_tsvec_triggerfunc(); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.authors_tsvec_triggerfunc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        -- before row trigger for authors table
BEGIN
	IF TG_TABLE_NAME = 'authors' THEN
	    NEW.tsvec := _authors_tsvec (NEW);
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.authors_tsvec_triggerfunc() OWNER TO gutenberg;

--
-- Name: authors_tsvec_update(integer); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.authors_tsvec_update(fk_authors integer) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
        -- for manual updates of authors.tsvec
-- creates tsvector for authors table from authors and aliases
DECLARE
r authors;
BEGIN
IF fk_authors IS NULL THEN
    RETURN NULL;
END IF;

SELECT * INTO r FROM authors WHERE authors.pk = fk_authors;
RETURN _authors_tsvec_update (r);
END;
$$;


ALTER FUNCTION public.authors_tsvec_update(fk_authors integer) OWNER TO gutenberg;

--
-- Name: books_title_triggerfunc(); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.books_title_triggerfunc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    -- after row trigger for attributes table
    -- updates books.title whenever attributes change
    BEGIN
	IF (TG_OP = 'DELETE') THEN
	   UPDATE books SET title = NULL WHERE books.pk = OLD.fk_books;
	   RETURN OLD;
	ELSE
	   UPDATE books SET title = NULL WHERE books.pk = NEW.fk_books;
	   RETURN NEW;
	END IF;
    END;
$$;


ALTER FUNCTION public.books_title_triggerfunc() OWNER TO gutenberg;

--
-- Name: books_title_update(integer); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.books_title_update(_fk_books integer) RETURNS text
    LANGUAGE sql
    AS $_$
    -- helper
    -- calculates book title from attributes table
    SELECT ltrim (substring (attributes.text FROM attributes.nonfiling))
       FROM attributes
       WHERE attributes.fk_books = $1
       AND attributes.fk_attriblist = ANY (ARRAY[240, 245, 246])
       ORDER BY attributes.fk_attriblist
       LIMIT 1;
$_$;


ALTER FUNCTION public.books_title_update(_fk_books integer) OWNER TO gutenberg;

--
-- Name: books_tsvec_1n_triggerfunc(); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.books_tsvec_1n_triggerfunc() RETURNS trigger
    LANGUAGE plpgsql
    AS $_$
-- after row trigger for authors, subjects, bookshelves tables
DECLARE
	r RECORD;
	tablename CONSTANT TEXT := TG_TABLE_NAME;
BEGIN
	FOR r IN EXECUTE 'SELECT fk_books FROM mn_books_'
		 	 || quote_ident (tablename)
			 || ' AS mn WHERE mn.fk_' 
			 || quote_ident (tablename)
			 || ' = $1' USING NEW.pk
        LOOP
	    UPDATE books SET tsvec = NULL WHERE books.pk = r.fk_books;
	END LOOP;
	RETURN NULL;
END;
$_$;


ALTER FUNCTION public.books_tsvec_1n_triggerfunc() OWNER TO gutenberg;

--
-- Name: books_tsvec_mn_triggerfunc(); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.books_tsvec_mn_triggerfunc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
-- after row trigger for mn_books_* tables
-- table must have fk_books field
BEGIN
	IF (TG_OP = 'DELETE') THEN
	    UPDATE books SET tsvec = NULL WHERE books.pk = OLD.fk_books;
	    RETURN OLD;
	ELSE	   
	    UPDATE books SET tsvec = NULL WHERE books.pk = NEW.fk_books;
	    RETURN NEW;
	END IF;
END;
$$;


ALTER FUNCTION public.books_tsvec_mn_triggerfunc() OWNER TO gutenberg;

--
-- Name: books_tsvec_triggerfunc(); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.books_tsvec_triggerfunc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        -- before row trigger for books table
DECLARE
r record;
BEGIN
NEW.tsvec := _books_tsvec (NEW);
r := _books_title (NEW);
NEW.title := r.text;
NEW.nonfiling = r.nonfiling;
RETURN NEW;
END;
$$;


ALTER FUNCTION public.books_tsvec_triggerfunc() OWNER TO gutenberg;

--
-- Name: books_tsvec_update(integer); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.books_tsvec_update(fk_books integer) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
        -- for manual updates and helper function for triggers
-- creates tsvector for books from authors, title, subjects, bookshelves, ...
DECLARE
r RECORD;
tsv TSVECTOR;
BEGIN
IF fk_books IS NULL THEN
    RETURN NULL;
END IF;

-- ebook no.
tsv := setweight (to_tsvector ('pg_catalog.simple', pf2 ('no.', '' || fk_books)), 'A');

-- authors
FOR r IN SELECT tsvec FROM authors, mn_books_authors AS mn 
         WHERE authors.pk = mn.fk_authors AND mn.fk_books = fk_books 
 AND tsvec IS NOT NULL LOOP
tsv := tsv || setweight (r.tsvec, 'A');
END LOOP;

-- title
FOR r IN SELECT text FROM attributes 
         WHERE fk_attriblist IN (240, 245, 246, 440, 505)
     AND attributes.fk_books = fk_books LOOP
tsv := tsv || setweight (to_tsvector (
             'pg_catalog.english', pf2 ('tx', r.text)), 'B');
END LOOP;

-- other attributes
FOR r IN SELECT text FROM attributes 
         WHERE fk_attriblist < 900 AND attributes.fk_books = fk_books LOOP
tsv := tsv || setweight (to_tsvector ('pg_catalog.english', r.text), 'C');
END LOOP;

-- subjects
FOR r IN SELECT subject FROM subjects, mn_books_subjects AS mn 
         WHERE subjects.pk = mn.fk_subjects AND mn.fk_books = fk_books LOOP
tsv := tsv || setweight (to_tsvector (
             'pg_catalog.english', pf2 ('sx', r.subject)), 'C');
END LOOP;

-- bookshelves
FOR r IN SELECT bookshelf FROM bookshelves, mn_books_bookshelves AS mn 
             WHERE bookshelves.pk = mn.fk_bookshelves AND mn.fk_books = fk_books LOOP
tsv := tsv || setweight (to_tsvector (
             'pg_catalog.english', pf2 ('bsx', r.bookshelf)), 'D');
END LOOP;

-- categories
FOR r IN SELECT category FROM categories, mn_books_categories AS mn 
         WHERE categories.pk = mn.fk_categories AND mn.fk_books = fk_books LOOP
tsv := tsv || to_tsvector ('pg_catalog.english', pf ('catx', r.category));
END LOOP;

-- loccs
FOR r IN SELECT locc, fk_loccs FROM loccs, mn_books_loccs AS mn 
         WHERE loccs.pk = mn.fk_loccs AND mn.fk_books = fk_books LOOP
tsv := tsv || to_tsvector ('pg_catalog.english', pf ('lcx', r.locc));
tsv := tsv || to_tsvector ('pg_catalog.english', 'lc.' || r.fk_loccs);
END LOOP;

-- languages
FOR r IN SELECT lang, fk_langs FROM langs, mn_books_langs AS mn 
         WHERE langs.pk = mn.fk_langs AND mn.fk_books = fk_books LOOP
tsv := tsv || to_tsvector (
             'pg_catalog.simple', pf ('l.', r.lang || ' ' || r.fk_langs));
END LOOP;

-- filetypes
SELECT array_agg (fk_filetypes) AS a INTO r 
       FROM (SELECT DISTINCT fk_filetypes FROM files 
            WHERE diskstatus = 0 AND files.fk_books = fk_books) AS foo;
tsv := tsv || to_tsvector ('pg_catalog.simple', 'y.' || array_to_string (r.a, ' y.'));

RETURN tsv;
END;
$$;


ALTER FUNCTION public.books_tsvec_update(fk_books integer) OWNER TO gutenberg;

--
-- Name: bookshelves_tsvec_triggerfunc(); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.bookshelves_tsvec_triggerfunc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        -- before row trigger for bookshelves table
BEGIN
	IF TG_TABLE_NAME = 'bookshelves' THEN
	    NEW.tsvec := _bookshelves_tsvec (NEW);
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.bookshelves_tsvec_triggerfunc() OWNER TO gutenberg;

--
-- Name: db_to_csv(text); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.db_to_csv(path text) RETURNS void
    LANGUAGE plpgsql
    AS $$
declare
   tables RECORD;
   statement TEXT;
begin
FOR tables IN
   SELECT (table_schema || '.' || table_name) AS schema_table
   FROM information_schema.tables t INNER JOIN information_schema.schemata s
   ON s.schema_name = t.table_schema
   WHERE t.table_schema NOT IN ('pg_catalog', 'information_schema', 'configuration')
   AND t.table_type NOT IN ('VIEW')
   ORDER BY schema_table
LOOP
   statement := 'COPY ' || tables.schema_table || ' TO ''' || path || '/' || tables.schema_table || '.csv' ||''' DELIMITER '';'' CSV HEADER';
   EXECUTE statement;
END LOOP;
return;
end;
$$;


ALTER FUNCTION public.db_to_csv(path text) OWNER TO gutenberg;

--
-- Name: filing(text, integer); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.filing(title text, nonfiling integer) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
       -- function to sort titles in filing order
BEGIN
RETURN ltrim (substring (title FROM nonfiling + 1));
END;
$$;


ALTER FUNCTION public.filing(title text, nonfiling integer) OWNER TO gutenberg;

--
-- Name: gin_extract_trgm(text, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gin_extract_trgm(text, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gin_extract_trgm';


ALTER FUNCTION public.gin_extract_trgm(text, internal) OWNER TO postgres;

--
-- Name: gin_extract_trgm(text, internal, smallint, internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gin_extract_trgm(text, internal, smallint, internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gin_extract_trgm';


ALTER FUNCTION public.gin_extract_trgm(text, internal, smallint, internal, internal) OWNER TO postgres;

--
-- Name: gin_trgm_consistent(internal, smallint, text, integer, internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gin_trgm_consistent';


ALTER FUNCTION public.gin_trgm_consistent(internal, smallint, text, integer, internal, internal) OWNER TO postgres;

--
-- Name: gtrgm_compress(internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gtrgm_compress(internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gtrgm_compress';


ALTER FUNCTION public.gtrgm_compress(internal) OWNER TO postgres;

--
-- Name: gtrgm_consistent(internal, text, integer, oid, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gtrgm_consistent(internal, text, integer, oid, internal) RETURNS boolean
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gtrgm_consistent';


ALTER FUNCTION public.gtrgm_consistent(internal, text, integer, oid, internal) OWNER TO postgres;

--
-- Name: gtrgm_decompress(internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gtrgm_decompress(internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gtrgm_decompress';


ALTER FUNCTION public.gtrgm_decompress(internal) OWNER TO postgres;

--
-- Name: gtrgm_penalty(internal, internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gtrgm_penalty(internal, internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gtrgm_penalty';


ALTER FUNCTION public.gtrgm_penalty(internal, internal, internal) OWNER TO postgres;

--
-- Name: gtrgm_picksplit(internal, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gtrgm_picksplit(internal, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gtrgm_picksplit';


ALTER FUNCTION public.gtrgm_picksplit(internal, internal) OWNER TO postgres;

--
-- Name: gtrgm_same(public.gtrgm, public.gtrgm, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) RETURNS internal
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gtrgm_same';


ALTER FUNCTION public.gtrgm_same(public.gtrgm, public.gtrgm, internal) OWNER TO postgres;

--
-- Name: gtrgm_union(bytea, internal); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.gtrgm_union(bytea, internal) RETURNS integer[]
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'gtrgm_union';


ALTER FUNCTION public.gtrgm_union(bytea, internal) OWNER TO postgres;

--
-- Name: pf(text, text); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.pf(p text, t text) RETURNS text
    LANGUAGE plpgsql
    AS $$
       -- returns string with all words prefixed by p
BEGIN       
       RETURN regexp_replace (t, E'\\m', p, 'g');
END;
$$;


ALTER FUNCTION public.pf(p text, t text) OWNER TO gutenberg;

--
-- Name: pf2(text, text); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.pf2(p text, t text) RETURNS text
    LANGUAGE plpgsql
    AS $$
       -- returns original string plus string with all words prefixed by p
BEGIN       
       RETURN t || ' ' || regexp_replace (t, E'\\m', p, 'g');
END;
$$;


ALTER FUNCTION public.pf2(p text, t text) OWNER TO gutenberg;

--
-- Name: px(text, text); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.px(p text, t text) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
       -- returns original string plus string with all words prefixed by p. and px
DECLARE
r RECORD;
s1 TEXT := '';
s2 TEXT := '';
        -- regex to fix '1921-1968' which would otherwise be parsed as '1921', '-1968'
t2 TEXT := regexp_replace (t, E'([\\d])-([\\d])', E'\\1_\\2');
BEGIN
FOR r IN SELECT token, tokid FROM ts_parse ('default', t2) 
WHERE tokid != 12
AND array_length (ts_lexize ('english_stem', token), 1) > 0 LOOP
              s1 := s1 || ' ' || p || 'x' || r.token;
      s2 := s2 || ' 0' || r.token;
END LOOP;

RETURN to_tsvector ('pg_catalog.english', t2 || s1 || s2);
END;
$$;


ALTER FUNCTION public.px(p text, t text) OWNER TO gutenberg;

--
-- Name: pxtest(text, text); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.pxtest(p text, t text) RETURNS tsvector
    LANGUAGE plpgsql
    AS $$
       -- returns original string plus string with all words prefixed by p. and px
DECLARE
r RECORD;
s1 TEXT := '';
s2 TEXT := '';
        -- regex to fix '1921-1968' which would otherwise be parsed as '1921', '-1968'
t2 TEXT := regexp_replace (t, E'([\\d])-([\\d])', E'\\1_\\2');
BEGIN
FOR r IN SELECT token, tokid FROM ts_parse ('default', t2) 
WHERE tokid != 12
AND array_length (ts_lexize ('english_stem', token), 1) > 0 LOOP
              s1 := s1 || ' ' || p || 'x' || r.token;
      s2 := s2 || ' 0' || r.token;
END LOOP;

RETURN to_tsvector ('pg_catalog.english', t2 || s1 || s2);
END;
$$;


ALTER FUNCTION public.pxtest(p text, t text) OWNER TO gutenberg;

--
-- Name: set_limit(real); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_limit(real) RETURNS real
    LANGUAGE c STRICT
    AS '$libdir/pg_trgm', 'set_limit';


ALTER FUNCTION public.set_limit(real) OWNER TO postgres;

--
-- Name: show_limit(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.show_limit() RETURNS real
    LANGUAGE c STABLE STRICT
    AS '$libdir/pg_trgm', 'show_limit';


ALTER FUNCTION public.show_limit() OWNER TO postgres;

--
-- Name: show_trgm(text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.show_trgm(text) RETURNS text[]
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'show_trgm';


ALTER FUNCTION public.show_trgm(text) OWNER TO postgres;

--
-- Name: similarity(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.similarity(text, text) RETURNS real
    LANGUAGE c IMMUTABLE STRICT
    AS '$libdir/pg_trgm', 'similarity';


ALTER FUNCTION public.similarity(text, text) OWNER TO postgres;

--
-- Name: similarity_op(text, text); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.similarity_op(text, text) RETURNS boolean
    LANGUAGE c STABLE STRICT
    AS '$libdir/pg_trgm', 'similarity_op';


ALTER FUNCTION public.similarity_op(text, text) OWNER TO postgres;

--
-- Name: subjects_tsvec_triggerfunc(); Type: FUNCTION; Schema: public; Owner: gutenberg
--

CREATE FUNCTION public.subjects_tsvec_triggerfunc() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
        -- before row trigger for subjects table
BEGIN
	IF TG_TABLE_NAME = 'subjects' THEN
	    NEW.tsvec := _subjects_tsvec (NEW);
	END IF;

	RETURN NEW;
END;
$$;


ALTER FUNCTION public.subjects_tsvec_triggerfunc() OWNER TO gutenberg;

--
-- Name: %; Type: OPERATOR; Schema: public; Owner: postgres
--

CREATE OPERATOR public.% (
    PROCEDURE = public.similarity_op,
    LEFTARG = text,
    RIGHTARG = text,
    COMMUTATOR = OPERATOR(public.%),
    RESTRICT = contsel,
    JOIN = contjoinsel
);


ALTER OPERATOR public.% (text, text) OWNER TO postgres;

--
-- Name: gin_trgm_ops; Type: OPERATOR FAMILY; Schema: public; Owner: postgres
--

CREATE OPERATOR FAMILY public.gin_trgm_ops USING gin;


ALTER OPERATOR FAMILY public.gin_trgm_ops USING gin OWNER TO postgres;

--
-- Name: gin_trgm_ops; Type: OPERATOR CLASS; Schema: public; Owner: postgres
--

CREATE OPERATOR CLASS public.gin_trgm_ops
    FOR TYPE text USING gin FAMILY public.gin_trgm_ops AS
    STORAGE integer ,
    OPERATOR 1 public.%(text,text) ,
    FUNCTION 1 (text, text) btint4cmp(integer,integer) ,
    FUNCTION 2 (text, text) public.gin_extract_trgm(text,internal) ,
    FUNCTION 3 (text, text) public.gin_extract_trgm(text,internal,smallint,internal,internal) ,
    FUNCTION 4 (text, text) public.gin_trgm_consistent(internal,smallint,text,integer,internal,internal);


ALTER OPERATOR CLASS public.gin_trgm_ops USING gin OWNER TO postgres;

--
-- Name: gist_trgm_ops; Type: OPERATOR FAMILY; Schema: public; Owner: postgres
--

CREATE OPERATOR FAMILY public.gist_trgm_ops USING gist;


ALTER OPERATOR FAMILY public.gist_trgm_ops USING gist OWNER TO postgres;

--
-- Name: gist_trgm_ops; Type: OPERATOR CLASS; Schema: public; Owner: postgres
--

CREATE OPERATOR CLASS public.gist_trgm_ops
    FOR TYPE text USING gist FAMILY public.gist_trgm_ops AS
    STORAGE public.gtrgm ,
    OPERATOR 1 public.%(text,text) ,
    FUNCTION 1 (text, text) public.gtrgm_consistent(internal,text,integer,oid,internal) ,
    FUNCTION 2 (text, text) public.gtrgm_union(bytea,internal) ,
    FUNCTION 3 (text, text) public.gtrgm_compress(internal) ,
    FUNCTION 4 (text, text) public.gtrgm_decompress(internal) ,
    FUNCTION 5 (text, text) public.gtrgm_penalty(internal,internal,internal) ,
    FUNCTION 6 (text, text) public.gtrgm_picksplit(internal,internal) ,
    FUNCTION 7 (text, text) public.gtrgm_same(public.gtrgm,public.gtrgm,internal);


ALTER OPERATOR CLASS public.gist_trgm_ops USING gist OWNER TO postgres;

--
-- Name: aliases; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.aliases (
    pk integer DEFAULT nextval(('public.aliases_pk_seq'::text)::regclass) NOT NULL,
    fk_authors integer NOT NULL,
    alias character varying(240),
    alias_heading integer DEFAULT 1
);


ALTER TABLE public.aliases OWNER TO gutenberg;

--
-- Name: aliases_pk_seq; Type: SEQUENCE; Schema: public; Owner: gutenberg
--

CREATE SEQUENCE public.aliases_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.aliases_pk_seq OWNER TO gutenberg;

--
-- Name: aliases_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gutenberg
--

ALTER SEQUENCE public.aliases_pk_seq OWNED BY public.aliases.pk;


--
-- Name: attriblist; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.attriblist (
    pk integer NOT NULL,
    type character varying(10) NOT NULL,
    name character varying(80) NOT NULL,
    caption character varying(40),
    CONSTRAINT attriblist_name CHECK (((name)::text <> (''::character varying)::text)),
    CONSTRAINT attriblist_type CHECK (((type)::text <> (''::character varying)::text))
);


ALTER TABLE public.attriblist OWNER TO gutenberg;

--
-- Name: attributes_pk_seq; Type: SEQUENCE; Schema: public; Owner: gutenberg
--

CREATE SEQUENCE public.attributes_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.attributes_pk_seq OWNER TO gutenberg;

--
-- Name: attributes_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gutenberg
--

ALTER SEQUENCE public.attributes_pk_seq OWNED BY public.attributes.pk;


--
-- Name: author_urls; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.author_urls (
    pk integer DEFAULT nextval(('public.author_urls_pk_seq'::text)::regclass) NOT NULL,
    fk_authors integer NOT NULL,
    description character varying(240),
    url character varying(240) NOT NULL
);


ALTER TABLE public.author_urls OWNER TO gutenberg;

--
-- Name: author_urls_pk_seq; Type: SEQUENCE; Schema: public; Owner: gutenberg
--

CREATE SEQUENCE public.author_urls_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.author_urls_pk_seq OWNER TO gutenberg;

--
-- Name: author_urls_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gutenberg
--

ALTER SEQUENCE public.author_urls_pk_seq OWNED BY public.author_urls.pk;


--
-- Name: authors_pk_seq; Type: SEQUENCE; Schema: public; Owner: gutenberg
--

CREATE SEQUENCE public.authors_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.authors_pk_seq OWNER TO gutenberg;

--
-- Name: authors_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gutenberg
--

ALTER SEQUENCE public.authors_pk_seq OWNED BY public.authors.pk;


--
-- Name: bookshelves_pk_seq; Type: SEQUENCE; Schema: public; Owner: gutenberg
--

CREATE SEQUENCE public.bookshelves_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.bookshelves_pk_seq OWNER TO gutenberg;

--
-- Name: bookshelves_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gutenberg
--

ALTER SEQUENCE public.bookshelves_pk_seq OWNED BY public.bookshelves.pk;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.categories (
    pk integer DEFAULT nextval(('public.categories_pk_seq'::text)::regclass) NOT NULL,
    category character varying(240) NOT NULL,
    CONSTRAINT categories_category CHECK (((category)::text <> (''::character varying)::text))
);


ALTER TABLE public.categories OWNER TO gutenberg;

--
-- Name: categories_pk_seq; Type: SEQUENCE; Schema: public; Owner: gutenberg
--

CREATE SEQUENCE public.categories_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categories_pk_seq OWNER TO gutenberg;

--
-- Name: categories_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gutenberg
--

ALTER SEQUENCE public.categories_pk_seq OWNED BY public.categories.pk;


--
-- Name: changelog; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.changelog (
    "time" timestamp without time zone,
    login character varying(80),
    sql text,
    script character varying(240)
);


ALTER TABLE public.changelog OWNER TO gutenberg;

--
-- Name: compressions; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.compressions (
    pk character varying(10) NOT NULL,
    compression character varying(240) NOT NULL,
    CONSTRAINT compressions_compression CHECK (((compression)::text <> (''::character varying)::text))
);


ALTER TABLE public.compressions OWNER TO gutenberg;

SET default_with_oids = false;

--
-- Name: dcmitypes; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.dcmitypes (
    pk integer NOT NULL,
    dcmitype text,
    description text
);


ALTER TABLE public.dcmitypes OWNER TO gutenberg;

--
-- Name: dcmitypes_pk_seq; Type: SEQUENCE; Schema: public; Owner: gutenberg
--

CREATE SEQUENCE public.dcmitypes_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.dcmitypes_pk_seq OWNER TO gutenberg;

--
-- Name: dcmitypes_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gutenberg
--

ALTER SEQUENCE public.dcmitypes_pk_seq OWNED BY public.dcmitypes.pk;


--
-- Name: dpid; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.dpid (
    fk_books integer NOT NULL,
    projectid text NOT NULL
);


ALTER TABLE public.dpid OWNER TO gutenberg;

SET default_with_oids = true;

--
-- Name: encodings; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.encodings (
    pk character varying(20) NOT NULL,
    sortorder integer DEFAULT 10
);


ALTER TABLE public.encodings OWNER TO gutenberg;

--
-- Name: filecount; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.filecount (
    count integer,
    filename character varying
);


ALTER TABLE public.filecount OWNER TO gutenberg;

--
-- Name: files; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.files (
    pk integer DEFAULT nextval(('public.files_pk_seq'::text)::regclass) NOT NULL,
    fk_books integer,
    fk_filetypes character varying(20),
    fk_encodings character varying(20),
    fk_compressions character varying(10),
    filename character varying(240) NOT NULL,
    filesize integer,
    filemtime timestamp without time zone,
    diskstatus integer DEFAULT 0 NOT NULL,
    obsoleted integer DEFAULT 0 NOT NULL,
    edition integer,
    md5hash bytea,
    sha1hash bytea,
    kzhash bytea,
    ed2khash bytea,
    tigertreehash bytea,
    note text,
    download integer DEFAULT 0
);


ALTER TABLE public.files OWNER TO gutenberg;

--
-- Name: files_pk_seq; Type: SEQUENCE; Schema: public; Owner: gutenberg
--

CREATE SEQUENCE public.files_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.files_pk_seq OWNER TO gutenberg;

--
-- Name: files_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gutenberg
--

ALTER SEQUENCE public.files_pk_seq OWNED BY public.files.pk;


--
-- Name: filetypes; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.filetypes (
    pk character varying(20) NOT NULL,
    filetype character varying(240) NOT NULL,
    sortorder integer DEFAULT 10,
    mediatype character varying(40),
    generated boolean,
    CONSTRAINT filetypes_filetype CHECK (((filetype)::text <> (''::character varying)::text))
);


ALTER TABLE public.filetypes OWNER TO gutenberg;

SET default_with_oids = false;

--
-- Name: fts; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.fts (
    array_to_string text
);


ALTER TABLE public.fts OWNER TO gutenberg;

SET default_with_oids = true;

--
-- Name: langs; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.langs (
    pk character varying(10) NOT NULL,
    lang character varying(80) NOT NULL,
    CONSTRAINT langs_lang CHECK (((lang)::text <> (''::character varying)::text))
);


ALTER TABLE public.langs OWNER TO gutenberg;

--
-- Name: loccs; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.loccs (
    pk character varying(10) NOT NULL,
    locc character varying(240) NOT NULL,
    CONSTRAINT loccs_locc CHECK (((locc)::text <> (''::character varying)::text))
);


ALTER TABLE public.loccs OWNER TO gutenberg;

--
-- Name: mirrors; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.mirrors (
    pk integer DEFAULT nextval(('public.mirrors_pk_seq'::text)::regclass) NOT NULL,
    continent character varying(80),
    nation character varying(80),
    location character varying(80),
    provider character varying(240) NOT NULL,
    url character varying(240) NOT NULL,
    note text
);


ALTER TABLE public.mirrors OWNER TO gutenberg;

--
-- Name: mirrors_pk_seq; Type: SEQUENCE; Schema: public; Owner: gutenberg
--

CREATE SEQUENCE public.mirrors_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.mirrors_pk_seq OWNER TO gutenberg;

--
-- Name: mirrors_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gutenberg
--

ALTER SEQUENCE public.mirrors_pk_seq OWNED BY public.mirrors.pk;


--
-- Name: mn_books_authors; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.mn_books_authors (
    fk_books integer NOT NULL,
    fk_authors integer NOT NULL,
    fk_roles character varying(10) DEFAULT 'cr'::character varying NOT NULL,
    heading integer DEFAULT 1
);


ALTER TABLE public.mn_books_authors OWNER TO gutenberg;

SET default_with_oids = false;

--
-- Name: mn_books_bookshelves; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.mn_books_bookshelves (
    fk_books integer NOT NULL,
    fk_bookshelves integer NOT NULL
);


ALTER TABLE public.mn_books_bookshelves OWNER TO gutenberg;

SET default_with_oids = true;

--
-- Name: mn_books_categories; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.mn_books_categories (
    fk_books integer NOT NULL,
    fk_categories integer NOT NULL
);


ALTER TABLE public.mn_books_categories OWNER TO gutenberg;

--
-- Name: mn_books_langs; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.mn_books_langs (
    fk_books integer NOT NULL,
    fk_langs character varying(10) NOT NULL
);


ALTER TABLE public.mn_books_langs OWNER TO gutenberg;

--
-- Name: mn_books_loccs; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.mn_books_loccs (
    fk_books integer NOT NULL,
    fk_loccs character varying(10) NOT NULL
);


ALTER TABLE public.mn_books_loccs OWNER TO gutenberg;

--
-- Name: mn_books_subjects; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.mn_books_subjects (
    fk_books integer NOT NULL,
    fk_subjects integer NOT NULL
);


ALTER TABLE public.mn_books_subjects OWNER TO gutenberg;

--
-- Name: mn_users_permissions; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.mn_users_permissions (
    fk_users integer NOT NULL,
    fk_permissions integer NOT NULL
);


ALTER TABLE public.mn_users_permissions OWNER TO gutenberg;

--
-- Name: permissions; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.permissions (
    pk integer DEFAULT nextval(('public.permissions_pk_seq'::text)::regclass) NOT NULL,
    permission character varying(80),
    note text
);


ALTER TABLE public.permissions OWNER TO gutenberg;

--
-- Name: permissions_pk_seq; Type: SEQUENCE; Schema: public; Owner: gutenberg
--

CREATE SEQUENCE public.permissions_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.permissions_pk_seq OWNER TO gutenberg;

--
-- Name: permissions_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gutenberg
--

ALTER SEQUENCE public.permissions_pk_seq OWNED BY public.permissions.pk;


--
-- Name: revision_seq; Type: SEQUENCE; Schema: public; Owner: gutenberg
--

CREATE SEQUENCE public.revision_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.revision_seq OWNER TO gutenberg;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.roles (
    pk character varying(10) NOT NULL,
    role character varying(240) NOT NULL,
    CONSTRAINT roles_role CHECK (((role)::text <> (''::character varying)::text))
);


ALTER TABLE public.roles OWNER TO gutenberg;

--
-- Name: subjects_pk_seq; Type: SEQUENCE; Schema: public; Owner: gutenberg
--

CREATE SEQUENCE public.subjects_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.subjects_pk_seq OWNER TO gutenberg;

--
-- Name: subjects_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gutenberg
--

ALTER SEQUENCE public.subjects_pk_seq OWNED BY public.subjects.pk;


SET default_with_oids = false;

--
-- Name: terms; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.terms (
    word text,
    ndoc integer,
    nentry integer
);


ALTER TABLE public.terms OWNER TO gutenberg;

--
-- Name: tweets; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.tweets (
    fk_books integer NOT NULL,
    "time" timestamp with time zone NOT NULL,
    media text NOT NULL
);


ALTER TABLE public.tweets OWNER TO gutenberg;

SET default_with_oids = true;

--
-- Name: users; Type: TABLE; Schema: public; Owner: gutenberg
--

CREATE TABLE public.users (
    pk integer DEFAULT nextval(('public.users_pk_seq'::text)::regclass) NOT NULL,
    login character varying(80),
    password character varying(80),
    note text,
    "user" character varying(80)
);


ALTER TABLE public.users OWNER TO gutenberg;

--
-- Name: users_pk_seq; Type: SEQUENCE; Schema: public; Owner: gutenberg
--

CREATE SEQUENCE public.users_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_pk_seq OWNER TO gutenberg;

--
-- Name: users_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: gutenberg
--

ALTER SEQUENCE public.users_pk_seq OWNED BY public.users.pk;


--
-- Name: v_appserver_books_4; Type: VIEW; Schema: public; Owner: gutenberg
--

CREATE VIEW public.v_appserver_books_4 AS
 SELECT books.pk,
    books.title,
    public.filing(books.title, books.nonfiling) AS filing,
    books.release_date,
    books.downloads,
    books.tsvec,
    ( SELECT array_agg(authors.author) AS array_agg
           FROM public.authors,
            public.mn_books_authors
          WHERE ((mn_books_authors.fk_books = books.pk) AND ((mn_books_authors.fk_roles)::text = ANY (ARRAY[('cre'::character varying)::text, ('aut'::character varying)::text])) AND (mn_books_authors.fk_authors = authors.pk))) AS author,
    ( SELECT array_agg(mn.fk_langs) AS array_agg
           FROM public.mn_books_langs mn
          WHERE (books.pk = mn.fk_books)) AS fk_langs,
    ( SELECT array_agg(mn.fk_categories) AS array_agg
           FROM public.mn_books_categories mn
          WHERE (mn.fk_books = books.pk)) AS fk_categories,
    ( SELECT array_agg(files.filename) AS array_agg
           FROM public.files
          WHERE ((files.fk_books = books.pk) AND ((files.fk_filetypes)::text = 'cover.small'::text))) AS coverpages
   FROM public.books;


ALTER TABLE public.v_appserver_books_4 OWNER TO gutenberg;

--
-- Name: v_appserver_books_categories; Type: VIEW; Schema: public; Owner: gutenberg
--

CREATE VIEW public.v_appserver_books_categories AS
 SELECT books.pk,
    books.title,
    books.release_date,
    books.downloads,
    (EXISTS ( SELECT mn_books_categories.fk_categories
           FROM public.mn_books_categories
          WHERE (books.pk = mn_books_categories.fk_books))) AS category
   FROM public.books;


ALTER TABLE public.v_appserver_books_categories OWNER TO gutenberg;

--
-- Name: v_appserver_books_categories_2; Type: VIEW; Schema: public; Owner: gutenberg
--

CREATE VIEW public.v_appserver_books_categories_2 AS
 SELECT books.pk,
    books.title,
    books.release_date,
    books.downloads,
    books.tsvec,
    ( SELECT array_agg(authors.author) AS array_agg
           FROM public.authors,
            public.mn_books_authors
          WHERE ((mn_books_authors.fk_books = books.pk) AND ((mn_books_authors.fk_roles)::text = ANY (ARRAY[('cre'::character varying)::text, ('aut'::character varying)::text])) AND (mn_books_authors.fk_authors = authors.pk))) AS author,
    ( SELECT array_agg(mn_books_categories.fk_categories) AS array_agg
           FROM public.mn_books_categories
          WHERE (mn_books_categories.fk_books = books.pk)) AS fk_categories
   FROM public.books;


ALTER TABLE public.v_appserver_books_categories_2 OWNER TO gutenberg;

--
-- Name: v_appserver_books_categories_3; Type: VIEW; Schema: public; Owner: gutenberg
--

CREATE VIEW public.v_appserver_books_categories_3 AS
 SELECT books.pk,
    books.title,
    books.release_date,
    books.downloads,
    books.tsvec,
    ( SELECT array_agg(authors.author) AS array_agg
           FROM public.authors,
            public.mn_books_authors
          WHERE ((mn_books_authors.fk_books = books.pk) AND ((mn_books_authors.fk_roles)::text = ANY (ARRAY[('cre'::character varying)::text, ('aut'::character varying)::text])) AND (mn_books_authors.fk_authors = authors.pk))) AS author,
    ( SELECT array_agg(mn_books_categories.fk_categories) AS array_agg
           FROM public.mn_books_categories
          WHERE (mn_books_categories.fk_books = books.pk)) AS fk_categories,
    ( SELECT array_agg(files.filename) AS array_agg
           FROM public.files
          WHERE ((files.fk_books = books.pk) AND ((files.fk_filetypes)::text = 'cover.small'::text))) AS coverpages
   FROM public.books;


ALTER TABLE public.v_appserver_books_categories_3 OWNER TO gutenberg;

--
-- Name: v_books_authors; Type: VIEW; Schema: public; Owner: gutenberg
--

CREATE VIEW public.v_books_authors AS
 SELECT mn_books_authors.fk_books,
    mn_books_authors.fk_authors,
    authors.author,
    mn_books_authors.heading,
    authors.born_floor,
    authors.born_ceil,
    authors.died_floor,
    authors.died_ceil,
    roles.role
   FROM ((public.mn_books_authors
     JOIN public.authors ON ((mn_books_authors.fk_authors = authors.pk)))
     JOIN public.roles ON (((mn_books_authors.fk_roles)::text = (roles.pk)::text)));


ALTER TABLE public.v_books_authors OWNER TO gutenberg;

--
-- Name: v_books_categories; Type: VIEW; Schema: public; Owner: gutenberg
--

CREATE VIEW public.v_books_categories AS
 SELECT mn_books_categories.fk_books,
    (EXISTS ( SELECT sub.fk_categories
           FROM public.mn_books_categories sub
          WHERE ((sub.fk_books = mn_books_categories.fk_books) AND ((sub.fk_categories >= 1) AND (sub.fk_categories <= 3))))) AS is_audio,
    (EXISTS ( SELECT sub.fk_categories
           FROM public.mn_books_categories sub
          WHERE ((sub.fk_books = mn_books_categories.fk_books) AND (sub.fk_categories = 4)))) AS is_music
   FROM public.mn_books_categories;


ALTER TABLE public.v_books_categories OWNER TO gutenberg;

--
-- Name: v_books_langs; Type: VIEW; Schema: public; Owner: gutenberg
--

CREATE VIEW public.v_books_langs AS
 SELECT mn_books_langs.fk_books,
    mn_books_langs.fk_langs,
    langs.lang
   FROM (public.mn_books_langs
     JOIN public.langs ON (((mn_books_langs.fk_langs)::text = (langs.pk)::text)));


ALTER TABLE public.v_books_langs OWNER TO gutenberg;

--
-- Name: v_books; Type: VIEW; Schema: public; Owner: gutenberg
--

CREATE VIEW public.v_books AS
 SELECT books.pk AS fk_books,
    v_books_authors.fk_authors,
    v_books_authors.author,
    v_books_authors.born_floor,
    v_books_authors.born_ceil,
    v_books_authors.died_floor,
    v_books_authors.died_ceil,
    v_books_authors.role,
    v_books_langs.fk_langs,
    v_books_langs.lang,
    v_books_categories.is_audio,
    v_books_categories.is_music,
    attributes.text AS title,
    attributes.fk_attriblist,
    substr(attributes.text, (attributes.nonfiling + 1)) AS filing
   FROM ((((public.books
     LEFT JOIN public.attributes ON ((books.pk = attributes.fk_books)))
     LEFT JOIN public.v_books_authors ON ((books.pk = v_books_authors.fk_books)))
     LEFT JOIN public.v_books_langs ON ((books.pk = v_books_langs.fk_books)))
     LEFT JOIN public.v_books_categories ON ((books.pk = v_books_categories.fk_books)))
  WHERE (attributes.fk_attriblist = 245);


ALTER TABLE public.v_books OWNER TO gutenberg;

--
-- Name: bookshelves pk; Type: DEFAULT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.bookshelves ALTER COLUMN pk SET DEFAULT nextval('public.bookshelves_pk_seq'::regclass);


--
-- Name: dcmitypes pk; Type: DEFAULT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.dcmitypes ALTER COLUMN pk SET DEFAULT nextval('public.dcmitypes_pk_seq'::regclass);


--
-- Name: aliases aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.aliases
    ADD CONSTRAINT aliases_pkey PRIMARY KEY (pk);


--
-- Name: attriblist attriblist_name_key; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.attriblist
    ADD CONSTRAINT attriblist_name_key UNIQUE (name);


--
-- Name: attriblist attriblist_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.attriblist
    ADD CONSTRAINT attriblist_pkey PRIMARY KEY (pk);


--
-- Name: attributes attributes_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_pkey PRIMARY KEY (pk);


--
-- Name: author_urls author_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.author_urls
    ADD CONSTRAINT author_urls_pkey PRIMARY KEY (pk);


--
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (pk);


--
-- Name: books books_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_pkey PRIMARY KEY (pk);


--
-- Name: bookshelves bookshelves_bookshelf_key; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.bookshelves
    ADD CONSTRAINT bookshelves_bookshelf_key UNIQUE (bookshelf);


--
-- Name: bookshelves bookshelves_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.bookshelves
    ADD CONSTRAINT bookshelves_pkey PRIMARY KEY (pk);


--
-- Name: categories categories_category_key; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_category_key UNIQUE (category);


--
-- Name: categories categories_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (pk);


--
-- Name: compressions compressions_compression_key; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.compressions
    ADD CONSTRAINT compressions_compression_key UNIQUE (compression);


--
-- Name: compressions compressions_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.compressions
    ADD CONSTRAINT compressions_pkey PRIMARY KEY (pk);


--
-- Name: dcmitypes dcmitypes_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.dcmitypes
    ADD CONSTRAINT dcmitypes_pkey PRIMARY KEY (pk);


--
-- Name: dpid dpid_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.dpid
    ADD CONSTRAINT dpid_pkey PRIMARY KEY (fk_books, projectid);


--
-- Name: encodings encodings_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.encodings
    ADD CONSTRAINT encodings_pkey PRIMARY KEY (pk);


--
-- Name: files files_filename_key; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_filename_key UNIQUE (filename);


--
-- Name: files files_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_pkey PRIMARY KEY (pk);


--
-- Name: filetypes filetypes_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.filetypes
    ADD CONSTRAINT filetypes_pkey PRIMARY KEY (pk);


--
-- Name: langs langs_lang_key; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.langs
    ADD CONSTRAINT langs_lang_key UNIQUE (lang);


--
-- Name: langs langs_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.langs
    ADD CONSTRAINT langs_pkey PRIMARY KEY (pk);


--
-- Name: loccs loccs_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.loccs
    ADD CONSTRAINT loccs_pkey PRIMARY KEY (pk);


--
-- Name: mirrors mirrors_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mirrors
    ADD CONSTRAINT mirrors_pkey PRIMARY KEY (pk);


--
-- Name: mn_books_authors mn_books_authors_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_authors
    ADD CONSTRAINT mn_books_authors_pkey PRIMARY KEY (fk_books, fk_authors, fk_roles);


--
-- Name: mn_books_bookshelves mn_books_bookshelves_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_bookshelves
    ADD CONSTRAINT mn_books_bookshelves_pkey PRIMARY KEY (fk_books, fk_bookshelves);


--
-- Name: mn_books_categories mn_books_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_categories
    ADD CONSTRAINT mn_books_categories_pkey PRIMARY KEY (fk_books, fk_categories);


--
-- Name: mn_books_langs mn_books_langs_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_langs
    ADD CONSTRAINT mn_books_langs_pkey PRIMARY KEY (fk_books, fk_langs);


--
-- Name: mn_books_loccs mn_books_loccs_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_loccs
    ADD CONSTRAINT mn_books_loccs_pkey PRIMARY KEY (fk_books, fk_loccs);


--
-- Name: mn_books_subjects mn_books_subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_subjects
    ADD CONSTRAINT mn_books_subjects_pkey PRIMARY KEY (fk_books, fk_subjects);


--
-- Name: mn_users_permissions mn_users_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_users_permissions
    ADD CONSTRAINT mn_users_permissions_pkey PRIMARY KEY (fk_users, fk_permissions);


--
-- Name: permissions permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (pk);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (pk);


--
-- Name: roles roles_role_key; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_role_key UNIQUE (role);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (pk);


--
-- Name: subjects subjects_subject_key; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_subject_key UNIQUE (subject);


--
-- Name: tweets tweets_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.tweets
    ADD CONSTRAINT tweets_pkey PRIMARY KEY (fk_books, media);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (pk);


--
-- Name: ix_aliases_lower_alias; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_aliases_lower_alias ON public.aliases USING btree (lower((alias)::text));


--
-- Name: ix_attributes_fk_books; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_attributes_fk_books ON public.attributes USING btree (fk_books);


--
-- Name: ix_attributes_fk_books_fk_attriblist_text; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE UNIQUE INDEX ix_attributes_fk_books_fk_attriblist_text ON public.attributes USING btree (fk_books, fk_attriblist, md5(text));


--
-- Name: ix_authors_author_born_floor_died_floor; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE UNIQUE INDEX ix_authors_author_born_floor_died_floor ON public.authors USING btree (author, born_floor, died_floor);


--
-- Name: ix_authors_downloads; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_authors_downloads ON public.authors USING btree (downloads);


--
-- Name: ix_authors_lower_author; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_authors_lower_author ON public.authors USING btree (lower((author)::text));


--
-- Name: ix_authors_release_date; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_authors_release_date ON public.authors USING btree (release_date);


--
-- Name: ix_books_downloads; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_books_downloads ON public.books USING btree (downloads);


--
-- Name: ix_books_filing; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_books_filing ON public.books USING btree (public.filing(title, nonfiling));


--
-- Name: ix_books_release_date; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_books_release_date ON public.books USING btree (release_date);


--
-- Name: ix_books_release_date_pk; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_books_release_date_pk ON public.books USING btree (release_date, pk);


--
-- Name: ix_books_title; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_books_title ON public.books USING btree (title);


--
-- Name: ix_bookshelves_downloads; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_bookshelves_downloads ON public.bookshelves USING btree (downloads);


--
-- Name: ix_bookshelves_release_date; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_bookshelves_release_date ON public.bookshelves USING btree (release_date);


--
-- Name: ix_changelog_login_time; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_changelog_login_time ON public.changelog USING btree (login, "time");


--
-- Name: ix_changelog_time; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_changelog_time ON public.changelog USING btree ("time");


--
-- Name: ix_files_filemtime; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_files_filemtime ON public.files USING btree (filemtime);


--
-- Name: ix_files_fk_books; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_files_fk_books ON public.files USING btree (fk_books);


--
-- Name: ix_mn_books_authors_fk_authors; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_mn_books_authors_fk_authors ON public.mn_books_authors USING btree (fk_authors);


--
-- Name: ix_mn_books_bookshelves_fk_bookshelves; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_mn_books_bookshelves_fk_bookshelves ON public.mn_books_bookshelves USING btree (fk_bookshelves);


--
-- Name: ix_mn_books_categories_fk_categories; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_mn_books_categories_fk_categories ON public.mn_books_categories USING btree (fk_categories);


--
-- Name: ix_mn_books_langs_fk_langs; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_mn_books_langs_fk_langs ON public.mn_books_langs USING btree (fk_langs);


--
-- Name: ix_mn_books_loccs_fk_loccs; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_mn_books_loccs_fk_loccs ON public.mn_books_loccs USING btree (fk_loccs);


--
-- Name: ix_mn_books_subjects_fk_subjects; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_mn_books_subjects_fk_subjects ON public.mn_books_subjects USING btree (fk_subjects);


--
-- Name: ix_subjects_downloads; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_subjects_downloads ON public.subjects USING btree (downloads);


--
-- Name: ix_subjects_release_date; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX ix_subjects_release_date ON public.subjects USING btree (release_date);


--
-- Name: terms_trigram_idx; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX terms_trigram_idx ON public.terms USING gin (word public.gin_trgm_ops);


--
-- Name: tsvecidx_attributes; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX tsvecidx_attributes ON public.attributes USING gin (tsvec);


--
-- Name: tsvecidx_authors; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX tsvecidx_authors ON public.authors USING gin (tsvec);


--
-- Name: tsvecidx_books; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX tsvecidx_books ON public.books USING gin (tsvec);


--
-- Name: tsvecidx_bookshelves; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX tsvecidx_bookshelves ON public.bookshelves USING gin (tsvec);


--
-- Name: tsvecidx_subjects; Type: INDEX; Schema: public; Owner: gutenberg
--

CREATE INDEX tsvecidx_subjects ON public.subjects USING gin (tsvec);


--
-- Name: attributes _1_attributes_tsvec; Type: TRIGGER; Schema: public; Owner: gutenberg
--

CREATE TRIGGER _1_attributes_tsvec BEFORE INSERT OR UPDATE ON public.attributes FOR EACH ROW EXECUTE PROCEDURE public.attributes_tsvec_triggerfunc();


--
-- Name: attributes _1_books_title; Type: TRIGGER; Schema: public; Owner: gutenberg
--

CREATE TRIGGER _1_books_title AFTER INSERT OR DELETE OR UPDATE ON public.attributes FOR EACH ROW EXECUTE PROCEDURE public.books_title_triggerfunc();


--
-- Name: books _1_books_tsvec; Type: TRIGGER; Schema: public; Owner: gutenberg
--

CREATE TRIGGER _1_books_tsvec BEFORE INSERT OR UPDATE ON public.books FOR EACH ROW EXECUTE PROCEDURE public.books_tsvec_triggerfunc();


--
-- Name: bookshelves _1_bookshelves_tsvec; Type: TRIGGER; Schema: public; Owner: gutenberg
--

CREATE TRIGGER _1_bookshelves_tsvec BEFORE INSERT OR UPDATE ON public.bookshelves FOR EACH ROW EXECUTE PROCEDURE public.bookshelves_tsvec_triggerfunc();


--
-- Name: subjects _1_subjects_tsvec; Type: TRIGGER; Schema: public; Owner: gutenberg
--

CREATE TRIGGER _1_subjects_tsvec BEFORE INSERT OR UPDATE ON public.subjects FOR EACH ROW EXECUTE PROCEDURE public.subjects_tsvec_triggerfunc();


--
-- Name: authors _2_authors_tsvec; Type: TRIGGER; Schema: public; Owner: gutenberg
--

CREATE TRIGGER _2_authors_tsvec BEFORE INSERT OR UPDATE ON public.authors FOR EACH ROW EXECUTE PROCEDURE public.authors_tsvec_triggerfunc();


--
-- Name: aliases _2_authors_tsvec_aliases; Type: TRIGGER; Schema: public; Owner: gutenberg
--

CREATE TRIGGER _2_authors_tsvec_aliases AFTER INSERT OR DELETE OR UPDATE ON public.aliases FOR EACH ROW EXECUTE PROCEDURE public.authors_tsvec_alias_triggerfunc();


--
-- Name: attributes _2_books_tsvec_attributes; Type: TRIGGER; Schema: public; Owner: gutenberg
--

CREATE TRIGGER _2_books_tsvec_attributes AFTER INSERT OR DELETE OR UPDATE ON public.attributes FOR EACH ROW EXECUTE PROCEDURE public.books_tsvec_mn_triggerfunc();


--
-- Name: authors _2_books_tsvec_authors; Type: TRIGGER; Schema: public; Owner: gutenberg
--

CREATE TRIGGER _2_books_tsvec_authors AFTER UPDATE ON public.authors FOR EACH ROW EXECUTE PROCEDURE public.books_tsvec_1n_triggerfunc();


--
-- Name: bookshelves _2_books_tsvec_bookshelves; Type: TRIGGER; Schema: public; Owner: gutenberg
--

CREATE TRIGGER _2_books_tsvec_bookshelves AFTER UPDATE ON public.bookshelves FOR EACH ROW EXECUTE PROCEDURE public.books_tsvec_1n_triggerfunc();


--
-- Name: mn_books_authors _2_books_tsvec_mn_books_authors; Type: TRIGGER; Schema: public; Owner: gutenberg
--

CREATE TRIGGER _2_books_tsvec_mn_books_authors AFTER INSERT OR DELETE ON public.mn_books_authors FOR EACH ROW EXECUTE PROCEDURE public.books_tsvec_mn_triggerfunc();


--
-- Name: mn_books_bookshelves _2_books_tsvec_mn_books_bookshelves; Type: TRIGGER; Schema: public; Owner: gutenberg
--

CREATE TRIGGER _2_books_tsvec_mn_books_bookshelves AFTER INSERT OR DELETE ON public.mn_books_bookshelves FOR EACH ROW EXECUTE PROCEDURE public.books_tsvec_mn_triggerfunc();


--
-- Name: mn_books_subjects _2_books_tsvec_mn_books_subjects; Type: TRIGGER; Schema: public; Owner: gutenberg
--

CREATE TRIGGER _2_books_tsvec_mn_books_subjects AFTER INSERT OR DELETE ON public.mn_books_subjects FOR EACH ROW EXECUTE PROCEDURE public.books_tsvec_mn_triggerfunc();


--
-- Name: subjects _2_books_tsvec_subjects; Type: TRIGGER; Schema: public; Owner: gutenberg
--

CREATE TRIGGER _2_books_tsvec_subjects AFTER UPDATE ON public.subjects FOR EACH ROW EXECUTE PROCEDURE public.books_tsvec_1n_triggerfunc();


--
-- Name: aliases $1; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.aliases
    ADD CONSTRAINT "$1" FOREIGN KEY (fk_authors) REFERENCES public.authors(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: author_urls $1; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.author_urls
    ADD CONSTRAINT "$1" FOREIGN KEY (fk_authors) REFERENCES public.authors(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: mn_users_permissions $1; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_users_permissions
    ADD CONSTRAINT "$1" FOREIGN KEY (fk_users) REFERENCES public.users(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: files $1; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT "$1" FOREIGN KEY (fk_filetypes) REFERENCES public.filetypes(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: mn_books_authors $2; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_authors
    ADD CONSTRAINT "$2" FOREIGN KEY (fk_authors) REFERENCES public.authors(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: mn_books_langs $2; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_langs
    ADD CONSTRAINT "$2" FOREIGN KEY (fk_langs) REFERENCES public.langs(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: mn_books_loccs $2; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_loccs
    ADD CONSTRAINT "$2" FOREIGN KEY (fk_loccs) REFERENCES public.loccs(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: mn_books_subjects $2; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_subjects
    ADD CONSTRAINT "$2" FOREIGN KEY (fk_subjects) REFERENCES public.subjects(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: mn_books_categories $2; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_categories
    ADD CONSTRAINT "$2" FOREIGN KEY (fk_categories) REFERENCES public.categories(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: files $2; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT "$2" FOREIGN KEY (fk_encodings) REFERENCES public.encodings(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: mn_users_permissions $2; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_users_permissions
    ADD CONSTRAINT "$2" FOREIGN KEY (fk_permissions) REFERENCES public.permissions(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: attributes $2; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT "$2" FOREIGN KEY (fk_attriblist) REFERENCES public.attriblist(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: mn_books_authors $3; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_authors
    ADD CONSTRAINT "$3" FOREIGN KEY (fk_roles) REFERENCES public.roles(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: files $3; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT "$3" FOREIGN KEY (fk_compressions) REFERENCES public.compressions(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: attributes $3; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT "$3" FOREIGN KEY (fk_langs) REFERENCES public.langs(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: attributes attributes_fk_books_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.attributes
    ADD CONSTRAINT attributes_fk_books_fkey FOREIGN KEY (fk_books) REFERENCES public.books(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: files files_fk_books_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.files
    ADD CONSTRAINT files_fk_books_fkey FOREIGN KEY (fk_books) REFERENCES public.books(pk) ON UPDATE CASCADE ON DELETE RESTRICT;


--
-- Name: mn_books_authors mn_books_authors_fk_books_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_authors
    ADD CONSTRAINT mn_books_authors_fk_books_fkey FOREIGN KEY (fk_books) REFERENCES public.books(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mn_books_bookshelves mn_books_bookshelves_fk_books_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_bookshelves
    ADD CONSTRAINT mn_books_bookshelves_fk_books_fkey FOREIGN KEY (fk_books) REFERENCES public.books(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mn_books_bookshelves mn_books_bookshelves_fk_bookshelves_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_bookshelves
    ADD CONSTRAINT mn_books_bookshelves_fk_bookshelves_fkey FOREIGN KEY (fk_bookshelves) REFERENCES public.bookshelves(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mn_books_categories mn_books_categories_fk_books_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_categories
    ADD CONSTRAINT mn_books_categories_fk_books_fkey FOREIGN KEY (fk_books) REFERENCES public.books(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mn_books_langs mn_books_langs_fk_books_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_langs
    ADD CONSTRAINT mn_books_langs_fk_books_fkey FOREIGN KEY (fk_books) REFERENCES public.books(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mn_books_loccs mn_books_loccs_fk_books_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_loccs
    ADD CONSTRAINT mn_books_loccs_fk_books_fkey FOREIGN KEY (fk_books) REFERENCES public.books(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: mn_books_subjects mn_books_subjects_fk_books_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.mn_books_subjects
    ADD CONSTRAINT mn_books_subjects_fk_books_fkey FOREIGN KEY (fk_books) REFERENCES public.books(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: tweets tweets_fk_books_fkey; Type: FK CONSTRAINT; Schema: public; Owner: gutenberg
--

ALTER TABLE ONLY public.tweets
    ADD CONSTRAINT tweets_fk_books_fkey FOREIGN KEY (fk_books) REFERENCES public.books(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: TABLE authors; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.authors TO PUBLIC;


--
-- Name: TABLE books; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.books TO PUBLIC;


--
-- Name: TABLE subjects; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.subjects TO PUBLIC;


--
-- Name: TABLE aliases; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.aliases TO PUBLIC;


--
-- Name: SEQUENCE aliases_pk_seq; Type: ACL; Schema: public; Owner: gutenberg
--

REVOKE ALL ON SEQUENCE public.aliases_pk_seq FROM gutenberg;
GRANT SELECT,UPDATE ON SEQUENCE public.aliases_pk_seq TO gutenberg WITH GRANT OPTION;


--
-- Name: TABLE author_urls; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.author_urls TO PUBLIC;


--
-- Name: SEQUENCE author_urls_pk_seq; Type: ACL; Schema: public; Owner: gutenberg
--

REVOKE ALL ON SEQUENCE public.author_urls_pk_seq FROM gutenberg;
GRANT SELECT,UPDATE ON SEQUENCE public.author_urls_pk_seq TO gutenberg WITH GRANT OPTION;


--
-- Name: SEQUENCE authors_pk_seq; Type: ACL; Schema: public; Owner: gutenberg
--

REVOKE ALL ON SEQUENCE public.authors_pk_seq FROM gutenberg;
GRANT SELECT,UPDATE ON SEQUENCE public.authors_pk_seq TO gutenberg WITH GRANT OPTION;


--
-- Name: TABLE compressions; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.compressions TO PUBLIC;


--
-- Name: TABLE encodings; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.encodings TO PUBLIC;


--
-- Name: TABLE files; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.files TO PUBLIC;


--
-- Name: SEQUENCE files_pk_seq; Type: ACL; Schema: public; Owner: gutenberg
--

REVOKE ALL ON SEQUENCE public.files_pk_seq FROM gutenberg;
GRANT SELECT,UPDATE ON SEQUENCE public.files_pk_seq TO gutenberg WITH GRANT OPTION;


--
-- Name: TABLE filetypes; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.filetypes TO PUBLIC;


--
-- Name: TABLE langs; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.langs TO PUBLIC;


--
-- Name: TABLE loccs; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.loccs TO PUBLIC;


--
-- Name: TABLE mirrors; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.mirrors TO PUBLIC;


--
-- Name: SEQUENCE mirrors_pk_seq; Type: ACL; Schema: public; Owner: gutenberg
--

REVOKE ALL ON SEQUENCE public.mirrors_pk_seq FROM gutenberg;
GRANT SELECT,UPDATE ON SEQUENCE public.mirrors_pk_seq TO gutenberg WITH GRANT OPTION;


--
-- Name: TABLE mn_books_authors; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.mn_books_authors TO PUBLIC;


--
-- Name: TABLE mn_books_langs; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.mn_books_langs TO PUBLIC;


--
-- Name: TABLE mn_books_loccs; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.mn_books_loccs TO PUBLIC;


--
-- Name: TABLE mn_books_subjects; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.mn_books_subjects TO PUBLIC;


--
-- Name: TABLE roles; Type: ACL; Schema: public; Owner: gutenberg
--

GRANT SELECT ON TABLE public.roles TO PUBLIC;


--
-- Name: SEQUENCE subjects_pk_seq; Type: ACL; Schema: public; Owner: gutenberg
--

REVOKE ALL ON SEQUENCE public.subjects_pk_seq FROM gutenberg;
GRANT SELECT,UPDATE ON SEQUENCE public.subjects_pk_seq TO gutenberg WITH GRANT OPTION;


--
-- PostgreSQL database dump complete
--

