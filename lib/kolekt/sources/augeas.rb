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
    def makeHash aug, path
      escaped = path.gsub '!', '\!'
      children = aug.match "#{escaped}/*[label()!=\"#comment\"]"
      value = aug.get escaped

      return value if children.empty?

      if children.all? {|c| c =~ /\/\d+$/} and value.nil? # array
        res = []
        children.each do |cpath|
          id = File.basename(cpath).to_i - 1
          raise '0 index!' if id == -1
          res[id] = makeHash aug, cpath
        end
        return res
      end

      res = {}

      children.each do |cpath|
        name = File.basename cpath

        if name =~ /(.*)\[(\d+)\]/
          res[$1] ||= []
          res[$1][$2.to_i - 1] = makeHash aug, cpath
        else
          res[name] = makeHash aug, cpath
        end
      end

      if !value.nil? and value != path
        raise 'Damn it, a conflict' if res.has_key? 'key'
        res['key'] = value
      end

      return res
    end
  end
end
