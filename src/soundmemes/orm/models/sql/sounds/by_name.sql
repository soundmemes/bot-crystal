-- name: by_name(search_query : String, limit : Int32)
SELECT
  id,
  user_id,
  title,
  telegram_file_id,
  coalesce(levenshtein(title, '{{!search_query}}'), 0) AS title_distance,
  coalesce(levenshtein(tags, '{{!search_query}}'), 0) AS tags_distance
FROM
  sounds
WHERE
  title ILIKE '%{{!search_query}}%' OR tags ILIKE '%{{!search_query}}%'
GROUP BY
  id
ORDER BY
  title_distance, tags_distance ASC
LIMIT
  {{limit}}
