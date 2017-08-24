require "redis"

class Services::Redis
  # TODO: Implement a pool instead of a single connection
  class_getter instance : ::Redis = ::Redis.new(url: ENV["REDIS_URL"]?)
end

# Shortcut for convenience
def redis
  Services::Redis.instance
end
