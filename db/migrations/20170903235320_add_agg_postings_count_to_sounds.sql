-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE sounds ADD COLUMN agg_postings_count INT;
CREATE INDEX sounds_agg_postings_count ON sounds (agg_postings_count);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE sounds DROP COLUMN agg_postings_count;
