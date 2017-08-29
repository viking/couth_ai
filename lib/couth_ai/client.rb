module CouthAI
  class Client
    class AppTokenRequired < Exception; end

    API_URI = URI.parse("https://fantasysports.yahooapis.com/fantasy/v2/")
    attr_writer :app_token

    def initialize(consumer_key, consumer_secret, session_filename = "/tmp/couth_ai_oauth.json")
      @consumer_key = consumer_key
      @consumer_secret = consumer_secret
      @session_filename = session_filename
    end

    def authorize_url
      client.auth_code.authorize_url(redirect_uri: "oob")
    end

    def fantasy_games
      response = get_response("./users;use_login=1/games")
      doc = REXML::Document.new(response.body)
      fantasy_games = [];
      REXML::XPath.each(doc, "//game") do |game_elt|
        attribs = {}
        game_elt.elements.each do |elt|
          attribs[elt.name] = elt.text
        end
        fantasy_games << FantasyGame.new(attribs)
      end
      fantasy_games
    end

    private

    def client
      @client ||= OAuth2::Client.new(@consumer_key, @consumer_secret, {
        site: "https://api.login.yahoo.com",
        authorize_url: "/oauth2/request_auth",
        token_url: "/oauth2/get_token"
      })
    end

    def token_options
      basic = ["#{@consumer_key}:#{@consumer_secret}"].pack("m0")
      {
        redirect_uri: "oob",
        headers: {'Authorization' => "Basic #{basic}"}
      }
    end

    def token
      if @token.nil?
        if File.exist?(@session_filename)
          begin
            @session = Session.load(@session_filename)
          rescue JSON::ParserError
          end
        end

        if @session
          @token = OAuth2::AccessToken.from_hash(client, @session.to_h)
        else
          if @app_token.nil?
            raise AppTokenRequired, "app_token must be set"
          end
          @token = client.auth_code.get_token(@app_token, token_options)
          @session = Session.from_hash(@token.to_hash)
          @session.save!
        end
      end
      @token
    end

    def get_response(path)
      token.get(API_URI.merge(path))
    end
  end
end
