require 'kolekt/sources/base'

module Kolekt::Sources
  class LsbRelease < Base
    def self.identifier
      'lsb_release'
    end

    def self.runnable?
      Kolekt::Helpers::Path.find 'lsb_release'
    end

    def dry
      Kolekt::Helpers::BootId::dry
    end

    def collect
      res = Hash[
        %x[lsb_release -a].lines.collect do |l|
          l.strip.split "\t"
        end]

      return [false, "exited with status #{$?.exitstatus}"] if $?.exitstatus != 0
      
      [true, res]
    end
  end
end
