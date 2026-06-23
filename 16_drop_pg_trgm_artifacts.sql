-- NOTE: this file must be run by postgres superuser, not gutenberg!

-- This SQL file removes the "unpackaged" pg_trgm artifacts from before
-- Postgres had full extension support. These artifacts are owned by
-- the postgres user in the gutenberg schema and thus must be removed
-- by the postgres user.

-- public functions
DROP FUNCTION IF EXISTS similarity;
DROP FUNCTION IF EXISTS show_trgm;
DROP FUNCTION IF EXISTS word_similarity;
DROP FUNCTION IF EXISTS strict_word_similarity;
DROP FUNCTION IF EXISTS show_limit;
DROP FUNCTION IF EXISTS set_limit;

-- operators
DROP OPERATOR IF EXISTS % (text, text);
DROP OPERATOR IF EXISTS <% (text, text);
DROP OPERATOR IF EXISTS %> (text, text);
DROP OPERATOR IF EXISTS <<% (text, text);
DROP OPERATOR IF EXISTS %>> (text, text);
DROP OPERATOR IF EXISTS <-> (text, text);
DROP OPERATOR IF EXISTS <<-> (text, text);
DROP OPERATOR IF EXISTS <->> (text, text);
DROP OPERATOR IF EXISTS <<<-> (text, text);
DROP OPERATOR IF EXISTS <->>> (text, text);

-- operator classes
DROP OPERATOR CLASS IF EXISTS gist_trgm_ops USING GIST;
DROP OPERATOR CLASS IF EXISTS gin_trgm_ops USING GIN;

-- operator family
DROP OPERATOR FAMILY IF EXISTS gist_trgm_ops USING GIST;
DROP OPERATOR FAMILY IF EXISTS gin_trgm_ops USING GIN;

-- internal extension functions
DROP FUNCTION IF EXISTS gtrgm_in CASCADE;
DROP FUNCTION IF EXISTS gtrgm_out CASCADE;
DROP FUNCTION IF EXISTS gtrgm_compress;
DROP FUNCTION IF EXISTS gtrgm_decompress;
DROP FUNCTION IF EXISTS gtrgm_consistent;
DROP FUNCTION IF EXISTS gtrgm_distance;
DROP FUNCTION IF EXISTS gtrgm_union;
DROP FUNCTION IF EXISTS gtrgm_same;
DROP FUNCTION IF EXISTS gtrgm_penalty;
DROP FUNCTION IF EXISTS gtrgm_picksplit;
DROP FUNCTION IF EXISTS gtrgm_options;
DROP FUNCTION IF EXISTS gin_extract_trgm (text, internal);
DROP FUNCTION IF EXISTS gin_extract_trgm (text, internal, smallint, internal, internal);
DROP FUNCTION IF EXISTS gin_trgm_consistent;
DROP FUNCTION IF EXISTS set_limit;
DROP FUNCTION IF EXISTS show_limit;
DROP FUNCTION IF EXISTS show_trgm;
DROP FUNCTION IF EXISTS similarity_op;
