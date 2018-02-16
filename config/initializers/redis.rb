QUEUE_PER_MINUTE = Redis::Namespace.new("hydra", :redis => Redis.new(YAML.load(ERB.new(File.read("#{Rails.root.to_s}/config/redis_conf.yml")).result)[Rails.env]))
QUEUE_TWO_MINUTE = Redis::Namespace.new("hydra", :redis => Redis.new(YAML.load(ERB.new(File.read("#{Rails.root.to_s}/config/redis_conf.yml")).result)[Rails.env]))
QUEUE_NO_RATE_LIMIT = Redis::Namespace.new("hydra", :redis => Redis.new(YAML.load(ERB.new(File.read("#{Rails.root.to_s}/config/redis_conf.yml")).result)[Rails.env]))

