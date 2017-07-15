-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
CREATE TABLE favorites (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users (id),
  sound_id INT NOT NULL REFERENCES sounds (id),
  created_at TIMESTAMPTZ NOT NULL
);
CREATE INDEX favorites_user_id_index ON favorites (user_id);
CREATE INDEX favorites_sound_id_index ON favorites (sound_id);
CREATE INDEX favorites_created_at_index ON favorites (created_at);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
DROP TABLE favorites;
