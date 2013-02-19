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
    begin
      s = Ohai::System.new
      s.all_plugins
      return [true, s]
    rescue Exception => e
      return [false, "exception (#{e})"]
    end
  end
end; end; end
