module CouthAI
  class FantasyGame
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
