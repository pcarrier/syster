module Kolekt
  module Helpers
    module Require
      def self.can_require? reqs
        begin
          reqs.each do |req|
            require req
          end
        rescue LoadError
          return false
        end
      end
    end
  end
end
