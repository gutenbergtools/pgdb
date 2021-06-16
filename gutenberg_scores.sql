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
-- Name: scores; Type: SCHEMA; Schema: -; Owner: gutenberg
--

CREATE SCHEMA scores;


ALTER SCHEMA scores OWNER TO gutenberg;

SET default_tablespace = '';

SET default_with_oids = true;

--
-- Name: also_downloads; Type: TABLE; Schema: scores; Owner: gutenberg
--

CREATE TABLE scores.also_downloads (
    id integer,
    fk_books integer NOT NULL,
    date date
);


ALTER TABLE scores.also_downloads OWNER TO gutenberg;

--
-- Name: also_downloads_id_seq; Type: SEQUENCE; Schema: scores; Owner: gutenberg
--

CREATE SEQUENCE scores.also_downloads_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE scores.also_downloads_id_seq OWNER TO gutenberg;

SET default_with_oids = false;

--
-- Name: author_downloads; Type: TABLE; Schema: scores; Owner: gutenberg
--

CREATE TABLE scores.author_downloads (
    date date NOT NULL,
    fk_authors integer NOT NULL,
    downloads integer NOT NULL
);


ALTER TABLE scores.author_downloads OWNER TO gutenberg;

SET default_with_oids = true;

--
-- Name: book_downloads; Type: TABLE; Schema: scores; Owner: gutenberg
--

CREATE TABLE scores.book_downloads (
    pk integer DEFAULT nextval(('scores.book_downloads_pk_seq'::text)::regclass) NOT NULL,
    date date NOT NULL,
    fk_books integer NOT NULL,
    downloads integer NOT NULL
);


ALTER TABLE scores.book_downloads OWNER TO gutenberg;

--
-- Name: book_downloads_pk_seq; Type: SEQUENCE; Schema: scores; Owner: gutenberg
--

CREATE SEQUENCE scores.book_downloads_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE scores.book_downloads_pk_seq OWNER TO gutenberg;

--
-- Name: book_downloads_pk_seq; Type: SEQUENCE OWNED BY; Schema: scores; Owner: gutenberg
--

ALTER SEQUENCE scores.book_downloads_pk_seq OWNED BY scores.book_downloads.pk;


SET default_with_oids = false;

--
-- Name: bookshelf_downloads; Type: TABLE; Schema: scores; Owner: gutenberg
--

CREATE TABLE scores.bookshelf_downloads (
    date date NOT NULL,
    fk_bookshelves integer NOT NULL,
    downloads integer NOT NULL
);


ALTER TABLE scores.bookshelf_downloads OWNER TO gutenberg;

SET default_with_oids = true;

--
-- Name: file_downloads; Type: TABLE; Schema: scores; Owner: gutenberg
--

CREATE TABLE scores.file_downloads (
    pk integer DEFAULT nextval(('scores.file_downloads_pk_seq'::text)::regclass) NOT NULL,
    date date NOT NULL,
    fk_files integer NOT NULL,
    downloads integer
);


ALTER TABLE scores.file_downloads OWNER TO gutenberg;

--
-- Name: file_downloads_pk_seq; Type: SEQUENCE; Schema: scores; Owner: gutenberg
--

CREATE SEQUENCE scores.file_downloads_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE scores.file_downloads_pk_seq OWNER TO gutenberg;

--
-- Name: file_downloads_pk_seq; Type: SEQUENCE OWNED BY; Schema: scores; Owner: gutenberg
--

ALTER SEQUENCE scores.file_downloads_pk_seq OWNED BY scores.file_downloads.pk;


SET default_with_oids = false;

--
-- Name: filetype_downloads; Type: TABLE; Schema: scores; Owner: gutenberg
--

CREATE TABLE scores.filetype_downloads (
    date date NOT NULL,
    fk_filetypes character varying(20) NOT NULL,
    downloads integer NOT NULL
);


ALTER TABLE scores.filetype_downloads OWNER TO gutenberg;

--
-- Name: subject_downloads; Type: TABLE; Schema: scores; Owner: gutenberg
--

CREATE TABLE scores.subject_downloads (
    date date NOT NULL,
    fk_subjects integer NOT NULL,
    downloads integer NOT NULL
);


ALTER TABLE scores.subject_downloads OWNER TO gutenberg;

--
-- Name: v_by_filetype; Type: VIEW; Schema: scores; Owner: gutenberg
--

CREATE VIEW scores.v_by_filetype AS
 SELECT filetype_downloads.fk_filetypes AS filetypes,
    sum(filetype_downloads.downloads) AS downloads
   FROM scores.filetype_downloads
  GROUP BY filetype_downloads.fk_filetypes
  ORDER BY (sum(filetype_downloads.downloads)) DESC;


ALTER TABLE scores.v_by_filetype OWNER TO gutenberg;

--
-- Name: book_downloads book_downloads_pkey; Type: CONSTRAINT; Schema: scores; Owner: gutenberg
--

ALTER TABLE ONLY scores.book_downloads
    ADD CONSTRAINT book_downloads_pkey PRIMARY KEY (pk);


--
-- Name: bookshelf_downloads bookshelf_downloads_date_key; Type: CONSTRAINT; Schema: scores; Owner: gutenberg
--

ALTER TABLE ONLY scores.bookshelf_downloads
    ADD CONSTRAINT bookshelf_downloads_date_key UNIQUE (date, fk_bookshelves);


--
-- Name: file_downloads file_downloads_pkey; Type: CONSTRAINT; Schema: scores; Owner: gutenberg
--

ALTER TABLE ONLY scores.file_downloads
    ADD CONSTRAINT file_downloads_pkey PRIMARY KEY (pk);


--
-- Name: filetype_downloads filetype_downloads_pkey; Type: CONSTRAINT; Schema: scores; Owner: gutenberg
--

ALTER TABLE ONLY scores.filetype_downloads
    ADD CONSTRAINT filetype_downloads_pkey PRIMARY KEY (date, fk_filetypes);


--
-- Name: author_downloads ix_author_downloads_date_fk_authors; Type: CONSTRAINT; Schema: scores; Owner: gutenberg
--

ALTER TABLE ONLY scores.author_downloads
    ADD CONSTRAINT ix_author_downloads_date_fk_authors UNIQUE (date, fk_authors);


--
-- Name: ix_also_downloads_fk_books; Type: INDEX; Schema: scores; Owner: gutenberg
--

CREATE UNIQUE INDEX ix_also_downloads_fk_books ON scores.also_downloads USING btree (fk_books, id);


--
-- Name: ix_also_downloads_id; Type: INDEX; Schema: scores; Owner: gutenberg
--

CREATE INDEX ix_also_downloads_id ON scores.also_downloads USING btree (id);


--
-- Name: ix_book_downloads_date_fk_books; Type: INDEX; Schema: scores; Owner: gutenberg
--

CREATE UNIQUE INDEX ix_book_downloads_date_fk_books ON scores.book_downloads USING btree (date, fk_books);


--
-- Name: ix_file_downloads_date_fk_files; Type: INDEX; Schema: scores; Owner: gutenberg
--

CREATE UNIQUE INDEX ix_file_downloads_date_fk_files ON scores.file_downloads USING btree (date, fk_files);


--
-- Name: file_downloads $1; Type: FK CONSTRAINT; Schema: scores; Owner: gutenberg
--

ALTER TABLE ONLY scores.file_downloads
    ADD CONSTRAINT "$1" FOREIGN KEY (fk_files) REFERENCES public.files(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: book_downloads $1; Type: FK CONSTRAINT; Schema: scores; Owner: gutenberg
--

ALTER TABLE ONLY scores.book_downloads
    ADD CONSTRAINT "$1" FOREIGN KEY (fk_books) REFERENCES public.books(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: also_downloads $1; Type: FK CONSTRAINT; Schema: scores; Owner: gutenberg
--

ALTER TABLE ONLY scores.also_downloads
    ADD CONSTRAINT "$1" FOREIGN KEY (fk_books) REFERENCES public.books(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: author_downloads author_downloads_fk_authors_fkey; Type: FK CONSTRAINT; Schema: scores; Owner: gutenberg
--

ALTER TABLE ONLY scores.author_downloads
    ADD CONSTRAINT author_downloads_fk_authors_fkey FOREIGN KEY (fk_authors) REFERENCES public.authors(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: bookshelf_downloads bookshelf_downloads_fk_bookshelves_fkey; Type: FK CONSTRAINT; Schema: scores; Owner: gutenberg
--

ALTER TABLE ONLY scores.bookshelf_downloads
    ADD CONSTRAINT bookshelf_downloads_fk_bookshelves_fkey FOREIGN KEY (fk_bookshelves) REFERENCES public.bookshelves(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: filetype_downloads filetype_downloads_fk_filetypes_fkey; Type: FK CONSTRAINT; Schema: scores; Owner: gutenberg
--

ALTER TABLE ONLY scores.filetype_downloads
    ADD CONSTRAINT filetype_downloads_fk_filetypes_fkey FOREIGN KEY (fk_filetypes) REFERENCES public.filetypes(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: subject_downloads subject_downloads_fk_subjects_fkey; Type: FK CONSTRAINT; Schema: scores; Owner: gutenberg
--

ALTER TABLE ONLY scores.subject_downloads
    ADD CONSTRAINT subject_downloads_fk_subjects_fkey FOREIGN KEY (fk_subjects) REFERENCES public.subjects(pk);


--
-- Name: SCHEMA scores; Type: ACL; Schema: -; Owner: gutenberg
--

GRANT USAGE ON SCHEMA scores TO backupuser;


--
-- Name: TABLE also_downloads; Type: ACL; Schema: scores; Owner: gutenberg
--

GRANT SELECT ON TABLE scores.also_downloads TO backupuser;


--
-- Name: SEQUENCE also_downloads_id_seq; Type: ACL; Schema: scores; Owner: gutenberg
--

GRANT SELECT ON SEQUENCE scores.also_downloads_id_seq TO backupuser;


--
-- Name: TABLE author_downloads; Type: ACL; Schema: scores; Owner: gutenberg
--

GRANT SELECT ON TABLE scores.author_downloads TO backupuser;


--
-- Name: TABLE book_downloads; Type: ACL; Schema: scores; Owner: gutenberg
--

GRANT SELECT ON TABLE scores.book_downloads TO backupuser;


--
-- Name: SEQUENCE book_downloads_pk_seq; Type: ACL; Schema: scores; Owner: gutenberg
--

GRANT SELECT ON SEQUENCE scores.book_downloads_pk_seq TO backupuser;


--
-- Name: TABLE bookshelf_downloads; Type: ACL; Schema: scores; Owner: gutenberg
--

GRANT SELECT ON TABLE scores.bookshelf_downloads TO backupuser;


--
-- Name: TABLE file_downloads; Type: ACL; Schema: scores; Owner: gutenberg
--

GRANT SELECT ON TABLE scores.file_downloads TO backupuser;


--
-- Name: SEQUENCE file_downloads_pk_seq; Type: ACL; Schema: scores; Owner: gutenberg
--

GRANT SELECT ON SEQUENCE scores.file_downloads_pk_seq TO backupuser;


--
-- Name: TABLE filetype_downloads; Type: ACL; Schema: scores; Owner: gutenberg
--

GRANT SELECT ON TABLE scores.filetype_downloads TO backupuser;


--
-- Name: TABLE subject_downloads; Type: ACL; Schema: scores; Owner: gutenberg
--

GRANT SELECT ON TABLE scores.subject_downloads TO backupuser;


--
-- Name: TABLE v_by_filetype; Type: ACL; Schema: scores; Owner: gutenberg
--

GRANT SELECT ON TABLE scores.v_by_filetype TO backupuser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: scores; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA scores REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA scores GRANT ALL ON SEQUENCES  TO gutenberg;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA scores GRANT SELECT ON SEQUENCES  TO backupuser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: scores; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA scores REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA scores GRANT ALL ON TABLES  TO gutenberg;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA scores GRANT SELECT ON TABLES  TO backupuser;


--
-- PostgreSQL database dump complete
--

