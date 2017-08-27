require "../orm/models/sound_post"

module Soundmemes::Interactors
  class CreateSoundPost
    include Utils::Logger

    def initialize(telegram_id @posting_user_telegram_id : Int32, @sound_id : Int32)
    end

    def call
      user = User.find_or_create(@posting_user_telegram_id)
      sound = Repo.get(Sound, @sound_id)

      new_post = SoundPost.new.tap { |p| p.user = user; p.sound = sound }
      changeset = SoundPost.changeset(new_post)

      if changeset.valid?
        Repo.insert(new_post)
      else
        logger.error("Invalid SoundPost changeset: #{changeset.errors}")
      end
    end
  end
end
