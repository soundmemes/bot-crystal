require "./base"
require "./user"

module Soundmemes
  module Entities
    struct Sound < Base
      mapping({
        id:               {type: Int32?},
        user:             {type: User?},
        title:            {type: String?},
        tags:             {type: String?},
        telegram_file_id: {type: String?},
        popularity:       {type: Float32?},
        created_at:       {type: Time?},
        updated_at:       {type: Time?},
      })
    end
  end
end
