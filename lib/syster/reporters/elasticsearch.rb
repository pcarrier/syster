require 'syster/reporters/base'
require 'syster/helpers/require'
require 'socket'

module Syster::Reporters
  class ElasticSearch < Base
    def self.runnable?
      Syster::Helpers::Require.can_require? %w[faraday json]
    end
  
    def initialize params={}
      require 'faraday'
      require 'json'

      @log = params[:logger] || Logger.new(STDERR)
      @update = {}
      @conn = Faraday.new :url => (params[:uri] || 'http://localhost:9200/')
      @hostname = Socket.gethostname

      begin
        @dry = get_dry
      rescue Exception => e
        @dry = {}
        @log.info "Couldn't get DRY (#{e}), creating documents"
        create_documents
      end
    end
  
    def report identifier, payload
      @update[identifier] = ::JSON::dump payload

      if @dry.has_key? identifier
        @dry[identifier][:last_run] = Time.now.to_i
      end
    end

    def wants identifier, dry_payload
      unless @dry.has_key? identifier
        @dry[identifier] = {'payload'    => nil,
                            'last_dried' => 0,
                            'last_run'   => 0}
      end

      orig = @dry[identifier]['payload']

      @dry[identifier]['payload'] = dry_payload
      @dry[identifier]['last_dried'] = Time.now.to_i

      return orig == dry_payload
    end
  
    def finish
      post_host_update
      post_dry_update
    end

    private
    def post_host_update
      script = @update.collect{|k,_| "ctx._source.#{k} = #{k}"}.join ';'
      params = @update.collect{|k,v| %["#{k}": #{v}]}.join ','

      post "/syster/host/#{@hostname}/_update", %[{"script": "#{script}", "params": {#{params}}}]
    end

    private
    def post_dry_update
      post "/syster/dry/#{@hostname}", ::JSON::dump(@dry)
    end

    private
    def get_dry
      payload = ::JSON::load get "/syster/dry/#{@hostname}"
      raise 'not found' unless payload['exists']
      return payload['_source']
    end

    private
    def create_documents
      post "/syster/dry/#{@hostname}", '{}'
      post "/syster/host/#{@hostname}", '{}'
    end

    private
    def post path, payload
      resp = @conn.post path do |req|
        req.body = payload
      end
      unless resp.status / 100 == 2 # 2XX
          raise "POST #{path} failed with #{resp.status} (#{resp.body})"
      end
      return resp.body
    end

    private
    def get path
      resp = @conn.get path
      unless resp.status / 100 == 2 # 2XX
          raise "POST #{path} failed with #{resp.status} (#{resp.body})"
      end
      return resp.body
    end
  end
end
