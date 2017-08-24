require "query-builder"
require "tren"
require "../../services/db"

module Soundmemes
  module Repositories
    abstract class Base
      protected getter db

      def initialize(@db : DB::Database)
      end

      def builder
        @@builder ||= Query::Builder.new
      end
    end
  end
end
