module CouthAI
  module Yahoo
    class Client
      class AppTokenRequired < Exception; end

      API_URI = URI.parse("https://fantasysports.yahooapis.com/fantasy/v2/")
      attr_writer :app_token

      def initialize(consumer_key, consumer_secret, session_filename = "/tmp/couth_ai/yahoo.json")
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
        REXML::XPath.each(doc, "//game") do |elt|
          fantasy_games << FantasyGame.from_xml(elt)
        end
        fantasy_games
      end

      def leagues(fantasy_game)
        response = get_response("./users;use_login=1/games;game_keys=#{fantasy_game.game_key}/leagues")
        doc = REXML::Document.new(response.body)
        leagues = []
        REXML::XPath.each(doc, "//league") do |elt|
          leagues << League.from_xml(elt)
        end
        leagues
      end

      def settings(fantasy_game, league)
        response = get_response("./users;use_login=1/games;game_keys=#{fantasy_game.game_key}/leagues;league_keys=#{league.league_key}/settings")
        doc = REXML::Document.new(response.body)
        settings_elt = REXML::XPath.first(doc, "//settings")
        Settings.from_xml(settings_elt)
      end

      def teams(fantasy_game, league)
        response = get_response("./users;use_login=1/games;game_keys=#{fantasy_game.game_key}/leagues;league_keys=#{league.league_key}/teams")
        doc = REXML::Document.new(response.body)
        teams = []
        REXML::XPath.each(doc, "//team") do |elt|
          teams << Team.from_xml(elt)
        end
        teams
      end

      def roster(team)
        response = get_response("./users;use_login=1/teams;team_keys=#{team.team_key}/roster")
        doc = REXML::Document.new(response.body)
        roster_elt = REXML::XPath.first(doc, "//roster")
        Roster.from_xml(roster_elt)
      end

      def players(league, params = {})
        conditions =
          if params.empty? then ""
          else ";" + params.collect { |(k, v)| "#{k}=#{v}" }.join(";")
          end
        response = get_response("./league/#{league.league_key}/players#{conditions}")
        doc = REXML::Document.new(response.body)
        players = []
        REXML::XPath.each(doc, "//player") do |elt|
          players << Player.from_xml(elt)
        end
        players
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
          @token = token.refresh!(token_options)
          @session = Session.from_hash(token.to_hash)
          @session.save!
        end
        token.get(API_URI.merge(path))
      end
    end
  end
end
