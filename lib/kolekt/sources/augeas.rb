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
  def mix h, v, cpath
    v_relevant = !v.nil? and v != cpath
    h_relevant = !h.empty?

    case true
    when (v_relevant and h_relevant) then
      raise 'Damn, $IT happened!' if h[:key] != nil
      h[:key] = v
      return h
    when h_relevant then
      return h
    when v_relevant then
      return v
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

      if name =~ /(.*)\[(\d+)\]/
        res[$1] ||= []
        res[$1][$2.to_i] = mix(h, v, cpath)
      else
        res[name] = mix h, v, cpath
      end
    end
    
    return res
  end
end; end; end
