class Question
  class << self
    def get(ques_id, key)
      $redis.hget(hash+":#{ques_id}", key)
    end
    
    def create(ques_id, body, answer)
      $redis.hset(hash+":#{ques_id}", 'body', body)
      $redis.hset(hash+":#{ques_id}", 'answer', answer)
    end
   
    private
      def hash
        'ques'
      end
  end
end

