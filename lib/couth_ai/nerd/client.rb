module CouthAI
  module Nerd
    class Client
      class InvalidResponse < Exception; end

      API_URI = URI.parse("https://www.fantasyfootballnerd.com/service/")

      def initialize(api_key, cache_path = "/tmp/couth_ai/nerd")
        @api_key = api_key
        @cache_path = cache_path
      end

      def weekly_projections(position, week)
        service = "weekly-projections"
        path_suffix = "#{position}/#{week}/"
        data = get_data(service, path_suffix)
        doc = REXML::Document.new(data)
        players = []
        REXML::XPath.each(doc, "//Player") do |elt|
          players << Player.from_xml(elt)
        end
        players
      end

      private

      def get_data(service, path_suffix, force = false)
        cache_dir = File.join(@cache_path, service, path_suffix)
        FileUtils.mkdir_p(cache_dir)

        cache_file = File.join(cache_dir, "result.xml")
        if File.exist?(cache_file) && !force
          File.read(cache_file)
        else
          uri = API_URI.merge("./#{service}/xml/#{@api_key}/#{path_suffix}")
          response = Net::HTTP.get_response(uri)
          if response.is_a?(Net::HTTPSuccess)
            body = response.body
            File.open(cache_file, 'w') { |f| f.write(body) }
            body
          else
            raise InvalidResponse, "invalid response for #{uri} (status code: #{response.code})"
          end
        end
      end
    end
  end
end
