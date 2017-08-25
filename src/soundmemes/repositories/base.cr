require "query-builder"
require "tren"
require "../../services/db"

module Soundmemes
  module Repositories
    abstract class Base
      protected getter! db
      protected getter! builder : Query::Builder { Query::Builder.new }

      def initialize(@db : DB::Database)
      end
    end
  end
end
