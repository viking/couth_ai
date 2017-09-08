module CouthAI
  module Yahoo
    class FantasyGame
      def self.from_xml(elt)
        attribs = {}
        elt.elements.each do |child_elt|
          value =
            case child_elt.name
            when "game_id", "game_key", "season"
              child_elt.text.to_i
            when "is_game_over", "is_offseason", "is_registration_over"
              child_elt.text == "1"
            else
              child_elt.text
            end
          attribs[child_elt.name] = value
        end
        self.new(attribs)
      end

      attr_reader :game_key, :game_id, :name, :code, :type, :url, :season,
        :is_registration_over, :is_game_over, :is_offseason

      def initialize(attribs = {})
        @game_key = attribs["game_key"]
        @game_id = attribs["game_id"]
        @name = attribs["name"]
        @code = attribs["code"]
        @type = attribs["type"]
        @url = attribs["url"]
        @season = attribs["season"]
        @is_registration_over = attribs["is_registration_over"]
        @is_game_over = attribs["is_game_over"]
        @is_offseason = attribs["is_offseason"]
      end
    end
  end
end
