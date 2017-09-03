require "../../utils/logger"
require "../orm/models/sound_post"

module Soundmemes
  module Jobs
    class CalculateSoundsPopularity
      include Dispatchable
      include Utils::Logger

      @@logger_progname = "JOB"

      POPULARITY_WINDOW = 1.day
      CALCULATE_PERIOD  = 1.hour

      def perform
        since = Time.now - POPULARITY_WINDOW

        total = Repo.aggregate(SoundPost, :count, :id, Query.where("created_at > ?", [since])).as(Int64)

        if total > 0
          q = <<-'SQL'
            UPDATE
              sounds
            SET
              popularity = sq.postings_count / ?::REAL
            FROM (
              SELECT
                sounds.id AS id,
                COUNT(sound_postings.id) AS postings_count
              FROM
                sounds
              LEFT OUTER JOIN
                sound_postings ON sound_postings.sound_id = sounds.id
              WHERE
                sound_postings.created_at > ?
              GROUP BY
                sounds.id
            ) AS sq
            WHERE
              sounds.id = sq.id
          SQL

          Repo.query(q, [total, since])
        else
          q = <<-'SQL'
            UPDATE
              sounds
            SET
              popularity = 0
          SQL

          Repo.query(q)
        end

        logger.info("Updated sound popularities (total posts in last day: #{total})")

        self.class.dispatch_in(CALCULATE_PERIOD)
      end
    end
  end
end
