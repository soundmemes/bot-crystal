require "../orm/models/sound"

module Soundmemes::Interactors
  class CreateSound
    def initialize(@user_telegram_id : Int32, @title : String, @tags : String?, @file_id : String)
    end

    def call
      user = User.new.tap &.telegram_id = @user_telegram_id
      sound = Sound.new.tap do |s|
        s.user = user
        s.title = @title
        s.tags = @tags
        s.telegram_file_id = @file_id
      end
      Repo.insert(sound)
    end
  end
end
