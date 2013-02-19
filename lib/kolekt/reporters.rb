Dir[File.join File.dirname(__FILE__), 'reporters', '*.rb'].each {|f| require f}

module Kolekt
  module Reporters
    def self.available
      @@AVAILABLE ||= Hash[constants.collect do |c|
        const_get c
      end.select do |c|
        c.instance_of? Class and c.identifier != 'base' and c.runnable?
      end.collect do |c|
        [c.identifer, c]
      end]
    end
  end
end
