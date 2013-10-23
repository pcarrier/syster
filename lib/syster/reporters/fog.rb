require 'syster/reporters/base'
require 'syster/helpers/require'
require 'socket'

module Syster::Reporters
  class Fog < Base
    DEFAULT_CONFIG = {:provider => 'AWS'}
    DEFAULT_BUCKET = 'abb-syster'
    DRY_KEY = 'dry'

    def self.runnable?
      Syster::Helpers::Require.can_require? %w[json fog]
    end

    def initialize params={}
      require 'json'
      require 'fog'

      raise 'missing fog configuration in FOG environment variable' unless ENV['FOG']
      config = DEFAULT_CONFIG.merge(::JSON::parse(ENV['FOG'], :symbolize_names => true))

      bucket = ENV['BUCKET'] || DEFAULT_BUCKET
      @directory = ::Fog::Storage.new(config).directories.get(bucket)
      @hostname = Socket.gethostname
      @dry = get(DRY_KEY) || {}
    end

    def report identifier, payload
      put identifier, payload
      @dry[identifier][:last_run] = Time.now.to_i if @dry.has_key? identifier
    end

    def wants identifier, dry_payload
      unless @dry.has_key? identifier
        @dry[identifier] = {
          'payload'    => nil,
          'last_dried' => 0,
          'last_run'   => 0
        }
      end

      orig = @dry[identifier]['payload']

      @dry[identifier]['payload'] = dry_payload
      @dry[identifier]['last_dried'] = Time.now.to_i

      return orig != dry_payload
    end

    def finish
      put DRY_KEY, @dry
    end

    private
    def path_for key
      "#{@hostname}:#{key}"
    end

    private
    def get key
      file = @directory.files.get path_for key
      ::JSON::load file.body if file
    end

    private
    def put key, content
      @directory.files.create(
        :key => path_for(key),
        :body => ::JSON::dump(content))
    end
  end
end
