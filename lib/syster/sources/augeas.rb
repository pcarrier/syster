require 'syster/sources/base'

module Syster::Sources
  class Augeas < Base
    def self.active?
      Syster::Helpers::Require.can_require? %w[augeas]
    end

    def collect
      require 'augeas'

      ::Augeas::open '/', nil, ::Augeas::NO_LOAD do |aug|
        # Those lenses create too much noise or are somewhat broken for us
        %w[Services Protocols Xml].each do |lens|
          aug.rm "/augeas/load/#{lens}"
        end

        aug.load
        return [true, jsonify(aug, '/files')]
      end
    end

    private
    def jsonify aug, path
      escaped = path.gsub '!', '\!'

      res = {}

      value = aug.get escaped
      res['/value'] = value unless value.nil?

      children = aug.match "#{escaped}/*[label()!=\"#comment\"]"
      children.each_with_index do |cpath, index|
        type, index = parse_path cpath
        obj = jsonify aug, cpath
        obj['/index'] = index
        unless obj.size == 0
          res[type] ||= []
          res[type][index] = obj
        end
      end

      return res
    end

    private
    def parse_path name
      base = File.basename name
      case base

      when /^\d+$/
        return 'entry', (base.to_i - 1)
      when /(.*)\[(\d+)\]/
        return $1, ($2.to_i - 1)
      else
        return base, 0
      end
    end
  end
end
