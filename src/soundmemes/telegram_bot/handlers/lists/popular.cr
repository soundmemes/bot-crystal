require "./_sound_list"

module Soundmemes
  module TelegramBot
    module Handlers::Lists
      class Popular < SoundList
        @@list_name = "popular"

        private def preload_data(page = 0)
          @total_number = Repo.aggregate(Sound, :count, :id).as(Int64)
          @sounds = Sound.popular(@@limit, offset: page * @@limit)
        end
      end
    end
  end
end
