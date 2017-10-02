require "redis"
require "pool/connection"

class Services::Redis
  class_getter pool
  @@pool = ConnectionPool(::Redis).new(capacity: 100, timeout: 0.01) do
    ::Redis.new(url: ENV["REDIS_URL"]?)
  end
end

# Shortcut for convenience
def redis(&block)
  Services::Redis.pool.connection do |redis|
    yield redis
  end
end

def redis
  Services::Redis.pool.checkout
end
