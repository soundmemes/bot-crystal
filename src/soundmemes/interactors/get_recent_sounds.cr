require "../orm/models/sound_posting"

module Soundmemes::Interactors
  class GetRecentSounds
    include Utils::Logger

    def initialize(@user_telegram_id : Int32, @limit : Int32 = 10, search_query : String? = nil)
    end

    def call
      user = User.find_or_create(@user_telegram_id)
      sounds = Repo.get(Sound, @sound_id) || raise SoundNotFoundError
    rescue ex : SoundNotFoundError
      logger.error("Sound not found with id #{@sound_id}!")
    end

    class SoundNotFoundError < Exception; end
  end
end
