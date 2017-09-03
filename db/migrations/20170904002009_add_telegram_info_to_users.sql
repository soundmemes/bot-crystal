-- +micrate Up
-- SQL in section 'Up' is executed when this migration is applied
ALTER TABLE users ADD COLUMN telegram_first_name VARCHAR(256);
ALTER TABLE users ADD COLUMN telegram_last_name VARCHAR(256);
ALTER TABLE users ADD COLUMN telegram_username VARCHAR(256);

-- +micrate Down
-- SQL section 'Down' is executed when this migration is rolled back
ALTER TABLE sounds DROP COLUMN telegram_first_name;
ALTER TABLE sounds DROP COLUMN telegram_last_name;
ALTER TABLE sounds DROP COLUMN telegram_username;
