-- remove unused hash columns
ALTER TABLE public.files
DROP COLUMN IF EXISTS md5hash,
DROP COLUMN IF EXISTS sha1hash,
DROP COLUMN IF EXISTS kzhash,
DROP COLUMN IF EXISTS ed2khash,
DROP COLUMN IF EXISTS tigertreehash
;