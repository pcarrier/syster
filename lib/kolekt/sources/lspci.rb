require 'kolekt/sources/base'

module Kolekt::Sources
  class LsPci < Base
    def self.runnable?
      Kolekt::Helpers::Path::find 'lspci'
    end

    def dry
      Kolekt::Helpers::BootId::dry
    end

    def collect
      res = Hash[%x[lspci].lines.collect{|l| l.strip.split(' ', 2)}]
      
      return [false, "exited with status #{$?.exitstatus}"] if $?.exitstatus != 0
      
      [true, res]
    end
  end
end
