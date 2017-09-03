-- name: favorites(telegram_user_id : PkeyValue, limit : Int32, offset : Int32)
SELECT
  sounds.*
FROM
  sounds
JOIN
  users ON users.telegram_id = {{telegram_user_id}}
JOIN
  favorites ON sound_id = sounds.id AND favorites.user_id = users.id
LIMIT
  {{limit}}
OFFSET
  {{offset}}
