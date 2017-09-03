require "./dispatch"
require "../soundmemes/jobs/calculate_sounds_popularity"
require "../soundmemes/jobs/calculate_sounds_posts_count"

def schedule_jobs
  Soundmemes::Jobs::CalculateSoundsPopularity.dispatch
  Soundmemes::Jobs::CalculateSoundsPostsCount.dispatch
end
