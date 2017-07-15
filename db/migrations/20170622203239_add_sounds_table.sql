-- +micrate Up
CREATE TABLE sounds (
  id SERIAL PRIMARY KEY,
  user_id INT NOT NULL REFERENCES users (id),
  title VARCHAR(100) NOT NULL,
  tags VARCHAR(256),
  telegram_file_id VARCHAR(64) NOT NULL,
  popularity REAL,
  created_at TIMESTAMPTZ NOT NULL,
  updated_at TIMESTAMPTZ
);
CREATE INDEX sounds_user_id_index ON sounds (user_id);
CREATE INDEX sounds_title_index ON sounds USING gin(to_tsvector('simple', title));
CREATE INDEX sounds_tags_index ON sounds USING gin(to_tsvector('simple', tags));
CREATE UNIQUE INDEX sounds_telegram_file_id_index ON sounds (telegram_file_id);
CREATE INDEX sounds_created_at_index ON sounds (created_at);
CREATE EXTENSION fuzzystrmatch;

-- +micrate Down
DROP TABLE sounds;
DROP EXTENSION fuzzystrmatch;
