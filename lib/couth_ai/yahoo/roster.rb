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
    end
  end
end
