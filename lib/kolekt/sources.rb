Dir[File.join File.dirname(__FILE__), 'sources', '*.rb'].each {|f| require f}

module Kolekt
  module Sources
    def self.available
      @@AVAILABLE ||= constants.collect do |c|
        const_get(c)
      end.select do |c|
        c.instance_of? Class and c.identifier != 'base'
      end
    end
  end
end
