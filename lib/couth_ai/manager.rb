module CouthAI
  class Manager
    def initialize(yahoo_client, nerd_client, league_id)
      @yahoo = yahoo_client
      @nerd = nerd_client
      @league_id = league_id
      @weekly_projections = Hash.new { |h, k| h[k] = {} }
    end

    def projections
      week = league.current_week
      roster.players.inject({}) do |result, player|
        name = player.name["full"]
        projs = weekly_projections(player.display_position, week)
        proj = projs.find { |p| p.display_name == name }
        result[name] =
          if proj
            calculator.projection(proj)
          else
            nil
          end
        result
      end
    end

    private

    def fantasy_game
      if @fantasy_game.nil?
        fantasy_games = @yahoo.fantasy_games
        @fantasy_game = fantasy_games.find { |fg| fg.code == "nfl" && !fg.is_game_over }
      end
      @fantasy_game
    end

    def league
      if @league.nil?
        leagues = @yahoo.leagues(fantasy_game)
        @league = leagues.find { |l| l.league_id == @league_id }
      end
      @league
    end

    def settings
      @settings ||= @yahoo.settings(fantasy_game, league)
    end

    def calculator
      @calculator ||= Calculator.new(settings)
    end

    def team
      @team ||= @yahoo.teams(fantasy_game, league).first
    end

    def roster
      @roster ||= @yahoo.roster(team)
    end

    def weekly_projections(position, week)
      if !@weekly_projections[position].has_key?(week)
        @weekly_projections[position][week] = @nerd.weekly_projections(position, week)
      end
      @weekly_projections[position][week]
    end
  end
end
