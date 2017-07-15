require "dispatch"

Dispatch.configure do |config|
  config.num_workers = 5
  config.queue_size = 10
  config.logger = Logger.new(STDOUT)
end
