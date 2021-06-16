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
-- Name: reviews; Type: SCHEMA; Schema: -; Owner: gutenberg
--

CREATE SCHEMA reviews;


ALTER SCHEMA reviews OWNER TO gutenberg;

SET default_tablespace = '';

SET default_with_oids = true;

--
-- Name: reviewers; Type: TABLE; Schema: reviews; Owner: gutenberg
--

CREATE TABLE reviews.reviewers (
    pk integer DEFAULT nextval(('reviews.reviewers_pk_seq'::text)::regclass) NOT NULL,
    name character varying NOT NULL,
    login character varying,
    password character varying
);


ALTER TABLE reviews.reviewers OWNER TO gutenberg;

--
-- Name: reviewers_pk_seq; Type: SEQUENCE; Schema: reviews; Owner: gutenberg
--

CREATE SEQUENCE reviews.reviewers_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reviews.reviewers_pk_seq OWNER TO gutenberg;

--
-- Name: reviewers_pk_seq; Type: SEQUENCE OWNED BY; Schema: reviews; Owner: gutenberg
--

ALTER SEQUENCE reviews.reviewers_pk_seq OWNED BY reviews.reviewers.pk;


--
-- Name: reviews; Type: TABLE; Schema: reviews; Owner: gutenberg
--

CREATE TABLE reviews.reviews (
    pk integer DEFAULT nextval(('reviews.reviews_pk_seq'::text)::regclass) NOT NULL,
    fk_books integer NOT NULL,
    fk_reviewers integer NOT NULL,
    title character varying NOT NULL,
    review text NOT NULL
);


ALTER TABLE reviews.reviews OWNER TO gutenberg;

--
-- Name: reviews_pk_seq; Type: SEQUENCE; Schema: reviews; Owner: gutenberg
--

CREATE SEQUENCE reviews.reviews_pk_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE reviews.reviews_pk_seq OWNER TO gutenberg;

--
-- Name: reviews_pk_seq; Type: SEQUENCE OWNED BY; Schema: reviews; Owner: gutenberg
--

ALTER SEQUENCE reviews.reviews_pk_seq OWNED BY reviews.reviews.pk;


--
-- Name: reviewers reviewers_pkey; Type: CONSTRAINT; Schema: reviews; Owner: gutenberg
--

ALTER TABLE ONLY reviews.reviewers
    ADD CONSTRAINT reviewers_pkey PRIMARY KEY (pk);


--
-- Name: reviews reviews_pkey; Type: CONSTRAINT; Schema: reviews; Owner: gutenberg
--

ALTER TABLE ONLY reviews.reviews
    ADD CONSTRAINT reviews_pkey PRIMARY KEY (pk);


--
-- Name: reviews $1; Type: FK CONSTRAINT; Schema: reviews; Owner: gutenberg
--

ALTER TABLE ONLY reviews.reviews
    ADD CONSTRAINT "$1" FOREIGN KEY (fk_books) REFERENCES public.books(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: reviews $2; Type: FK CONSTRAINT; Schema: reviews; Owner: gutenberg
--

ALTER TABLE ONLY reviews.reviews
    ADD CONSTRAINT "$2" FOREIGN KEY (fk_reviewers) REFERENCES reviews.reviewers(pk) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: SCHEMA reviews; Type: ACL; Schema: -; Owner: gutenberg
--

GRANT USAGE ON SCHEMA reviews TO backupuser;


--
-- Name: TABLE reviewers; Type: ACL; Schema: reviews; Owner: gutenberg
--

GRANT SELECT ON TABLE reviews.reviewers TO backupuser;


--
-- Name: SEQUENCE reviewers_pk_seq; Type: ACL; Schema: reviews; Owner: gutenberg
--

GRANT SELECT ON SEQUENCE reviews.reviewers_pk_seq TO backupuser;


--
-- Name: TABLE reviews; Type: ACL; Schema: reviews; Owner: gutenberg
--

GRANT SELECT ON TABLE reviews.reviews TO backupuser;


--
-- Name: SEQUENCE reviews_pk_seq; Type: ACL; Schema: reviews; Owner: gutenberg
--

GRANT SELECT ON SEQUENCE reviews.reviews_pk_seq TO backupuser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: reviews; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA reviews REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA reviews GRANT ALL ON SEQUENCES  TO gutenberg;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA reviews GRANT SELECT ON SEQUENCES  TO backupuser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: reviews; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA reviews REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA reviews GRANT ALL ON TABLES  TO gutenberg;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA reviews GRANT SELECT ON TABLES  TO backupuser;


--
-- PostgreSQL database dump complete
--

