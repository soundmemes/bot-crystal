require "../soundmemes/jobs/calculate_sounds_popularity"

def schedule_jobs
  Soundmemes::Jobs::CalculateSoundsPopularity.dispatch
end
