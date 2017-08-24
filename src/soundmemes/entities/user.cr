require "./base"

module Soundmemes
  module Entities
    struct User < Base
      mapping({
        id:          {type: Int32?},
        telegram_id: {type: Int32?},
      })
    end
  end
end
