module CouthAI
  module Yahoo
    class Settings
      def self.from_xml(elt)
        attribs = {}
        elt.elements.each do |child_elt|
          value =
            case child_elt.name
            when "playoff_start_week", "num_playoff_teams", "num_playoff_consolation_teams", "draft_time", "max_teams", "waiver_time", "trade_reject_time"
              child_elt.text.to_i
            when "is_auction_draft", "uses_playoff", "has_playoff_consolation_games", "uses_playoff_reseeding", "uses_lock_eliminated_teams", "has_multiweek_championship", "uses_faab", "pickem_enabled", "uses_fractional_points", "uses_negative_points"
              child_elt.text == "1"
            when "trade_end_date"
              Date.strptime(child_elt.text, "%Y-%m-%d")
            when "roster_positions"
              child_elt.elements.inject("roster_position/*", {}) do |hash, grandchild_elt|
                hash[grandchild_elt.name] =
                  case grandchild_elt.name
                  when "count"
                    grandchild_elt.text.to_i
                  else
                    grandchild_elt.text
                  end
                hash
              end
            when "stat_categories"
              child_elt.elements.collect("stats/stat") do |grandchild_elt|
                grandchild_elt.elements.inject(nil, {}) do |hash, greatgrandchild_elt|
                  hash[greatgrandchild_elt.name] =
                    case greatgrandchild_elt.name
                    when "stat_id", "sort_order"
                      greatgrandchild_elt.text.to_i
                    when "enabled", "is_only_display_stat", "is_excluded_from_display"
                      greatgrandchild_elt.text == "1"
                    when "stat_position_types"
                      greatgrandchild_elt.elements.collect do |g3child_elt|
                        g3child_elt.elements.inject(nil, {}) do |hash, g4child_elt|
                          hash[g4child_elt.name] =
                            case g4child_elt.name
                            when "position_type"
                              g4child_elt.text
                            when "is_only_display_stat"
                              g4child_elt.text == "1"
                            end
                          hash
                        end
                      end
                    else
                      greatgrandchild_elt.text
                    end
                  hash
                end
              end
            when "stat_modifiers"
              child_elt.elements.collect("stats/stat") do |grandchild_elt|
                grandchild_elt.elements.inject(nil, {}) do |hash, greatgrandchild_elt|
                  hash[greatgrandchild_elt.name] =
                    case greatgrandchild_elt.name
                    when "stat_id"
                      greatgrandchild_elt.text.to_i
                    when "value"
                      greatgrandchild_elt.text.to_f
                    end
                  hash
                end
              end
            when "divisions"
              child_elt.elements.collect do |grandchild_elt|
                grandchild_elt.elements.inject(nil, {}) do |hash, greatgrandchild_elt|
                  hash[greatgrandchild_elt.name] =
                    case greatgrandchild_elt.name
                    when "division_id"
                      greatgrandchild_elt.text.to_i
                    when "name"
                      greatgrandchild_elt.text
                    end
                  hash
                end
              end
            else
              child_elt.text
            end
          attribs[child_elt.name] = value
        end
        Settings.new(attribs)
      end

      attr_reader :draft_type, :is_auction_draft, :scoring_type,
        :persistent_url, :uses_playoff, :has_playoff_consolation_games,
        :playoff_start_week, :uses_playoff_reseeding,
        :uses_lock_eliminated_teams, :num_playoff_teams,
        :num_playoff_consolation_teams, :has_multiweek_championship,
        :waiver_type, :waiver_rule, :uses_faab, :draft_time,
        :post_draft_players, :max_teams, :waiver_time, :trade_end_date,
        :trade_ratify_type, :trade_reject_time, :player_pool, :cant_cust_list,
        :roster_positions, :stat_categories, :divisions, :pickem_enabled,
        :uses_fractional_points, :uses_negative_points

      def initialize(attribs = {})
        @draft_type = attribs["draft_type"]
        @is_auction_draft = attribs["is_auction_draft"]
        @scoring_type = attribs["scoring_type"]
        @persistent_url = attribs["persistent_url"]
        @uses_playoff = attribs["uses_playoff"]
        @has_playoff_consolation_games = attribs["has_playoff_consolation_games"]
        @playoff_start_week = attribs["playoff_start_week"]
        @uses_playoff_reseeding = attribs["uses_playoff_reseeding"]
        @uses_lock_eliminated_teams = attribs["uses_lock_eliminated_teams"]
        @num_playoff_teams = attribs["num_playoff_teams"]
        @num_playoff_consolation_teams = attribs["num_playoff_consolation_teams"]
        @has_multiweek_championship = attribs["has_multiweek_championship"]
        @waiver_type = attribs["waiver_type"]
        @waiver_rule = attribs["waiver_rule"]
        @uses_faab = attribs["uses_faab"]
        @draft_time = attribs["draft_time"]
        @post_draft_players = attribs["post_draft_players"]
        @max_teams = attribs["max_teams"]
        @waiver_time = attribs["waiver_time"]
        @trade_end_date = attribs["trade_end_date"]
        @trade_ratify_type = attribs["trade_ratify_type"]
        @trade_reject_time = attribs["trade_reject_time"]
        @player_pool = attribs["player_pool"]
        @cant_cust_list = attribs["cant_cust_list"]
        @roster_positions = attribs["roster_positions"]
        @divisions = attribs["divisions"]
        @pickem_enabled = attribs["pickem_enabled"]
        @uses_fractional_points = attribs["uses_fractional_points"]
        @uses_negative_points = attribs["uses_negative_points"]

        # combine stat_categories and stat_modifiers
        @stat_categories = attribs["stat_categories"]
        attribs["stat_modifiers"].each do |mod|
          stat = @stat_categories.find { |cat| cat["stat_id"] == mod["stat_id"] }
          stat["modifier"] = mod["value"]
        end
      end
    end
  end
end
