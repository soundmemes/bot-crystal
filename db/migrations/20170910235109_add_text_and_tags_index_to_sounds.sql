-- +micrate Up
CREATE EXTENSION pg_trgm;
CREATE INDEX sounds_trgm_title_index ON sounds USING gin (title gin_trgm_ops);
CREATE INDEX sounds_trgm_tags_index ON sounds USING gin (tags gin_trgm_ops);

-- +micrate Down
DROP INDEX sounds_trgm_title_index;
DROP INDEX sounds_trgm_tags_index;
DROP EXTENSION pg_trgm;
