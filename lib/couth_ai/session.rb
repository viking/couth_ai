module CouthAI
  class Session
    def self.load(filename = "/tmp/couth_ai_oauth.json")
      str = File.read(filename)
      hash = JSON.parse(str)
      keys = hash.keys
      keys.each do |key|
        hash[key.to_sym] = hash.delete(key)
      end
      from_hash(hash)
    end

    def self.from_hash(hash)
      new(hash[:access_token], hash[:refresh_token], hash[:expires_at])
    end

    def initialize(access_token, refresh_token, expires_at)
      @access_token = access_token
      @refresh_token = refresh_token
      @expires_at = expires_at
    end

    def to_h
      {
        :access_token => @access_token,
        :refresh_token => @refresh_token,
        :expires_at => @expires_at
      }
    end

    def save!(filename = "/tmp/couth_ai_oauth.json")
      File.open(filename, 'w') { |f| f.write(JSON.generate(to_h)) }
    end
  end
end
