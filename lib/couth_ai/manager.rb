module CouthAI
  class Manager
    def initialize(yahoo_client, nerd_client, league_id)
      @yahoo = yahoo_client
      @nerd = nerd_client
      @league_id = league_id
      @weekly_projections = Hash.new { |h, k| h[k] = {} }
    end

    def calculate_projections!
      week = league.current_week
      result = Hash.new { |h, k| h[k] = [] }
      roster.players.each do |player|
        name = player.name["full"]
        projs = weekly_projections(player.display_position, week)
        proj = projs.find do |p|
          proj_name = p.display_name
          if player.display_position == "DEF"
            proj_name = proj_name.split(" ").first
          end
          proj_name == name
        end

        if proj
          player.projected_points = calculator.projection(proj)
        end
      end
    end

    def optimize_roster!
      calculate_projections!
      roster_positions = settings.roster_positions
      roster_positions.each do |roster_position|
        position = roster_position["position"]
        next if position == "BN"
        count = roster_position["count"]

        eligible = roster.eligible_players_for(position).sort { |a, b| b.projected_points <=> a.projected_points }
        starter_ids = eligible[0, count].collect { |player| player.player_id }
        roster.set_starters_by_id(position, starter_ids)
      end
      @yahoo.update_roster(team, roster)
    end

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

    private

    def weekly_projections(position, week)
      if !@weekly_projections[position].has_key?(week)
        @weekly_projections[position][week] = @nerd.weekly_projections(position, week)
      end
      @weekly_projections[position][week]
    end
  end
end
