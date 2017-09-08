module CouthAI
  module Yahoo
    class Team
      def self.from_xml(elt)
        attribs = {}
        elt.elements.each do |child_elt|
          value =
            case child_elt.name
            when "team_id", "division_id", "faab_balance", "number_of_moves", "number_of_trades", "auction_budget_total"
              child_elt.text.to_i
            when "is_owned_by_current_login", "has_draft_grade"
              child_elt.text == "1"
            when "team_logos", "roster_adds", "managers"
              nil
            else
              child_elt.text
            end
          attribs[child_elt.name] = value
        end
        Team.new(attribs)
      end

      attr_reader :team_key, :team_id, :name, :is_owned_by_current_login, :url,
        :team_logos, :division_id, :waiver_priority, :faab_balance,
        :number_of_moves, :number_of_trades, :roster_adds, :league_scoring_type,
        :has_draft_grade, :auction_budget_total, :managers

      def initialize(attribs = {})
        @team_key = attribs['team_key']
        @team_id = attribs['team_id']
        @name = attribs['name']
        @is_owned_by_current_login = attribs['is_owned_by_current_login']
        @url = attribs['url']
        @team_logos = attribs['team_logos']
        @division_id = attribs['division_id']
        @waiver_priority = attribs['waiver_priority']
        @faab_balance = attribs['faab_balance']
        @number_of_moves = attribs['number_of_moves']
        @number_of_trades = attribs['number_of_trades']
        @roster_adds = attribs['roster_adds']
        @league_scoring_type = attribs['league_scoring_type']
        @has_draft_grade = attribs['has_draft_grade']
        @auction_budget_total = attribs['auction_budget_total']
        @managers = attribs['managers']
      end
    end
  end
end
