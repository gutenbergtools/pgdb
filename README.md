# pgdb
## Postgres Database for Project Gutenberg

- In a branch, add a migration file to the repo, prefixed with digits according to sequence.
- open PR
- Apply the migration to gutenberg_dev database `psql -h dbhost -U gutenberg -s gutenberg_dev -f XX_migration_name.sql`
- snapshot the migrated schema `pg_dump -h dbhost -U gutenberg -s gutenberg_dev -n public` and commit to branch
- review results and apply to gutenberg database

## backupuser
Privileges for user `backupuser` are set in:

```
02_public_add_readonly_user_privileges.sql
03_cherrypy_add_readonly_user_privileges.sql
04_reviews_add_readonly_user_privileges.sql
05_robots_add_readonly_user_privileges.sql
06_scores_add_readonly_user_privileges.sql
```

This user can make database dumps remotely from a management node by:
- Schema only: `pg_dump --user backupuser --host dbhost -s gutenberg_dev > guten_dev_schema.sql`
- Full database: `pg_dump --user backupuser --host dbhost gutenberg_dev > guten_dev_full.sql`

The database can be restored from one of these dumps by running locally on dbhost:

```
dropdb gutenberg_dev
createdb -T template0 gutenberg_dev
psql gutenberg_dev < guten_dev_full.sql
```
