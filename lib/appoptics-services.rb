
require_relative 'appoptics-services/service'

require 'active_support/core_ext/hash/indifferent_access'

module AppOptics
  module Services
    def self.version
      File.read(File.join(File.dirname(__FILE__), '../VERSION')).chomp
    end
  end
end
