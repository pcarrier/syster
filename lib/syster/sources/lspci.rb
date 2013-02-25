require 'syster/sources/base'
require 'syster/helpers/boot_id'

module Syster::Sources
  class LsPci < Base
    def self.runnable?
      Syster::Helpers::Path::find 'lspci'
    end

    def dry
      Syster::Helpers::BootId::dry
    end

    def collect
      res = Hash[%x[lspci].lines.collect{|l| l.strip.split(' ', 2)}]
      
      return [false, "exited with status #{$?.exitstatus}"] if $?.exitstatus != 0
      
      [true, res]
    end
  end
end
