require "query-builder"
require "tren"

module Soundmemes
  module Repositories
    class Base
      def self.builder
        @@builder ||= Query::Builder.new
      end
    end
  end
end
