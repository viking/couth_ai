module CouthAI
  module Yahoo
    class Player
      def self.from_xml(elt)
        attribs = {}
        elt.elements.each do |child_elt|
          value =
            case child_elt.name
            when "player_id", "uniform_number"
              child_elt.text.to_i
            when "is_undroppable", "is_editable"
              child_elt.text == "1"
            when "name", "headshot"
              child_elt.elements.inject(nil, {}) do |hash, grandchild_elt|
                hash[grandchild_elt.name] = grandchild_elt.text
                hash
              end
            when "bye_weeks"
              child_elt.elements.collect { |e| e.text.to_i }
            when "eligible_positions"
              child_elt.elements.collect { |e| e.text }
            when "selected_position"
              child_elt.elements.inject(nil, {}) do |hash, grandchild_elt|
                hash[grandchild_elt.name] =
                  case grandchild_elt.name
                  when "week"
                    grandchild_elt.text.to_i
                  else
                    grandchild_elt.text
                  end
                hash
              end
            else
              child_elt.text
            end
          attribs[child_elt.name] = value
        end
        Player.new(attribs)
      end

      attr_reader :player_key, :player_id, :name, :editorial_player_key,
        :editorial_team_key, :editorial_team_full_name, :editorial_team_abbr,
        :bye_weeks, :uniform_number, :display_position, :headshot, :image_url,
        :is_undroppable, :position_type, :eligible_positions,
        :has_player_notes, :selected_position, :is_editable
      attr_writer :projected_points

      def initialize(attribs = {})
        @player_key = attribs["player_key"]
        @player_id = attribs["player_id"]
        @name = attribs["name"]
        @editorial_player_key = attribs["editorial_player_key"]
        @editorial_team_key = attribs["editorial_team_key"]
        @editorial_team_full_name = attribs["editorial_team_full_name"]
        @editorial_team_abbr = attribs["editorial_team_abbr"]
        @bye_weeks = attribs["bye_weeks"]
        @uniform_number = attribs["uniform_number"]
        @display_position = attribs["display_position"]
        @headshot = attribs["headshot"]
        @image_url = attribs["image_url"]
        @is_undroppable = attribs["is_undroppable"]
        @position_type = attribs["position_type"]
        @eligible_positions = attribs["eligible_positions"]
        @has_player_notes = attribs["has_player_notes"]
        @selected_position = attribs["selected_position"]
        @is_editable = attribs["is_editable"]
      end

      def projected_points
        @projected_points || 0.0
      end

      def inspect
        "#<#{self.class.name} name=#{@name&.fetch("full", nil).inspect} eligible_positions=#{@eligible_positions.inspect} selected_position=#{@selected_position&.fetch("position", nil).inspect} ...>"
      end
    end
  end
end
