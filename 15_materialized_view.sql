-- Author: Zachary Rosario (github.com/zachjesus)
-- Based on libgutenberg DublinCoreMapping.py
-- Precomputes joins into cache for faster search results and filter operations.
-- This materialized view is intended to be refreshed periodically.
-- Make sure to run before upgrading Postgres as the pg_trgm extension will have to be manually removed and re-installed otherwise.

BEGIN;

SET LOCAL client_min_messages = WARNING;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_extension WHERE extname = 'pg_trgm') THEN
        RETURN;
    END IF;
    
    BEGIN
        CREATE EXTENSION pg_trgm;
    EXCEPTION 
        WHEN duplicate_function THEN
            EXECUTE 'CREATE EXTENSION pg_trgm FROM unpackaged';
    END;
END $$;

DROP MATERIALIZED VIEW IF EXISTS mv_books_dc CASCADE;
CREATE MATERIALIZED VIEW mv_books_dc AS
SELECT
    b.pk AS book_id,
    b.title,
    -- Subtitle (raw MARC 245)
    (
        SELECT a.text
        FROM attributes a
        WHERE a.fk_books = b.pk AND a.fk_attriblist = 245
        LIMIT 1
    ) AS subtitle,
    b.tsvec,
    b.downloads,
    b.release_date,
    b.copyrighted,

    -- Combined searchable text for books (title, authors, subjects, bookshelves)
    -- Used for the fuzzy search
    CONCAT_WS(' ',
        b.title,
        (SELECT STRING_AGG(au.author, ' ')
         FROM mn_books_authors mba
         JOIN authors au ON mba.fk_authors = au.pk
         WHERE mba.fk_books = b.pk),
        (SELECT STRING_AGG(s.subject, ' ')
         FROM mn_books_subjects mbs
         JOIN subjects s ON mbs.fk_subjects = s.pk
         WHERE mbs.fk_books = b.pk),
        (SELECT STRING_AGG(bs.bookshelf, ' ')
         FROM mn_books_bookshelves mbbs
         JOIN bookshelves bs ON mbbs.fk_bookshelves = bs.pk
         WHERE mbbs.fk_books = b.pk)
    ) AS book_text,

    -- All language codes as array
    COALESCE((
        SELECT ARRAY_AGG(DISTINCT l.pk::text)
        FROM mn_books_langs mbl
        JOIN langs l ON mbl.fk_langs = l.pk
        WHERE mbl.fk_books = b.pk
    ), ARRAY['en']::text[]) AS lang_codes,

    EXISTS (
        SELECT 1 FROM mn_books_categories mbc
        WHERE mbc.fk_books = b.pk AND mbc.fk_categories IN (1, 2)
    ) AS is_audio,

    (
        SELECT MAX(au.born_floor)
        FROM mn_books_authors mba
        JOIN authors au ON mba.fk_authors = au.pk
        WHERE mba.fk_books = b.pk AND au.born_floor > 0
    ) AS max_author_birthyear,

    (
        SELECT MIN(au.born_floor)
        FROM mn_books_authors mba
        JOIN authors au ON mba.fk_authors = au.pk
        WHERE mba.fk_books = b.pk AND au.born_floor > 0
    ) AS min_author_birthyear,

    (
        SELECT MAX(au.died_floor)
        FROM mn_books_authors mba
        JOIN authors au ON mba.fk_authors = au.pk
        WHERE mba.fk_books = b.pk AND au.died_floor > 0
    ) AS max_author_deathyear,

    (
        SELECT MIN(au.died_floor)
        FROM mn_books_authors mba
        JOIN authors au ON mba.fk_authors = au.pk
        WHERE mba.fk_books = b.pk AND au.died_floor > 0
    ) AS min_author_deathyear,

    -- LoCC codes as array 
    COALESCE((
        SELECT ARRAY_AGG(lc.pk)
        FROM mn_books_loccs mblc
        JOIN loccs lc ON mblc.fk_loccs = lc.pk
        WHERE mblc.fk_books = b.pk
    ), ARRAY[]::text[]) AS locc_codes,

    -- Creator Information (all field ordered)
    (
        SELECT ARRAY_AGG(au.pk ORDER BY mba.heading, r.role, au.author)
        FROM mn_books_authors mba
        JOIN authors au ON mba.fk_authors = au.pk
        JOIN roles r ON mba.fk_roles = r.pk
        WHERE mba.fk_books = b.pk
    ) AS creator_ids,
    (
        SELECT ARRAY_AGG(au.author ORDER BY mba.heading, r.role, au.author)
        FROM mn_books_authors mba
        JOIN authors au ON mba.fk_authors = au.pk
        JOIN roles r ON mba.fk_roles = r.pk
        WHERE mba.fk_books = b.pk
    ) AS creator_names,
    (
        SELECT ARRAY_AGG(r.role ORDER BY mba.heading, r.role, au.author)
        FROM mn_books_authors mba
        JOIN authors au ON mba.fk_authors = au.pk
        JOIN roles r ON mba.fk_roles = r.pk
        WHERE mba.fk_books = b.pk
    ) AS creator_roles,
    (
        SELECT ARRAY_AGG(au.born_floor ORDER BY mba.heading, r.role, au.author)
        FROM mn_books_authors mba
        JOIN authors au ON mba.fk_authors = au.pk
        JOIN roles r ON mba.fk_roles = r.pk
        WHERE mba.fk_books = b.pk
    ) AS creator_born_floor,
    (
        SELECT ARRAY_AGG(au.born_ceil ORDER BY mba.heading, r.role, au.author)
        FROM mn_books_authors mba
        JOIN authors au ON mba.fk_authors = au.pk
        JOIN roles r ON mba.fk_roles = r.pk
        WHERE mba.fk_books = b.pk
    ) AS creator_born_ceil,
    (
        SELECT ARRAY_AGG(au.died_floor ORDER BY mba.heading, r.role, au.author)
        FROM mn_books_authors mba
        JOIN authors au ON mba.fk_authors = au.pk
        JOIN roles r ON mba.fk_roles = r.pk
        WHERE mba.fk_books = b.pk
    ) AS creator_died_floor,
    (
        SELECT ARRAY_AGG(au.died_ceil ORDER BY mba.heading, r.role, au.author)
        FROM mn_books_authors mba
        JOIN authors au ON mba.fk_authors = au.pk
        JOIN roles r ON mba.fk_roles = r.pk
        WHERE mba.fk_books = b.pk
    ) AS creator_died_ceil,

    -- Subjects (ordered alphabetically)
    (
        SELECT ARRAY_AGG(s.pk ORDER BY s.subject)
        FROM mn_books_subjects mbs
        JOIN subjects s ON mbs.fk_subjects = s.pk
        WHERE mbs.fk_books = b.pk
    ) AS subject_ids,
    (
        SELECT ARRAY_AGG(s.subject ORDER BY s.subject)
        FROM mn_books_subjects mbs
        JOIN subjects s ON mbs.fk_subjects = s.pk
        WHERE mbs.fk_books = b.pk
    ) AS subject_names,

    -- Bookshelves (ordered alphabetically)
    (
        SELECT ARRAY_AGG(bs.pk ORDER BY bs.bookshelf)
        FROM mn_books_bookshelves mbbs
        JOIN bookshelves bs ON mbbs.fk_bookshelves = bs.pk
        WHERE mbbs.fk_books = b.pk
    ) AS bookshelf_ids,
    (
        SELECT ARRAY_AGG(bs.bookshelf ORDER BY bs.bookshelf)
        FROM mn_books_bookshelves mbbs
        JOIN bookshelves bs ON mbbs.fk_bookshelves = bs.pk
        WHERE mbbs.fk_books = b.pk
    ) AS bookshelf_names,

    -- DCMI types (default to Text)
    COALESCE((
        SELECT ARRAY_AGG(d.dcmitype ORDER BY d.dcmitype)
        FROM mn_books_categories mbc
        JOIN dcmitypes d ON mbc.fk_categories = d.pk
        WHERE mbc.fk_books = b.pk
    ), ARRAY['Text']::text[]) AS dcmitypes,

    -- Publisher (MARC 260 or 264)
    (
        SELECT a.text
        FROM attributes a
        WHERE a.fk_books = b.pk AND a.fk_attriblist IN (260, 264)
        ORDER BY a.fk_attriblist
        LIMIT 1
    ) AS publisher,

    -- Summary (MARC 520)
    (
        SELECT ARRAY_AGG(a.text ORDER BY a.pk)
        FROM attributes a
        WHERE a.fk_books = b.pk AND a.fk_attriblist = 520
    ) AS summary,

    -- Credits (MARC 508)
    (
        SELECT ARRAY_AGG(a.text ORDER BY a.pk)
        FROM attributes a
        WHERE a.fk_books = b.pk AND a.fk_attriblist = 508
    ) AS credits,

    -- Reading level (MARC 908)
    (
        SELECT a.text
        FROM attributes a
        WHERE a.fk_books = b.pk AND a.fk_attriblist = 908
        ORDER BY a.pk
        LIMIT 1
    ) AS reading_level,

    -- Cover pages (MARC 901)
    (
        SELECT ARRAY_AGG(a.text ORDER BY a.pk)
        FROM attributes a
        WHERE a.fk_books = b.pk AND a.fk_attriblist = 901
    ) AS coverpage,

    -- Formats (files, ordered by filetype sort order)
    (
        SELECT ARRAY_AGG(f.filename ORDER BY ft.sortorder, f.fk_filetypes)
        FROM files f
        LEFT JOIN filetypes ft ON f.fk_filetypes = ft.pk
        WHERE f.fk_books = b.pk
          AND f.obsoleted = 0
          AND f.diskstatus = 0
    ) AS format_filenames,
    (
        SELECT ARRAY_AGG(f.fk_filetypes ORDER BY ft.sortorder, f.fk_filetypes)
        FROM files f
        LEFT JOIN filetypes ft ON f.fk_filetypes = ft.pk
        WHERE f.fk_books = b.pk
          AND f.obsoleted = 0
          AND f.diskstatus = 0
    ) AS format_filetypes,
    (
        SELECT ARRAY_AGG(ft.filetype ORDER BY ft.sortorder, f.fk_filetypes)
        FROM files f
        LEFT JOIN filetypes ft ON f.fk_filetypes = ft.pk
        WHERE f.fk_books = b.pk
          AND f.obsoleted = 0
          AND f.diskstatus = 0
    ) AS format_hr_filetypes,
    (
        SELECT ARRAY_AGG(ft.mediatype ORDER BY ft.sortorder, f.fk_filetypes)
        FROM files f
        LEFT JOIN filetypes ft ON f.fk_filetypes = ft.pk
        WHERE f.fk_books = b.pk
          AND f.obsoleted = 0
          AND f.diskstatus = 0
    ) AS format_mediatypes,
    (
        SELECT ARRAY_AGG(f.filesize ORDER BY ft.sortorder, f.fk_filetypes)
        FROM files f
        LEFT JOIN filetypes ft ON f.fk_filetypes = ft.pk
        WHERE f.fk_books = b.pk
          AND f.obsoleted = 0
          AND f.diskstatus = 0
    ) AS format_extents
FROM books b;

-- INDEXES
CREATE UNIQUE INDEX idx_mv_pk ON mv_books_dc (book_id);


CREATE INDEX idx_mv_btree_downloads ON mv_books_dc (downloads DESC);
CREATE INDEX idx_mv_btree_copyrighted ON mv_books_dc (copyrighted);
CREATE INDEX idx_mv_btree_is_audio ON mv_books_dc (is_audio) WHERE is_audio = true;
CREATE INDEX idx_mv_btree_birthyear_max ON mv_books_dc (max_author_birthyear) WHERE max_author_birthyear IS NOT NULL;
CREATE INDEX idx_mv_btree_birthyear_min ON mv_books_dc (min_author_birthyear) WHERE min_author_birthyear IS NOT NULL;
CREATE INDEX idx_mv_btree_deathyear_max ON mv_books_dc (max_author_deathyear) WHERE max_author_deathyear IS NOT NULL;
CREATE INDEX idx_mv_btree_deathyear_min ON mv_books_dc (min_author_deathyear) WHERE min_author_deathyear IS NOT NULL;
CREATE INDEX idx_mv_btree_release_date ON mv_books_dc (release_date DESC NULLS LAST);
CREATE INDEX idx_mv_gin_lang ON mv_books_dc USING GIN (lang_codes);

CREATE INDEX idx_mv_book_tsvec ON mv_books_dc USING GIN (tsvec);
CREATE INDEX idx_mv_fuzzy_book ON mv_books_dc USING GIST (book_text gist_trgm_ops);

ANALYZE mv_books_dc;

-- Refresh Function (for use with systemd timer or cron)
-- SELECT refresh_mv_books_dc();
-- psql -U postgres -d your_database -c "SELECT refresh_mv_books_dc();"

CREATE OR REPLACE FUNCTION refresh_mv_books_dc()
RETURNS void
LANGUAGE plpgsql
AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_books_dc;
    ANALYZE mv_books_dc;
END;
$$;

COMMIT;

SELECT pg_size_pretty(pg_total_relation_size('mv_books_dc')) AS mv_total_size, pg_size_pretty(pg_indexes_size('mv_books_dc')) AS mv_index_size;
