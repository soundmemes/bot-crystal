-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE sound_postings (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users (id),
  sound_id INT NOT NULL REFERENCES sounds (id),
  telegram_message_id INT,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ
);
CREATE INDEX sound_postings_user_id_index ON sound_postings (user_id);
CREATE INDEX sound_postings_sound_id_index ON sound_postings (sound_id);
CREATE INDEX sound_postings_created_at_index ON sound_postings (created_at);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE sound_postings;
