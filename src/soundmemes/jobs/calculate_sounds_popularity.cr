require "../../utils/logger"
require "../../services/db"

module Soundmemes
  module Jobs
    class CalculateSoundsPopularity
      include Dispatchable
      include Utils::Logger

      @@logger_progname = "JOB"

      POPULARITY_WINDOW = 1.day
      CALCULATE_PERIOD  = 1.hour

      def perform
        q = <<-SQL
          SELECT
            COUNT(id)
          FROM
            sound_postings
          WHERE
            created_at > $1
        SQL

        total = db.query_one(q, Time.now - POPULARITY_WINDOW, as: {Int64}).to_f

        if total > 0
          q = <<-'SQL'
            UPDATE
              sounds
            SET
              popularity = sq.postings_count / {{total}}
            FROM (
              SELECT
                sounds.id AS id,
                COUNT(sound_postings.id) AS postings_count
              FROM
                sounds
              LEFT OUTER JOIN
                sound_postings ON sound_postings.sound_id = sounds.id
              GROUP BY
                sounds.id
            ) AS sq
            WHERE
              sounds.id = sq.id
          SQL

          q = q.gsub("{{total}}", total)
        else
          q = <<-'SQL'
            UPDATE
              sounds
            SET
              popularity = 0
          SQL
        end

        db.exec(q)

        logger.debug("Updated sound popularities")

        self.class.dispatch_in(CALCULATE_PERIOD)
      end
    end
  end
end
