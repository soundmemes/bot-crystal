-- name: by_name(search_query : String, limit : Int32 = 10)
SELECT
  id,
  user_id,
  title,
  telegram_file_id,
  coalesce(levenshtein(title, '{{search_query}}'), 0) AS title_distance,
  coalesce(levenshtein(tags, '{{search_query}}'), 0) AS tags_distance
FROM
  sounds
WHERE
  title ILIKE '%{{search_query}}%' OR tags ILIKE '%{{search_query}}%'
GROUP BY
  id
ORDER BY
  title_distance, tags_distance ASC
LIMIT
  {{limit}}

-- name: by_popularity(limit : Int32 = 10)
SELECT
  id,
  user_id,
  title,
  telegram_file_id
FROM
  sounds
ORDER BY
  coalesce(popularity, 0) DESC
LIMIT
  {{limit}}

-- name: favorites(telegram_user_id : Int32)
SELECT
  sounds.id,
  sounds.user_id,
  sounds.title,
  sounds.telegram_file_id
FROM
  sounds
JOIN
  users ON users.telegram_id = {{telegram_user_id}}
JOIN
  favorites ON sound_id = sounds.id AND favorites.user_id = users.id

-- name: recent(telegram_user_id : Int32, search_query : String, limit : Int32 = 10)
SELECT DISTINCT
  sounds.id,
  sounds.user_id,
  sounds.title,
  sounds.telegram_file_id,
  max(sound_postings.created_at) AS last_posted,
  coalesce(levenshtein(title, '{{search_query}}'), 0) AS title_distance,
  coalesce(levenshtein(tags, '{{search_query}}'), 0) AS tags_distance
FROM
  sounds
JOIN
  users ON users.telegram_id = {{telegram_user_id}}
JOIN
  sound_postings ON sound_postings.sound_id = sounds.id AND sound_postings.user_id = users.id
WHERE
  sounds.title ILIKE '%{{search_query}}%' OR sounds.tags ILIKE '%{{search_query}}%'
GROUP BY
  sounds.id
ORDER BY
  title_distance, tags_distance ASC, last_posted DESC
LIMIT
  {{limit}}

-- name: recent(telegram_user_id : Int32, limit : Int32 = 10)
SELECT DISTINCT
  sounds.id,
  sounds.user_id,
  sounds.title,
  sounds.telegram_file_id,
  max(sound_postings.created_at) AS last_posted
FROM
  sounds
JOIN
  users ON users.telegram_id = {{telegram_user_id}}
JOIN
  sound_postings ON sound_postings.sound_id = sounds.id AND sound_postings.user_id = users.id
GROUP BY
  sounds.id
ORDER BY
  last_posted DESC
LIMIT
  {{limit}}
