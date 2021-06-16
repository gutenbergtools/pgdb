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
-- Name: robots; Type: SCHEMA; Schema: -; Owner: gutenberg
--

CREATE SCHEMA robots;


ALTER SCHEMA robots OWNER TO gutenberg;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: blocks; Type: TABLE; Schema: robots; Owner: gutenberg
--

CREATE TABLE robots.blocks (
    ip cidr NOT NULL,
    host text,
    has_info boolean DEFAULT false,
    is_blocked boolean DEFAULT true,
    is_whitelisted boolean DEFAULT false,
    created timestamp without time zone DEFAULT now(),
    expires timestamp without time zone,
    types text[],
    org text,
    country text,
    note text,
    whois text,
    user_agents text[],
    requests text[],
    count integer DEFAULT 1 NOT NULL,
    hits integer DEFAULT 0 NOT NULL,
    cidr cidr,
    asn text,
    client_ip cidr,
    proxy_type text,
    proxy_ip cidr,
    headers text[]
);


ALTER TABLE robots.blocks OWNER TO gutenberg;

SET default_with_oids = true;

--
-- Name: ips; Type: TABLE; Schema: robots; Owner: gutenberg
--

CREATE TABLE robots.ips (
    ip inet,
    firstseen timestamp without time zone,
    lastseen timestamp without time zone,
    hits integer,
    rhits integer,
    hhits integer,
    ua character varying
);


ALTER TABLE robots.ips OWNER TO gutenberg;

--
-- Name: blocks blocks_pkey; Type: CONSTRAINT; Schema: robots; Owner: gutenberg
--

ALTER TABLE ONLY robots.blocks
    ADD CONSTRAINT blocks_pkey PRIMARY KEY (ip);


--
-- Name: ix_blocks_expires; Type: INDEX; Schema: robots; Owner: gutenberg
--

CREATE INDEX ix_blocks_expires ON robots.blocks USING btree (expires);


--
-- Name: ix_ips_ip; Type: INDEX; Schema: robots; Owner: gutenberg
--

CREATE INDEX ix_ips_ip ON robots.ips USING btree (ip);


--
-- Name: SCHEMA robots; Type: ACL; Schema: -; Owner: gutenberg
--

GRANT USAGE ON SCHEMA robots TO backupuser;


--
-- Name: TABLE blocks; Type: ACL; Schema: robots; Owner: gutenberg
--

GRANT SELECT ON TABLE robots.blocks TO backupuser;


--
-- Name: TABLE ips; Type: ACL; Schema: robots; Owner: gutenberg
--

GRANT SELECT ON TABLE robots.ips TO backupuser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: robots; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA robots REVOKE ALL ON SEQUENCES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA robots GRANT ALL ON SEQUENCES  TO gutenberg;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA robots GRANT SELECT ON SEQUENCES  TO backupuser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: robots; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA robots REVOKE ALL ON TABLES  FROM postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA robots GRANT ALL ON TABLES  TO gutenberg;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA robots GRANT SELECT ON TABLES  TO backupuser;


--
-- PostgreSQL database dump complete
--

