module Soundmemes
  module Models
    struct User
      property id, telegram_id

      def initialize(@id : Int32 | Nil = nil, @telegram_id : Int32 | Nil = nil)
      end
    end
  end
end
