--
-- PostgreSQL grant privileges to backupuser to allow it to run pg_dump remotely
-- Run as postgres user
-- For use when: 
--   1. user gutenberg is owner of databases gutenberg and gutenberg_dev
--   2. user backupuser has been created, but not granted privileges
-- Note: Granting privileges to a schema is relative to a database, so run the
-- grant statements with database gutenberg or gutenberg_dev selected to apply
-- to that database.
--

-- schema cherrypy
GRANT ALL ON ALL TABLES IN SCHEMA cherrypy TO gutenberg;
GRANT ALL ON ALL SEQUENCES IN SCHEMA cherrypy TO gutenberg;
ALTER DEFAULT PRIVILEGES IN SCHEMA cherrypy GRANT ALL ON TABLES TO gutenberg;
ALTER DEFAULT PRIVILEGES IN SCHEMA cherrypy GRANT ALL ON SEQUENCES TO gutenberg;

GRANT SELECT ON ALL TABLES IN SCHEMA cherrypy TO backupuser;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA cherrypy TO backupuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA cherrypy GRANT SELECT ON TABLES TO backupuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA cherrypy GRANT SELECT ON SEQUENCES TO backupuser;
GRANT USAGE ON SCHEMA cherrypy TO backupuser;

--
-- End of grants
--
