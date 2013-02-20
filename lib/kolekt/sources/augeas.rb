require 'kolekt/sources/base'

module Kolekt::Sources
  class Augeas < Base
    def self.active?
      Kolekt::Helpers::Require.can_require? %w[augeas]
    end

    def collect
      require 'augeas'

      ::Augeas::open '/', nil, ::Augeas::NO_LOAD do |aug|
        # Those lenses create too much noise or are somewhat broken for us
        %w[Services Protocols Xml].each do |lens|
          aug.rm "/augeas/load/#{lens}"
        end

        aug.load
        return [true, makeHash(aug, '/files')]
      end
    end

    private
    def mix h, v, cpath
      v_relevant = !v.nil? and v != cpath
      h_relevant = !h.nil? and !h.empty?

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
      escaped = path.gsub '!', '\!'
      children = aug.match "#{escaped}/*[label()!=\"#comment\"]"

      return nil if children.empty?

      if children.all? {|c| c =~ /\/\d+$/} # array
        res = []
        children.each do |cpath|
          res[File.basename(cpath).to_i - 1] = makeHash aug, cpath
        end
        return res
      end

      res = {}
      children.each do |cpath|
        name = File.basename cpath
        v = aug.get cpath
        h = makeHash aug, cpath

        if name =~ /(.*)\[(\d+)\]/
          res[$1] ||= []
          res[$1][$2.to_i - 1] = mix(h, v, cpath)
        else
          res[name] = mix h, v, cpath
        end
      end

      return res
    end
  end
end
