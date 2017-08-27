require "../orm/models/sound"

module Soundmemes::Interactors
  class CreateSound
    include Utils::Logger

    def initialize(@user_telegram_id : Int32, @title : String, @tags : String?, @file_id : String)
    end

    def call
      user = Repo.get_by(User, telegram_id: @user_telegram_id)

      sound = Sound.new.tap do |s|
        s.user = user
        s.title = @title
        s.tags = @tags
        s.telegram_file_id = @file_id
      end
      changeset = Sound.changeset(sound)

      if changeset.valid?
        Repo.insert(sound)
      else
        logger.error("Invalid Sound changeset: #{changeset.errors}")
      end
    end
  end
end
