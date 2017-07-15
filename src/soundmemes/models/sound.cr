require "./user"

module Soundmemes
  module Models
    struct Sound
      property id, user, telegram_file_id, title, tags, querying_type, created_at

      enum QueryingType
        Regular
        Recent
        Favorite
      end

      def initialize(@id : Int32?, @user : Models::User?, @telegram_file_id : String? = nil, @title : String? = nil, @tags : String? = nil, @querying_type : QueryingType? = nil, @created_at : Time? = nil)
      end
    end
  end
end
