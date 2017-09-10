module CouthAI
  module Nerd
    class Player
      def self.from_xml(elt)
        attribs = {}
        elt.elements.each do |child_elt|
          key = child_elt.name.gsub(/[A-Z]+/) { |s| "_" + s.downcase }
          value =
            case child_elt.name
            when "week", "playerId"
              child_elt.text.to_i
            when "position", "displayName", "team"
              child_elt.text
            else
              child_elt.text.to_f
            end
          attribs[key] = value
        end
        Player.new(attribs)
      end

      attr_reader :week, :player_id, :position, :pass_att, :pass_cmp,
        :pass_yds, :pass_td, :pass_int, :rush_att, :rush_yds, :rush_td,
        :fumbles_lost, :receptions, :rec_yds, :rec_td, :fg, :fg_att, :xp,
        :def_int, :def_fr, :def_ff, :def_sack, :def_td, :def_ret_td,
        :def_safety, :def_pa, :def_yds_allowed, :display_name, :team

      def initialize(attribs = {})
        @week = attribs["week"]
        @player_id = attribs["player_id"]
        @position = attribs["position"]
        @pass_att = attribs["pass_att"]
        @pass_cmp = attribs["pass_cmp"]
        @pass_yds = attribs["pass_yds"]
        @pass_td = attribs["pass_td"]
        @pass_int = attribs["pass_int"]
        @rush_att = attribs["rush_att"]
        @rush_yds = attribs["rush_yds"]
        @rush_td = attribs["rush_td"]
        @fumbles_lost = attribs["fumbles_lost"]
        @receptions = attribs["receptions"]
        @rec_yds = attribs["rec_yds"]
        @rec_td = attribs["rec_td"]
        @fg = attribs["fg"]
        @fg_att = attribs["fg_att"]
        @xp = attribs["xp"]
        @def_int = attribs["def_int"]
        @def_fr = attribs["def_fr"]
        @def_ff = attribs["def_ff"]
        @def_sack = attribs["def_sack"]
        @def_td = attribs["def_td"]
        @def_ret_td = attribs["def_ret_td"]
        @def_safety = attribs["def_safety"]
        @def_pa = attribs["def_pa"]
        @def_yds_allowed = attribs["def_yds_allowed"]
        @display_name = attribs["display_name"]
        @team = attribs["team"]
      end
    end
  end
end
