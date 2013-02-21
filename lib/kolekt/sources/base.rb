module Kolekt
  module Sources
    class Base
      def self.identifier
        self.name.sub(/^.*::/, '').downcase
      end

      # Guard execution (in case of missing gems, binaries, etc.)
      def self.runnable?
        true
      end

      # When DRY doesn't return [false, ...], the source won't be re-invoked as
      # long as the JSON serialization of the 2nd element remains identical.
      def dry
        [false, "DRY unavailable"]
      end

      # [success, payload (can be serialized to JSON)]
      def collect
        [false, nil]
      end
    end
  end
end
