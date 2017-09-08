require 'oauth2'
require 'rexml/document'
require 'json'
require 'date'
require 'net/http'
require 'fileutils'

module CouthAI
  autoload :Version, "couth_ai/version"
  autoload :Yahoo, "couth_ai/yahoo"
  autoload :Nerd, "couth_ai/nerd"
end
