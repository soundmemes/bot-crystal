-- +micrate Up
CREATE INDEX sounds_popularity_index ON sounds (popularity);

-- +micrate Down
DROP INDEX IF EXISTS sounds_popularity_index;
