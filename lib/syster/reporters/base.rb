module Syster
  module Reporters
    class Base
      # Guard execution (in case of missing gems, binaries, etc.)
      def self.runnable?
        true
      end

      def self.identifier
        self.name.sub(/^.*::/, '').downcase
      end

      def initialize options={}
      end

      def report name, payload
      end

      # Stupid by default
      def wants identifier, dry_payload
        true
      end

      def finish
      end
    end
  end
end