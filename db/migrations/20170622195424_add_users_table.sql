-- +micrate Up
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  telegram_id INT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL
);
CREATE UNIQUE INDEX users_telegram_id_index ON users (telegram_id);

-- +micrate Down
DROP TABLE users;
