module CouthAI
  module Yahoo
    class League
      def self.from_xml(elt)
        attribs = {}
        elt.elements.each do |child_elt|
          value =
            case child_elt.name
            when "num_teams", "current_week", "start_week", "end_week", "season"
              child_elt.text.to_i
            when "allow_add_to_dl_extra_pos", "is_pro_league", "is_cash_league"
              child_elt.text == "1"
            when "start_date", "end_date"
              Date.strptime(child_elt.text, "%Y-%m-%d")
            else
              child_elt.text
            end
          attribs[child_elt.name] = value
        end
        League.new(attribs)
      end

      attr_reader :league_key, :league_id, :name, :url, :draft_status,
        :num_teams, :edit_key, :weekly_deadline, :league_update_timestamp,
        :scoring_type, :league_type, :renew, :renewed, :short_invitation_url,
        :allow_add_to_dl_extra_pos, :is_pro_league, :is_cash_league,
        :current_week, :start_week, :start_date, :end_week, :end_date,
        :game_code, :season

      def initialize(attribs = {})
        @league_key = attribs['league_key']
        @league_id = attribs['league_id']
        @name = attribs['name']
        @url = attribs['url']
        @draft_status = attribs['draft_status']
        @num_teams = attribs['num_teams']
        @edit_key = attribs['edit_key']
        @weekly_deadline = attribs['weekly_deadline']
        @league_update_timestamp = attribs['league_update_timestamp']
        @scoring_type = attribs['scoring_type']
        @league_type = attribs['league_type']
        @renew = attribs['renew']
        @renewed = attribs['renewed']
        @short_invitation_url = attribs['short_invitation_url']
        @allow_add_to_dl_extra_pos = attribs['allow_add_to_dl_extra_pos']
        @is_pro_league = attribs['is_pro_league']
        @is_cash_league = attribs['is_cash_league']
        @current_week = attribs['current_week']
        @start_week = attribs['start_week']
        @start_date = attribs['start_date']
        @end_week = attribs['end_week']
        @end_date = attribs['end_date']
        @game_code = attribs['game_code']
        @season = attribs['season']
      end
    end
  end
end
