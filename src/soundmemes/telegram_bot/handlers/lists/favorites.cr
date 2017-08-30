require "./_sound_list"
require "../../../orm/models/favorite"

module Soundmemes
  module TelegramBot
    module Handlers::Lists
      class Favorites < SoundList
        @@list_name = "favorites"

        private def preload_data(page = 0)
          @total_number = Repo.aggregate(Favorite, :count, :id, Query.where(user_id: @user.id)).as(Int64)
          @sounds = Sound.favorites(@user, @@limit, page * @@limit)
        end
      end
    end
  end
end
