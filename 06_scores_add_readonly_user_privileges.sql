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

--
-- Grant user backupuser connect access to databases
--

GRANT CONNECT ON DATABASE gutenberg TO backupuser;
GRANT CONNECT ON DATABASE gutenberg_dev TO backupuser;
GRANT CONNECT ON DATABASE postgres TO backupuser;

--
-- Grant user gutenberg the necessary privileges for the grants to backupuser
-- to succeed. Grant user backupuser read-only access to databases. 
--

-- schema scores
GRANT ALL ON ALL TABLES IN SCHEMA scores TO gutenberg;
GRANT ALL ON ALL SEQUENCES IN SCHEMA scores TO gutenberg;
ALTER DEFAULT PRIVILEGES IN SCHEMA scores GRANT ALL ON TABLES TO gutenberg;
ALTER DEFAULT PRIVILEGES IN SCHEMA scores GRANT ALL ON SEQUENCES TO gutenberg;

GRANT SELECT ON ALL TABLES IN SCHEMA scores TO backupuser;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA scores TO backupuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA scores GRANT SELECT ON TABLES TO backupuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA scores GRANT SELECT ON SEQUENCES TO backupuser;
GRANT USAGE ON SCHEMA scores TO backupuser;

--
-- End of grants
--
