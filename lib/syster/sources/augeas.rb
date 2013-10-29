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
      # undocumented need to escape ! in queries
      escaped = path.gsub '!', '\!'

      res = {}

      value = aug.get escaped
      res['/value'] = value unless value.nil?

      # discard comments
      children = aug.match "#{escaped}/*[label()!=\"#comment\"]"

      children.each_with_index do |cpath, index|
        type, index = parse_path cpath
        obj = jsonify aug, cpath
        obj['/index'] = index

        unless obj.size == 0
          if index
            res[type] ||= []
            res[type][index] = obj
          else
            res[type] = obj
          end
        end
      end

      return res
    end

    # returns a type, index singleton from a path
    # - Common case:
    #   '/foo/bar[1]' returns 'bar', 0
    # - Unnamed entries:
    #   '/foo/1' returns 'entries, 0
    # - Unnumbered entries:
    #   '/foo/bar' return 'bar', nil
    private
    def parse_path name
      base = File.basename name

      case base
      when /^\d+$/
        # 0-indexed
        return 'entries', (base.to_i - 1)
      when /(.*)\[(\d+)\]/
        return $1, ($2.to_i - 1)
      else
        return base, nil
      end
    end
  end
end
