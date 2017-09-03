require "../../utils/logger"
require "../orm/repo"

module Soundmemes
  module Jobs
    class CalculateSoundsPostsCount
      include Dispatchable
      include Utils::Logger

      @@logger_progname = "JOB"

      CALCULATE_PERIOD = 1.minute

      def perform
        q = <<-'SQL'
          UPDATE
            sounds
          SET
            agg_postings_count = sq.postings_count
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

        Repo.query(q)
        logger.debug("Updated sounds posts count")

        self.class.dispatch_in(CALCULATE_PERIOD)
      end
    end
  end
end
