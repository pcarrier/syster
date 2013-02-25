require 'syster/sources/base'
require 'syster/helpers/puppet'

module Syster::Sources
  class PuppetCatalog < Base
    def self.runnable?
      Syster::Helpers::Require.can_require? %w[puppet json]
    end

    def initialize options={}
      @puppet = Syster::Helpers::Puppet.initialized
    end

    def dry
      begin
        s = File.stat catalog_path
        return [true, [s.mtime.to_i, s.size]]
      rescue
        return [false, "can't stat #{catalog_path}"]
      end
    end

    def collect
      return [true, data_graph['data']]
    end

    # Trying to reproduce the JSON document here. Probably not perfect.
    private
    def data_graph
      case catalog_type
      when :yaml
        require 'yaml'
        doc = ::YAML::load File::read catalog_path
        return doc.to_pson_data_hash
      when :json, nil
        require 'json'
        return ::JSON::load File::read catalog_path
      end
    end

    private
    def catalog_type
      @catalog_type ||= (@puppet[:catalog_cache_terminus] || :json)
    end

    private
    def catalog_path
      case catalog_type
      when :yaml
        @catalog_path ||= File.join @puppet[:clientyamldir], "#{@puppet[:certname]}.yaml"
      when :json, nil
        @catalog_path ||= File.join @puppet[:client_datadir], "#{@puppet[:certname]}.json"
      end
    end
  end
end
