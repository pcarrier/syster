require 'kolekt/sources/base'

module Kolekt; module Sources; class Ohai < Base
  def self.runnable?
    begin
      require 'ohai'
      return true
    rescue LoadError
      return false
    end
  end

  def collect
    sys = ::Ohai::System.new
    sys.all_plugins
    return [true, sys]
  end
end; end; end
