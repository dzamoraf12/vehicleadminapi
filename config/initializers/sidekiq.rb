require "sidekiq/web"

Sidekiq.configure_server do |config|
  config.redis = { url: ENV["REDIS_URL"], network_timeout: 5 }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV["REDIS_URL"] }
end
