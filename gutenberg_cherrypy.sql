--
-- PostgreSQL database dump
--

\restrict UMt73ESqVe7o8J7zcvliweREUjw3gzchLSdodf4zZCpWvDSaiEU2k2cNzGWuUbJ

-- Dumped from database version 16.13
-- Dumped by pg_dump version 16.13

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
-- Name: cherrypy; Type: SCHEMA; Schema: -; Owner: gutenberg
--

CREATE SCHEMA cherrypy;


ALTER SCHEMA cherrypy OWNER TO gutenberg;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: sessions; Type: TABLE; Schema: cherrypy; Owner: gutenberg
--

CREATE TABLE cherrypy.sessions (
    id character varying(40) NOT NULL,
    expires timestamp without time zone,
    data bytea
);


ALTER TABLE cherrypy.sessions OWNER TO gutenberg;

--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: cherrypy; Owner: gutenberg
--

ALTER TABLE ONLY cherrypy.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: SCHEMA cherrypy; Type: ACL; Schema: -; Owner: gutenberg
--

GRANT USAGE ON SCHEMA cherrypy TO backupuser;


--
-- Name: TABLE sessions; Type: ACL; Schema: cherrypy; Owner: gutenberg
--

GRANT SELECT ON TABLE cherrypy.sessions TO backupuser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: cherrypy; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA cherrypy GRANT ALL ON SEQUENCES TO gutenberg;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA cherrypy GRANT SELECT ON SEQUENCES TO backupuser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: cherrypy; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA cherrypy GRANT ALL ON TABLES TO gutenberg;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA cherrypy GRANT SELECT ON TABLES TO backupuser;


--
-- PostgreSQL database dump complete
--

\unrestrict UMt73ESqVe7o8J7zcvliweREUjw3gzchLSdodf4zZCpWvDSaiEU2k2cNzGWuUbJ

