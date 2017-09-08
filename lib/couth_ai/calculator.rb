module CouthAI
  class Calculator
    CATEGORY_MAP = {
      "O" => {
        "Passing Yards" => :pass_yds,
        "Passing Touchdowns" => :pass_td,
        "Interceptions" => :pass_int,
        "Sacks" => nil,
        "Rushing Attempts" => :rush_att,
        "Rushing Yards" => :rush_yds,
        "Rushing Touchdowns" => :rush_td,
        "Targets" => nil,
        "Receptions" => :receptions,
        "Receiving Yards" => :rec_yds,
        "Receiving Touchdowns" => :rec_td,
        "Return Touchdowns" => nil,
        "2-Point Conversions" => nil,
        "Fumbles Lost" => :fumbles_lost,
        "Offensive Fumble Return TD" => nil,
        "Field Goals 0-19 Yards" => nil,
        "Field Goals 20-29 Yards" => nil,
        "Field Goals 30-39 Yards" => nil,
        "Field Goals 40-49 Yards" => nil,
        "Field Goals 50+ Yards" => nil,
        "Field Goals Missed 0-19 Yards" => nil,
        "Field Goals Missed 20-29 Yards" => nil,
        "Field Goals Missed 30-39 Yards" => nil,
        "Field Goals Missed 40-49 Yards" => nil,
        "Field Goals Missed 50+ Yards" => nil,
        "Point After Attempt Made" => :xp,
        "Point After Attempt Missed" => nil,
      },
      "DT" => {
        "Points Allowed" => :def_pa,
        "Sack" => :def_sack,
        "Interception" => :def_int,
        "Fumble Recovery" => :def_fr,
        "Touchdown" => :def_td,
        "Safety" => :def_safety,
        "Block Kick" => nil,
        "Points Allowed 0 points" => nil,
        "Points Allowed 1-6 points" => nil,
        "Points Allowed 7-13 points" => nil,
        "Points Allowed 14-20 points" => nil,
        "Points Allowed 21-27 points" => nil,
        "Points Allowed 28-34 points" => nil,
        "Points Allowed 35+ points" => nil,
        "Extra Point Returned" => nil,
      }
    }

    def initialize(settings)
      @settings = settings
    end

    def projection(proj)
      result = @settings.stat_categories.inject(0) do |sum, stat|
        pos_map = CATEGORY_MAP[stat["position_type"]]
        name = pos_map ? pos_map[stat["name"]] : nil
        if name.nil? || stat["modifier"].nil?
          sum
        else
          sum + proj.send(name) * stat["modifier"]
        end
      end

      # field goals
      result += proj.fg * 3
      result -= (proj.fg_att - proj.fg) * 3

      # points allowed
      if proj.position == "DEF"
        def_pa = proj.def_pa
        def_pa_stat_name =
          if def_pa == 0
            "Points Allowed 0 points"
          elsif def_pa <= 6
            "Points Allowed 1-6 points"
          elsif def_pa <= 13
            "Points Allowed 7-13 points"
          elsif def_pa <= 20
            "Points Allowed 14-20 points"
          elsif def_pa <= 27
            "Points Allowed 21-27 points"
          elsif def_pa <= 34
            "Points Allowed 28-34 points"
          elsif def_pa >= 35
            "Points Allowed 35+ points"
          end

        if def_pa_stat_name
          stat = @settings.stat_categories.find { |name| name == def_pa_stat_name }
          result += stat["modifier"]
        end
      end
      result
    end
  end
end
