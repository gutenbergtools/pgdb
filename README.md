# pgdb
Postgres Database for Project Gutenberg

- In a branch, add a migration file to the repo, prefixed with digits according to sequence.
- open PR
- Apply the migration to gutenberg_dev database `psql -h dbhost -U gutenberg -s gutenberg_dev -f XX_migration_name.sql`
- snapshot the migrated schema `pg_dump -h dbhost -U gutenberg -s gutenberg_dev -n public` and commit to branch
- review results and apply to gutenberg database