class User
  class << self
    def get(phone, key)
      $redis.hget(hash+":#{phone}", key)
    end
    
    def register(phone, user_name)
      $redis.hset(hash+":#{phone}", 'name', user_name)
      $redis.hset(hash+":#{phone}", 'count', 0)
    end
    
    def update(phone, key, value)
      $redis.hset(hash+":#{phone}", key, value)
    end

    private
      def hash
        'user'
      end
  end
end
