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
      fantasy_games = []
      REXML::XPath.each(doc, "//game") do |game_elt|
        attribs = {}
        game_elt.elements.each do |elt|
          value =
            case elt.name
            when "game_id", "game_key", "season"
              elt.text.to_i
            when "is_game_over", "is_offseason", "is_registration_over"
              elt.text == "1"
            else
              elt.text
            end
          attribs[elt.name] = value
        end
        fantasy_games << FantasyGame.new(attribs)
      end
      fantasy_games
    end

    def leagues(fantasy_game)
      response = get_response("./users;use_login=1/games;game_keys=#{fantasy_game.game_key}/leagues")
      doc = REXML::Document.new(response.body)
      leagues = []
      REXML::XPath.each(doc, "//league") do |league_elt|
        attribs = {}
        league_elt.elements.each do |elt|
          value =
            case elt.name
            when "num_teams", "current_week", "start_week", "end_week", "season"
              elt.text.to_i
            when "allow_add_to_dl_extra_pos", "is_pro_league", "is_cash_league"
              elt.text == "1"
            when "start_date", "end_date"
              Date.strptime(elt.text, "%Y-%m-%d")
            else
              elt.text
            end
          attribs[elt.name] = value
        end
        leagues << League.new(attribs)
      end
      leagues
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
      if token.expired?
        puts "Refreshing token..."
        p token
        token.refresh!(token_options)
        p token
      end
      token.get(API_URI.merge(path))
    end
  end
end
