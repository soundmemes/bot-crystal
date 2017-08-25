-- name: recent(telegram_user_id : PkeyValue, limit : Int32, search_query : String)
SELECT DISTINCT
  sounds.id,
  sounds.user_id,
  sounds.title,
  sounds.telegram_file_id,
  max(sound_postings.created_at) AS last_posted,
  coalesce(levenshtein(title, '{{!search_query}}'), 0) AS title_distance,
  coalesce(levenshtein(tags, '{{!search_query}}'), 0) AS tags_distance
FROM
  sounds
JOIN
  users ON users.telegram_id = {{telegram_user_id}}
JOIN
  sound_postings ON sound_postings.sound_id = sounds.id AND sound_postings.user_id = users.id
WHERE
  sounds.title ILIKE '%{{!search_query}}%' OR sounds.tags ILIKE '%{{!search_query}}%'
GROUP BY
  sounds.id
ORDER BY
  title_distance, tags_distance ASC, last_posted DESC
LIMIT
  {{limit}}

-- name: recent(telegram_user_id : PkeyValue, limit : Int32)
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
