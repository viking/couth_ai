module CouthAI
  module Yahoo
    class Roster
      def self.from_xml(elt)
        attribs = {}
        elt.elements.each do |child_elt|
          value =
            case child_elt.name
            when "week"
              child_elt.text.to_i
            when "is_editable"
              child_elt.text == "1"
            when "players"
              child_elt.elements.collect { |e| Player.from_xml(e) }
            else
              child_elt.text
            end
          attribs[child_elt.name] = value
        end
        Roster.new(attribs)
      end

      attr_reader :coverage_type, :week, :is_editable, :players

      def initialize(attribs = {})
        @coverage_type = attribs["coverage_type"]
        @week = attribs["week"]
        @is_editable = attribs["is_editable"]
        @players = attribs["players"]
      end

      def eligible_players_for(position)
        @players.select { |player| player.eligible_positions.include?(position) }
      end

      def set_starters_by_id(position, ids)
        @players.each do |player|
          current_position = player.selected_position["position"]
          if current_position == position
            if !ids.include?(player.player_id)
              player.selected_position["position"] = "BN"
            end
          elsif ids.include?(player.player_id)
            player.selected_position["position"] = position
          end
        end
      end

      def to_update_xml
        result = %{<?xml version="1.0"?><fantasy_content><roster>}
        result << %{<coverage_type>#{@coverage_type}</coverage_type>}
        result << %{<week>#{@week}</week>}
        result << %{<players>}
        @players.each do |player|
          result << %{<player>}
          result << %{<player_key>#{player.player_key}</player_key>}
          result << %{<position>#{player.selected_position["position"]}</position>}
          result << %{</player>}
        end
        result << %{</players></roster></fantasy_content>}
      end
    end
  end
end
