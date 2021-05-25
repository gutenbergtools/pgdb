--
-- PostgreSQL grant privileges to backupuser to allow it to run pg_dump remotely
-- Run as postgres user
-- For use when: 
--   1. user gutenberg is owner of databases gutenberg and gutenberg_dev
--   2. user backupuser has been created, but not granted privileges
--

--
-- Grant user gutenberg the necessary privileges for the grants to backupuser
-- to succeed
--

GRANT ALL ON ALL TABLES IN SCHEMA public TO gutenberg;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO gutenberg;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO gutenberg;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO gutenberg;

--
-- Grant user backupuser read-only access to databases
--

GRANT CONNECT ON DATABASE gutenberg TO backupuser;
GRANT CONNECT ON DATABASE gutenberg_dev TO backupuser;
GRANT CONNECT ON DATABASE postgres TO backupuser;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO backupuser;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO backupuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO backupuser;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO backupuser;

GRANT USAGE ON SCHEMA public TO backupuser;

--
-- End of grants
--
