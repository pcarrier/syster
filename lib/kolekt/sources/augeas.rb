require 'kolekt/sources/base'

module Kolekt; module Sources; class Augeas < Base
  def self.active?
    begin
      require 'augeas'
      return true
    rescue LoadError
      return false
    end
  end

  def collect
    require 'augeas'
    begin
      res = nil
      ::Augeas::open '/', nil, ::Augeas::NO_LOAD do |aug|
        # Those lenses create too much noise
        %w[Services Protocols].each do |lens|
          aug.rm "/augeas/load/#{lens}"
        end

        aug.load
        res = makeHash aug, '/files'
      end
      return [true, res]
    rescue Exception => e
      return [false, "exception (#{e})"]
    end
  end

  private
  def makeHash aug, path
    res = {}
    # Filter out comments
    aug.match(%[#{path}/*[label()!="#comment"]]).each do |cpath|
      name = File.basename cpath
      v = aug.get cpath
      h = makeHash aug, cpath
    
      v_relevant = !v.nil? and v != cpath
      h_relevant = !h.empty?

      case true
      when (v_relevant and h_relevant) then
        res[name] = h
        raise 'Damn, it happened' if res[name][:value] != nil
        res[name][:value] = v
      when h_relevant then
        res[name] = h
      when v_relevant then
        res[name] = v
      end
    end
    
    return res
  end
end; end; end
