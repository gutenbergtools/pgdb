# Project Gutenberg Postgres Database Definition

This repo holds the active definitions for the Project Gutenberg postgres
database, broken down by schema, in:
```
gutenberg_cherrypy.sql
gutenberg_public.sql
gutenberg_reviews.sql
gutenberg_robots.sql
gutenberg_scores.sql
```

## Creating the `.sql` files
These definitions were created from the active ibiblio database with:
```bash
export DB_HOST=gutenberg-pg1.int.ibiblio.org

# dump non-public schemas
for schema in cherrypy reviews robots scores; do
    pg_dump -h $DB_HOST -U gutenberg -s gutenberg -n $schema > gutenberg_$schema.sql
done

# dump the public schema
# we have to do this separately to get the pg_tgrm extension as it lives in the
# database's public schema, but isn't part of the public schema
pg_dump -h $DB_HOST -U gutenberg -s gutenberg -N cherrypy -N reviews -N robots -N scores  > gutenberg_public.sql
```

It also includes migration scripts, prefixed by `##_`, for upgrading from prior versions.

## Updates
- In a branch, add a migration file to the repo, prefixed with digits according to sequence.
- Open PR
- Apply the migration to `gutenberg_dev` database `psql -h dbhost -U gutenberg -s gutenberg_dev -f XX_migration_name.sql`
- Snapshot the migrated schema from the `gutenberg_dev` database using the process above and commit to branch
- Review results and apply to `gutenberg` database

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

```bash
dropdb gutenberg_dev
createdb -T template0 gutenberg_dev
psql gutenberg_dev < guten_dev_full.sql
```
